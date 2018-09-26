/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2018 NG Informática - TOTVS Software Partner
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include 'protheus.ch'
#include 'testsuite.ch'

#define HASHMAP_CMP_IGNORE_CASE 'I'
#define HASHMAP_CMP_TRIM        'T'

TestSuite NGHashMap Description 'NGHashMap' Verbose
    Data oMap
    Data oBigMap
    Data oSmallMap

    Feature _01_New      Description 'It should create instances of the hashmap'
    Feature _02_Put      Description 'It should put a key value pair on the hashmap'
    Feature _03_Get      Description 'It should get an element from a hashmap'
    Feature _04_Rehash   Description 'It should rehash and grow the hashmap dynamically'
    Feature _05_Keys     Description 'It should provide the hashmap keys'
    Feature _06_GetOpt   Description 'It should optionally get an element from a hashmap'
    Feature _07_Has      Description 'It should tell whether an element exists in the hashmap'
    Feature _08_Remove   Description 'It should remove an element from a hashmap'
    Feature _09_Free     Description 'It should release the memory'
    Feature _10_Database Description 'It should test with real database records'
    Feature _11_Param    Description 'It should support {HASHMAP_CMP_*}'
EndTestSuite

Feature _01_New TestSuite NGHashMap
    ::oMap      := NGHashMap():New()
    ::oBigMap   := NGHashMap():New( 30000 )
    ::oSmallMap := NGHashMap():New( 2 )

    ::Expect( ::oMap:Length() ):ToBe( 0 )
    ::Expect( ::oBigMap:Length() ):ToBe( 0 )
    ::Expect( ::oSmallMap:Length() ):ToBe( 0 )
Return

Feature _02_Put TestSuite NGHashMap
    ::oMap:Put( 'HELLO', 'MOTTO' )
    ::oMap:Put( 'HELLO', 'WORLD' )
    ::Expect( ::oMap:Length() ):ToBe( 1 )
Return

Feature _03_Get TestSuite NGHashMap
    ::Expect( ::oMap:Get( 'HELLO' ) ):ToBe( 'WORLD' )
    ::Expect( ::oMap:Get( 'BYE' ) ):ToBe( Nil )
Return

Feature _04_Rehash TestSuite NGHashMap
    ::oSmallMap:Put( '.hs', 'Haskell' )
    ::Expect( ::oSmallMap:Length() ):ToBe( 1 )
    ::oSmallMap:Put( '.java', 'Java' )
    ::Expect( ::oSmallMap:Length() ):ToBe( 2 )
    ::oSmallMap:Put( '.php', 'PHP')
    ::Expect( ::oSmallMap:Length() ):ToBe( 3 )
    ::oSmallMap:Put( '.scala', 'Scala' )
    ::Expect( ::oSmallMap:Length() ):ToBe( 4 )
    ::oSmallMap:Put( '.pl', 'Perl' )
    ::Expect( ::oSmallMap:Length() ):ToBe( 5 )
Return

Feature _05_Keys TestSuite NGHashMap
    Local oKeys := ::oSmallMap:Keys()

    ::Expect( oKeys ):ToHaveType( 'A' )
    ::Expect( oKeys ):ToBe( { '.php', '.java', '.hs', '.scala', '.pl' } )
    ::Expect( ::oSmallMap:Get( '.php' ) ):ToBe( 'PHP' )
    ::Expect( ::oSmallMap:Get( '.java' ) ):ToBe( 'Java' )
    ::Expect( ::oSmallMap:Get( '.hs' ) ):ToBe( 'Haskell' )
    ::Expect( ::oSmallMap:Get( '.scala' ) ):ToBe( 'Scala' )
    ::Expect( ::oSmallMap:Get( '.pl' ) ):ToBe( 'Perl' )
Return

Feature _06_GetOpt TestSuite NGHashMap
    ::oBigMap:Put( 'NAME', 'Celão' )
    ::oBigMap:Put( 'HOPE', Nil )

    ::Expect( ::oBigMap:GetOptional( 'NAME', 'Tibúrcio' ) ):ToBe( 'Celão' )
    ::Expect( ::oBigMap:GetOptional( 'HOPE', .T. ) ):ToBe( Nil )
    ::Expect( ::oBigMap:GetOptional( 'SADNESS', .T. ) ):ToBe( .T. )
Return

Feature _07_Has TestSuite NGHashMap
    Local aKeys
    Local nIndex

    ::Expect( ::oSmallMap:Has( '.php' ) ):ToBe( .T. )
    ::Expect( ::oSmallMap:Has( '.cpp' ) ):ToBe( .F. )

    // A map should have all its keys!
    aKeys := ::oSmallMap:Keys()
    For nIndex := 1 To Len( aKeys )
        ::Expect( ::oSmallMap:Has( aKeys[ nIndex ] ) ):ToBe( .T. )
    Next
Return

Feature _08_Remove TestSuite NGHashMap
    Local nLength := ::oSmallMap:Length()

    ::Expect( ::oSmallMap:Remove( '.java' ) ):ToBe( .T. )
    ::Expect( ::oSmallMap:Remove( '.cpp' ) ):ToBe( .F. )
    ::Expect( ::oSmallMap:Length() ):ToBe( nLength - 1 )
Return

Feature _09_Free TestSuite NGHashMap
    ::oSmallMap:Free()
    ::oBigMap:Free()
    ::oMap:Free()
Return

Feature _10_Database TestSuite NGHashMap
    Local nCount
    Local nIndex
    Local oMap := NGHashMap():New( 10000 )

    TCLink()
    dbUseArea( .T., 'CTREECDX', '\system\sx2990.dtc', 'SX2', .T., .T. )
    dbSelectArea( 'SX2' )
    SX2->( dbSetOrder( 1 ) )

    nCount := SX2->( RecCount() )
    Do While !SX2->( EoF() )
        oMap:Put( SX2->X2_CHAVE, SX2->X2_NOME )
        SX2->( dbSkip() )
    EndDo

    // All items must count on hashmap because {X2_CHAVE} is unique
    ::Expect( oMap:Length() ):ToBe( nCount )

    SX2->( dbCloseArea() )
Return

Feature _11_Param TestSuite NGHashMap
    Local oTrim := NGHashMap():New( 256, HASHMAP_CMP_TRIM )
    Local oCase := NGHashMap():New( 256, HASHMAP_CMP_IGNORE_CASE )
    Local oMap  := NGHashMap():New( 256, HASHMAP_CMP_IGNORE_CASE + HASHMAP_CMP_TRIM )

    oTrim:Put( 'lorem', 'ipsum' )
    oTrim:Put( '  dolor ', 'sit' )
    ::Expect( oTrim:Get( 'lorem' ) ):ToBe( 'ipsum' )
    ::Expect( oTrim:Get( '   lorem' ) ):ToBe( 'ipsum' )
    ::Expect( oTrim:Get( 'dolor' ) ):ToBe( 'sit' )
    ::Expect( oTrim:Get( 'LOREM' ) ):ToBe( Nil )
    ::Expect( oTrim:Get( 'Dolor' ) ):ToBe( Nil )

    oCase:Put( 'lorem', 'ipsum' )
    oCase:Put( '  dolor ', 'sit' )
    ::Expect( oCase:Get( 'lorem' ) ):ToBe( 'ipsum' )
    ::Expect( oCase:Get( '   lorem' ) ):ToBe( Nil )
    ::Expect( oCase:Get( 'dolor' ) ):ToBe( Nil )
    ::Expect( oCase:Get( 'LOREM' ) ):ToBe( 'ipsum' )
    ::Expect( oCase:Get( 'Dolor' ) ):ToBe( Nil )

    oMap:Put( 'lorem', 'ipsum' )
    oMap:Put( '  dolor ', 'sit' )
    ::Expect( oMap:Get( 'lorem' ) ):ToBe( 'ipsum' )
    ::Expect( oMap:Get( '   lorem' ) ):ToBe( 'ipsum' )
    ::Expect( oMap:Get( 'dolor' ) ):ToBe( 'sit' )
    ::Expect( oMap:Get( 'LOREM' ) ):ToBe( 'ipsum' )
    ::Expect( oMap:Get( 'Dolor' ) ):ToBe( 'sit' )
Return

CompileTestSuite NGHashMap
