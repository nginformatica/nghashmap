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

/**
 * Benchmarks using {NGHashMap}, {tHashMap} and array storage with {aScan}
 */
#include 'protheus.ch'

#define BENCHMARK_DIR '\benchmark'
#define CSV_ASCAN 'ascan.csv'
#define CSV_NGHASHMAP 'nghashmap.csv'
#define CSV_THASHMAP 'thashmap.csv'

Static Function PrepareCSV( cFile )
    Local nHandle

    If !ExistDir( BENCHMARK_DIR )
        MakeDir( BENCHMARK_DIR )
    EndIf

    If File( BENCHMARK_DIR + '\' + cFile )
        FErase( BENCHMARK_DIR + '\' + cFile )
    EndIf

    nHandle := FCreate( BENCHMARK_DIR + '\' + cFile )
Return nHandle

Static Function Report( nHandle, nTime, nCount )
    FWrite( nHandle, cValToChar( nTime - M->nOffset ) + ',' + cValToChar( nCount ) + Chr( 10 ) )
Return

Static Function NextWord()
    Local nLength := Randomize( 4, 12 )
    Local nIndex
    Local cWord := ''

    For nIndex := 1 To nLength
        cWord += Chr( Randomize( 33, 90 ) )
    Next
Return cWord

Static Function GenData( aPairs )
    Local nIndex
    Local cWord

    For nIndex := 1 To 10000
        cWord := NextWord()
        aPairs[ nIndex ] := { cWord, cWord }
    Next
Return

Static Function GoNGHASH( nHandle, aData )
    Local oMap
    Local nIndex
    Local nRet := 0

    oMap := NGHashMap():New( 10000 )

    Private nOffset := Seconds()
    For nIndex := 1 To Len( aData )
        oMap:Put( aData[ nIndex, 1 ], aData[ nIndex, 2 ] )
        Report( nHandle, Seconds(), ++nRet )
    Next
Return

Static Function GoTHASH( nHandle, aData )
    Local oMap
    Local nIndex
    Local nRet := 0

    oMap := HMNew()

    Private nOffset := Seconds()
    For nIndex := 1 To Len( aData )
        HMSet( oMap, aData[ nIndex, 1 ], aData[ nIndex, 2 ] )
        Report( nHandle, Seconds(), ++nRet )
    Next
Return

User Function NGHMBench()
    Local nHandleNGHASH := PrepareCSV( CSV_NGHASHMAP )
    Local nHandleASCAN  := PrepareCSV( CSV_ASCAN )
    Local nHandleTHASH  := PrepareCSV( CSV_THASHMAP )
    Local aPairs[ 10000 ]

    GenData( @aPairs )

    GoNGHASH( nHandleNGHASH, @aPairs )
    GoTHASH( nHandleTHASH, @aPairs )

    FClose( nHandleASCAN )
    FClose( nHandleNGHASH )
    FClose( nHandleTHASH )

    CpyS2T( BENCHMARK_DIR + '\' + CSV_NGHASHMAP, 'C:\tmp/' )
    CpyS2T( BENCHMARK_DIR + '\' + CSV_ASCAN, 'C:\tmp/' )
    CpyS2T( BENCHMARK_DIR + '\' + CSV_THASHMAP, 'C:\tmp/' )
Return
