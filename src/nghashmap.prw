#ifdef __HARBOUR__
    #include 'hbclass.ch'
#else
    #include 'protheus.ch'
#endif

#define HASHMAP_KEY   1
#define HASHMAP_VALUE 2

#define HASHMAP_CMP_IGNORE_CASE 'I'
#define HASHMAP_CMP_TRIM        'T'

/**
 * A hashmap that provides amortized O(1) get/set of key/values
 */
Class NGHashMap
    /**
     * The buckets with chained key value pairs in arrays
     */
    Data aBuckets
    /**
     * The number of buckets
     */
    Data nSize
    /**
     * The constant count of elements
     */
    Data nLength
    /**
     * Comparison mode {HASHMAP_CMP_IGNORE_CASE}+{HASHMAP_CMP_TRIM}
     */
    Data cMode

    Method New()
    Method Free()
    Method Get( cKey )
    Method Hash( cKey )
    Method Has( cKey )
    Method Keys()
    Method Length()
    Method Put( cKey, xValue )
    Method Rehash()
    Method Remove( cKey )
EndClass

/**
 * Creates a hashmap.
 *
 * @author Marcelo Camargo
 * @param nSize {Numeric} - number of buckets to allocate
 * @param cMode {String} - hashing mode
 * @returns a new instance of the hashmap
 * @see {HASHMAP_CMP_IGNORE_CASE}, {HASHMAP_CMP_TRIM}
 */
Method New( nSize, cMode ) Class NGHashMap
    Local aBuckets[ IIf( nSize == Nil, 256, nSize ), 0 ]
    ::aBuckets := aBuckets
    ::nSize    := Len( ::aBuckets )
    ::nLength  := 0
    ::cMode    := IIf( cMode == Nil, '', cMode )
Return Self

/**
 * Releases the hashmap memory.
 *
 * @author Marcelo Camargo
 */
Method Free() Class NGHashMap
    ::nSize    := Nil
    ::nLength  := Nil
    ::aBuckets := Nil
Return Nil

/**
 * Returns the value stored by a key in the hashmap. If it doesn't exist,
 * give NIL.
 *
 * @author Marcelo Camargo
 * @param cKey {String} key to lookup
 * @returns either the stored value or NIL
 */
Method Get( cKey ) Class NGHashMap
    Local cHashKey := ::Hash( @cKey )
    Local aBucket  := ::aBuckets[ cHashKey ]
    Local nIndex

    For nIndex := 1 To Len( aBucket )
        If aBucket[ nIndex, HASHMAP_KEY ] == cKey
            Return aBucket[ nIndex, 2 ]
        EndIf
    Next
Return Nil

/**
 * Returns whether a key exists in a hashmap
 *
 * @author Marcelo Camargo
 * @param cKey {String} key to lookup
 * @returns whether the key is in the hashmap
 */
Method Has( cKey ) Class NGHashMap
    Local cHashKey := ::Hash( @cKey )
    Local aBucket  := ::aBuckets[ cHashKey ]
    Local nIndex

    For nIndex := 1 To Len( aBucket )
        If aBucket[ nIndex, HASHMAP_KEY ] == cKey
            Return .T.
        EndIf
    Next
Return .F.

/**
 * Application of DJB hash function using the buckets count as constraint.
 * {<n> * 33 + nChar} stands for {<n> << 5 + nChar}.
 *
 * @author Marcelo Camargo
 * @param cKey {String} - key to hash
 * @returns the integer hash from 1 up to the number of buckets
 */
Method Hash( cKey ) Class NGHashMap
    Local nChar
    Local nIndex
    Local nHash      := 5381
    Local nKeyLength := Len( cKey )

    If HASHMAP_CMP_IGNORE_CASE $ ::cMode
        cKey := Upper( cKey )
    EndIf

    If HASHMAP_CMP_TRIM $ ::cMode
        cKey := AllTrim( cKey )
    EndIf

    For nIndex := 1 To nKeyLength
        nChar := Asc( SubStr( cKey, nIndex, 1 ) )
        nHash := nHash * 33 + nChar
    Next

    nHash := Int( nHash % ::nSize + 1 )
Return nHash

/**
 * Returns all keys of the hashmap. Costs {O(n) + k} where {k} stands for the
 * maximum slot with duplicate entries, often {1}.
 *
 * @author Marcelo Camargo
 * @returns the list of keys
 */
Method Keys() Class NGHashMap
    Local aKeys[ ::nLength ]
    Local nPosition := 1
    Local nIndex
    Local nBucket

    For nIndex := 1 To Len( ::aBuckets )
        For nBucket := 1 To Len( ::aBuckets[ nIndex ] )
            aKeys[ nPosition++ ] := ::aBuckets[ nIndex, nBucket, HASHMAP_KEY ]
        Next
    Next
Return aKeys

/**
 * Returns the computed size of the hashmap
 *
 * @author Marcelo Camargo
 * @returns count of keys
 */
Method Length() Class NGHashMap
Return ::nLength

/**
 * Inserts a value on the hashmap. If it already exists, replaces it.
 * This method can handle auto-resizing of the hashmap.
 *
 * @author Marcelo Camargo
 * @param cKey {String} - key to insert
 * @param xValue {Mixed} - value to associate
 */
Method Put( cKey, xValue ) Class NGHashMap
    Local cHashKey
    Local aBucket
    Local nIndex
    Local lKeyExists

    // Rehash when the count of elements is greater than the buckets count
    If ::nLength >= ::nSize
        ::Rehash()
    EndIf

    cHashKey   := ::Hash( @cKey )
    aBucket    := ::aBuckets[ cHashKey ]
    lKeyExists := .F.

    For nIndex := 1 To Len( aBucket )
        If aBucket[ nIndex, HASHMAP_KEY ] == cKey
            lKeyExists := .T.
            Exit
        EndIf
    Next

    // When the key has a hash in a bucket, replace. Otherwise, set
    If lKeyExists
        aBucket[ nIndex, HASHMAP_VALUE ] := xValue
    Else
        aAdd( aBucket, { cKey, xValue } )
        ::nLength++
    EndIf
Return Nil

/**
 * Doubles the physical size of the hashmap and rehashes the current
 * keys.
 *
 * @author Marcelo Camargo
 */
Method Rehash() Class NGHashMap
    Local nOldLength := ::nLength
    Local nOldSize   := ::nSize
    Local aOldBucket := ::aBuckets
    Local nIndex

    ::nSize    *= 2
    ::nLength  := 0
    ::aBuckets := Array( ::nSize, 0 )

    For nIndex := 1 To Len( aOldBucket )
        aEval( aOldBucket[ nIndex ], { |aPair| ::Put( aPair[ HASHMAP_KEY ], aPair[ HASHMAP_VALUE ] ) } )
    Next

    aOldBucket := Nil
Return

/**
 * Removes an element of the hashmap
 *
 * @author Marcelo Camargo
 * @param cKey {String} - key of element to remove
 * @returns {Logical} whether the value was found and removed
 */
Method Remove( cKey )
    Local cHashKey := ::Hash( @cKey )
    Local aBucket  := ::aBuckets[ cHashKey ]
    Local nIndex

    For nIndex := 1 To Len( aBucket )
        If aBucket[ nIndex, HASHMAP_KEY ] == cKey
            aDel( aBucket, nIndex )
            aSize( aBucket, Len( aBucket ) - 1 )
            Return .T.
        EndIf
    Next
Return .F.
