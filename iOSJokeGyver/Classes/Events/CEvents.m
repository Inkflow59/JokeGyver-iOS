/* Copyright (c) 1996-2014 Clickteam
*
* This source code is part of the iOS exporter for Clickteam Multimedia Fusion 2
* and Clickteam Fusion 2.5.
*
* Permission is hereby granted to any person obtaining a legal copy
* of Clickteam Multimedia Fusion 2 or Clickteam Fusion 2.5 to use or modify this source
* code for debugging, optimizing, or customizing applications created with
* Clickteam Multimedia Fusion 2 and/or Clickteam Fusion 2.5.
* Any other use of this source code is prohibited.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
* IN THE SOFTWARE.
*/
// ----------------------------------------------------------------------------------
//
// CEVENTS : actions, conditions et expressions
//
//----------------------------------------------------------------------------------
#import "CEvents.h"
#import "CValue.h"
#import "CEventProgram.h"
#import "CRun.h"
#import "COI.h"
#import "CLO.h"
#import "CLOList.h"
#import "CSoundPlayer.h"
#import "CQualToOiList.h"
#import "CRunFrame.h"
#import "CColMask.h"
#import "CLayer.h"
#import "CSpriteGen.h"
#import "CRunApp.h"
#import "CRect.h"
#import "CBackDrawCls.h"
#import "CBackDrawClsZone.h"
#import "CObject.h"
#import "CRCom.h"
#import "CRSpr.h"
#import "CRMvt.h"
#import "CRAni.h"
#import "CRVal.h"
#import "CObjInfo.h"
#import "CMove.h"
#import "CObjectCommon.h"
#import "CImageBank.h"
#import "CSoundBank.h"
#import "CImage.h"
#import "CLoop.h"
#import "CArrayList.h"
#import "CValue.h"
#import "CText.h"
#import "CDefTexts.h"
#import "CDefText.h"
#import "CServices.h"
#import "CCounter.h"
#import "CActive.h"
#import "CMoveDef.h"
#import "CMoveBullet.h"
#import "CAnim.h"
#import "CAnimDir.h"
#import "CMovePath.h"
#import "CFontInfo.h"
#import "CSprite.h"
#import "CRSpr.h"
#import "CJoystickAcc.h"
#import "CBitmap.h"
#import "CCndExtension.h"
#import "CActExtension.h"
#import "CExtension.h"
#import "CCCA.h"
#import "COIList.h"
#import "CMoveExtension.h"
#import "CAnimHeader.h"
#import "CRenderer.h"
#import "CRunview.h"
#import "CEffectEx.h"

// New Line
// --------
NSString* szNewLine=@"\r\n";
NSString* chaineVide=@"";
extern CALLEXP_ROUTINE callTable_Expression[];

// Retour de conditions avec negations
// -----------------------------------
BOOL negaFALSE(event* pe)
{
    if (pe->evtFlags2&EVFLAG2_NOT) return TRUE;
    return FALSE;
}
BOOL negaTRUE(event* pe)
{
    if (pe->evtFlags2&EVFLAG2_NOT) return FALSE;
    return TRUE;
}

// ------------------------------------------------------------------
// Effectue les comparaisons generales (PARAM 1 == PARAM_COMPARAISON)
// ------------------------------------------------------------------
BOOL compareTo(CValue* pValue1, CValue* pValue2, short comp)
{
    switch (comp)
    {
        case 0:    // COMPARE_EQ:
            return [pValue1 equal:pValue2];
        case 1:    // COMPARE_NE:
            return [pValue1 notEqual:pValue2];
        case 2:    // COMPARE_LE:
            return [pValue1 lower:pValue2];
        case 3:    // COMPARE_LT:
            return [pValue1 lowerThan:pValue2];
        case 4:    // COMPARE_GE:
            return [pValue1 greater:pValue2];
        case 5:    // COMPARE_GT:
            return [pValue1 greaterThan:pValue2];
    }
    return false;
}
BOOL compareToInt(CValue* pValue1, int value2, short comp)
{
    switch (comp)
    {
        case 0:    // COMPARE_EQ:
            return [pValue1 equalInt:value2];
        case 1:    // COMPARE_NE:
            return [pValue1 notEqualInt:value2];
        case 2:    // COMPARE_LE:
            return [pValue1 lowerInt:value2];
        case 3:    // COMPARE_LT:
            return [pValue1 lowerThanInt:value2];
        case 4:    // COMPARE_GE:
            return [pValue1 greaterInt:value2];
        case 5:    // COMPARE_GT:
            return [pValue1 greaterThanInt:value2];
    }
    return false;
}
BOOL compareToDouble(CValue* pValue1, double value2, short comp)
{
    switch (comp)
    {
        case 0:    // COMPARE_EQ:
            return [pValue1 equalDouble:value2];
        case 1:    // COMPARE_NE:
            return [pValue1 notEqualDouble:value2];
        case 2:    // COMPARE_LE:
            return [pValue1 lowerDouble:value2];
        case 3:    // COMPARE_LT:
            return [pValue1 lowerThanDouble:value2];
        case 4:    // COMPARE_GE:
            return [pValue1 greaterDouble:value2];
        case 5:    // COMPARE_GT:
            return [pValue1 greaterThanDouble:value2];
    }
    return false;
}
BOOL compareTer(int value1, int value2, int comparaison)
{
    switch (comparaison)
    {
        case COMPARE_EQ:
            return (value1==value2);
        case COMPARE_NE:
            return (value1!=value2);
        case COMPARE_LE:
            return (value1<=value2);
        case COMPARE_LT:
            return (value1<value2);
        case COMPARE_GE:
            return (value1>=value2);
        case COMPARE_GT:
            return (value1>value2);
    }
    return FALSE;
}
BOOL compareTerDouble(double value1, double value2, int comparaison)
{
    switch (comparaison)
    {
        case COMPARE_EQ:
            return (value1==value2);
        case COMPARE_NE:
            return (value1!=value2);
        case COMPARE_LE:
            return (value1<=value2);
        case COMPARE_LT:
            return (value1<value2);
        case COMPARE_GE:
            return (value1>=value2);
        case COMPARE_GT:
            return (value1>value2);
    }
    return FALSE;
}
BOOL compareCondition(event* pe, CRun* rhPtr, int value1)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    int value2=[rhPtr get_EventExpressionInt:pEvp];
    return compareTer(value1, value2, pEvp->evp.evpW.evpW0);
}

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// Objet SPEAKER
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------


BOOL cndNoSpSamPlaying(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    BOOL bPlaying = NO;
    short nSound = 0;
    if (pEvp->evpCode == PARAM_EXPSTRING)
    {
        NSString* name = [rhPtr get_EventExpressionString:pEvp];
        nSound = [rhPtr->rhApp->soundBank getSoundHandleFromName:name];
    }
    else
    {
        LPSND pSnd=(LPSND)&pEvp->evp.evpW.evpW0;
        nSound = pSnd->sndHandle;
    }
    if (nSound >= 0)
        bPlaying = [rhPtr->rhApp->soundPlayer isSamplePlaying:nSound];
    if (bPlaying==NO)
        return negaTRUE(pe);
    return negaFALSE(pe);
}

BOOL cndNoSpChannelPlaying(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    int nChannel = [rhPtr get_EventExpressionInt:pEvp];
    BOOL ret = NO;
    ret = [rhPtr->rhApp->soundPlayer isChannelPlaying:nChannel-1];
    if (ret==NO)
        return negaTRUE(pe);
    return negaFALSE(pe);
}

// -------------------------------------
// CONDITION: IS NO MUSIC/SAMPLE PLAYING
// -------------------------------------
BOOL cndNoSamPlaying(event* pe, CRun* rhPtr, LPHO pHo)
{
    BOOL ret=[rhPtr->rhApp->soundPlayer isSoundPlaying];
    if (ret==NO)
        return negaTRUE(pe);
    return negaFALSE(pe);
}

// -------------------------------------
// CONDITION: IS MUSIC/SAMPLE PAUSED
// -------------------------------------
BOOL cndSpSamPaused(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    short nSound = 0;
    if (pEvp->evpCode == PARAM_EXPSTRING)
    {
        NSString* name = [rhPtr get_EventExpressionString:pEvp];
        nSound = [rhPtr->rhApp->soundBank getSoundHandleFromName:name];
    }
    else
    {
        LPSND pSnd=(LPSND)&pEvp->evp.evpW.evpW0;
        nSound = pSnd->sndHandle;
    }
    if (nSound >= 0 && [rhPtr->rhApp->soundPlayer isSamplePaused:nSound] )
        return negaTRUE(pe);
    return negaFALSE(pe);
}

BOOL cndSpChannelPaused(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    int nChannel = [rhPtr get_EventExpressionInt:pEvp];
    if ( nChannel >= 1 && nChannel <= NCHANNELS )
    {
        if ( [rhPtr->rhApp->soundPlayer isChannelPaused:nChannel-1] )
            return negaTRUE(pe);
    }
    return negaFALSE(pe);
}

// -------------------
// ACTION: PLAY SAMPLE
// -------------------
void actPlaySample(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    short nSound = 0;
    BOOL bUninterruptible=NO;
    if (pEvp->evpCode == PARAM_EXPSTRING)
    {
        NSString* name = [rhPtr get_EventExpressionString:pEvp];
        nSound = [rhPtr->rhApp->soundBank getSoundHandleFromName:name];
    }
    else
    {
        LPSND pSnd=(LPSND)&pEvp->evp.evpW.evpW0;
        nSound = pSnd->sndHandle;
        if ((pSnd->sndFlags&PSOUNDFLAG_UNINTERRUPTABLE)!=0)
            bUninterruptible=YES;
    }
    if (nSound >= 0)
        [rhPtr->rhApp->soundPlayer play:nSound withNLoops:1 andChannel:-1 andPrio:bUninterruptible andVolume:-1 andPan:0 andFreq:0];
}

void actPlaySample2(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    short nSound = 0;
    BOOL bUninterruptible=NO;
    if (pEvp->evpCode == PARAM_EXPSTRING)
    {
        NSString* name = [rhPtr get_EventExpressionString:pEvp];
        nSound = [rhPtr->rhApp->soundBank getSoundHandleFromName:name];
    }
    else
    {
        LPSND pSnd=(LPSND)&pEvp->evp.evpW.evpW0;
        nSound = pSnd->sndHandle;
        if ((pSnd->sndFlags&PSOUNDFLAG_UNINTERRUPTABLE)!=0)
            bUninterruptible=YES;
    }
    if (nSound >= 0)
    {
        pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
        int channel=[rhPtr get_EventExpressionInt:pEvp];
        pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
        int nLoops=[rhPtr get_EventExpressionInt:pEvp];
        pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
        int volume=[rhPtr get_EventExpressionInt:pEvp];
        pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
        int pan=[rhPtr get_EventExpressionInt:pEvp];
        pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
        int freq=[rhPtr get_EventExpressionInt:pEvp];
        [rhPtr->rhApp->soundPlayer play:nSound withNLoops:nLoops andChannel:channel-1 andPrio:bUninterruptible andVolume:volume andPan:pan andFreq:freq];
    }
}

// ----------------------------
// ACTION: STOP SPECIFIC SAMPLE
// ----------------------------
void actStopSpeSample(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    short nSound = 0;
    if (pEvp->evpCode == PARAM_EXPSTRING)
    {
        NSString* name = [rhPtr get_EventExpressionString:pEvp];
        nSound = [rhPtr->rhApp->soundBank getSoundHandleFromName:name];
    }
    else
    {
        LPSND pSnd=(LPSND)&pEvp->evp.evpW.evpW0;
        nSound = pSnd->sndHandle;
    }
    if (nSound >= 0)
        [rhPtr->rhApp->soundPlayer stopSample:nSound];
}

// -----------------------------
// ACTION: PLAY AND LOOP SAMPLE
// -----------------------------
void actPlayLoopSample(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    short nSound = 0;
    BOOL bUninterruptible=NO;
    if (pEvp->evpCode == PARAM_EXPSTRING)
    {
        NSString* name = [rhPtr get_EventExpressionString:pEvp];
        nSound = [rhPtr->rhApp->soundBank getSoundHandleFromName:name];
    }
    else
    {
        LPSND pSnd=(LPSND)&pEvp->evp.evpW.evpW0;
        nSound = pSnd->sndHandle;
        if ((pSnd->sndFlags&PSOUNDFLAG_UNINTERRUPTABLE)!=0)
            bUninterruptible=YES;
    }
    int number=[rhPtr get_EventExpressionInt:pEvp2];
    if (nSound >= 0)
        [rhPtr->rhApp->soundPlayer play:nSound withNLoops:number andChannel:-1 andPrio:bUninterruptible andVolume:-1 andPan:0 andFreq:0];
}

// -------------------
// ACTION: STOP ALL SAMPLES
// -------------------
void actStopAllSamples(event* pe, CRun* rhPtr)
{
    [rhPtr->rhApp->soundPlayer stopAllSounds];
}

// -------------------
// ACTION: PAUSE SAMPLE
// -------------------
void actPauseSample(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    short nSound = 0;
    if (pEvp->evpCode == PARAM_EXPSTRING)
    {
        NSString* name = [rhPtr get_EventExpressionString:pEvp];
        nSound = [rhPtr->rhApp->soundBank getSoundHandleFromName:name];
    }
    else
    {
        LPSND pSnd=(LPSND)&pEvp->evp.evpW.evpW0;
        nSound = pSnd->sndHandle;
    }
    if (nSound >= 0)
        [rhPtr->rhApp->soundPlayer pauseSample:nSound];
}

// -------------------------
// ACTION: PAUSE ALL SAMPLES
// -------------------------
void actPauseAllChannels(event* pe, CRun* rhPtr)
{
    [rhPtr->rhApp->soundPlayer pause:NO];
}

// ---------------------
// ACTION: RESUME SAMPLE
// ---------------------
void actResumeSample(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    short nSound = 0;
    if (pEvp->evpCode == PARAM_EXPSTRING)
    {
        NSString* name = [rhPtr get_EventExpressionString:pEvp];
        nSound = [rhPtr->rhApp->soundBank getSoundHandleFromName:name];
    }
    else
    {
        LPSND pSnd=(LPSND)&pEvp->evp.evpW.evpW0;
        nSound = pSnd->sndHandle;
    }
    if (nSound >= 0)
        [rhPtr->rhApp->soundPlayer resumeSample:nSound];
}

// --------------------------
// ACTION: RESUME ALL SAMPLES
// --------------------------
void actResumeAllChannels(event* pe, CRun* rhPtr)
{
    [rhPtr->rhApp->soundPlayer resume:NO];
}

// -----------------------------------------
// ACTION: PLAY SAMPLE ON A SPECIFIC CHANNEL
// -----------------------------------------
void actPlayChannel(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    short nSound = 0;
    BOOL bUninterruptible=NO;
    if (pEvp->evpCode == PARAM_EXPSTRING)
    {
        NSString* name = [rhPtr get_EventExpressionString:pEvp];
        nSound = [rhPtr->rhApp->soundBank getSoundHandleFromName:name];
    }
    else
    {
        LPSND pSnd=(LPSND)&pEvp->evp.evpW.evpW0;
        nSound = pSnd->sndHandle;
        if ((pSnd->sndFlags&PSOUNDFLAG_UNINTERRUPTABLE)!=0)
            bUninterruptible=YES;
    }
    int nChannel = [rhPtr get_EventExpressionInt:pEvp2];
    if (nSound >= 0)
        [rhPtr->rhApp->soundPlayer play:nSound withNLoops:1 andChannel:nChannel-1 andPrio:bUninterruptible andVolume:-1 andPan:0 andFreq:0];
}

// --------------------------------------------------
// ACTION: PLAY AND LOOP SAMPLE ON A SPECIFIC CHANNEL
// --------------------------------------------------
void actPlayLoopChannel(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    LPEVP pEvp3=(LPEVP)((LPBYTE)pEvp2+pEvp2->evpSize);
    short nSound = 0;
    BOOL bUninterruptible=NO;
    if (pEvp->evpCode == PARAM_EXPSTRING)
    {
        NSString* name = [rhPtr get_EventExpressionString:pEvp];
        nSound = [rhPtr->rhApp->soundBank getSoundHandleFromName:name];
    }
    else
    {
        LPSND pSnd=(LPSND)&pEvp->evp.evpW.evpW0;
        nSound = pSnd->sndHandle;
        if ((pSnd->sndFlags&PSOUNDFLAG_UNINTERRUPTABLE)!=0)
            bUninterruptible=YES;
    }
    int nChannel = [rhPtr get_EventExpressionInt:pEvp2];
    int nLoops = [rhPtr get_EventExpressionInt:pEvp3];
    if (nSound >= 0)
        [rhPtr->rhApp->soundPlayer play:nSound withNLoops:nLoops andChannel:nChannel-1 andPrio:bUninterruptible andVolume:-1 andPan:0 andFreq:0];
}

// ---------------------
// ACTION: PAUSE CHANNEL
// ---------------------
void actPauseChannel(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int nChannel = [rhPtr get_EventExpressionInt:pEvp];
    [rhPtr->rhApp->soundPlayer pauseChannel:nChannel-1];
}

// ----------------------
// ACTION: RESUME CHANNEL
// ----------------------
void actResumeChannel(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int nChannel = [rhPtr get_EventExpressionInt:pEvp];
    [rhPtr->rhApp->soundPlayer resumeChannel:nChannel-1];
}

// --------------------
// ACTION: STOP CHANNEL
// --------------------
void actStopChannel(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int nChannel = [rhPtr get_EventExpressionInt:pEvp];
    [rhPtr->rhApp->soundPlayer stopChannel:nChannel-1];
}

// ----------------------------
// ACTION: SET CHANNEL POSITION
// ----------------------------
void actSetPosChannel(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int nChannel = [rhPtr get_EventExpressionInt:pEvp];
    
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    int dwPos=[rhPtr get_EventExpressionInt:pEvp2];
    [rhPtr->rhApp->soundPlayer setPositionChannel:nChannel-1 withPosition:dwPos];
}

// ---------------------------
// ACTION: SET SAMPLE POSITION
// ---------------------------
void actSetPosSample(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    short nSound = 0;
    if (pEvp->evpCode == PARAM_EXPSTRING)
    {
        NSString* name = [rhPtr get_EventExpressionString:pEvp];
        nSound = [rhPtr->rhApp->soundBank getSoundHandleFromName:name];
    }
    else
    {
        LPSND pSnd=(LPSND)&pEvp->evp.evpW.evpW0;
        nSound = pSnd->sndHandle;
    }
    int dwPos=[rhPtr get_EventExpressionInt:pEvp2];
    if (nSound >= 0)
        [rhPtr->rhApp->soundPlayer setPositionSample:nSound withPosition:dwPos];
}

// --------------------------
// ACTION: SET CHANNEL VOLUME
// --------------------------
void actSetVolumeChannel(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int nChannel = [rhPtr get_EventExpressionInt:pEvp];
    
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    int nVolume=[rhPtr get_EventExpressionInt:pEvp2];
    [rhPtr->rhApp->soundPlayer setVolumeChannel:nChannel-1 withVolume:nVolume];
}

// --------------------------
// ACTION: SET CHANNEL PAN
// --------------------------
void actSetPanChannel(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int nChannel = [rhPtr get_EventExpressionInt:pEvp];
    
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    int nPan=[rhPtr get_EventExpressionInt:pEvp2];
    [rhPtr->rhApp->soundPlayer setPanChannel:nChannel-1 withPan:nPan/100.0f];
}

// -----------------------------------
// ACTION: SET MAIN VOLUME FOR SAMPLES
// -----------------------------------
void actSetSampleMainVolume(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int nVolume=[rhPtr get_EventExpressionInt:pEvp];
    [rhPtr->rhApp->soundPlayer setMainVolume:nVolume];
}


// -------------------------
// ACTION: SET SAMPLE VOLUME
// -------------------------
void actSetSampleVolume(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    short nSound = 0;
    if (pEvp->evpCode == PARAM_EXPSTRING)
    {
        NSString* name = [rhPtr get_EventExpressionString:pEvp];
        nSound = [rhPtr->rhApp->soundBank getSoundHandleFromName:name];
    }
    else
    {
        LPSND pSnd=(LPSND)&pEvp->evp.evpW.evpW0;
        nSound = pSnd->sndHandle;
    }
    int nVolume=[rhPtr get_EventExpressionInt:pEvp2];
    if (nSound >= 0)
        [rhPtr->rhApp->soundPlayer setVolumeSample:nSound withVolume:nVolume];
}

// -----------------------------------
// ACTION: SET MAIN SAMPLE PAN
// -----------------------------------
void actSetSampleMainPan(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int nPan=[rhPtr get_EventExpressionInt:pEvp];
    [rhPtr->rhApp->soundPlayer setPan:nPan/100.0f];
}

// -------------------------
// ACTION: SET SAMPLE PAN
// -------------------------
void actSetSamplePan(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    short nSound = 0;
    if (pEvp->evpCode == PARAM_EXPSTRING)
    {
        NSString* name = [rhPtr get_EventExpressionString:pEvp];
        nSound = [rhPtr->rhApp->soundBank getSoundHandleFromName:name];
    }
    else
    {
        LPSND pSnd=(LPSND)&pEvp->evp.evpW.evpW0;
        nSound = pSnd->sndHandle;
    }
    int nPan=[rhPtr get_EventExpressionInt:pEvp2];
    if (nSound >= 0)
        [rhPtr->rhApp->soundPlayer setPanSample:nSound withPan:nPan/100.0f];
}

// ------------------------------------
// ACTION: SOUND FREQUENCIES
// ------------------------------------

void actSetFreqChannel(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int nChannel = [rhPtr get_EventExpressionInt:pEvp];

    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    int nFreq=[rhPtr get_EventExpressionInt:pEvp2];
    [rhPtr->rhApp->soundPlayer setFreqChannel:nChannel-1 withFreq:nFreq];
}

void actSetFreqSample(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    short nSound = 0;
    if (pEvp->evpCode == PARAM_EXPSTRING)
    {
        NSString* name = [rhPtr get_EventExpressionString:pEvp];
        nSound = [rhPtr->rhApp->soundBank getSoundHandleFromName:name];
    }
    else
    {
        LPSND pSnd=(LPSND)&pEvp->evp.evpW.evpW0;
        nSound = pSnd->sndHandle;
    }
    int nFreq=[rhPtr get_EventExpressionInt:pEvp2];
    if (nSound >= 0)
        [rhPtr->rhApp->soundPlayer setFreqSample:nSound withFreq:nFreq];
}

void expSampleFrequency(CRun* rhPtr)
{
    nextToken();
    NSString* pSampleName = [rhPtr get_ExpressionStringNoCopy];
    [getCurrentResult() forceInt:[rhPtr->rhApp->soundPlayer getSampleFrequency:pSampleName]];
}

void expChannelFrequency(CRun* rhPtr)
{
    nextToken();
    int nChannel=[rhPtr get_ExpressionInt];
    [getCurrentResult() forceInt:[rhPtr->rhApp->soundPlayer getFrequencyChannel:nChannel-1]];
}

// -----------------------------------
// EXPRESSION: channel sample name
// -----------------------------------
void expChannelSampleName(CRun* rhPtr)
{
    nextToken();
    int nChannel=[rhPtr get_ExpressionInt];
    if (nChannel > 0 && nChannel <= NCHANNELS)
    {
        if ([rhPtr->rhApp->soundPlayer isChannelPlaying:nChannel-1] || [rhPtr->rhApp->soundPlayer isChannelPaused:nChannel-1])
        {
            [getCurrentResult() forceString:[rhPtr->rhApp->soundPlayer getSoundNameChannel:nChannel-1]];
            return;
        }
    }
    [getCurrentResult() forceString:@""];
}


// ------------------------------------
// ACTION: LOCK CHANNEL
// ------------------------------------
void actLockChannel(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int nChannel = [rhPtr get_EventExpressionInt:pEvp];
    [rhPtr->rhApp->soundPlayer lockChannel:nChannel-1];
}

// ------------------------------------
// ACTION: UNLOCK CHANNEL
// ------------------------------------
void actUnlockChannel(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int nChannel = [rhPtr get_EventExpressionInt:pEvp];
    [rhPtr->rhApp->soundPlayer unLockChannel:nChannel-1];
}

// -----------------------------------
// EXPRESSION: main volume for samples
// -----------------------------------
void expSampleMainVolume(CRun* rhPtr)
{
    [getCurrentResult() forceInt:[rhPtr->rhApp->soundPlayer getMainVolume]];
}

// -----------------------------------
// EXPRESSION: sample volume
// -----------------------------------
void expSampleVolume(CRun* rhPtr)
{
    nextToken();
    NSString* pSampleName = [rhPtr get_ExpressionStringNoCopy];
    [getCurrentResult() forceInt:[rhPtr->rhApp->soundPlayer getSampleVolume:pSampleName]];
}

// -----------------------------------
// EXPRESSION: channel volume
// -----------------------------------
void expChannelVolume(CRun* rhPtr)
{
    nextToken();
    int nChannel=[rhPtr get_ExpressionInt];
    [getCurrentResult() forceInt:[rhPtr->rhApp->soundPlayer getVolumeChannel:nChannel-1]];
}

// -----------------------------------
// EXPRESSION: sample main pan
// -----------------------------------
void expSampleMainPan(CRun* rhPtr)
{
    [getCurrentResult() forceDouble:[rhPtr->rhApp->soundPlayer getPan]*100.0f];
}
// -----------------------------------
// EXPRESSION: sample pan
// -----------------------------------
void expSamplePan(CRun* rhPtr)
{
    nextToken();
    NSString* pSampleName = [rhPtr get_ExpressionStringNoCopy];
    [getCurrentResult() forceDouble:[rhPtr->rhApp->soundPlayer getSamplePan:pSampleName]*100.0f];
}

// -----------------------------------
// EXPRESSION: channel Pan
// -----------------------------------
void expChannelPan(CRun* rhPtr)
{
    nextToken();
    int nChannel =[rhPtr get_ExpressionInt];
    [getCurrentResult() forceDouble:[rhPtr->rhApp->soundPlayer getPanChannel:nChannel-1]*100.0f];
}

// -----------------------------------
// EXPRESSION: sample position
// -----------------------------------
void expSamplePosition(CRun* rhPtr)
{
    nextToken();
    NSString* pSampleName = [rhPtr get_ExpressionStringNoCopy];
    [getCurrentResult() forceInt:[rhPtr->rhApp->soundPlayer getSamplePosition:pSampleName]];
}

// -----------------------------------
// EXPRESSION: channel Position
// -----------------------------------
void expChannelPosition(CRun* rhPtr)
{
    nextToken();
    int nChannel =[rhPtr get_ExpressionInt];
    [getCurrentResult() forceInt:[rhPtr->rhApp->soundPlayer getPositionChannel:nChannel-1]];
}

// -----------------------------------
// EXPRESSION: sample duration
// -----------------------------------
void expSampleDuration(CRun* rhPtr)
{
    nextToken();
    NSString* pSampleName = [rhPtr get_ExpressionStringNoCopy];
    [getCurrentResult() forceInt:[rhPtr->rhApp->soundPlayer getSampleDuration:pSampleName]];
}

// -----------------------------------
// EXPRESSION: channel Duration
// -----------------------------------
void expChannelDuration(CRun* rhPtr)
{
    nextToken();
    int nChannel = [rhPtr get_ExpressionInt];
    [getCurrentResult() forceInt:[rhPtr->rhApp->soundPlayer getDurationChannel:nChannel-1]];
}



// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// Table d'appel de l'objet KEYBOARD
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------


// -----------------------------
// EXPRESSION: position souris
// -----------------------------
void expXMouse(CRun* rhPtr)         // to be reviewed not need if just added in rh2Mouse-
{
    [getCurrentResult() forceInt:rhPtr->rh2MouseX+rhPtr->rhWindowX];
    //[getCurrentResult() forceInt:rhPtr->rh2MouseX];
}

void expYMouse(CRun* rhPtr)
{
    [getCurrentResult() forceInt:rhPtr->rh2MouseY+rhPtr->rhWindowY];
    //[getCurrentResult() forceInt:rhPtr->rh2MouseY];
}

// -----------------------------
// CONDITION: user clicks
// -----------------------------
BOOL eva1MClick(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    short key=(short)rhPtr->rhEvtProg->rhCurParam[0];
    if (pEvp->evp.evpW.evpW0!=key)
        return NO;
    rhPtr->rhApp->lastInteraction = CGRectMake(rhPtr->rh2MouseX, rhPtr->rh2MouseY, 1, 1);
    return YES;
}
BOOL eva2MClick(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    if (pEvp->evp.evpW.evpW0!=rhPtr->rhEvtProg->rh2CurrentClick)
        return NO;
    rhPtr->rhApp->lastInteraction = CGRectMake(rhPtr->rh2MouseX, rhPtr->rh2MouseY, 1, 1);
    return YES;
}

// -----------------------------------
// CONDITION: user clicks on an object (evenementielle)
// -----------------------------------
BOOL eva1MClickOnObject(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    
    if ((short)rhPtr->rhEvtProg->rhCurParam[0]!=pEvp->evp.evpW.evpW0) return NO;        // La touche
    
    OINUM oi=(OINUM)rhPtr->rhEvtProg->rhCurParam[1];                            //; L'objet qui clique
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    if (oi==pEvp2->evp.evpW.evpW1)                                //; L'oi sur lequel on clique
    {
        [rhPtr->rhEvtProg evt_AddCurrentObject:rhPtr->rhEvtProg->rh4_2ndObject];
        CSprite* sprite = rhPtr->rhEvtProg->rh4_2ndObject->roc->rcSprite;
        if(sprite != nil)
            rhPtr->rhApp->lastInteraction = [CServices CGRectFromSprite:sprite];
        return YES;
    }
    
    short oil=pEvp2->evp.evpW.evpW0;
    if (oil>=0) return NO;                                    // Un Qualifier?
    CQualToOiList* qoil=rhPtr->rhEvtProg->qualToOiList[oil&0x7FFF];
    int qoi;
    for (qoi=0; qoi<qoil->nQoi; qoi+=2)
    {
        if (qoil->qoiList[qoi]==oi)
        {
            [rhPtr->rhEvtProg evt_AddCurrentQualifier:oil];
            [rhPtr->rhEvtProg evt_AddCurrentObject:rhPtr->rhEvtProg->rh4_2ndObject];
            CSprite* sprite = rhPtr->rhEvtProg->rh4_2ndObject->roc->rcSprite;
            if(sprite != nil)
                rhPtr->rhApp->lastInteraction = [CServices CGRectFromSprite:sprite];
            return YES;
        }
    }
    return NO;
}
BOOL eva2MClickOnObject(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    
    if (pEvp->evp.evpW.evpW0!=rhPtr->rhEvtProg->rh2CurrentClick) return NO;
    
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    return [rhPtr getMouseOnObjectsEDX:pEvp2->evp.evpW.evpW0 withNegation:NO];
}

BOOL evaMOnObject(event* pe, CRun* rhPtr, LPHO pHo)
{
    BOOL flag = (pe->evtFlags2&EVFLAG2_NOT)!=0;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    return [rhPtr getMouseOnObjectsEDX:pEvp->evp.evpW.evpW0 withNegation:flag];
}

BOOL evaOnMousePressed(event* pe, CRun* rhPtr, LPHO pHo)
{
    BOOL negated=(pe->evtFlags2&EVFLAG2_NOT)!=0;
    BOOL mouseState = rhPtr->rhApp->bMouseDown;
    return mouseState ^ negated;
}

BOOL evaPressKey(event* pe, CRun* rhPtr, LPHO pHo)
{
    //LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    //short winKey = pEvp->evp.evpW.evpW0;
    BOOL isPressed = false; //[rhPtr->rhApp->keyWrapper isPressed:winKey];
    if (!isPressed)
        return negaFALSE(pe);
    
    if (compute_GlobalNoRepeat(rhPtr))
        return negaTRUE(pe);
    return negaFALSE(pe);
}

BOOL evaKeyDepressed(event* pe, CRun* rhPtr, LPHO pHo)
{
    //LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    //short winKey = pEvp->evp.evpW.evpW0;
    BOOL isPressed = false; //[rhPtr->rhApp->keyWrapper isPressed:winKey];
    if (isPressed)
        return negaTRUE(pe);
    return negaFALSE(pe);
}

// ----------------------------------------------------
// Verifie la presence de la souris dans une  zone [ebx]
// ----------------------------------------------------
BOOL mouseInZone(int* pZone, CRun* rhPtr)
{
    int x = rhPtr->rh2MouseX + rhPtr->rhWindowX;            // Dans la zone?
    int y = rhPtr->rh2MouseY + rhPtr->rhWindowY;
    /*
    int parentX = 0;
    int parentY = 0;
    
    if(rhPtr->rhApp->parentApp !=nil)
    {
        parentX += rhPtr->rhApp->parentApp->run->rhWindowX;
        parentY += rhPtr->rhApp->parentApp->run->rhWindowY;
    }
    x -=rhPtr->rhApp->parentX;
    y -=rhPtr->rhApp->parentX;
    */
    if (x>=*pZone && x<*(pZone+2) && y>=*(pZone+1) && y<*(pZone+3))
        return YES;
    return NO;
}

// -----------------------------------
// CONDITION: user clicks in a zone
// -----------------------------------
static LPEVP GetZoneCoordinates(LPEVP pEvp, CRun* rhPtr, int* pCoordinates)
{
	LPEVP pEvp2 = EVPNEXT(pEvp);
	if (pEvp->evpCode == PARAM_ZONE)
	{
		pCoordinates[0] = pEvp->evp.evpW.evpW0;
		pCoordinates[1] = pEvp->evp.evpW.evpW1;
		pCoordinates[2] = pEvp->evp.evpW.evpW2;
		pCoordinates[3] = pEvp->evp.evpW.evpW3;
	}
	else
	{
		pCoordinates[0] = [rhPtr get_EventExpressionInt:pEvp2];
		pEvp2 = EVPNEXT(pEvp2);
		pCoordinates[1] = [rhPtr get_EventExpressionInt:pEvp2];
		pEvp2 = EVPNEXT(pEvp2);
		pCoordinates[2] = [rhPtr get_EventExpressionInt:pEvp2];
		pEvp2 = EVPNEXT(pEvp2);
		pCoordinates[3] = [rhPtr get_EventExpressionInt:pEvp2];
		pEvp2 = EVPNEXT(pEvp2);
	}
	return pEvp2;
}

BOOL eva1MClickInZone(event* pe, CRun* rhPtr, LPHO pHO)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
	int zone[4];
	GetZoneCoordinates(pEvp2, rhPtr, zone);

    if ((short)rhPtr->rhEvtProg->rhCurParam[0]!=pEvp->evp.evpW.evpW0) return NO;
    return mouseInZone(zone, rhPtr);
}
BOOL eva2MClickInZone(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
	int zone[4];
	GetZoneCoordinates(pEvp2, rhPtr, zone);

    if (pEvp->evp.evpW.evpW0!=rhPtr->rhEvtProg->rh2CurrentClick) return NO;
    return mouseInZone(zone, rhPtr);
}

// -----------------------------------
// CONDITION: mouse pointer in a zone
// -----------------------------------
BOOL evaMInZone(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
	int zone[4];
	GetZoneCoordinates(pEvp, rhPtr, zone);
    if (mouseInZone(zone, rhPtr)) return negaTRUE(pe);
    return negaFALSE(pe);
}





// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// Table d'appel de l'objet TIMER
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------

// ---------------------------------------------------------
// EXPRESSION: valeur brute du timer
// ---------------------------------------------------------
void expTim_Value(CRun* rhPtr)
{
    [getCurrentResult() forceInt:rhPtr->rhTimer];
    
    // Only for benchmarks
//    int tm = CACurrentMediaTime() * 1000;
//    [getCurrentResult() forceInt:tm];
}
// ---------------------------------------------------------
// EXPRESSION: Timer en centiemes
// ---------------------------------------------------------
void expTim_Cent(CRun* rhPtr)
{
    int c=rhPtr->rhTimer/10;
    [getCurrentResult() forceInt:(c%100)];
}
// ---------------------------------------------------------
// EXPRESSION: Timer en secondes
// ---------------------------------------------------------
void expTim_Sec(CRun* rhPtr)
{
    int s=rhPtr->rhTimer/1000;
    [getCurrentResult() forceInt:(s%60)];
}
// ---------------------------------------------------------
// EXPRESSION: Timer en minutes
// ---------------------------------------------------------
void expTim_Min(CRun* rhPtr)
{
    int s=rhPtr->rhTimer/60000;
    [getCurrentResult() forceInt:(s%60)];
}
// ---------------------------------------------------------
// EXPRESSION: Timer en heures
// ---------------------------------------------------------
void expTim_Hour(CRun* rhPtr)
{
    int s=rhPtr->rhTimer/3600000;
    [getCurrentResult() forceInt:s];
}

// -------------------------------------------------------------
// CONDITION: timer equals (appele a l'interieur d'un evenement)
// -------------------------------------------------------------
BOOL evaTimerEqu(event* pe, CRun* rhPtr, LPHO pHo)
{
    if (pe->evtFlags&EVFLAGS_DONE) return  NO;        //; Timer deja execute?
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    int time=pEvp->evp.evpL.evpL0;
    if (rhPtr->rhTimer<time) return NO;                // Compare au timer
    pe->evtFlags|=EVFLAGS_DONE;                            // Marque l'evenement
    return YES;
}

// ---------------------------------------------------------
// CONDITION: timer inferieur
// ---------------------------------------------------------
BOOL evaTimerInf(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    
    int time;
    if (pEvp->evpCode==PARAM_EXPRESSION)
        time=[rhPtr get_EventExpressionInt:pEvp];
    else
        time=(int)pEvp->evp.evpL.evpL0;
    
    if (rhPtr->rhTimer>time) return NO;
    return YES;
}


// ---------------------------------------------------------
// CONDITION: timer superieur
// ---------------------------------------------------------
BOOL evaTimerSup(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    
    int time;
    if (pEvp->evpCode==PARAM_EXPRESSION)
        time=[rhPtr get_EventExpressionInt:pEvp];
    else
        time=(int)pEvp->evp.evpL.evpL0;
    
    if (rhPtr->rhTimer>time) return YES;
    return NO;
}

// ---------------------------------------------------------
// CONDITION: timeout
// ---------------------------------------------------------
BOOL evaTimeOut(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    
    int time;
    if (pEvp->evpCode==PARAM_EXPRESSION)
        time=[rhPtr get_EventExpressionInt:pEvp];
    else
        time=(int)pEvp->evp.evpL.evpL0;
    
    if (rhPtr->rh4TimeOut>time) return YES;
    return NO;
}

// ---------------------------------------------------------
// CONDITION: every
// ---------------------------------------------------------
BOOL evaEvery(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    
    pEvp->evp.evpL.evpL1-=rhPtr->rhTimerDelta;
    if (pEvp->evp.evpL.evpL1>0) return NO;
    pEvp->evp.evpL.evpL1+=pEvp->evp.evpL.evpL0;
    return YES;
}

// ---------------------------------------------------------
// ACTION: set timer
// ---------------------------------------------------------
void actSetTimer(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int newTime;
    if (pEvp->evpCode==PARAM_EXPRESSION)
        newTime=[rhPtr get_EventExpressionInt:pEvp];
    else
        newTime=pEvp->evp.evpL.evpL0;
    
    double time=CFAbsoluteTimeGetCurrent()*1000;
    rhPtr->rhTimer=newTime;
    rhPtr->rhTimerOld=time-rhPtr->rhTimer;
    
    [rhPtr->rhEvtProg restartTimerEvents];
}

// ---------------------------------------------------------
// CONDITION: timer equals avec expression
// ---------------------------------------------------------
BOOL evaTimerEquals(event* pe, CRun* rhPtr, CObject* pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp + pEvp->evpSize);
    
    int time;
    if (pEvp->evpCode==PARAM_EXPRESSION)
        time=[rhPtr get_EventExpressionInt:pEvp];
    else
        time=(int)pEvp->evp.evpL.evpL0;
    
    if (rhPtr->rhTimer >= time)
    {
        if (pEvp2->evp.evpL.evpL0 == rhPtr->rhLoopCount)
        {
            pEvp2->evp.evpL.evpL0 = rhPtr->rhLoopCount + 1;
            return NO;
        }
        pEvp2->evp.evpL.evpL0 = rhPtr->rhLoopCount + 1;
        return YES;
    }
    return NO;
}

// ---------------------------------------------------------
// CONDITION: every avec expressions
// ---------------------------------------------------------
BOOL evaEvery2(event* pe, CRun* rhPtr, CObject* pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp + pEvp->evpSize);
    
    int time = 0;
    if ((pEvp2->evp.evpL.evpL0 & 1) == 0)
    {
        if (pEvp->evpCode==PARAM_EXPRESSION)
            time=[rhPtr get_EventExpressionInt:pEvp];
        else
            time=pEvp->evp.evpL.evpL0;
        pEvp2->evp.evpL.evpL0 = (time << 1) | 1;
        //pEvp->evp.evpL.evpL1 = -1;
        //NSLog(@"set Timer to %d", time);
    }
    else
    {
        unsigned int timerDelta = ((rhPtr->rhTimerDelta & 0x7FFFFFFF) << 1);
        int current = (pEvp2->evp.evpL.evpL0 & 0xFFFFFFFE);
        if(timerDelta > 1000)
            time = 2;
        current -= timerDelta;
        if (current <= 0)
        {
            if (pEvp->evpCode==PARAM_EXPRESSION)
                time=[rhPtr get_EventExpressionInt:pEvp];
            else
                time=(pEvp->evp.evpL.evpL0);
            current += (time << 1);
            pEvp2->evp.evpL.evpL0 = current | 1;
            return YES;
        }
        pEvp2->evp.evpL.evpL0 = current | 1;
    }
    return NO;
    
}

void RACT_EVENTAFTER(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int timer;
    if (pEvp->evpCode==PARAM_EXPRESSION)
        timer=[rhPtr get_EventExpressionInt:pEvp];
    else
        timer=pEvp->evp.evpL.evpL0;
    pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    NSString* pName=[rhPtr get_EventExpressionString:pEvp];
    
    LPTIMEREVENT pLoop=(LPTIMEREVENT)rhPtr->rh4TimerEvents;
    LPTIMEREVENT pPrevious=nil;
    while(pLoop!=NULL)
    {
        pPrevious=pLoop;
        pLoop=(LPTIMEREVENT)pLoop->next;
    }
    LPTIMEREVENT pEvent=(LPTIMEREVENT)malloc(sizeof(TimerEvent));
    if (pPrevious==nil)
        rhPtr->rh4TimerEvents=pEvent;
    else
        pPrevious->next=pEvent;
    pEvent->type=TIMEREVENTTYPE_ONESHOT;
    pEvent->timer=rhPtr->rhTimer+timer;
    pEvent->name=[[NSString alloc] initWithString:pName];
    pEvent->next=nil;
    pEvent->bDelete = NO;
}
void RACT_NEVENTSAFTER(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int timer;
    if (pEvp->evpCode==PARAM_EXPRESSION)
        timer=[rhPtr get_EventExpressionInt:pEvp];
    else
        timer=pEvp->evp.evpL.evpL0;
    pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    int loops=[rhPtr get_EventExpressionInt:pEvp];
    int timerNext;
    pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    if (pEvp->evpCode==PARAM_EXPRESSION)
        timerNext=[rhPtr get_EventExpressionInt:pEvp];
    else
        timerNext=pEvp->evp.evpL.evpL0;
    pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    NSString* pName=[rhPtr get_EventExpressionString:pEvp];
    
    LPTIMEREVENT pLoop=(LPTIMEREVENT)rhPtr->rh4TimerEvents;
    LPTIMEREVENT pPrevious=nil;
    while(pLoop!=nil)
    {
        pPrevious=pLoop;
        pLoop=(LPTIMEREVENT)pLoop->next;
    }
    LPTIMEREVENT pEvent=(LPTIMEREVENT)malloc(sizeof(TimerEvent));
    if (pPrevious==nil)
        rhPtr->rh4TimerEvents=pEvent;
    else
        pPrevious->next=pEvent;
    pEvent->type=TIMEREVENTTYPE_REPEAT;
    pEvent->timer=rhPtr->rhTimer+timer;
    pEvent->timerNext=timerNext;
    pEvent->timerPosition=0;
    pEvent->loops=loops;
    pEvent->index=0;
    pEvent->next=nil;
    pEvent->bDelete = NO;
    pEvent->name = [[NSString alloc] initWithString:pName];
}
BOOL RCND_ONEVENT(event* pe, CRun* rhPtr, CObject* pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    NSString* pName=[rhPtr get_EventExpressionString:pEvp];
    if ([pName caseInsensitiveCompare:rhPtr->timerEventName] == 0)
    {
        return YES;
    }
    return NO;
}
void REXP_EVENTAFTER(CRun* rhPtr)
{
    [getCurrentResult() forceInt:rhPtr->rhEvtProg->rhCurParam[1]];
}

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// Table d'appel de l'objet GAME
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------



// ---------------------------------------------------------
// CONDITION: number of level =
// ---------------------------------------------------------
BOOL evaLevel(event* pe, CRun* rhPtr, LPHO pHo)
{
    return NO;
}

// ----------------------------
// EXPRESSION: NUMBER OF LEVEL
// ----------------------------
void expGam_NLevelOld(CRun* rhPtr)
{
    [getCurrentResult() forceInt:rhPtr->rhApp->currentFrame];
}
void expGam_NLevel(CRun* rhPtr)
{
    [getCurrentResult() forceInt:rhPtr->rhApp->currentFrame + 1];
}

// ---------------------------------------------------------
// CONDITION: at start of level
// ---------------------------------------------------------
BOOL evaStart(event* pe, CRun* rhPtr, LPHO pHo)
{
    if (rhPtr->rhLoopCount>2) return NO;
    return YES;
}
// ---------------------------------------------------------
// CONDITION: at end of level (toujours vrai) FRA: bug lorsque condition utilisee en deuxieme dans le groupe
// ---------------------------------------------------------
BOOL evaEnd(event* pe, CRun* rhPtr, LPHO pHo)
{
    return YES;
}

// ---------------------------------------------------------
// CONDITION : IS OBSTACLE
// ---------------------------------------------------------
BOOL evaIsObstacle(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    
    int x=[rhPtr get_EventExpressionInt:pEvp];
    int y=[rhPtr get_EventExpressionInt:pEvp2];
    
    //    if (IsObstacleAt(x, y, CM_TEST_OBSTACLE))
    //    if ( ColMask_TestPoint(idEditWin, x, y, CM_TEST_OBSTACLE) )
    if ( [rhPtr->rhFrame bkdCol_TestPoint:x withY:y andLayer:LAYER_ALL andPlane:CM_TEST_OBSTACLE] )
        return negaTRUE(pe);
    return negaFALSE(pe);
}

// ---------------------------------------------------------
// CONDITION : IS LADDER
// ---------------------------------------------------------
BOOL evaIsLadder(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    
    int x=[rhPtr get_EventExpressionInt:pEvp];
    int y=[rhPtr get_EventExpressionInt:pEvp2];
    
    if ( ![rhPtr y_GetLadderAt_Absolute:-1 withX:x andY:y].isNil() )
        return negaTRUE(pe);
    return negaFALSE(pe);
}

// ---------------------------------------------------------
// CONDITION: END OF PAUSE 2
// ---------------------------------------------------------
BOOL evaEndOfPause2(event* pe, CRun* rhPtr, LPHO pHo)
{
    if (rhPtr->rh4EndOfPause!=rhPtr->rhLoopCount-1) return NO;
    return YES;
}

// ---------------------------------------------------------
// CONDITION: FRAME LOADED
// ---------------------------------------------------------
BOOL evaFrameLoaded(event* pe, CRun* rhPtr, LPHO pHo)
{
    if (rhPtr->rh4LoadCount!=rhPtr->rhLoopCount-1) return negaFALSE(pe);
    return negaTRUE(pe);
}

// ---------------------------------------------------------
// CONDITION: FRAME SAVED
// ---------------------------------------------------------
BOOL evaFrameSaved(event* pe, CRun* rhPtr, LPHO pHo)
{
    if (rhPtr->rh4SaveFrameCount!=rhPtr->rhLoopCount-1) return negaFALSE(pe);
    return negaTRUE(pe);
}

// ---------------------------------------------------------
// EXPRESSION : GET COLLISION MASK
// ---------------------------------------------------------
void expGam_GetCollisionMask(CRun* rhPtr)
{
    int x, y;
    
    nextToken();
    x=[rhPtr get_ExpressionInt];
    nextToken();
    y=[rhPtr get_ExpressionInt];
    
    int result=0;
    if ( ![rhPtr y_GetLadderAt_Absolute:-1 withX:x andY:y].isNil() )
        result=2;
    else
    {
        //        if ( IsObstacleAt(x, y, CM_TEST_OBSTACLE) )
        //        if ( ColMask_TestPoint(idEditWin, x, y, CM_TEST_OBSTACLE) )
        if ( [rhPtr->rhFrame bkdCol_TestPoint:x withY:y andLayer:LAYER_ALL andPlane:CM_TEST_OBSTACLE] )
            result=1;
    }
    
    [getCurrentResult() forceInt:(result)];
}

// ---------------------------------------------------------
// EXPRESSION : GET FRAMERATE
// ---------------------------------------------------------
void expGam_FrameRate(CRun* rhPtr)
{
    [getCurrentResult() forceInt:[rhPtr getFrameRate]];
}

// ---------------------------------------------------------
// EXPRESSION : GET VIRTUAL WIDTH
// ---------------------------------------------------------
void expGam_GetVirtualWidth(CRun* rhPtr)
{
    [getCurrentResult() forceInt:(int)rhPtr->rhFrame->leVirtualRect.right];
}

// ---------------------------------------------------------
// EXPRESSION : GET VIRTUAL HEIGHT
// ---------------------------------------------------------
void expGam_GetVirtualHeight(CRun* rhPtr)
{
    [getCurrentResult() forceInt:(int)rhPtr->rhFrame->leVirtualRect.bottom];
}

// ---------------------------------------------------------
// EXPRESSION : GET FRAME BACKGROUND COLOR
// ---------------------------------------------------------
void expGam_GetFrameBkdColor(CRun* rhPtr)
{
    [getCurrentResult() forceInt:rhPtr->rhFrame->leBackground];
}

// ---------------------------------------------------------
// EXPRESSION : GET GRAPHIC MODE
// ---------------------------------------------------------

void expGam_GraphicMode(CRun* rhPtr)
{
    [getCurrentResult() forceInt:4];
}

// ---------------------------------------------------------
// EXPRESSION : GET PIXEL SHADER VERSION
// ---------------------------------------------------------

void expGam_PixelShaderV(CRun* rhPtr)
{
    [getCurrentResult() forceInt:2];
}

// ---------------------------------------------------------
// EXPRESSION : GET FRAME ALPHA COEF
// ---------------------------------------------------------

void expGam_FrameAlphaCoef(CRun* rhPtr)
{
    CRunFrame* frame = rhPtr->rhFrame;

     int effect = frame->effect;
     int effectParam = frame->effectParam;
     int alpha = 0;
     int rgbaCoeff = effectParam;

     //Check for Shaders or RGBA filter set
     if((effect & BOP_MASK) == BOP_EFFECTEX
             || (effect & BOP_RGBAFILTER) != 0)
         alpha = 255-(rgbaCoeff&0xFF000000 >> 24);
     else
     {
         if(effectParam == -1)
             alpha = 0;
         else
             alpha = effectParam*2;
     }
    [getCurrentResult() forceInt:alpha];
}

// ---------------------------------------------------------
// EXPRESSION : GET FRAME RGB COEF
// ---------------------------------------------------------

void expGam_FrameRGBCoef(CRun* rhPtr)
{
    CRunFrame* frame = rhPtr->rhFrame;

    int effect = frame->effect;
    int effectParam = frame->effectParam;
    int argb = 0;
    int rgbaCoeff = effectParam;

    //Check for Shaders or RGBA filter set
    if(((effect & BOP_MASK) >= BOP_BLEND
            && (effect & BOP_MASK) <= BOP_EFFECTEX)
            || (effect & BOP_RGBAFILTER) != 0)
        argb = swapRGB((rgbaCoeff & 0x00FFFFFF));
    else
        argb = 0x00FFFFFF;

    [getCurrentResult() forceInt:argb];
}

// ---------------------------------------------------------
// EXPRESSION : GET FRAME EFFECT PARAM
// ---------------------------------------------------------

void expGam_FrameEffectParam(CRun* rhPtr)
{
    CRunFrame* frame = rhPtr->rhFrame;
    nextToken();
    NSString* paramName = [rhPtr get_ExpressionString];

    if (frame->effectEx == nil || paramName == nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }

    if((frame->effect & BOP_MASK) == BOP_EFFECTEX) {
        if (frame->effectEx != nil) {
            int index = [frame->effectEx getParamIndex:paramName];
            if (index != -1) {
                switch ([frame->effectEx getParamType:index]) {
                 case EFFECTPARAM_INTFLOAT4:
                 case EFFECTPARAM_INT:
                     [getCurrentResult() forceInt:[frame->effectEx getParamInt:index]];
                     return;
                 case EFFECTPARAM_FLOAT:
                     [getCurrentResult() forceDouble:[frame->effectEx getParamFloat:index]];
                     return;
                }
            }
        }
    }
    [getCurrentResult() forceInt:0];
}

// ------------------
// ACTION: RESTART LEVEL
// ------------------
void actRestartLevel(event* pe, CRun* rhPtr)
{
    rhPtr->rhQuit=LOOPEXIT_RESTART;
}

// ------------------
// ACTION: NEXT LEVEL
// ------------------
void actNextLevel(event* pe, CRun* rhPtr)
{
    rhPtr->rhQuit=LOOPEXIT_NEXTLEVEL;
}

// ----------------------
// ACTION: PREVIOUS LEVEL
// ----------------------
void actPrevLevel(event* pe, CRun* rhPtr)
{
    rhPtr->rhQuit=LOOPEXIT_PREVLEVEL;
}

// ------------------
// ACTION: GOTO LEVEL
// ------------------
void actGotoLevel(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    
    int level=pEvp->evp.evpW.evpW0;
    if (pEvp->evpCode==PARAM_FRAME)
    {
        // Verifie la validite du level
        if ([rhPtr->rhApp HCellToNCell:level]==-1) return;
    }
    else
    {
        // Avec un calcul
        level=[rhPtr get_EventExpressionInt:pEvp]-1;        // Une expression
        if (level<0 || level>=4096) return;            // Entre 0 et 4096
        level|=0x8000;
    }
    rhPtr->rhQuit=LOOPEXIT_GOTOLEVEL;
    rhPtr->rhQuitParam=level;
}

// ----------------
// ACTION: END GAME
// ----------------
void actEndGame(event* pe, CRun* rhPtr)
{
    rhPtr->rhQuit=LOOPEXIT_ENDGAME;
}

// ----------------
// ACTION: RESTART GAME
// ----------------
void actRestartGame(event* pe, CRun* rhPtr)
{
    rhPtr->rhQuit=LOOPEXIT_NEWGAME;
}

// ------------------
// ACTION: PAUSE GAME
// ------------------
void actPauseGame(event* pe, CRun* rhPtr)
{
    rhPtr->rhQuit=LOOPEXIT_PAUSEGAME;
}

// Center the display in accordance with the edges
// -----------------------------------------
void setDisplay(CRun* rhPtr, int x, int y, int nLayer, DWORD flags)
{
    int windowWidth = rhPtr->rh3WindowSx;
    int windowHeight = rhPtr->rh3WindowSy;
    
    //Fix centering if using virtual width/height and if smaller than the resized window size
    if(rhPtr->rhFrame->leVirtualRect.right != rhPtr->rhFrame->leWidth && windowWidth < rhPtr->rhApp->gaCxWin)
        windowWidth = rhPtr->rhApp->gaCxWin;
    if(rhPtr->rhFrame->leVirtualRect.bottom != rhPtr->rhFrame->leHeight && windowHeight < rhPtr->rhApp->gaCyWin)
        windowHeight = rhPtr->rhApp->gaCyWin;

    x -= windowWidth/2;                //; Taille de la fenetre d'affichage
    y -= windowHeight/2;
    
    double xf = (double)x;
    double yf = (double)y;
    
    if ( nLayer != -1 && nLayer < (int)rhPtr->rhFrame->nLayers )
    {
        CLayer* pLayer = rhPtr->rhFrame->layers[nLayer];
        //TODO center based on layer center
        if ( pLayer->xCoef > 1.0 )
        {
            double dxf = xf;
            dxf /= pLayer->xCoef;
            xf = dxf;
        }
        if ( pLayer->yCoef > 1.0 )
        {
            double dyf = yf;
            dyf /= pLayer->yCoef;
            yf = dyf;
        }
    }
    
    x = (int)xf;
    y = (int)yf;
    
    if (rhPtr->rhGameFlags&GAMEFLAGS_LIMITEDSCROLL)
    {
        // In game mode, is limited to the borders of the frame ...
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        if (x<0)
            x=0;                    // Sort ‡ haut/gauche?
        if (y<0)
            y=0;
        int x2=x+rhPtr->rh3WindowSx;    // Sort a droite/bas?
        int y2=y+rhPtr->rh3WindowSy;
        if (x2>rhPtr->rhLevelSx)
        {
            x2=rhPtr->rhLevelSx-rhPtr->rh3WindowSx;
            if (x2<0)
                x2=0;
            x=x2;
        }
        if (y2>rhPtr->rhLevelSy)
        {
            y2=rhPtr->rhLevelSy-rhPtr->rh3WindowSy;
            if (y2<0)
                y2=0;
            y=y2;
        }
    }
    else
    {
        // In monitor mode, is limited to 320 sized edges ...
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        if (x<-GAME_XBORDER)
            x=-GAME_XBORDER;
        int xr=rhPtr->rhLevelSx+GAME_XBORDER;
        int x2=x+rhPtr->rh3WindowSx;
        if (x2>xr)
            x=xr-rhPtr->rh3WindowSx;
        if (y<-GAME_YBORDER)
            y=-GAME_YBORDER;
        int yr=rhPtr->rhLevelSy+GAME_YBORDER;
        int y2=y+rhPtr->rh3WindowSy;
        if (y2>yr)
            y=yr-rhPtr->rh3WindowSy;
    }
    // The end of the loop...
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (flags&1)
    {
        if (x!=rhPtr->rhWindowX)
        {
            rhPtr->rh3DisplayX=x;
            rhPtr->rh3Scrolling|=RH3SCROLLING_SCROLL;
        }
    }
    if (flags&2)
    {
        if (y!=rhPtr->rhWindowY)
        {
            rhPtr->rh3DisplayY=y;
            rhPtr->rh3Scrolling|=RH3SCROLLING_SCROLL;
        }
    }
    
    
    //Ensure all mouse input coordinates are updated after a scroll:
    //[rhPtr getMouseCoords];
    
    if((rhPtr->rh3Scrolling & RH3SCROLLING_SCROLL) !=0)
        rhPtr->rhApp->nWindowUpdate++;
}


// ----------------------------------
// Interprets a structure POSITION EAX = Structure position
// ----------------------------------

BOOL read_Position(CRun* rhPtr, LPPOS pPos, DWORD getDir, int* pX, int* pY, int* pDir, BOOL* pBRepeat, int* pLayer)
{
    if ( pLayer != nil )
        *pLayer = -1;
    
    if (pPos->posOINUMParent==-1)
    {
        // Pas d'objet parent
        // ~~~~~~~~~~~~~~~~~~
        if (getDir!=0)                                    // Tenir compte de la direction?
        {
            *pDir=-1;
            if ((pPos->posFlags&CPF_DEFAULTDIR)==0)        // Garder la direction de l'objet
            {
                *pDir=[rhPtr get_Direction:pPos->posDir];        // Va chercher la direction
            }
        }
        *pX=pPos->posX;
        *pY=pPos->posY;
        if ( pLayer != nil )
        {
            int nLayer = pPos->posLayer;
            if ( nLayer > rhPtr->rhFrame->nLayers - 1 )
                nLayer = rhPtr->rhFrame->nLayers - 1;
            *pLayer = nLayer;
        }
        *pBRepeat=NO;
    }
    else
    {
        // Trouve le parent
        // ~~~~~~~~~~~~~~~~
        rhPtr->rhEvtProg->rh2EnablePick=0;
        LPHO pHo=[rhPtr->rhEvtProg get_CurrentObjects:pPos->posOiList];
        *pBRepeat=rhPtr->rhEvtProg->repeatFlag;
        if (pHo==nil) return NO;
        *pX=[pHo getX];
        *pY=[pHo getY];
        if ( pLayer != nil )
            *pLayer = pHo->hoLayer;
        
        if (pPos->posFlags&CPF_ACTION)                    // Relatif au point d'action?
        {
            if (pHo->hoOEFlags&OEFLAG_ANIMATIONS)
            {
                if ( pHo->roc->rcImage >= 0 )
                {
                    float angle = pHo->roc->rcAngle;
                    CRunMvtPhysics* pMvt = [rhPtr GetPhysicMovement:pHo];
                    if (pMvt != nil)
                    {
                        angle = pMvt->GetAngle();
						if (angle == ANGLE_MAGIC)
							angle = pHo->roc->rcAngle;
                    }
                    ImageInfo ifo=[rhPtr->rhApp->imageBank getImageInfoEx:pHo->roc->rcImage withAngle:angle andScaleX:pHo->roc->rcScaleX andScaleY:pHo->roc->rcScaleY];
                    *pX+=ifo.xAP-ifo.xSpot;
                    *pY+=ifo.yAP-ifo.ySpot;
                }
            }
        }
        
        if (pPos->posFlags&CPF_DIRECTION)                // Tenir compte de la direction?
        {
            int dir=(pPos->posAngle+[rhPtr getDir:pHo])&0x1F;    // La direction courante
            int px, py;
            px=[CMove getDeltaX:pPos->posSlope withAngle:dir];
            py=[CMove getDeltaY:pPos->posSlope withAngle:dir];
            *pX+=px;
            *pY+=py;
        }
        else
        {
            *pX+=pPos->posX;                                // Additionne la position relative
            *pY+=pPos->posY;
        }
        
        if (getDir&0x01)
        {
            if (pPos->posFlags&CPF_DEFAULTDIR)            // Mettre la direction par defaut?
            {
                *pDir=-1;
            }
            else if (pPos->posFlags&CPF_INITIALDIR)        // Mettre la direction initiale?
            {
                *pDir=[rhPtr getDir:pHo];
            }
            else
            {
                *pDir=[rhPtr get_Direction:pPos->posDir];        // Va cherche la direction
            }
        }
    }
    
    // Verification des directions: dans le terrain!!
    if (getDir&0x02)
    {
        if (*pX<rhPtr->rh3XMinimumKill || *pX>rhPtr->rh3XMaximumKill) return NO;
        if (*pY<rhPtr->rh3YMinimumKill || *pY>rhPtr->rh3YMaximumKill) return NO;
    }
    
    return YES;
}

// -------------------------
// ACTION: CENTRE LE DISPLAY
// -------------------------
void actCDisplay(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int x, y, dir;
    BOOL bRepeat;
    int nLayer;
    
    if (read_Position(rhPtr, (LPPOS)&pEvp->evp.evpW.evpW0, 0, &x, &y, &dir, &bRepeat, &nLayer))            //; Pas de direction, pas de controle coords
        setDisplay(rhPtr, x, y, nLayer, 3);
}

// ------------------------------
// ACTION: CENTRE LE DISPLAY EN X
// ------------------------------
void actCDisplayX(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    
    int x=[rhPtr get_EventExpressionInt:pEvp];
    setDisplay(rhPtr, x, 0, -1, 1);
}
// ------------------------------
// ACTION: CENTRE LE DISPLAY EN Y
// ------------------------------
void actCDisplayY(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    
    int y=[rhPtr get_EventExpressionInt:pEvp];
    setDisplay(rhPtr, 0, y, -1, 2);
}

// ------------------------------
// ACTION: SET VIRTUAL WIDTH
// ------------------------------
void actSetVirtualWidth(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int newWidth = [rhPtr get_EventExpressionInt:pEvp];
    
    if ( newWidth < 0 )
        newWidth = 0x7FFFF000;
    //    else if ( newWidth < curFrame.m_hdr.leWidth )
    //        newWidth = curFrame.m_hdr.leWidth;
    
    if ( rhPtr->rhFrame->leVirtualRect.right != newWidth )
    {
        rhPtr->rhFrame->leVirtualRect.right = rhPtr->rhLevelSx = newWidth;
        
        // Position de KILL des objets loin du terrain
        rhPtr->rh3XMaximumKill=rhPtr->rhLevelSx+GAME_XBORDER;
    }
}

// ------------------------------
// ACTION: SET VIRTUAL HEIGHT
// ------------------------------
void actSetVirtualHeight(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int newHeight = [rhPtr get_EventExpressionInt:pEvp];
    
    if ( newHeight < 0 )
        newHeight = 0x7FFFF000;
    //    else if ( newHeight < curFrame.m_hdr.leHeight )
    //        newHeight = curFrame.m_hdr.leHeight;
    
    if ( rhPtr->rhFrame->leVirtualRect.bottom != newHeight )
    {
        rhPtr->rhFrame->leVirtualRect.bottom = rhPtr->rhLevelSy = newHeight;
        
        // Position de KILL des objets loin du terrain
        rhPtr->rh3YMaximumKill=rhPtr->rhLevelSy+GAME_YBORDER;
    }
}

// ------------------------------
// ACTION: SET FRAME BKD COLOR
// ------------------------------
void actSetFrameBkdColor(event* pe, CRun* rhPtr)
{
    LPEVP pEvp = (LPEVP)((LPBYTE)pe+ACT_SIZE);
    int color = (DWORD)pEvp->evp.evpL.evpL0;
    if ( pEvp->evpCode != PARAM_COLOUR )
        color = [rhPtr get_EventExpressionInt:pEvp];
    
    rhPtr->rhFrame->leBackground = color;
    
    // Redraw frame
    [rhPtr ohRedrawLevel:NO];
}

// ----------------------------------
// ACTION: DELETE CREATED BACKDROP AT
// ----------------------------------
void actDelCreatedBkdAt(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    LPEVP pEvp3=(LPEVP)((LPBYTE)pEvp2+pEvp2->evpSize);
    LPEVP pEvp4=(LPEVP)((LPBYTE)pEvp3+pEvp3->evpSize);
    
    int nLayer = [rhPtr get_EventExpressionInt:pEvp] - 1;        // 1-based
    int x = [rhPtr get_EventExpressionInt:pEvp2];
    int y = [rhPtr get_EventExpressionInt:pEvp3];
    int bFineDetection = [rhPtr get_EventExpressionInt:pEvp4];
    
    [rhPtr deleteBackdrop2At:nLayer withX:x andY:y andFlag:bFineDetection];
}

// ------------------------------------
// Set frame width
// ------------------------------------
void actSetFrameWidth(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int newWidth = [rhPtr get_EventExpressionInt:pEvp];        // 1-based
    
    int nOldWidth=rhPtr->rhFrame->leWidth;
    rhPtr->rhFrame->leWidth=newWidth;
    if (nOldWidth==rhPtr->rhFrame->leVirtualRect.right)
    {
        rhPtr->rhFrame->leVirtualRect.right=rhPtr->rhLevelSx=newWidth;
        rhPtr->rh3XMaximumKill=rhPtr->rhLevelSx+GAME_XBORDER;
    }
    if (rhPtr->rhFrame->colMask!=nil)
    {
        [rhPtr->rhFrame->colMask release];
        rhPtr->rhFrame->colMask = [CColMask create:-COLMASK_XMARGIN withY1:-COLMASK_YMARGIN andX2:rhPtr->rhFrame->leWidth + COLMASK_XMARGIN andY2:rhPtr->rhFrame->leHeight + COLMASK_YMARGIN andFlags:[rhPtr->rhFrame getMaskBits]];
    }
    [rhPtr ohRedrawLevel:YES];

    for (int i=0; i<rhPtr->rhFrame->nLayers; ++i)
    {
        CLayer* pLayer = rhPtr->rhFrame->layers[i];
        [pLayer resetZones];
    }
}

// ------------------------------------
// Set frame height
// ------------------------------------
void actSetFrameHeight(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int newHeight = [rhPtr get_EventExpressionInt:pEvp];        // 1-based
    
    int nOldHeight=rhPtr->rhFrame->leHeight;
    rhPtr->rhFrame->leHeight=newHeight;
    if (nOldHeight==rhPtr->rhFrame->leVirtualRect.bottom)
    {
        rhPtr->rhFrame->leVirtualRect.bottom=rhPtr->rhLevelSy=newHeight;
        rhPtr->rh3YMaximumKill=rhPtr->rhLevelSy+GAME_YBORDER;
    }
    if (rhPtr->rhFrame->colMask!=nil)
    {
        [rhPtr->rhFrame->colMask release];
        rhPtr->rhFrame->colMask = [CColMask create:-COLMASK_XMARGIN withY1:-COLMASK_YMARGIN andX2:rhPtr->rhFrame->leWidth + COLMASK_XMARGIN andY2:rhPtr->rhFrame->leHeight + COLMASK_YMARGIN andFlags:[rhPtr->rhFrame getMaskBits]];
    }
    [rhPtr ohRedrawLevel:YES];

    for (int i=0; i<rhPtr->rhFrame->nLayers; ++i)
    {
        CLayer* pLayer = rhPtr->rhFrame->layers[i];
        [pLayer resetZones];
    }
}

void actSetFrameEffect(event*pe, CRun* rhPtr)    // ACT_SETFRAMEEFFECT
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    char* pName=(char*)&pEvp->evp.evpW.evpW0;
    NSString* name;
    if(rhPtr->rhApp->bUnicode)
        name = [[NSString alloc] initWithCharacters:(unichar*)pName length:strUnicharLen((unichar*)pName)];
    else
        name = [[NSString alloc] initWithCString:pName encoding:NSWindowsCP1252StringEncoding];

    CRunFrame* frame = rhPtr->rhFrame;
    
    int effect = BOP_COPY;
    frame->frameInkEffectShader = -1;
    
    if (name != nil && [name length] > 0)
    {
		if ( [name compare:@"Add"] == 0 )
		{
			effect=BOP_ADD;
		}
		else if ( [name compare:@"Invert"] == 0 )
		{
			effect=BOP_INVERT;
		}
		else if ( [name compare:@"Sub"] == 0 )
		{
			effect=BOP_SUB;
		}
		else if ( [name compare:@"Mono"] == 0 )
		{
			effect=BOP_MONO;
		}
		else if ( [name compare:@"Blend"] == 0 )
		{
			effect=BOP_BLEND;
		}
		else if ( [name compare:@"XOR"] == 0 )
		{
			effect=BOP_XOR;
		}
		else if ( [name compare:@"OR"] == 0 )
		{
			effect=BOP_OR;
		}
		else if ( [name compare:@"AND"] == 0 )
		{
			effect=BOP_AND;
		}
		else if([frame checkOrCreateEffectIfNeeded:rhPtr->rhApp andName:name] != -1)
		{
			effect = BOP_EFFECTEX;
			frame->frameInkEffectShader = [frame->effectEx getIndexShader];
		}
    }

    frame->effect &=~BOP_MASK;
    frame->effect |= effect;


}

void actSetFrameEffectParam(event*pe, CRun* rhPtr)    // ACT_SETFRAMEEFFECTPARAM
{
    CRunFrame* frame = rhPtr->rhFrame;
    
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    NSString* paramName=[rhPtr get_EventExpressionStringNoCopy:pp];
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* paramValue=[rhPtr get_EventExpressionAny:pp];
        
    if((frame->effect & BOP_MASK) == BOP_EFFECTEX)
    {
       if(frame->effectEx != nil)
       {
           int paramIndex = [frame->effectEx getParamIndex:paramName];
           if(paramIndex != -1)
           {
               [frame->effectEx setParamValue:paramIndex andValue:paramValue];
           }
       }
    }
}

void actSetFrameEffectParamTexture(event*pe, CRun* rhPtr)    // ACT_SETFRAMEEFFECTPARAMTEXTURE
{
    CRunFrame* frame = rhPtr->rhFrame;

    if((frame->effect & BOP_MASK) == BOP_EFFECTEX)
    {
        if(frame->effectEx != nil)
        {
            LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
            NSString* paramName=[rhPtr get_EventExpressionStringNoCopy:pEvp];
            
            int paramIndex = [frame->effectEx getParamIndex:paramName];
            if(paramIndex != -1)
            {
                pEvp = (LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
                NSString* fileName = nil;
                if ( pEvp->evpCode == PARAM_FILENAME )
                {
                    if (rhPtr->rhTempString!=nil)
                        [rhPtr->rhTempString release];
                    
                    char* str = (char*)&pEvp->evp.evpW.evpW0;
                    if(rhPtr->rhApp->bUnicode)
                        fileName = [[NSString alloc] initWithCharacters:(unichar*)str length:strUnicharLen((unichar*)str)];
                    else
                        fileName = [[NSString alloc] initWithCString:str encoding:NSWindowsCP1252StringEncoding];
                }
                else
                    fileName = [rhPtr get_EventExpressionString:pEvp];
                
                if(fileName == nil)
                    return;
                
                if(rhPtr->rhApp->embeddedFiles != nil)
                {
                    NSData* data = [rhPtr->rhApp loadResourceData:fileName];
                    if(data != nil)
                    {
                        CImage* img = nil;
                        UIImage* imageToLoad = [[UIImage alloc] initWithData:data];
                        if(imageToLoad != nil)
                            img = [CImage loadUIImage:imageToLoad];
                        
                        if(img != nil)
                        {
                            int handle = [rhPtr->rhApp->imageBank addImage:img withXSpot:0 andYSpot:0 andXAP:0 andYAP:0 andCount:1];
                            [frame->effectEx setParamAt:paramIndex withTexture:handle];
                        }
                    }
                }
            }
        }
    }

}

void actSetFrameAlphaCoef(event*pe, CRun* rhPtr)    // ACT_SETFRAMEALPHACOEF
{
    CRunFrame* frame = rhPtr->rhFrame;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    unsigned char alpha = (unsigned char)clamp(255-[rhPtr get_EventExpressionInt:pEvp], 0, 255);
    
    BOOL wasSemi = ((frame->effect & BOP_RGBAFILTER) == 0);
    frame->effect = (frame->effect & BOP_MASK) | BOP_RGBAFILTER;
    unsigned int rgbaCoeff = 0x00FFFFFF;
    
    if(!wasSemi)
        rgbaCoeff = frame->effectParam;
    
    unsigned int alphaPart = (unsigned int)alpha << 24;
    unsigned int rgbPart = (rgbaCoeff & 0x00FFFFFF);
    frame->effectParam = alphaPart | rgbPart;
}

void actSetFrameRGBCoef(event*pe, CRun* rhPtr)    // ACT_SETFRAMERGBCOEF
{
    CRunFrame* frame = rhPtr->rhFrame;

    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    unsigned int argb = (unsigned int)[rhPtr get_EventExpressionInt:pEvp];
    
    BOOL wasSemi = ((frame->effect & BOP_RGBAFILTER) == 0);
    frame->effect = (frame->effect & BOP_MASK) | BOP_RGBAFILTER;
    
    unsigned int rgbaCoeff = frame->effectParam;
    unsigned int alphaPart;
    if(wasSemi)
    {
        if(frame->effectParam == -1)
            alphaPart = 0xFF000000;
        else
            alphaPart = 255-(frame->effectParam*2 << 24);
    }
    else
        alphaPart = (rgbaCoeff & 0xFF000000);
    
    unsigned int rgbPart = swapRGB((argb & 0x00FFFFFF));
    unsigned int filter = alphaPart | rgbPart;
    frame->effectParam = filter;
}

void actSetStretchResampling(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int value = [rhPtr get_EventExpressionInt:pEvp];        // 1-based
    
    rhPtr->rhApp->hdr2Options &= ~AH2OPT_ANTIALIASED;
    if (value != 0)
        rhPtr->rhApp->hdr2Options |= AH2OPT_ANTIALIASED;
    if ( rhPtr->rhApp->renderer != nil )
    {
        if ((rhPtr->rhApp->hdr2Options & AH2OPT_ANTIALIASED) != 0)
            rhPtr->rhApp->renderer->view.layer.magnificationFilter = kCAFilterLinear;
        else
            rhPtr->rhApp->renderer->view.layer.magnificationFilter = kCAFilterNearest;
    }
}

// ------------------------------------
// ACTION: DELETE ALL CREATED BACKDROPS
// ------------------------------------
void actDelAllCreatedBkd(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int nLayer = [rhPtr get_EventExpressionInt:pEvp] - 1;        // 1-based
    
    [rhPtr deleteAllBackdrop2:nLayer];
}

// -----------------------------
// ACTION: EFFACEMENT DE L'ECRAN
// -----------------------------
void actCls(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    
    int color=(DWORD)pEvp->evp.evpL.evpL0;
    if (pEvp->evpCode!=PARAM_COLOUR)
    {
        color=[rhPtr get_EventExpressionInt:pEvp];
    }
    CBackDrawCls* back=[[CBackDrawCls alloc] init];
    back->color=color;
}

// -----------------------------
// ACTION: EFFACEMENT D'UNE ZONE
// -----------------------------
void actClearZone(event* pe, CRun* rhPtr)
{
    // ANDOS TODO
    /*
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
	int zone[4];
	LPEVP pEvp2 = GetZoneCoordinates(pEvp, rhPtr, zone);

    int color=(DWORD)pEvp2->evp.evpL.evpL0;
    if (pEvp2->evpCode!=PARAM_COLOUR)
    {
        color=[rhPtr get_EventExpressionInt:pEvp2];
    }
    CBackDrawClsZone* back=[[CBackDrawClsZone alloc] init];
    back->color=color;
	back->x1=zone[0];
	back->y1=zone[1];
	back->x2=zone[2];
	back->y2=zone[3];
    */
}

// ----------------------
// ACTION : SET FRAMERATE
// ----------------------
void actSetFrameRate(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int value=[rhPtr get_EventExpressionInt:pEvp];
    if (value>=1 && value<=1000)
    {
        [rhPtr->rhApp setFrameRate:value];
    }
}

// -----------------------------------------
// PAUSE APPLICATION AND RESUME WITH ANY KEY
// -----------------------------------------
void actPauseAnyKey(event* pe, CRun* rhPtr)
{
    rhPtr->rh4PauseKey=-1;
    rhPtr->rhQuit=LOOPEXIT_PAUSEGAME;
}

// ------------------------------
// ACTION: SAVE FRAME
// ------------------------------
void actSaveFrame(event* pe, CRun* rhPtr)
{
}

// ------------------------------
// ACTION: LOAD FRAME
// ------------------------------
void actLoadFrame(event* pe, CRun* rhPtr)
{
}

// ------------------------------
// ACTION: LOAD APPLICATION
// ------------------------------
void actLoadApplication(event* pe, CRun* rhPtr)
{
}

// -------------------------------
// PLAY DEMO
// -------------------------------
void actPlayDemo(event*pe, CRun* rhPtr)
{
}

// ----------------------------
// EXPRESSION: NUMBER OF PLAYER
// ----------------------------
void expGam_NPlayer(CRun* rhPtr)
{
    [getCurrentResult() forceInt:rhPtr->rhNPlayers];
}

// ---------------------------------------
// EXPRESSION: WIDTH / HEIGHT OF PLAYFIELD
// ---------------------------------------
void expGam_PlayWidth(CRun* rhPtr)
{
    [getCurrentResult() forceInt:rhPtr->rhFrame->leWidth];    // rhPtr->rhLevelSx); incorrect rhLevelSx est maintenant la taille virtuelle
}
void expGam_PlayHeight(CRun* rhPtr)
{
    [getCurrentResult() forceInt:rhPtr->rhFrame->leHeight];    // rhPtr->rhLevelSy);
}

// -----------------------------------------------------
// EXPRESSION: XLEFT / XRIGHT / YTOP / YBOTTOM PLAYFIELD
// -----------------------------------------------------
void expGam_PlayXLeft(CRun* rhPtr)
{
    int r=rhPtr->rhWindowX;
    if ((rhPtr->rh3Scrolling & RH3SCROLLING_SCROLL) != 0)
        r=(int)rhPtr->rh3DisplayX;
    if (r<0) r=0;
    
    [getCurrentResult() forceInt:r];
}
void expGam_PlayXRight(CRun* rhPtr)
{
    int r=rhPtr->rhWindowX;
    if ((rhPtr->rh3Scrolling & RH3SCROLLING_SCROLL) != 0)
        r=(int)rhPtr->rh3DisplayX;
    r+=rhPtr->rh3WindowSx;
    if (r>rhPtr->rhLevelSx)
        r=rhPtr->rhLevelSx;
    
    [getCurrentResult() forceInt:r];
}
void expGam_PlayYTop(CRun* rhPtr)
{
    int r=rhPtr->rhWindowY;
    if ((rhPtr->rh3Scrolling & RH3SCROLLING_SCROLL) != 0)
        r=(int)rhPtr->rh3DisplayY;
    if (r<0) r=0;
    
    [getCurrentResult() forceInt:r];
}
void expGam_PlayYBottom(CRun* rhPtr)
{
    int r=rhPtr->rhWindowY;
    if ((rhPtr->rh3Scrolling & RH3SCROLLING_SCROLL) != 0)
        r=(int)rhPtr->rh3DisplayY;
    r+=rhPtr->rh3WindowSy;
    if (r>rhPtr->rhLevelSy)
        r=rhPtr->rhLevelSy;
    
    [getCurrentResult() forceInt:r];
}




// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// GESTION OBJET CREATE
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------


// ------------------------------------------------------------
// CONDITION: Selection des objets actifs ayant une value donne
// ------------------------------------------------------------

// Old version for sprite objects only
BOOL evaChooseValue1(event* pe, CRun* rhPtr, ECVROUTINE pRoutine)
{
    int cpt=0;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    LPHO pHo=[rhPtr->rhEvtProg evt_FirstObjectFromType:OBJ_SPR];

    LPEXP pToken = (LPEXP)&pEvp->evp.evpW.evpW1;
    LPEXP pNextToken = (LPEXP)((LPBYTE)pToken+pToken->expSize);
    if ( (pToken->expCode.expLCode.expCode == EXPL_LONG || pToken->expCode.expLCode.expCode == EXPL_DOUBLE) && pNextToken->expCode.expLCode.expCode == 0 )
    {
        int value = (pToken->expCode.expLCode.expCode == EXPL_LONG) ? pToken->expu.expl.expLParam : (int)pToken->expu.expd.expDouble;
        rhPtr->rh4ExpToken=pNextToken;                    // I think it's not mandatory but just in case, as Get_EventExpressionInt does it...
        while(pHo!=nil)
        {
            cpt++;
            if (pRoutine(pHo, value)==NO)
            {
                cpt--;
                [rhPtr->rhEvtProg evt_DeleteCurrentObject];
            }
            pHo=[rhPtr->rhEvtProg evt_NextObjectFromType];
        }
    }
    else
    {
        while(pHo!=nil)
        {
            cpt++;
            int value=[rhPtr get_EventExpressionInt:pEvp];
            if (pRoutine(pHo, value)==NO)
            {
                cpt--;
                [rhPtr->rhEvtProg evt_DeleteCurrentObject];
            }
            pHo=[rhPtr->rhEvtProg evt_NextObjectFromType];
        }
    }

    // Vrai / Faux?
    if (cpt!=0) return YES;
    return NO;
}

// Nouvelle version pour tous les objets
BOOL evaChooseValue2(event* pe, CRun* rhPtr, ECVROUTINE pRoutine)
{
    int cpt=0;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    LPHO pHo=[rhPtr->rhEvtProg evt_FirstObjectFromType:-1];

    LPEXP pToken = (LPEXP)&pEvp->evp.evpW.evpW1;
    LPEXP pNextToken = (LPEXP)((LPBYTE)pToken+pToken->expSize);
    if ( (pToken->expCode.expLCode.expCode == EXPL_LONG || pToken->expCode.expLCode.expCode == EXPL_DOUBLE) && pNextToken->expCode.expLCode.expCode == 0 )
    {
        int value = (pToken->expCode.expLCode.expCode == EXPL_LONG) ? pToken->expu.expl.expLParam : (int)pToken->expu.expd.expDouble;
        rhPtr->rh4ExpToken=pNextToken;                    // I think it's not mandatory but just in case, as Get_EventExpressionInt does it...
        while(pHo!=nil)
        {
            cpt++;
            if (pRoutine(pHo, value)==FALSE)
            {
                cpt--;
                [rhPtr->rhEvtProg evt_DeleteCurrentObject];
            }
            pHo=[rhPtr->rhEvtProg evt_NextObjectFromType];
        }
    }
    else
    {
        while(pHo!=nil)
        {
            cpt++;
            int value=[rhPtr get_EventExpressionInt:pEvp];
            if (pRoutine(pHo, value)==FALSE)
            {
                cpt--;
                [rhPtr->rhEvtProg evt_DeleteCurrentObject];
            }
            pHo=[rhPtr->rhEvtProg evt_NextObjectFromType];
        }
    }

    // Vrai / Faux?
    if (cpt!=0) return YES;
    return NO;
}
BOOL pickFlagSet(LPHO pHo, int value)
{
    if (pHo->rov!=nil)
    {
        if (pHo->rov->rvValueFlags&(1<<value))
            return TRUE;
    }
    return FALSE;
}
BOOL evaChooseFlagSet_old(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaChooseValue1(pe, rhPtr, pickFlagSet);
}
BOOL evaChooseFlagSet(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaChooseValue2(pe, rhPtr, pickFlagSet);
}
BOOL pickFlagReset(LPHO pHo, int value)
{
    if (pHo->rov!=nil)
    {
        if (pHo->rov->rvValueFlags&(1<<value))
            return NO;
    }
    return YES;
}

BOOL evaChooseFlagReset_old(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaChooseValue1(pe, rhPtr, pickFlagReset);
}
BOOL evaChooseFlagReset(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaChooseValue2(pe, rhPtr, pickFlagReset);
}

// CHOOSE VALUE ancienne version, avec juste les objets actifs
BOOL evaChooseValue_old(event* pe, CRun* rhPtr, LPHO pHoIn)
{
    int cpt=0;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    
    // Boucle d'exploration
    LPHO pHo=[rhPtr->rhEvtProg evt_FirstObjectFromType:OBJ_SPR];        //!!! QUE FAIRE?
    while(pHo!=NULL)
    {
        cpt++;
        
        int number;
        if (pEvp->evpCode==PARAM_ALTVALUE_EXP)
            number=[rhPtr get_EventExpressionInt:pEvp];
        else
            number=pEvp->evp.evpW.evpW0;
        int value=[rhPtr get_EventExpressionInt:pEvp2];
        
        if (pHo->ros!=nil)
        {
            if (compareTer([[pHo->rov getValue:number] getInt], value, pEvp2->evp.evpW.evpW0)==NO)
            {
                [rhPtr->rhEvtProg evt_DeleteCurrentObject];
                cpt--;
            }
        }
        pHo=[rhPtr->rhEvtProg evt_NextObjectFromType];
    };
    // Vrai / Faux?
    if (cpt!=0) return YES;
    return NO;
}

// Nouvelle version avec tous les objets
BOOL evaChooseValue(event* pe, CRun* rhPtr, LPHO pHoIn)
{
    int cpt=0;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    LPHO pHo=[rhPtr->rhEvtProg evt_FirstObjectFromType:-1];

    LPEXP pToken2 = (LPEXP)&pEvp2->evp.evpW.evpW1;
    LPEXP pNextToken2 = (LPEXP)((LPBYTE)pToken2+pToken2->expSize);
    if ( pEvp->evpCode!=PARAM_ALTVALUE_EXP && (pToken2->expCode.expLCode.expCode == EXPL_LONG || pToken2->expCode.expLCode.expCode == EXPL_DOUBLE) && pNextToken2->expCode.expLCode.expCode == 0 )
    {
        int value = (pToken2->expCode.expLCode.expCode == EXPL_LONG) ? pToken2->expu.expl.expLParam : (int)pToken2->expu.expd.expDouble;
        while(pHo!=nil)
        {
            cpt++;
            
            int number=pEvp->evp.evpW.evpW0;
            //int value=[rhPtr get_EventExpressionInt:pEvp2];
            rhPtr->rh4ExpToken=pNextToken2;                    // I think it's not mandatory but just in case, as Get_EventExpressionInt does it...
            
            if (pHo->ros!=nil)
            {
                if (compareTer([[pHo->rov getValue:number] getInt], value, pEvp2->evp.evpW.evpW0)==NO)
                {
                    [rhPtr->rhEvtProg evt_DeleteCurrentObject];
                    cpt--;
                }
            }
            pHo=[rhPtr->rhEvtProg evt_NextObjectFromType];
        }
    }
    else
    {
        while(pHo!=nil)
        {
            cpt++;
            
            int number;
            if (pEvp->evpCode==PARAM_ALTVALUE_EXP)
                number=[rhPtr get_EventExpressionInt:pEvp];
            else
                number=pEvp->evp.evpW.evpW0;
            int value=[rhPtr get_EventExpressionInt:pEvp2];
            
            if (pHo->ros!=nil)
            {
                if (compareTer([[pHo->rov getValue:number] getInt], value, pEvp2->evp.evpW.evpW0)==NO)
                {
                    [rhPtr->rhEvtProg evt_DeleteCurrentObject];
                    cpt--;
                }
            }
            pHo=[rhPtr->rhEvtProg evt_NextObjectFromType];
        }
    }

    // Vrai / Faux?
    if (cpt!=0) return YES;
    return NO;
}

// -------------------------------------------------
// CONDITION: pick one active object from identifier *** verifier, FAUX!
// -------------------------------------------------
BOOL evaPickFromId(event* pe, CRun* rhPtr, LPHO pHoIn)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    
    int value=[rhPtr get_EventExpressionInt:pEvp];
    int number=value&0xFFFF;
    if (number>=(int)rhPtr->rhMaxObjects) return FALSE;
    LPHO pHo=rhPtr->rhObjectList[number];
    if (pHo==nil) return NO;
    
    int code=value>>16;
    if (code!=pHo->hoCreationId) return NO;
    
    // Dans une liste selectionnee ou pas?
    CObjInfo* poil=pHo->hoOiList;
    if (poil->oilEventCount==rhPtr->rhEvtProg->rh2EventCount)
    {
        short next=poil->oilListSelected;
        LPHO pHoFound=0;
        while(next>=0)
        {
            pHoFound=rhPtr->rhObjectList[next];
            if (pHo==pHoFound) break;
            next=pHoFound->hoNextSelected;
        };
        if (pHo!=pHoFound) return NO;
    }
    poil->oilEventCount=rhPtr->rhEvtProg->rh2EventCount;            // Seul sur la liste!
    poil->oilListSelected=-1;
    poil->oilNumOfSelected=0;
    pHo->hoNextSelected=-1;
    [rhPtr->rhEvtProg evt_AddCurrentObject:pHo];
    return YES;
}

// ----------------------------------
// CONDITION: total number of object=
// ----------------------------------
BOOL evaNumOfAllObjects(event* pe, CRun* rhPtr, LPHO pHo)
{
    return compareCondition(pe, rhPtr, rhPtr->rhNObjects);
}
BOOL evaNumOfAllObjects_old(event* pe, CRun* rhPtr, LPHO pHo)
{
    [rhPtr->rhEvtProg count_ObjectsFromType:OBJ_SPR withStop:-1];
    return compareCondition(pe, rhPtr, rhPtr->rhEvtProg->evtNSelectedObjects);
}

// ----------------------------------------------------
// CONDITION: selection d'un objet actif au hasard
// ----------------------------------------------------
BOOL evaChooseAll(event* pe, CRun* rhPtr, LPHO pHoIn)
{
    [rhPtr->rhEvtProg count_ObjectsFromType:0 withStop:-1];        // Trouve l'objet a choisir
    if (rhPtr->rhEvtProg->evtNSelectedObjects==0) return NO;
    int rnd=(int)[rhPtr random:(short)rhPtr->rhEvtProg->evtNSelectedObjects];
    LPHO pHo=[rhPtr->rhEvtProg count_ObjectsFromType:0 withStop:rnd];
    [rhPtr->rhEvtProg evt_DeleteCurrent];                        // Vire tout
    [rhPtr->rhEvtProg evt_AddCurrentObject:pHo];                    // Met le seul
    return YES;
}
BOOL evaChooseAll_old(event* pe, CRun* rhPtr, LPHO pHoIn)
{
    [rhPtr->rhEvtProg count_ObjectsFromType:OBJ_SPR withStop:-1];    //; Trouve l'objet a choisir
    if (rhPtr->rhEvtProg->evtNSelectedObjects==0) return NO;
    int rnd=(int)[rhPtr random:(short)rhPtr->rhEvtProg->evtNSelectedObjects];
    LPHO pHo=[rhPtr->rhEvtProg count_ObjectsFromType:OBJ_SPR withStop:rnd];
    [rhPtr->rhEvtProg evt_DeleteCurrentType:OBJ_SPR];                // Vire tout
    [rhPtr->rhEvtProg evt_AddCurrentObject:pHo];                    // Met le seul
    return YES;
}

// -------------------------------------------------------------
// CONDITION: selection d'un objet actif au hasard dans une zone
// -------------------------------------------------------------
BOOL evaChooseZone(event* pe, CRun* rhPtr, LPHO pHoIn)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
	int zone[4];
	GetZoneCoordinates(pEvp, rhPtr, zone);

    [rhPtr->rhEvtProg count_ZoneTypeObjects:zone withStop:-1 andType:0];        // Compte le objets
    if (rhPtr->rhEvtProg->evtNSelectedObjects==0) return NO;
    int rnd=(int)[rhPtr random:(short)rhPtr->rhEvtProg->evtNSelectedObjects];
    LPHO pHo=[rhPtr->rhEvtProg count_ZoneTypeObjects:zone withStop:rnd andType:0];    // Pointe le bon objet
    [rhPtr->rhEvtProg evt_DeleteCurrent];
    [rhPtr->rhEvtProg evt_AddCurrentObject:pHo];
    return YES;
}
    
BOOL evaChooseZone_old(event* pe, CRun* rhPtr, LPHO pHoIn)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
	int zone[4];
	GetZoneCoordinates(pEvp, rhPtr, zone);

    [rhPtr->rhEvtProg count_ZoneTypeObjects:zone withStop:-1 andType:OBJ_SPR];        // Compte le objets
    if (rhPtr->rhEvtProg->evtNSelectedObjects==0) return FALSE;
    int rnd=(int)[rhPtr random:(short)rhPtr->rhEvtProg->evtNSelectedObjects];
    LPHO pHo=[rhPtr->rhEvtProg count_ZoneTypeObjects:zone withStop:rnd andType:OBJ_SPR];    // Pointe le bon objet
    [rhPtr->rhEvtProg evt_DeleteCurrent];
    [rhPtr->rhEvtProg evt_AddCurrentObject:pHo];
    return YES;
}
    
// -------------------------------------------------------
// CONDITION: selection de tous les objets actifs d'une zone
// -------------------------------------------------------
BOOL evaChooseAllInZone(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
	int zone[4];
	GetZoneCoordinates(pEvp, rhPtr, zone);

    if ([rhPtr->rhEvtProg select_ZoneTypeObjects:zone withType:0]!=0) return YES;
    return NO;
}
BOOL evaChooseAllInZone_old(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
	int zone[4];
	GetZoneCoordinates(pEvp, rhPtr, zone);

    if ([rhPtr->rhEvtProg select_ZoneTypeObjects:zone withType:OBJ_SPR]!=0) return YES;
    return NO;
}

// ---------------------------------------------
// CONDITION: selection des objets sur une ligne
// ---------------------------------------------
BOOL evaChooseAllInLine(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    int x1=[rhPtr get_EventExpressionInt:pEvp];
    
    pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    int y1=[rhPtr get_EventExpressionInt:pEvp];
    
    pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    int x2=[rhPtr get_EventExpressionInt:pEvp];
    
    pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    int y2=[rhPtr get_EventExpressionInt:pEvp];
    
    if ([rhPtr->rhEvtProg select_LineOfSight:x1 withY1:y1 andX2:x2 andY2:y2]!=0)
        return YES;
    
    return NO;
}

// -------------------------------------------
// CONDITION: no more active objects in a zone
// -------------------------------------------
BOOL evaNoMoreAllZone(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
	int zone[4];
	GetZoneCoordinates(pEvp, rhPtr, zone);
    [rhPtr->rhEvtProg count_ZoneTypeObjects:zone withStop:-1 andType:0];
    if (rhPtr->rhEvtProg->evtNSelectedObjects!=0) return NO;
    return YES;
}
BOOL evaNoMoreAllZone_old(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
	int zone[4];
	GetZoneCoordinates(pEvp, rhPtr, zone);
    [rhPtr->rhEvtProg count_ZoneTypeObjects:zone withStop:-1 andType:OBJ_SPR];
    if (rhPtr->rhEvtProg->evtNSelectedObjects!=0) return NO;
    return YES;
}

// ---------------------------------------------
// CONDITION: number of object in a zone=
// ---------------------------------------------
BOOL evaNumOfAllZone(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
	int zone[4];
	LPEVP pEvp2 = GetZoneCoordinates(pEvp, rhPtr, zone);

    // Le nombre d'objets
    [rhPtr->rhEvtProg count_ZoneTypeObjects:zone withStop:-1 andType:0];
    
    // Le parametre
    int value=[rhPtr get_EventExpressionInt:pEvp2];
    
    return compareTer(rhPtr->rhEvtProg->evtNSelectedObjects, value, pEvp2->evp.evpW.evpW0);
}
BOOL evaNumOfAllZone_old(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
	int zone[4];
	LPEVP pEvp2 = GetZoneCoordinates(pEvp, rhPtr, zone);

    // Le nombre d'objets
    [rhPtr->rhEvtProg count_ZoneTypeObjects:zone withStop:-1 andType:OBJ_SPR];
    
    // Le parametre
    int value=[rhPtr get_EventExpressionInt:pEvp2];
    
    return compareTer(rhPtr->rhEvtProg->evtNSelectedObjects, value, pEvp2->evp.evpW.evpW0);
}

// -------------------------
// ACTION : CREATE OBJECT
// -------------------------
void actCreateByName(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    NSString* pName = [rhPtr get_EventExpressionString:pEvp];
    
    int x, y, dir;
    BOOL bRepeat;
    int nLayer;
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);

    // Build 283.9: if read_Position returns NO x and y are not defined, so the object was created anywhere (apparently very far)
    // => fix, the object is not created anymore in this case, like Android and Flash
    if (read_Position(rhPtr, (LPPOS)&pEvp2->evp.evpW.evpW0, 0x11, &x, &y, &dir, &bRepeat, &nLayer) == NO)
        return;
    else
    {
        if (bRepeat)
        {
            pe->evtFlags|=ACTFLAGS_REPEAT;                    // Refaire cette action
            rhPtr->rhEvtProg->rh2ActionLoop = YES;                        // Refaire un tour d'actions
        }
    }
    
    COI* oiPtr;
    for (oiPtr=[rhPtr->rhApp->OIList getFirstOI]; oiPtr!=nil; oiPtr=[rhPtr->rhApp->OIList getNextOI])
    {
        if ( oiPtr->oiType>=OBJ_SPR )
        {
            if ( [oiPtr->oiName caseInsensitiveCompare:pName] == 0)
            {
                break;
            }
        }
    }
    
    if (oiPtr != nil)
    {
        int number=[rhPtr f_CreateObject:-1 withOIHandle:oiPtr->oiHandle andX:x andY:y andDir:dir andFlags:0 andLayer:nLayer andNumCreation:-1];
        if (number>=0)
        {
            CObject* pHo=rhPtr->rhObjectList[number];
            [rhPtr->rhEvtProg evt_AddCurrentObject:pHo];

            // Build 283.2: add physics attractor
            AddPhysicsAttractor(rhPtr, pHo);

            CRunMvtPhysics* pPhysics = [rhPtr GetPhysicMovement:pHo];
            if (pPhysics != nil)
                pPhysics->CreateBody(pHo);
            else
            {
                if (rhPtr->rh4Box2DBase != nil)
                {
                    rhPtr->rh4Box2DBase->pAddNormalObject(rhPtr->rh4Box2DBase, pHo);
                }
            }
        if(nLayer != -1)
        {
            if((pHo->hoOEFlags & OEFLAG_SPRITES) != 0)
            {
                CLayer *layer = rhPtr->rhFrame->layers[nLayer];
                if((layer->dwOptions & (FLOPT_TOHIDE | FLOPT_VISIBLE)) != FLOPT_VISIBLE)
                   [pHo->ros obHide];
            }
        }

        }
    }
}

void actCreateByNameExp(event* pe, CRun* rhPtr)
{
	LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
	NSString* pName = [rhPtr get_EventExpressionString:pEvp];

	pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
	int x = [rhPtr get_EventExpressionInt:pEvp];
	pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
	int y = [rhPtr get_EventExpressionInt:pEvp];
	pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
	int nLayer = [rhPtr get_EventExpressionInt:pEvp] - 1;

    COI* oiPtr;
    for (oiPtr=[rhPtr->rhApp->OIList getFirstOI]; oiPtr!=nil; oiPtr=[rhPtr->rhApp->OIList getNextOI])
    {
    	if ( oiPtr->oiType>=OBJ_SPR )
    	{
    		if ( [oiPtr->oiName caseInsensitiveCompare:pName] == 0)
			{
				break;
			}
		}
	}
    
	if (oiPtr != nil)
	{
        int number=[rhPtr f_CreateObject:-1 withOIHandle:oiPtr->oiHandle andX:x andY:y andDir:-1 andFlags:0 andLayer:nLayer andNumCreation:-1];
		if (number>=0)
		{
			CObject* pHo=rhPtr->rhObjectList[number];
			[rhPtr->rhEvtProg evt_AddCurrentObject:pHo];

			// Build 283.2: add physics attractor
			AddPhysicsAttractor(rhPtr, pHo);

            CRunMvtPhysics* pPhysics = (CRunMvtPhysics*)[rhPtr GetPhysicMovement:pHo];
            if (pPhysics != nil)
                pPhysics->CreateBody(pHo);
            else
            {
                if (rhPtr->rh4Box2DBase != nil)
                {
                    ((LPRDATABASE)rhPtr->rh4Box2DBase)->pAddNormalObject(rhPtr->rh4Box2DBase, pHo);
                }
            }
			if(nLayer != -1)
			{
				if((pHo->hoOEFlags & OEFLAG_SPRITES) != 0)
				{
					CLayer *layer = rhPtr->rhFrame->layers[nLayer];
					if((layer->dwOptions & (FLOPT_TOHIDE | FLOPT_VISIBLE)) != FLOPT_VISIBLE)
					   [pHo->ros obHide];
				}
			}
		}
	}
}

void actCreateObject(event* pe, CRun* rhPtr)
{
    // Cherche la position de creation
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    int x, y, dir;
    BOOL bRepeat;
    int nLayer;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);

    // Build 283.9: if read_Position returns NO x and y are not defined, so the object was created anywhere (apparently very far)
    // => fix, the object is not created anymore in this case, like Android and Flash
    if (read_Position(rhPtr, (LPPOS)&pEvp->evp.evpW.evpW0, 0x11, &x, &y, &dir, &bRepeat, &nLayer) == NO)
        return;
    else
    {
        if (bRepeat)
        {
            pe->evtFlags|=ACTFLAGS_REPEAT;                    // Refaire cette action
            rhPtr->rhEvtProg->rh2ActionLoop = YES;                        // Refaire un tour d'actions
        }
        else
        {
            pe->evtFlags&=~ACTFLAGS_REPEAT;                    // Ne pas refaire cette action
        }
    }
    
    // Cree l'objet
    // ~~~~~~~~~~~~
    LPCDP pCdp=(LPCDP)&pEvp->evp.evpW.evpW0;                // Pointe le parametre
    int number=[rhPtr f_CreateObject:pCdp->cdpHFII withOIHandle:pCdp->cdpOi andX:x andY:y andDir:dir andFlags:0 andLayer:nLayer andNumCreation:-1];

    // Met l'objet dans la liste des objets selectionnes
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (number>=0)
    {
        LPHO pHo=rhPtr->rhObjectList[number];
        [rhPtr->rhEvtProg evt_AddCurrentObject:pHo];

        // Build 283.2: add physics attractor
        AddPhysicsAttractor(rhPtr, pHo);

        CRunMvtPhysics* pPhysics = [rhPtr GetPhysicMovement:pHo];
        if (pPhysics != nil)
            pPhysics->CreateBody(pHo);
        else
        {
            if (rhPtr->rh4Box2DBase != nil)
            {
                rhPtr->rh4Box2DBase->pAddNormalObject(rhPtr->rh4Box2DBase, pHo);
            }

        }
        if(nLayer != -1)
        {
            if((pHo->hoOEFlags & OEFLAG_SPRITES) != 0)
            {
                CLayer *layer = rhPtr->rhFrame->layers[nLayer];
                if((layer->dwOptions & (FLOPT_TOHIDE | FLOPT_VISIBLE)) != FLOPT_VISIBLE)
                   [pHo->ros obHide];
            }
        }
    }
}

void actCreateObjectExp(event* pe, CRun* rhPtr)
{
	// Cherche la position de creation
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
	OINUM oi = pEvp->evp.evpW.evpW1;
	if (oi < 0)
		return;
	pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
	int x = [rhPtr get_EventExpressionInt:pEvp];
	pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
	int y = [rhPtr get_EventExpressionInt:pEvp];
	pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
	int nLayer = [rhPtr get_EventExpressionInt:pEvp] - 1;

	// Cree l'objet
	// ~~~~~~~~~~~~
	int number=[rhPtr f_CreateObject:-1 withOIHandle:oi andX:x andY:y andDir:-1 andFlags:0 andLayer:nLayer andNumCreation:-1];

	// Met l'objet dans la liste des objets selectionnes
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	if (number>=0)
	{
		LPHO pHo=rhPtr->rhObjectList[number];
		[rhPtr->rhEvtProg evt_AddCurrentObject:pHo];

		// Build 283.2: add physics attractor
		AddPhysicsAttractor(rhPtr, pHo);

        CRunMvtPhysics* pPhysics = (CRunMvtPhysics*)[rhPtr GetPhysicMovement:pHo];
        if (pPhysics != nil)
            pPhysics->CreateBody(pHo);
        else
        {
            if (rhPtr->rh4Box2DBase != nil)
            {
                ((LPRDATABASE)rhPtr->rh4Box2DBase)->pAddNormalObject(rhPtr->rh4Box2DBase, pHo);
            }
        }
        if(nLayer != -1)
        {
            if((pHo->hoOEFlags & OEFLAG_SPRITES) != 0)
            {
                CLayer *layer = rhPtr->rhFrame->layers[nLayer];
                if((layer->dwOptions & (FLOPT_TOHIDE | FLOPT_VISIBLE)) != FLOPT_VISIBLE)
                   [pHo->ros obHide];
            }
        }
	}
}

// Build 283.2: add fans, treadmills and magnet to engine
void AddPhysicsAttractor(CRun* rhPtr, CObject* pObject)
{
    if (pObject->hoType>=32 &&
        (pObject->hoCommon->ocIdentifier==FANIDENTIFIER || pObject->hoCommon->ocIdentifier==TREADMILLIDENTIFIER || pObject->hoCommon->ocIdentifier==MAGNETIDENTIFIER || pObject->hoCommon->ocIdentifier==ROPEANDCHAINIDENTIFIER) )
    {
        int pOL=0;
        int nObjects;
        for (nObjects=0; nObjects<rhPtr->rhNObjects; pOL++, nObjects++)
        {
            while(rhPtr->rhObjectList[pOL]==nil) pOL++;
            CObject* pObjectBase=rhPtr->rhObjectList[pOL];
            if (pObjectBase->hoType>=32 && pObjectBase->hoCommon->ocIdentifier==BASEIDENTIFIER)
            {
                RUNDATABASE* rdPtrBase = (RUNDATABASE*)((CRunBox2DParent*)((CExtension*)pObjectBase)->ext)->m_object;
                if (pObject->hoCommon->ocIdentifier == FANIDENTIFIER)
                {
                    if ( rdPtrBase->pAddFan(rdPtrBase, pObject) )
                        break;
                }
                else if (pObject->hoCommon->ocIdentifier == TREADMILLIDENTIFIER)
                {
                    if ( rdPtrBase->pAddTreadmill(rdPtrBase, pObject) )
                        break;
                }
                else if (pObject->hoCommon->ocIdentifier == MAGNETIDENTIFIER)
                {
                    if ( rdPtrBase->pAddMagnet(rdPtrBase, pObject) )
                        break;
                }
                else if (pObject->hoCommon->ocIdentifier == ROPEANDCHAINIDENTIFIER)
                {
                    if ( rdPtrBase->pAddRope(rdPtrBase, pObject) )
                        break;
                }
            }
        }
    }
}


// -----------------------------------------
// EXPRESSION : NOMBRE TOTAL D'OBJETS
// -----------------------------------------
void expCre_NumberAll(CRun* rhPtr)
{
    [getCurrentResult() forceInt:rhPtr->rhNObjects];
}

void expCre_LastFixedValue(CRun* rhPtr)
{
    [getCurrentResult() forceInt:rhPtr->rhLastCreatedObjectFixedValue];
}

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// GESTION DE L'OBJET PLAYER
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------


// Retourne les valeurs
// --------------------
void expPla_GetScore(CRun* rhPtr)
{
    int joueur=rhPtr->rh4ExpToken->expu.expo.expOi;
    int* scores = [rhPtr->rhApp getScores];
    [getCurrentResult() forceInt:scores[joueur]];
}
void expPla_GetLives(CRun* rhPtr)
{
    int joueur=rhPtr->rh4ExpToken->expu.expo.expOi;
    int* lives = [rhPtr->rhApp getLives];
    [getCurrentResult() forceInt:lives[joueur]];
}

// Changement des scores
// ---------------------
void actPla_SetScore(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    
    int value=[rhPtr get_EventExpressionInt:pEvp];    // Expression
    int joueur=pe->evtOi;                            // Joueur
    
    int* scores = [rhPtr->rhApp getScores];
    scores[joueur]=value;                            // Change la valeur
    [rhPtr update_PlayerObjects:joueur withType:OBJ_SCORE andValue:scores[joueur]];
}

void actPla_AddScore(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    
    int value=[rhPtr get_EventExpressionInt:pEvp];        // Expression
    int joueur=pe->evtOi;                                // Joueur
    
    int* scores = [rhPtr->rhApp getScores];
    int score=scores[joueur];
    score+=value;
    scores[joueur]=score;                // Change la valeur
    
    [rhPtr update_PlayerObjects:joueur withType:OBJ_SCORE andValue:scores[joueur]];
}

void actPla_SubScore(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    
    int value=[rhPtr get_EventExpressionInt:pEvp];        // Expression
    int joueur=pe->evtOi;                                // Joueur
    
    int* scores = [rhPtr->rhApp getScores];
    int score=scores[joueur];
    score-=value;
    if (score<0)
        score=0;
    scores[joueur]=score;                // Change la valeur
    
    [rhPtr update_PlayerObjects:joueur withType:OBJ_SCORE andValue:scores[joueur]];
}

// Termine les vies, genere les evenements PLUS DE VIE
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void actPla_FinishLives(CRun* rhPtr, int joueur, int live)
{
    int* lives = [rhPtr->rhApp getLives];
    if (live==lives[joueur])
        return;
    
    // Nouvelle vie=0?
    if (live==0)
    {
        if (lives[joueur]!=0)
        {
            [rhPtr->rhEvtProg push_Event:0 withCode:CNDL_NOMORELIVE andParam:0 andObject:nil andOI:(short)joueur];
        }
    }
    
    // Change les objets...
    lives[joueur]=live;
    [rhPtr update_PlayerObjects:joueur withType:OBJ_LIVES andValue:live];
}

// Changement des vies
// -------------------
void actPla_SetLives(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    
    int value=[rhPtr get_EventExpressionInt:pEvp];        // Expression
    int joueur=pe->evtOi;                                // Joueur
    actPla_FinishLives(rhPtr, joueur, value);
}
void actPla_AddLives(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    
    int value=[rhPtr get_EventExpressionInt:pEvp];        // Expression
    int joueur=pe->evtOi;                                // Joueur
    
    int* lives = [rhPtr->rhApp getLives];
    int live=lives[joueur];
    live+=value;
    actPla_FinishLives(rhPtr, joueur, live);
}
void actPla_SubLives(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    
    int value=[rhPtr get_EventExpressionInt:pEvp];        // Expression
    int joueur=pe->evtOi;                                // Joueur
    
    int* lives = [rhPtr->rhApp getLives];
    int live=lives[joueur];
    live-=value;
    if (live<0) live=0;
    actPla_FinishLives(rhPtr, joueur, live);
}


void actPla_SetPlayerName(event* pe, CRun* rhPtr)
{
    LPEVP pEvp = (LPEVP)((LPBYTE)pe+ACT_SIZE);
    NSString* pString = [rhPtr get_EventExpressionStringNoCopy:pEvp];
    
    int joueur = pe->evtOi;
    if ( joueur >= MAX_PLAYER )
        return;
    if ( pString == nil )
        return;
    rhPtr->rhApp->playerNames[joueur]=[[NSString alloc] initWithString:pString];
}

void expPla_GetPlayerName(CRun* rhPtr)
{
    int joueur = rhPtr->rh4ExpToken->expu.expo.expOi;
    [getCurrentResult() forceString:rhPtr->rhApp->playerNames[joueur]];
}

// ---------------------------------------------------------
// CONDITION: comparaison au score
// ---------------------------------------------------------
BOOL evaScores(event* pe, CRun* rhPtr, LPHO pHo)
{
    int joueur=pe->evtOi;
    int* scores = [rhPtr->rhApp getScores];
    int score=scores[joueur];
    return compareCondition(pe, rhPtr, score);
}
// ---------------------------------------------------------
// CONDITION: comparaison au nomber de vies
// ---------------------------------------------------------
BOOL evaLives(event* pe, CRun* rhPtr, LPHO pHo)
{
    int joueur=pe->evtOi;
    int* lives = [rhPtr->rhApp getLives];
    int live=lives[joueur];
    return compareCondition(pe, rhPtr, live);
}
// ---------------------------------------------------------
// CONDITION: plus de vies
// ---------------------------------------------------------
BOOL evaNoMoreLive(event* pe, CRun* rhPtr, LPHO pHo)
{
    int joueur=pe->evtOi;
    int* lives = [rhPtr->rhApp getLives];
    int live=lives[joueur];
    
    if (live!=0)
        return NO;
    return YES;
}

// ---------------------------------------------------------
// CONDITION: joystick pressed
// ---------------------------------------------------------
BOOL eva1JoyPressed(event* pe, CRun* rhPtr, LPHO pHo)
{
    int joueur=pe->evtOi;                        //; Le numero du player
    if (joueur!=rhPtr->rhEvtProg->rhCurOi) return NO;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    short j=(short)rhPtr->rhEvtProg->rhCurParam[0];
    j&=pEvp->evp.evpW.evpW0;
    if (j!=pEvp->evp.evpW.evpW0) return NO;
    return YES;
}
BOOL eva2JoyPressed(event* pe, CRun* rhPtr, LPHO pHo)
{
    BYTE b=rhPtr->rh2NewPlayer&rhPtr->rhPlayer;
    
    short s=(short)b;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    s&=pEvp->evp.evpW.evpW0;
    if (pEvp->evp.evpW.evpW0!=s) return NO;
    return YES;
}

// ---------------------------------------------------------
// CONDITION: joystick pushed
// ---------------------------------------------------------
BOOL evaJoyPushed(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    short s=(short)rhPtr->rhPlayer;
    s&=pEvp->evp.evpW.evpW0;
    if (s!=pEvp->evp.evpW.evpW0) return negaFALSE(pe);
    return negaTRUE(pe);
}

// -------------------
// ACTION: NO INPUT
// -------------------
void actNoInput(event* pe, CRun* rhPtr)
{
    rhPtr->rh2InputMask=0;                                        // Plus d'entree
}

// -------------------
// ACTION: RESTORE INPUT
// -------------------
void actRestoreInput(event* pe, CRun* rhPtr)
{
    rhPtr->rh2InputMask=0xFF;                                        // Plus d'entree
}




// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// Table d'appel de l'objet SYSTEME
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------

void expSys_Rien(CRun* rhPtr)
{
    [getCurrentResult() forceInt:0];
}

// ---------------------------------------------------------------------------
// CONDITION ON LOOP
// ---------------------------------------------------------------------------
BOOL evaOnLoop(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    LPEXP pToken=(LPEXP)&pEvp->evp.evpW.evpW1;

    NSString* pName;
    if (pToken->expCode.expSCode.expType==-1 && pToken->expCode.expSCode.expNum==3 && ((LPEXP)((LPBYTE)pToken+pToken->expSize))->expCode.expLCode.expCode==0)
        pName=(NSString*)[rhPtr->rhEvtProg->allocatedStrings get:pToken->expu.expw.expWParam0];
    else
        pName=[rhPtr get_EventExpressionStringNoCopy:pEvp];
    if (pName==nil)
        return NO;
    
    if ([rhPtr->rh4CurrentFastLoop caseInsensitiveCompare:pName]!=0)
        return NO;
    rhPtr->rhEvtProg->rh2ActionOn=0;
    return YES;
}

// ---------------------------------------------------------------------------
// ACTION STARTLOOP
// ---------------------------------------------------------------------------
void actStartLoop(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    NSString* pName = nil;
    
    if (rhPtr->rh4ComplexOnLoop == 0 && rhPtr->rh4PosOnLoop != nil)
    {
        CCArrayList* rh4PosOnLoop = (CCArrayList*)rhPtr->rh4PosOnLoop;
        int loopNumber = pEvp->evp.evpW.evpW0;
        if (loopNumber == 0)
        {
            pName = [rhPtr get_EventExpressionString:pEvp];
            if (pName != nil)
            {
                for (int nOnLoop = 0; nOnLoop < rh4PosOnLoop->Size(); nOnLoop++)
                {
                    CPosOnLoop* posOnLoop = (CPosOnLoop*)rh4PosOnLoop->Get(nOnLoop);
                    if ([pName caseInsensitiveCompare:posOnLoop->m_name] == 0)
                    {
                        loopNumber = nOnLoop + 1;
                        break;
                    }
                }
            }
        }
        
        if (loopNumber != 0)
        {
            LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
            int number=[rhPtr get_EventExpressionInt:pEvp2];
            if (number == 0)
                return;
            
            CPosOnLoop* posOnLoop = (CPosOnLoop*)rhPtr->rh4PosOnLoop->Get(loopNumber - 1);
            if (posOnLoop->m_bOR == NO)
            {
                CLoop* pLoop;
                int loopindex = posOnLoop->m_fastLoopIndex;
                if ( loopindex != -1 )
                    pLoop = (CLoop*)[rhPtr->rh4FastLoops get:loopindex];
                else
                    pLoop = [rhPtr addFastLoop:posOnLoop->m_name withIndexPtr:&loopindex];
                if ( pLoop == nil )
                    return;
                BOOL bInfinite;
                
                pLoop->flags&=~FLFLAG_STOP;
                
                bInfinite=NO;
                if (number<0)
                {
                    bInfinite=YES;
                    number=10;
                }
                NSString* save=rhPtr->rh4CurrentFastLoop;
                BOOL actionLoop=rhPtr->rhEvtProg->rh2ActionLoop;                // Flag boucle
                int actionLoopCount=rhPtr->rhEvtProg->rh2ActionLoopCount;        // Numero de boucle d'actions
                LPEVG eventGroup=rhPtr->rhEvtProg->rhEventGroup;
                int baseTempValues=rhPtr->rhBaseTempValues;
                rhPtr->rhBaseTempValues=rhPtr->rhCurTempValue;
                for (pLoop->index=0; pLoop->index<number; pLoop->index++)
                {
                    rhPtr->rh4CurrentFastLoop=pLoop->name;
                    rhPtr->rhEvtProg->rh2ActionOn=0;
                    [rhPtr->rhEvtProg computeEventFastLoopList:posOnLoop->m_deltas];
                    if (pLoop->flags&FLFLAG_STOP)
                        break;
                    if (bInfinite)
                        number=pLoop->index+10;
                    pLoop = (CLoop*)[rhPtr->rh4FastLoops get:loopindex];
                }
                rhPtr->rhBaseTempValues=baseTempValues;
                rhPtr->rhEvtProg->rhEventGroup=eventGroup;
                rhPtr->rhEvtProg->rh2ActionLoopCount=actionLoopCount;            // Numero de boucle d'actions
                rhPtr->rhEvtProg->rh2ActionLoop=actionLoop;                    // Flag boucle
                rhPtr->rh4CurrentFastLoop=save;
                rhPtr->rhEvtProg->rh2ActionOn=1;
                return;
            }
        }
    }
    
    if (pName==nil)
        pName=[rhPtr get_EventExpressionString:pEvp];
    if (pName==nil)
        return;
    
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    int number=[rhPtr get_EventExpressionInt:pEvp2];
    
    //No loop is needed to run (also fixes crash)
    if(number==0)
        return;
    
    CLoop* pLoop = [rhPtr addFastLoop:pName withIndexPtr:NULL];
    BOOL bInfinite;
    
    pLoop->flags&=~FLFLAG_STOP;
    
    bInfinite=NO;
    if (number<0)
    {
        bInfinite=YES;
        number=10;
    }
    NSString* save=rhPtr->rh4CurrentFastLoop;
    BOOL actionLoop=rhPtr->rhEvtProg->rh2ActionLoop;                // Flag boucle
    int actionLoopCount=rhPtr->rhEvtProg->rh2ActionLoopCount;        // Numero de boucle d'actions
    LPEVG eventGroup=rhPtr->rhEvtProg->rhEventGroup;
    int baseTempValues=rhPtr->rhBaseTempValues;
    rhPtr->rhBaseTempValues=rhPtr->rhCurTempValue;
    for (pLoop->index=0; pLoop->index<number; pLoop->index++)
    {
        rhPtr->rh4CurrentFastLoop=pLoop->name;
        rhPtr->rhEvtProg->rh2ActionOn=0;
        [rhPtr->rhEvtProg handle_GlobalEvents:CNDL_ONLOOP];
        if (pLoop->flags&FLFLAG_STOP)
            break;
        if (bInfinite)
            number=pLoop->index+10;
    }
    rhPtr->rhBaseTempValues=baseTempValues;
    rhPtr->rhEvtProg->rhEventGroup=eventGroup;
    rhPtr->rhEvtProg->rh2ActionLoopCount=actionLoopCount;            // Numero de boucle d'actions
    rhPtr->rhEvtProg->rh2ActionLoop=actionLoop;                    // Flag boucle
    rhPtr->rh4CurrentFastLoop=save;
    rhPtr->rhEvtProg->rh2ActionOn=1;
}

// ---------------------------------------------------------------------------
// ACTION SETLOOPINDEX
// ---------------------------------------------------------------------------
void actSetLoopIndex(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEXP pToken = (LPEXP)&pEvp->evp.evpW.evpW1;
    if ( pToken->expCode.expSCode.expType == -1 && pToken->expCode.expSCode.expNum == 0 && ((LPEXP)((LPBYTE)pToken+pToken->expSize))->expCode.expLCode.expCode == 0 )
    {
        int fastLoopIndex = pToken->expu.expl.expLParam;
        
        LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
        int number=[rhPtr get_EventExpressionInt:pEvp2];
        
        CLoop* pLoop=(CLoop*)[rhPtr->rh4FastLoops get:fastLoopIndex];
        pLoop->index=number;
    }
    else
    {
        NSString* pName=[rhPtr get_EventExpressionStringNoCopy:pEvp];
    
        LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
        int number=[rhPtr get_EventExpressionInt:pEvp2];
    
        CLoop* pLoop;
        int index;
        for (index=0; index<[rhPtr->rh4FastLoops size]; index++)
        {
            pLoop=(CLoop*)[rhPtr->rh4FastLoops get:index];
            if ([pLoop->name caseInsensitiveCompare:pName]==0)
            {
                pLoop->index=number;
                break;
            }
        }
    }
}

// ---------------------------------------------------------------------------
// ACTION STOP LOOP
// ---------------------------------------------------------------------------
void actStopLoop(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEXP pToken = (LPEXP)&pEvp->evp.evpW.evpW1;
    if ( pToken->expCode.expSCode.expType == -1 && pToken->expCode.expSCode.expNum == 0 && ((LPEXP)((LPBYTE)pToken+pToken->expSize))->expCode.expLCode.expCode == 0 )
    {
        int fastLoopIndex = pToken->expu.expl.expLParam;
        
        CLoop* pLoop=(CLoop*)[rhPtr->rh4FastLoops get:fastLoopIndex];
        pLoop->flags|=FLFLAG_STOP;
    }
    else
    {
        NSString* pName=[rhPtr get_EventExpressionStringNoCopy:pEvp];
    
        CLoop* pLoop;
        int index;
        for (index=0; index<[rhPtr->rh4FastLoops size]; index++)
        {
            pLoop=(CLoop*)[rhPtr->rh4FastLoops get:index];
            if ([pLoop->name caseInsensitiveCompare:pName]==0)
            {
                pLoop->flags|=FLFLAG_STOP;
                break;
            }
        }
    }
}

// ---------------------------------------------------------------------------
// ACTION : RANDOMIZE
// ---------------------------------------------------------------------------
void ActRandomize(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    rhPtr->rh3Graine=(short)[rhPtr get_EventExpressionInt:pEvp];
}

// ---------------------------------------------------------------------------
// EXPRESSION LOOPINDEX
// ---------------------------------------------------------------------------
void expSys_LoopIndex(CRun* rhPtr)
{
    LPEXP pExpressionToken = rhPtr->rh4ExpToken;
    nextToken();
    CLoop* pLoop;
    int index;
    
    LPEXP pToken = rhPtr->rh4ExpToken;
    LPEXP pNextToken = (LPEXP)((LPBYTE)pToken+pToken->expSize);
    NSString* pName=[rhPtr get_ExpressionStringNoCopy];

    if (  pToken->expCode.expLCode.expCode == EXPL_STRING && (pNextToken->expCode.expLCode.expCode <= OPERATOR_START || pNextToken->expCode.expLCode.expCode >= OPERATOR_END) )
    {
        for (index=0; index<[rhPtr->rh4FastLoops size]; index++)
        {
            pLoop=(CLoop*)[rhPtr->rh4FastLoops get:index];
            if ([pLoop->name caseInsensitiveCompare:pName]==0)
            {
                pExpressionToken->expCode.expLCode.expCode = EXPL_LOOPINDEXBYINDEX;
                pToken->expu.expl.expLParam = index;
                [getCurrentResult() forceInt:pLoop->index];
                return;
            }
        }
    }

    for (index=0; index<[rhPtr->rh4FastLoops size]; index++)
    {
        pLoop=(CLoop*)[rhPtr->rh4FastLoops get:index];
        if ([pLoop->name caseInsensitiveCompare:pName]==0)
        {
            [getCurrentResult() forceInt:pLoop->index];
            return;
        }
    }
    [getCurrentResult() forceInt:0];
}

void expSys_LoopIndexByIndex(CRun* rhPtr)
{
    rhPtr->rh4ExpToken = (LPEXP)((LPBYTE)rhPtr->rh4ExpToken+rhPtr->rh4ExpToken->expSize);   // nextToken();
    int index = rhPtr->rh4ExpToken->expu.expl.expLParam;
    rhPtr->rh4ExpToken = (LPEXP)((LPBYTE)rhPtr->rh4ExpToken+rhPtr->rh4ExpToken->expSize);   // nextToken();
    CLoop* pLoop=(CLoop*)[rhPtr->rh4FastLoops get:index];
    [getCurrentResult() forceInt:pLoop->index];
}

// ---------------------------------------------------------------------------
// CONDITION : once
// ---------------------------------------------------------------------------
BOOL evaOnce(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVG pEvg=rhPtr->rhEvtProg->rhEventGroup;
    if (pEvg->evgFlags&EVGFLAGS_ONCE) return NO;                    // Deja evalue?
    pEvg->evgFlags|=EVGFLAGS_ONCE;                                    //; Marque pour le prochain!
    return YES;
}

// ---------------------------------------------------------------------------
// CONDITION : not always
// ---------------------------------------------------------------------------
BOOL evaNotAlways(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVG pEvg=rhPtr->rhEvtProg->rhEventGroup;
    if (pEvg->evgFlags&EVGFLAGS_NOTALWAYS) return YES;                // Deja evalue?
    if (pEvg->evgFlags&EVGFLAGS_NOMORE) return NO;                //; Verification, valide?
    pEvg->evgInhibit=-2;                                            // Premier coup!
    pEvg->evgFlags|=EVGFLAGS_NOTALWAYS;
    return YES;
}

// ---------------------------------------------------------------------------
// CONDITION : repeat XXX times
// ---------------------------------------------------------------------------
BOOL evaRepeat(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVG pEvg=rhPtr->rhEvtProg->rhEventGroup;
    if (pEvg->evgFlags&EVGFLAGS_REPEAT)
        return YES;                //; Deja evalue?
    if (pEvg->evgFlags&EVGFLAGS_NOMORE)
        return NO;                //; Verification, valide?
    
    // Va evaluer l'expression
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    pEvg->evgInhibitCpt=[rhPtr get_EventExpressionInt:pEvp];        //; Repeat valide!
    pEvg->evgFlags|=EVGFLAGS_REPEAT;
    return YES;
}

// ---------------------------------------------------------------------------
// CONDITION : no more than every XXX
// ---------------------------------------------------------------------------
BOOL evaNoMore(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVG pEvg=rhPtr->rhEvtProg->rhEventGroup;
    if (pEvg->evgFlags&EVGFLAGS_NOMORE)
    {
        LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
        if (pEvp->evpCode==PARAM_EXPRESSION)
            pEvg->evgInhibit=[rhPtr get_EventExpressionInt:pEvp]/10;
        return YES;
    }
    if (pEvg->evgFlags&(EVGFLAGS_REPEAT|EVGFLAGS_NOTALWAYS)) return NO;    //; Verification, valide?
    
    // Va evaluer l'expression
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    if (pEvp->evpCode==PARAM_EXPRESSION)
        pEvg->evgInhibit=[rhPtr get_EventExpressionInt:pEvp]/10;
    else
        pEvg->evgInhibit=pEvp->evp.evpL.evpL0/10;
    pEvg->evgInhibitCpt=0;                                            // Init du compteur
    pEvg->evgFlags|=EVGFLAGS_NOMORE;                                // NOMORE valide!
    return YES;
}

// ---------------------------------------------------------------------------
// CONDITION : comparaison generale
// ---------------------------------------------------------------------------
BOOL evaCompare(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    [rhPtr->evaTmp forceValue:[rhPtr get_EventExpressionAnyNoCopy:pp]];
    
    pp=(LPEVP)((LPBYTE)pp+pp->evpSize);
    int comp=pp->evp.evpW.evpW0;
    CValue* pValue2=[rhPtr get_EventExpressionAnyNoCopy:pp];
    
    return compareTo(rhPtr->evaTmp, pValue2, comp);
}

// ---------------------------------------------------------------------------
// CONDITION : comparaison ‡ une variable globale
// ---------------------------------------------------------------------------

BOOL evaCompareGlobalIntEQ(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+CND_SIZE);
    int var = pp->evp.evpW.evpW0;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:var];
    return [gValue equalInt:((LPEXP)&pp->evp.evpW.evpW1)->expu.expl.expLParam];
}
BOOL evaCompareGlobalDblEQ(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+CND_SIZE);
    int var = pp->evp.evpW.evpW0;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:var];
    return [gValue equalDouble:((LPEXP)&pp->evp.evpW.evpW1)->expu.expd.expDouble];
}
BOOL evaCompareGlobalIntNE(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+CND_SIZE);
    int var = pp->evp.evpW.evpW0;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:var];
    return [gValue notEqualInt:((LPEXP)&pp->evp.evpW.evpW1)->expu.expl.expLParam];
}
BOOL evaCompareGlobalDblNE(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+CND_SIZE);
    int var = pp->evp.evpW.evpW0;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:var];
    return [gValue notEqualDouble:((LPEXP)&pp->evp.evpW.evpW1)->expu.expd.expDouble];
}
BOOL evaCompareGlobalIntLE(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+CND_SIZE);
    int var = pp->evp.evpW.evpW0;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:var];
    return [gValue lowerInt:((LPEXP)&pp->evp.evpW.evpW1)->expu.expl.expLParam];
}
BOOL evaCompareGlobalDblLE(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+CND_SIZE);
    int var = pp->evp.evpW.evpW0;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:var];
    return [gValue lowerDouble:((LPEXP)&pp->evp.evpW.evpW1)->expu.expd.expDouble];
}
BOOL evaCompareGlobalIntLT(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+CND_SIZE);
    int var = pp->evp.evpW.evpW0;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:var];
    return [gValue lowerThanInt:((LPEXP)&pp->evp.evpW.evpW1)->expu.expl.expLParam];
}
BOOL evaCompareGlobalDblLT(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+CND_SIZE);
    int var = pp->evp.evpW.evpW0;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:var];
    return [gValue lowerThanDouble:((LPEXP)&pp->evp.evpW.evpW1)->expu.expd.expDouble];
}
BOOL evaCompareGlobalIntGE(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+CND_SIZE);
    int var = pp->evp.evpW.evpW0;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:var];
    return [gValue greaterInt:((LPEXP)&pp->evp.evpW.evpW1)->expu.expl.expLParam];
}
BOOL evaCompareGlobalDblGE(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+CND_SIZE);
    int var = pp->evp.evpW.evpW0;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:var];
    return [gValue greaterDouble:((LPEXP)&pp->evp.evpW.evpW1)->expu.expd.expDouble];
}
BOOL evaCompareGlobalIntGT(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+CND_SIZE);
    int var = pp->evp.evpW.evpW0;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:var];
    return [gValue greaterThanInt:((LPEXP)&pp->evp.evpW.evpW1)->expu.expl.expLParam];
}
BOOL evaCompareGlobalDblGT(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+CND_SIZE);
    int var = pp->evp.evpW.evpW0;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:var];
    return [gValue greaterThanDouble:((LPEXP)&pp->evp.evpW.evpW1)->expu.expd.expDouble];
}

BOOL evaCompareGlobal(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    int var;
    if (pp->evpCode==PARAM_VARGLOBAL_EXP)
        var=[rhPtr get_EventExpressionInt:pp]-1;
    else
        var=pp->evp.evpW.evpW0;
    
    CValue* pGValue = [rhPtr->rhApp getGlobalValueAt:var];
    //[rhPtr->evaTmp forceValue:pGValue];

    pp=(LPEVP)((LPBYTE)pp+pp->evpSize);
    int comp=pp->evp.evpW.evpW0;
    CValue* pValue2=[rhPtr get_EventExpressionAnyNoCopy:pp];
    
    return compareTo(pGValue, pValue2, comp);        // rhPtr->evaTmp
}

// ---------------------------------------------------------------------------
// CONDITION : comparaison ‡ une chaine globale
// ---------------------------------------------------------------------------
BOOL evaCompareGlobalString(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    int var;
    if (pp->evpCode==PARAM_VARGLOBAL_EXP)
        var=[rhPtr get_EventExpressionInt:pp]-1;
    else
        var=pp->evp.evpW.evpW0;
    
    NSString* pString = [rhPtr->rhApp getGlobalStringAt:var];
    
    //Make "fake" cvalue that doesn't have it's own string (one less allocation optimization)
    CValue* evaTmp = rhPtr->evaTmp;
    NSString* oldString = evaTmp->stringValue;
    short oldType = evaTmp->type;
    evaTmp->stringValue = pString;
    evaTmp->type = TYPE_STRING;
    
    pp=(LPEVP)((LPBYTE)pp+pp->evpSize);
    int comp=pp->evp.evpW.evpW0;
    CValue* pValue2=[rhPtr get_EventExpressionAnyNoCopy:pp];
    
    BOOL ret = compareTo(rhPtr->evaTmp, pValue2, comp);
    
    //Restore the old cvalue
    evaTmp->stringValue = oldString;
    evaTmp->type = oldType;
    
    return ret;
}

// ---------------------------------------------------------------------------
// CONDITION : Running as
// ---------------------------------------------------------------------------
BOOL evaRunningAs(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+CND_SIZE);
    int var;
    if (pp->evpCode == PARAM_RUNTIME)
        var = pp->evp.evpW.evpW0;
    else
        var = [rhPtr get_EventExpressionInt:pp];
    if (var == RUNTIME_IOS)
        return negaTRUE(pe);
    return negaFALSE(pe);
}

// ---------------------------------------------------------------------------
// ACTION : set global value
// ---------------------------------------------------------------------------
CValue* getGlobal(event* pe, CRun* rhPtr, int* num)
{
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    
    if (pp->evpCode==PARAM_VARGLOBAL_EXP || pp->evpCode==PARAM_STRINGGLOBAL_EXP)    // modif Yves build 242, ajout PARAM_STRINGGLOBAL_EXP
        *num=[rhPtr get_EventExpressionInt:pp]-1;
    else
        *num=pp->evp.evpW.evpW0;
    
    pp=(LPEVP)((LPBYTE)pp+pp->evpSize);
    
    // = return Get_EventExpressionAny
    rhPtr->rh4ExpToken=(LPEXP)&pp->evp.evpW.evpW1;
    return [rhPtr getExpression];
}

// Set global value to simple value
void actSetGlobalInt(event* pe, CRun* rhPtr)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+ACT_SIZE);
    int num = pp->evp.evpW.evpW0;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:num];
    [gValue forceInt:((LPEXP)&pp->evp.evpW.evpW1)->expu.expl.expLParam];
}
void actSetGlobalDbl(event* pe, CRun* rhPtr)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+ACT_SIZE);
    int num = pp->evp.evpW.evpW0;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:num];
    [gValue forceDouble:((LPEXP)&pp->evp.evpW.evpW1)->expu.expd.expDouble];
}

// Set global value (by index) to simple value
void actSetGlobalIntNumExp(event* pe, CRun* rhPtr)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+ACT_SIZE);
    int num = [rhPtr get_EventExpressionInt:pp]-1;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:num];
    [gValue forceInt:((LPEXP)&pp->evp.evpW.evpW1)->expu.expl.expLParam];
}
void actSetGlobalDblNumExp(event* pe, CRun* rhPtr)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+ACT_SIZE);
    int num = [rhPtr get_EventExpressionInt:pp]-1;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:num];
    [gValue forceDouble:((LPEXP)&pp->evp.evpW.evpW1)->expu.expd.expDouble];
}

// Set global value to any value
void actSetGlobal(event* pe, CRun* rhPtr)
{
    int num;
    CValue* pValue=getGlobal(pe, rhPtr, &num);
    [rhPtr->rhApp setGlobalValueAt:num value:pValue];
}
void actSetGlobalString(event* pe, CRun* rhPtr)
{
    int num;
    CValue* pValue=getGlobal(pe, rhPtr, &num);
    [rhPtr->rhApp setGlobalStringAt:num string:[pValue getString]];
}

// Add simple value to global value
void actAddGlobalInt(event* pe, CRun* rhPtr)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+ACT_SIZE);
    int num = pp->evp.evpW.evpW0;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:num];
    [gValue addInt:((LPEXP)&pp->evp.evpW.evpW1)->expu.expl.expLParam];
}
void actAddGlobalDbl(event* pe, CRun* rhPtr)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+ACT_SIZE);
    int num = pp->evp.evpW.evpW0;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:num];
    [gValue addDouble:((LPEXP)&pp->evp.evpW.evpW1)->expu.expd.expDouble];
}
void actAddGlobalIntNumExp(event* pe, CRun* rhPtr)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+ACT_SIZE);
    int num = [rhPtr get_EventExpressionInt:pp]-1;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:num];
    [gValue addInt:((LPEXP)&pp->evp.evpW.evpW1)->expu.expl.expLParam];
}
void actAddGlobalDblNumExp(event* pe, CRun* rhPtr)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+ACT_SIZE);
    int num = [rhPtr get_EventExpressionInt:pp]-1;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:num];
    [gValue addDouble:((LPEXP)&pp->evp.evpW.evpW1)->expu.expd.expDouble];
}

// Add any value to global value
void actAddGlobal(event* pe, CRun* rhPtr)
{
    int num;
    CValue* pValue2=getGlobal(pe, rhPtr, &num);
    
    CValue* pValue1 = [rhPtr->rhApp getGlobalValueAt:num];    // Retourne le pointeur sur la global value
    [pValue1 add:pValue2];                                // Addition directe
}

// Subtract simple value from global value
void actSubGlobalInt(event* pe, CRun* rhPtr)
{
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int num = pp->evp.evpW.evpW0;
    pp=(LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:num];
    [gValue subInt:((LPEXP)&pp->evp.evpW.evpW1)->expu.expl.expLParam];
}
void actSubGlobalDbl(event* pe, CRun* rhPtr)
{
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int num = pp->evp.evpW.evpW0;
    pp=(LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:num];
    [gValue subDouble:((LPEXP)&pp->evp.evpW.evpW1)->expu.expd.expDouble];
}
void actSubGlobalIntNumExp(event* pe, CRun* rhPtr)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+ACT_SIZE);
    int num = [rhPtr get_EventExpressionInt:pp]-1;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:num];
    [gValue subInt:((LPEXP)&pp->evp.evpW.evpW1)->expu.expl.expLParam];
}
void actSubGlobalDblNumExp(event* pe, CRun* rhPtr)
{
    LPEVP pp = (LPEVP)((LPBYTE)pe+ACT_SIZE);
    int num = [rhPtr get_EventExpressionInt:pp]-1;
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* gValue = [rhPtr->rhApp getGlobalValueAt:num];
    [gValue subDouble:((LPEXP)&pp->evp.evpW.evpW1)->expu.expd.expDouble];
}

// Add any value from global value
void actSubGlobal(event* pe, CRun* rhPtr)
{
    int num;
    CValue* pValue2=getGlobal(pe, rhPtr, &num);
    
    CValue* pValue1 = [rhPtr->rhApp getGlobalValueAt:num];
    
    [pValue1 sub:pValue2];
}

// ---------------------------------------------------------------------------
// OPERANDE : get global value
// ---------------------------------------------------------------------------
void expSys_GlobalValue(CRun* rhPtr)
{
    nextToken();                        // Saute le token
    
    int num=[rhPtr get_ExpressionInt]-1;
    
    CValue *pValue = [rhPtr->rhApp getGlobalValueAt:num];
    [getCurrentResult() forceValue:pValue];
}
void expSys_GlobalValueNamed(CRun* rhPtr)
{
    int num=rhPtr->rh4ExpToken->expu.expv.expNum;    // &15; YVES: enlevÈ
    
    CValue* pValue = [rhPtr->rhApp getGlobalValueAt:num];
    [getCurrentResult() forceValue:pValue];
}

// ---------------------------------------------------------------------------
// OPERANDE : get global string
// ---------------------------------------------------------------------------
void expSys_GlobalString(CRun* rhPtr)
{
    nextToken();                        // Saute le token
    
    int num=[rhPtr get_ExpressionInt]-1;
    
     NSString* pString = [rhPtr->rhApp getGlobalStringAt:num];
    [getCurrentResult() forceString:pString];
}
void expSys_GlobalStringNamed(CRun* rhPtr)
{
    int num=rhPtr->rh4ExpToken->expu.expv.expNum;    // &15; YVES: enlevÈ
    
    NSString* pString = [rhPtr->rhApp getGlobalStringAt:num];
    [getCurrentResult() forceString:pString];
}

// ---------------------------------------------------------------------------
// OPERANDE : String Regex
// ---------------------------------------------------------------------------
/*
void expSys_StringRegex(CRun* rhPtr)
{
    nextToken();                        // Saute le token
    NSString* pSourceString = [rhPtr get_ExpressionString];
    nextToken();                        // Saute le token
    NSString* pPatternString = [rhPtr get_ExpressionString];
    nextToken();                        // Saute le token
    NSString* pReplaceString = [rhPtr get_ExpressionString];

    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pPatternString options:NSRegularExpressionSearch error:&error];
    NSString *pModifiedString = pSourceString;
    if(error == nil)
    {
        pModifiedString = [regex stringByReplacingMatchesInString:pSourceString options:0 range:NSMakeRange(0, [pSourceString length]) withTemplate:pReplaceString];
    }
    [getCurrentResult() forceString:pModifiedString];
}
*/

// ---------------------------------------------------------------------------
// OPERANDE : String Replace
// ---------------------------------------------------------------------------
void expSys_StringReplace(CRun* rhPtr)
{
    nextToken();                        // Saute le token
    NSString* pSourceString = [rhPtr get_ExpressionString];
    nextToken();                        // Saute le token
    NSString* pFindString = [rhPtr get_ExpressionString];
    nextToken();                        // Saute le token
    NSString* pReplaceString = [rhPtr get_ExpressionString];

    pSourceString  = [pSourceString  stringByReplacingOccurrencesOfString:pFindString withString:pReplaceString];
    [getCurrentResult() forceString:pSourceString];
}

// ---------------------------------------------------------------------------
// ACTION : activate / desactivate group of events
// ---------------------------------------------------------------------------
LPEVG InactGroup(LPEVG evgPtr)
{
    int cpt=0;
    BOOL bQuit=NO;
    LPEVT evtPtr;
    
    while(TRUE)
    {
        evgPtr->evgFlags|=EVGFLAGS_INACTIVE;
        
        evtPtr=EVGFIRSTEVT(evgPtr);
        switch (evtPtr->evtCode.evtLCode.evtCode)
        {
            case CNDL_GROUP:
                cpt++;
                break;
            case CNDL_ENDGROUP:
                cpt--;
                if (cpt==0)
                    bQuit=YES;
                break;
        }
        if (bQuit)
            break;
        
        evgPtr=EVGNEXT(evgPtr);
    }
    return evgPtr;
}
LPEVG ActGroup(LPEVG evgPtr)
{
    int cpt=0;
    BOOL bQuit=NO;
    LPEVT evtPtr;
    
    while(TRUE)
    {
        evgPtr->evgFlags&=~EVGFLAGS_INACTIVE;
        
        evtPtr=EVGFIRSTEVT(evgPtr);
        switch (evtPtr->evtCode.evtLCode.evtCode)
        {
            case CNDL_GROUP:
                cpt++;
                break;
            case CNDL_ENDGROUP:
                cpt--;
                if (cpt==0)
                    bQuit=YES;
                break;
        }
        if (bQuit)
            break;
        
        evgPtr=EVGNEXT(evgPtr);
    }
    return evgPtr;
}

LPEVG GrpActivate(LPEVG evgPtr)
{
    LPEVT evtPtr=EVGFIRSTEVT(evgPtr);
    LPGRP grpPtr=(LPGRP)&EVTPARAMS(evtPtr)->evp.evpW.evpW0;
    int cpt;
    BOOL bQuit;
    
    if ((grpPtr->grpFlags&GRPFLAGS_PARENTINACTIVE)==0)
    {
        evgPtr->evgFlags&=~EVGFLAGS_INACTIVE;
        
        for (evgPtr=EVGNEXT(evgPtr), bQuit=NO, cpt=1; ;)
        {
            evtPtr=EVGFIRSTEVT(evgPtr);
            switch (evtPtr->evtCode.evtLCode.evtCode)
            {
                case CNDL_GROUP:
                    grpPtr=(LPGRP)&EVTPARAMS(evtPtr)->evp.evpW.evpW0;
                    if (cpt==1)
                    {
                        grpPtr->grpFlags&=~GRPFLAGS_PARENTINACTIVE;
                    }
                    if ((grpPtr->grpFlags&GRPFLAGS_GROUPINACTIVE)==0)
                    {
                        evgPtr=GrpActivate(evgPtr);
                        continue;
                    }
                    else
                    {
                        cpt++;
                    }
                    break;
                case CNDL_ENDGROUP:
                    cpt--;
                    if (cpt==0)
                    {
                        evgPtr->evgFlags&=~EVGFLAGS_INACTIVE;
                        bQuit=YES;
                        evgPtr=EVGNEXT(evgPtr);
                    }
                    break;
                case CNDL_GROUPSTART:
                    if (cpt==1)
                    {
                        evgPtr->evgFlags&=~EVGFLAGS_INACTIVE;
                        evgPtr->evgFlags&=~EVGFLAGS_ONCE;
                    }
                    break;
                case CNDL_ENDCHILDEVENT:
                    evgPtr->evgFlags |= EVGFLAGS_INACTIVE;
                    break;
                default:
                    if (cpt==1)
                    {
                        evgPtr->evgFlags&=~EVGFLAGS_INACTIVE;
                    }
                    break;
            }
            if (bQuit)
                break;
            
            evgPtr=EVGNEXT(evgPtr);
        }
    }
    else
    {
        // Saute le groupe et les sous-groupes
        for (evgPtr=EVGNEXT(evgPtr), bQuit=NO, cpt=1; ;evgPtr=EVGNEXT(evgPtr))
        {
            evtPtr=EVGFIRSTEVT(evgPtr);
            switch (evtPtr->evtCode.evtLCode.evtCode)
            {
                case CNDL_GROUP:
                    cpt++;
                    break;
                case CNDL_ENDGROUP:
                    cpt--;
                    if (cpt==0)
                    {
                        bQuit=YES;
                        evgPtr=EVGNEXT(evgPtr);
                    }
                    break;
                case CNDL_ENDCHILDEVENT:
                    evgPtr->evgFlags |= EVGFLAGS_INACTIVE;
                    break;
            }
            if (bQuit)
                break;
        }
    }
    return evgPtr;
}
void actGrpActivate(event* pe, CRun* rhPtr)
{
    LPEVP evpPtr=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVG evgPtr=(LPEVG)((LPBYTE)evpPtr+evpPtr->evp.evpL.evpL0);
    LPEVT evtPtr=EVGFIRSTEVT(evgPtr);
    
    LPGRP grpPtr=(LPGRP)&EVTPARAMS(evtPtr)->evp.evpW.evpW0;
    BOOL bFlag=(grpPtr->grpFlags&GRPFLAGS_GROUPINACTIVE)!=0;
    grpPtr->grpFlags&=~GRPFLAGS_GROUPINACTIVE;
    
    if (bFlag)
    {
        GrpActivate(evgPtr);
    }
}

LPEVG GrpDeactivate(LPEVG evgPtr)
{
    LPEVT evtPtr=EVGFIRSTEVT(evgPtr);
    LPGRP grpPtr=(LPGRP)&EVTPARAMS(evtPtr)->evp.evpW.evpW0;
    
    evgPtr->evgFlags|=EVGFLAGS_INACTIVE;
    
    int cpt;
    BOOL bQuit, bFlag;
    
    for (evgPtr=EVGNEXT(evgPtr), bQuit=NO, cpt=1; ;)
    {
        evtPtr=EVGFIRSTEVT(evgPtr);
        switch (evtPtr->evtCode.evtLCode.evtCode)
        {
            case CNDL_GROUP:
                grpPtr=(LPGRP)&EVTPARAMS(evtPtr)->evp.evpW.evpW0;
                bFlag=(grpPtr->grpFlags&GRPFLAGS_PARENTINACTIVE)==0;
                if (cpt==1)
                {
                    grpPtr->grpFlags|=GRPFLAGS_PARENTINACTIVE;
                }
                if (bFlag!=0 && (grpPtr->grpFlags&GRPFLAGS_GROUPINACTIVE)==0)
                {
                    evgPtr=GrpDeactivate(evgPtr);
                    continue;
                }
                else
                {
                    cpt++;
                }
                break;
            case CNDL_ENDGROUP:
                cpt--;
                if (cpt==0)
                {
                    evgPtr->evgFlags|=EVGFLAGS_INACTIVE;
                    bQuit=YES;
                    evgPtr=EVGNEXT(evgPtr);
                }
                break;
            default:
                if (cpt==1)
                {
                    evgPtr->evgFlags|=EVGFLAGS_INACTIVE;
                }
                break;
        }
        if (bQuit)
            break;
        
        evgPtr=EVGNEXT(evgPtr);
    }
    return evgPtr;
}
void actGrpDesactivate(event* pe, CRun* rhPtr)
{
    LPEVP evpPtr=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVG evgPtr=(LPEVG)((LPBYTE)evpPtr+evpPtr->evp.evpL.evpL0);
    LPEVT evtPtr=EVGFIRSTEVT(evgPtr);
    
    LPGRP grpPtr=(LPGRP)&EVTPARAMS(evtPtr)->evp.evpW.evpW0;
    BOOL bFlag=(grpPtr->grpFlags&GRPFLAGS_GROUPINACTIVE)==0;
    grpPtr->grpFlags|=GRPFLAGS_GROUPINACTIVE;
    
    if (bFlag==YES && (grpPtr->grpFlags&GRPFLAGS_PARENTINACTIVE)==0)
    {
        GrpDeactivate(evgPtr);
    }
}

// ---------------------------------------------------------------------------
// CONDITION : un groupe est-il active?
// ---------------------------------------------------------------------------
BOOL evaGrpActivated(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    LPEVG pEvg=(LPEVG)((LPBYTE)pEvp+pEvp->evp.evpL.evpL0);
    if (pEvg->evgFlags&EVGFLAGS_INACTIVE)
        return negaFALSE(pe);
    return negaTRUE(pe);
}

// ---------------------------------------------------------------------------
// CONDITION : On group start
// ---------------------------------------------------------------------------
BOOL evaOnGroupStart(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVG pEvg=rhPtr->rhEvtProg->rhEventGroup;
    if (pEvg->evgFlags&EVGFLAGS_ONCE)
        return negaFALSE(pe);                    // Deja evalue?
    pEvg->evgFlags|=EVGFLAGS_ONCE;                                    //; Marque pour le prochain!
    return negaTRUE(pe);
}

// ---------------------------------------------------------------------------
// CONDITION : X chances our of Y
// ---------------------------------------------------------------------------
BOOL evaChance(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    int param1=[rhPtr get_EventExpressionInt:pEvp];
    pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    int param2=[rhPtr get_EventExpressionInt:pEvp];
    if (param1 >= param2)
        return YES;
    if (param2>=1 && param1>0 && param1<=param2)
    {
        int rnd=(int)[rhPtr random:(short)param2];
        if (rnd<param1)
        {
            return YES;
        }
    }
    return NO;
}

// ---------------------------------------------------------------------------
// ACTION: extract binary file to temp file
// ---------------------------------------------------------------------------
void actExtractBinFile(event* pe, CRun* rhPtr)
{
/*    LPEVP pEvp = (LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPSTR pString = Get_EventExpressionString(pEvp);
    
    LPSTR pTempPath = (LPSTR)malloc(_MAX_PATH);
    GetFile(pString, pTempPath, 0);
    free(pTempPath);
*/
}
// ---------------------------------------------------------------------------
// ACTION: release binary temp file
// ---------------------------------------------------------------------------
void actReleaseBinFile(event* pe, CRun* rhPtr)
{
/*
    LPEVP pEvp = (LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPSTR pString = Get_EventExpressionString(pEvp);
    ReleaseFile(pString);
*/
}

// Child events
void actExecuteChildEvents(event* pe, CRun* rhPtr)
{
    rhPtr->rhChildEventToExecute = pe;
}

// First condition in a child event
BOOL evaStartChildEvent(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp = (LPEVP)((LPBYTE)pe+CND_SIZE);
    childEventParam* pParam = (childEventParam*)&pEvp->evp.evpW.evpW0;
    
    // Restore object selection
    if ( pParam->objList[0] != -1 )
    {
        std::vector<saveSelection> selectedObjects = rhPtr->rhChildEventSelectionStack.at(rhPtr->rhChildEventSelectionStack.size()-1);
        [rhPtr->rhEvtProg evt_RestoreSelectedObjects:pParam->objList withObjects:selectedObjects];
    }
    
    return TRUE;
}



// ---------------------------------------------------------------------------
// OPERANDE: une chaine
// ---------------------------------------------------------------------------
void expSys_String(CRun* rhPtr)
{
    [getCurrentResult() releaseString];
/*
    if (rhPtr->rhApp->bUnicode==NO)
    {
        size_t l=strlen((char*)&rhPtr->rh4ExpToken->expu.expw.expWParam0);
        getCurrentResult()->stringValue=[[NSString alloc] initWithBytes:&rhPtr->rh4ExpToken->expu.expw.expWParam0 length:l encoding:NSWindowsCP1252StringEncoding];
    }
    else
    {
        int l=0;
        unichar* ptr;
        for (ptr=(unichar*)&rhPtr->rh4ExpToken->expu.expw.expWParam0; *ptr!=0; ptr++)
        {
            l++;
        }
        
        //Possible to pre-create the NSString at frame load-time to skip this step?
        NSString* retnsstring = [[NSString alloc] initWithCharacters:(unichar*)&rhPtr->rh4ExpToken->expu.expw.expWParam0 length:l];
        getCurrentResult()->stringValue=retnsstring;
    }
*/
    getCurrentResult()->stringValue=(NSString*)[rhPtr->rhEvtProg->allocatedStrings get:rhPtr->rh4ExpToken->expu.expw.expWParam0];
    [getCurrentResult()->stringValue retain];
    getCurrentResult()->type=TYPE_STRING;
}

// ---------------------------------------------------------------------------
// OPERANDE : long
// ---------------------------------------------------------------------------
void expSys_Long(CRun* rhPtr)
{
    [getCurrentResult() forceInt:rhPtr->rh4ExpToken->expu.expl.expLParam];
}

// ---------------------------------------------------------------------------
// OPERANDE : random(x)
// ---------------------------------------------------------------------------
void expSys_Random(CRun* rhPtr)
{
    nextToken();                                // Saute le token
    short num=(short)[rhPtr get_ExpressionInt];            // Le parametre
    [getCurrentResult() forceInt:[rhPtr random:num]];    // Genere le chiffre
}

// ---------------------------------------------------------------------------
// Object replacement functions
// ---------------------------------------------------------------------------
void expSys_Zero(CRun* rhPtr)
{
    [getCurrentResult() forceInt:0];
}
void expSys_Empty(CRun* rhPtr)
{
    [getCurrentResult() forceString:@""];
}
                 

// ---------------------------------------------------------------------------
// OPERANDE: =VAL(x)
// ---------------------------------------------------------------------------
void funcVal(NSString* pString, CValue* pValue)
{
    unichar c;
    double fract, ent, val;
    int dw = 0;
    int nString=0;
    NSUInteger strLength = [pString length];
    
    if (strLength==0)
    {
        [pValue forceInt:0];
        return;
    }
    while([pString characterAtIndex:nString]==32 && nString < (strLength -1))
    {
        nString++;
    }
    c=[pString characterAtIndex:nString];
    if (c=='-' || (c>='0' && c<='9'))
    {
        BOOL    expFlag=NO;
        BOOL    floatFlag=NO;
        
        // Hexa ou binaire?
        if (c=='0' && [pString length]>2)
        {
            c=[pString characterAtIndex:nString+1];
            if (c=='x' || c=='X')
            {
                dw=0;
                nString+=2;

                while(nString<[pString length])
                {
                    c=[pString characterAtIndex:nString++];
                    if (c>='0' && c<='9')
                        dw=dw*16+c-'0';
                    else if (c>='A' && c<='F')
                        dw=dw*16+c-'A'+10;
                    else if (c>='a' && c<='f')
                        dw=dw*16+c-'a'+10;
                    else
                        break;
                }
                [pValue forceInt:dw];
                return;
            }
            else if (c=='b' || c=='B')
            {
                NSUInteger binaryLength = [pString length];
                dw=0;
                for(int i=2; i<binaryLength; ++i)
                {
                    c=[pString characterAtIndex:i];
                    if (c=='1')
                        dw=dw*2+1;
                    else if (c=='0')
                        dw=dw*2;
                    else
                        break;
                }
                [pValue forceInt:dw];
                return;
            }
        }
        
        // Float ou int : trouve la fin du chiffre, indique si c'est un float
        if (c=='-') nString++;
        do
        {
            if (nString>=[pString length])
            {
                break;
            }
            
            c=[pString characterAtIndex:nString++];
            
            if (c>='0' && c<='9') continue;
            
            if (c=='.')
            {
                floatFlag=YES;
                continue;
            }
            
            if (c=='E' || c=='e' || c=='D' || c=='d')
            {
                if (expFlag==NO)
                {
                    expFlag=YES;
                    floatFlag=YES;
                    continue;
                }
            }
            if (c=='+' || c=='-')
            {
                if (expFlag) continue;
            }
            break;
            
        } while(YES);
        
        // Converti en double...
        NSString* pString2=[pString substringToIndex:nString];
        val=[pString2 doubleValue];
        
        // Regarde on ne peut pas faire un long?
        if (floatFlag==NO)
        {
            fract=modf(val, &ent);
            if (fract==0.0)
            {
                if (ent>=-2147483646.0 && ent<=2147483646.0)
                {
                    [pValue forceInt:(int)ent];
                    return;
                }
            }
        }
        [pValue forceDouble:val];
        return;
    }
    [pValue forceInt:0];
    return;
}
void expSys_Val(CRun* rhPtr)
{
    nextToken();
    
    NSString* pString=[rhPtr get_ExpressionStringNoCopy];
    funcVal(pString, getCurrentResult());
}

// =NEWLINE$()
void expSys_NewLine(CRun* rhPtr)
{
    [getCurrentResult() forceString:szNewLine];
}

// ---------------------------------------------------------------------------
// OPERANDE: =STR$(x)
// ---------------------------------------------------------------------------
void expSys_Str(CRun* rhPtr)
{
    NSString* buffer;
    
    nextToken();
    CValue* pValue=[rhPtr getExpression];
    switch([pValue getType])
    {
        default:
        case TYPE_INT:
            buffer=[NSString stringWithFormat:@"%i", [pValue getInt]];
            break;
        case TYPE_DOUBLE:
            buffer=[NSString stringWithFormat:@"%g", [pValue getDouble]];
            break;
    }
    [getCurrentResult() forceString:buffer];
}


// ---------------------------------------------------------------------------
// FONCTIONS FLOAT
// ---------------------------------------------------------------------------
void expSys_SIN(CRun* rhPtr)
{
    nextToken();
    double value=[rhPtr get_ExpressionDouble];
    
    // Build 247
    if ( value == 180.0 )
        [getCurrentResult() forceDouble:0.0];        // otherwise the result is slightly different from 0 (e-16...)
    else
    {
        double temp=sin( value/57.295779513082320876798154814105 );
        [getCurrentResult() forceDouble:temp];
    }
}
void expSys_COS(CRun* rhPtr)
{
    nextToken();
    double value=[rhPtr get_ExpressionDouble];
    
    // Build 247
    if ( value == 90.0 || value == 270.0 )
        [getCurrentResult() forceDouble:0.0];        // otherwise the result is slightly different from 0 (e-16...)
    else
    {
        double temp=cos( value/57.295779513082320876798154814105 );
        [getCurrentResult() forceDouble:temp];
    }
}
void expSys_TAN(CRun* rhPtr)
{
    nextToken();
    double value=[rhPtr get_ExpressionDouble];
    double temp=tan( value/57.295779513082320876798154814105 );
    [getCurrentResult() forceDouble:temp];
}
void expSys_CEIL(CRun* rhPtr)
{
    nextToken();
    double value=[rhPtr get_ExpressionDouble];
    [getCurrentResult() forceDouble:ceil(value)];
}
void expSys_ABS(CRun* rhPtr)
{
    nextToken();
    double value=[rhPtr get_ExpressionDouble];
    if (value<0) value=-value;
    [getCurrentResult() forceDouble:value];
}
void expSys_FLOOR(CRun* rhPtr)
{
    nextToken();
    double value=[rhPtr get_ExpressionDouble];
    [getCurrentResult() forceDouble:floor(value)];
}
void expSys_ASIN(CRun* rhPtr)
{
    nextToken();
    double value=[rhPtr get_ExpressionDouble];
    double temp=asin(value)*57.295779513082320876798154814105;
    [getCurrentResult() forceDouble:temp];
}
void expSys_ACOS(CRun* rhPtr)
{
    nextToken();
    double value=[rhPtr get_ExpressionDouble];
    double temp=acos(value)*57.295779513082320876798154814105;
    [getCurrentResult() forceDouble:temp];
}
void expSys_ATAN(CRun* rhPtr)
{
    nextToken();
    double value=[rhPtr get_ExpressionDouble];
    double temp=atan(value)*57.295779513082320876798154814105;
    [getCurrentResult() forceDouble:temp];
}
void expSys_ATAN2(CRun* rhPtr)
{
    nextToken();
    double y=[rhPtr get_ExpressionDouble];
    nextToken();
    double x=[rhPtr get_ExpressionDouble];
    double temp=atan2(y,x)*57.295779513082320876798154814105;
    [getCurrentResult() forceDouble:temp];
}
void expSys_NOT(CRun* rhPtr)
{
    nextToken();
    int value=[rhPtr get_ExpressionInt];
    [getCurrentResult() forceInt:(value^0xFFFFFFFF)];
}
void expSys_SQR(CRun* rhPtr)
{
    nextToken();
    double value=[rhPtr get_ExpressionDouble];
    [getCurrentResult() forceDouble:sqrt(value)];
}
void expSys_LOG(CRun* rhPtr)
{
    nextToken();
    double value=[rhPtr get_ExpressionDouble];
    [getCurrentResult() forceDouble:log10(value)];
}
void expSys_LN(CRun* rhPtr)
{
    nextToken();
    double value=[rhPtr get_ExpressionDouble];
    [getCurrentResult() forceDouble:log(value)];
}
void expSys_EXP(CRun* rhPtr)
{
    nextToken();
    double value=[rhPtr get_ExpressionDouble];
    [getCurrentResult() forceDouble:exp(value)];
}
void expSys_INT(CRun* rhPtr)
{
    nextToken();
    double value=[rhPtr get_ExpressionDouble];
    [getCurrentResult() forceInt:(int)value];
}
void expSys_Round(CRun* rhPtr)
{
    nextToken();
    double value=[rhPtr get_ExpressionDouble];
    double toto;
    int ret=(int)value;
    double f=modf(value, &toto);
    if (f<-0.5) ret--;
    if (f>=0.5) ret++;
    [getCurrentResult() forceInt:ret];
}
void expSys_Min(CRun* rhPtr)
{
    double d1, d2;
    int l1, l2;
    
    nextToken();
    CValue* value=[rhPtr get_ExpressionAny];
    if ( [value getType] == TYPE_DOUBLE )
    {
        d1 = [value getDouble];
        nextToken();
        value = [rhPtr getExpression];
        d2 = [value getDouble];
        [getCurrentResult() forceDouble:mind(d1, d2)];
    }
    else
    {
        l1 = [value getInt];
        nextToken();
        value = [rhPtr getExpression];
        if ( [value getType] == TYPE_DOUBLE )
        {
            d1 = l1;
            d2 = [value getDouble];
            [getCurrentResult() forceDouble:mind(d1, d2)];
        }
        else
        {
            l2 = [value getInt];
            [getCurrentResult() forceInt:MIN(l1, l2)];
        }
    }
}
void expSys_Max(CRun* rhPtr)
{
    double d1, d2;
    int l1, l2;
    
    nextToken();
    CValue* value=[rhPtr get_ExpressionAny];
    if ( [value getType] == TYPE_DOUBLE )
    {
        d1 = [value getDouble];
        nextToken();
        value = [rhPtr getExpression];
        d2 = [value getDouble];
        [getCurrentResult() forceDouble:maxd(d1, d2)];
    }
    else
    {
        l1 = [value getInt];
        nextToken();
        value = [rhPtr getExpression];
        if ( [value getType] == TYPE_DOUBLE )
        {
            d1 = l1;
            d2 = [value getDouble];
            [getCurrentResult() forceDouble:maxd(d1, d2)];
        }
        else
        {
            l2 = [value getInt];
            [getCurrentResult() forceInt:MAX(l1, l2)];
        }
    }
}
void expSys_GetRGB(CRun* rhPtr)
{
    nextToken();
    int r=[rhPtr get_ExpressionInt];
    nextToken();
    int g=[rhPtr get_ExpressionInt];
    nextToken();
    int b=[rhPtr get_ExpressionInt];
    
    int rgb=((b&255)*65536) + ((g&255)*256) + (r&255);
    [getCurrentResult() forceInt:rgb];
}
void expSys_GetRed(CRun* rhPtr)
{
    nextToken();
    int rgb=[rhPtr get_ExpressionInt];
    [getCurrentResult() forceInt:(rgb&255)];
}
void expSys_GetGreen(CRun* rhPtr)
{
    nextToken();
    int rgb=[rhPtr get_ExpressionInt];
    [getCurrentResult() forceInt:(rgb>>8)&255];
}
void expSys_GetBlue(CRun* rhPtr)
{
    nextToken();
    int rgb=[rhPtr get_ExpressionInt];
    [getCurrentResult() forceInt:(rgb>>16)&255];
}

// ---------------------------------------------------------------------------
// FONCTIONS STRING
// ---------------------------------------------------------------------------
void expSys_LEN(CRun* rhPtr)
{
    nextToken();
    NSString* pString=[rhPtr get_ExpressionStringNoCopy];
    [getCurrentResult() forceInt:(int)[pString length]];
}
void expSys_HEX(CRun* rhPtr)
{
    nextToken();
    int a=[rhPtr get_ExpressionInt];
    [getCurrentResult() releaseString];
    getCurrentResult()->stringValue=[[NSString alloc] initWithFormat:@"0x%lX", (unsigned long)a];
    getCurrentResult()->type=TYPE_STRING;
}
void expSys_BIN(CRun* rhPtr)
{
    nextToken();
    int a=[rhPtr get_ExpressionInt];
    
    NSMutableString* buffer=[[NSMutableString alloc] initWithString:@"0b"];

    for(int cp = a; cp > 0; cp >>= 1)
        [buffer insertString:((cp & 1) ? @"1" : @"0") atIndex:2];
    [getCurrentResult() forceString:buffer];
    [buffer release];
}

void expSys_LEFT(CRun* rhPtr)
{
    nextToken();
    NSString* string=[rhPtr get_ExpressionString];
    nextToken();
    int pos=[rhPtr get_ExpressionInt];
    
    int l = (int)[string length];
    if (pos>l) pos=l;
    if (pos<=0)
    {
        [getCurrentResult() forceString:@""];
        return;
    }
    string=[string substringToIndex:pos];
    [getCurrentResult() forceString:string];
}

void expSys_RIGHT(CRun* rhPtr)
{
    nextToken();
    NSString*  string=[rhPtr get_ExpressionString];
    nextToken();
    int pos=[rhPtr get_ExpressionInt];
    
    int len = (int)[string length];
    if (pos<=0)
    {
        [getCurrentResult() forceString:@""];
        return;
    }
    if (pos>=len) pos=len;
    string=[string substringFromIndex:len-pos];
    [getCurrentResult() forceString:string];
}

void expSys_MID(CRun* rhPtr)
{
    nextToken();
    NSString* string=[rhPtr get_ExpressionString];
    nextToken();
    int start=[rhPtr get_ExpressionInt];
    nextToken();
    int len=[rhPtr get_ExpressionInt];
    
    int l = (int)[string length];
    if (start<0) start=0;
    if (start+len>l) len=l-start;
    if (len<=0)
    {
        [getCurrentResult() forceString:@""];
        return;
    }
    NSRange range;
    range.location=start;
    range.length=len;
    string=[string substringWithRange:range];
    [getCurrentResult() forceString:string];
}

void expSys_DOUBLE(CRun* rhPtr)
{
    double tempDouble;
    memcpy(&tempDouble, &rhPtr->rh4ExpToken->expu.expd.expDouble, sizeof(double));
    [getCurrentResult() forceDouble:tempDouble];
}

void expSys_Lower(CRun* rhPtr)
{
    nextToken();
    NSString* pString=[rhPtr get_ExpressionString];
    pString=[pString lowercaseString];
    [getCurrentResult() forceString:pString];
}

void expSys_Upper(CRun* rhPtr)
{
    nextToken();
    NSString* pString=[rhPtr get_ExpressionString];
    pString=[pString uppercaseString];
    [getCurrentResult() forceString:pString];
}

void expSys_FloatStr(CRun* rhPtr)
{
    nextToken();
    double v = [rhPtr get_ExpressionDouble];
    nextToken();
    int nDigits = [rhPtr get_ExpressionInt];
    nextToken();
    int nDecimals = [rhPtr get_ExpressionInt];
    /*
     NSString* s;
     
     BOOL bRemoveTrailingZeros=NO;
     if (v>-1.0 & v<1.0)
     {
     nDecimals=nDigits;
     bRemoveTrailingZeros=YES;
     }
     
     NSString* formatFlags = @"";
     NSString* formatWidth = @"";
     NSString* formatPrecision = @"";
     NSString* formatType = @"g";
     
     if ((flags&CPTDISPFLAG_FLOAT_PADD)!=0)
     {
     formatFlags = @"0";
     if(nDecimals > 0)
     ++nDigits;
     formatWidth = [NSString stringWithFormat:@"%i", nDigits];
     }
     
     if (nDecimals>=0)
     {
     formatPrecision = [NSString stringWithFormat:@".%i", nDecimals];
     formatType = @"f";
     }
     
     NSString* format = [NSString stringWithFormat:@"%%%@%@%@%@", formatFlags, formatWidth, formatPrecision, formatType];
     s=[[NSString alloc] initWithFormat:format, v];
     */
    NSString *s = @"";
    s = [s stringByAppendingString:(v >= 0 ? @"" : @"-")];
    v = std::abs(v);
    if (nDecimals == 0) {
        s = [s stringByAppendingString:[NSString stringWithFormat:@"%ld" ,(long)v]];
    }
    else if (nDecimals > 0) {
        s = [s stringByAppendingString:[NSString stringWithFormat:@"%ld" ,(long)v]];
        long frac = round((v - (long)v) * pow(10 , nDecimals));
        s = [s stringByAppendingString:@"."];
        NSString * f = [[@"%0" stringByAppendingString:[NSString stringWithFormat:@"%d" ,nDecimals]] stringByAppendingString:@"ld"];
        s = [s stringByAppendingString:[NSString stringWithFormat:f ,frac]];
    }
    else if (nDecimals == -1) {
        NSString * adouble;
        if(v < 0.1)
            adouble = [NSString stringWithFormat:@"%.22e" ,v];
        else
            adouble = [NSString stringWithFormat:@"%.22f" ,v];
        
        NSString * DecNotation = @"";
        NSString * NotScientific = @"";
        int ExpNotation = 0;
        int ExpCnt = 0;
        double new_double=0.0;
        
        if ([adouble rangeOfString:@"e"].location != NSNotFound) {
            NSRange fRange = NSMakeRange(0, [adouble rangeOfString:@"e"].location);
            DecNotation = [adouble substringWithRange:fRange];
            ExpNotation += [[adouble substringFromIndex:[adouble rangeOfString:@"e"].location + 1] integerValue];
            new_double = [DecNotation doubleValue];
            
            while (new_double > 1.0) {
                new_double /= 10.0;
                ExpCnt++;
            }
            
        }
        else {
            DecNotation = adouble;
            new_double = [DecNotation doubleValue];
            
            while (new_double > 1.0) {
                new_double /= 10.0;
                ExpCnt++;
            }
            
        }
        if (ExpCnt > 0) {
            ExpNotation += (ExpCnt - 1);
            ExpCnt = 1;
        }
        if (nDigits < ExpNotation + ExpCnt || v < 1.0) {
            if (nDigits >= 0) {
                double num = (double)round(new_double * pow(10 , nDigits));
                double frac = num/ pow(10 , nDigits - ExpCnt);
                if (frac - (long)frac > 0)
                {
                    int exp = MAX(nDigits-ExpCnt , 1);
                    NSString * f = [[@"%." stringByAppendingString:[NSString stringWithFormat:@"%d" ,exp]] stringByAppendingString:@"f"];
                    s = [s stringByAppendingString:[NSString stringWithFormat:f ,frac]];
                }
                else if (frac > 0)
                    s = [s stringByAppendingString:[NSString stringWithFormat:@"%ld" ,(long)frac]];
                else if(ExpNotation == 0)
                    s = [s stringByAppendingString:@"0"];
            }
            if (ExpNotation != 0) {
                NotScientific = [NSString stringWithFormat:@"e%c%03d" , (ExpNotation >= 0 ? '+' : '-') , abs(ExpNotation)];
                s = [s stringByAppendingString:NotScientific];
            }
        }
        else if (nDigits == ExpNotation + ExpCnt) {
            long dn = (long)(round(new_double * pow(10 , nDigits)) / pow(10, nDigits - ExpCnt) * pow(10 , nDigits - ExpCnt));
            s = [s stringByAppendingString:[NSString stringWithFormat: @"%ld", dn]];
        }
        else {
            s = [s stringByAppendingString:[NSString stringWithFormat: @"%ld", (long)v]];
            if (nDigits - ExpNotation > 0) {
                long frac = round((v - (long)v) * pow(10 , nDigits - ExpNotation - ExpCnt));
                if (frac > 0) {
                    s = [s stringByAppendingString:@"."];
                    s = [s stringByAppendingString:[NSString stringWithFormat: @"%ld", frac]];
                }
            }
        }
    }
    else if(nDecimals < -1)
    {
        s = [s stringByAppendingString:[NSString stringWithFormat:@"%ld" ,(long)round(v * pow(10 , nDecimals))]];
    }
    
    [getCurrentResult() forceString:s];
}
void expSys_Find(CRun* rhPtr)
{
    nextToken();
    NSString* pMainString=[rhPtr get_ExpressionString];
    nextToken();
    NSString* pSubString=[rhPtr get_ExpressionString];
    nextToken();
    int firstChar=[rhPtr get_ExpressionInt];
    
    if (firstChar>=[pMainString length])
    {
        [getCurrentResult() forceInt:-1];
        return;
    }
    
    NSRange rangeSearch;
    rangeSearch.location=firstChar;
    rangeSearch.length=[pMainString length]-firstChar;
    NSRange found=[pMainString rangeOfString:pSubString options:0 range:rangeSearch];
    if (found.location==NSNotFound)
    {
        [getCurrentResult() forceInt:-1];
    }
    else
    {
        [getCurrentResult() forceInt:(int)found.location];
    }
}

void expSys_FindReverse(CRun* rhPtr)
{
    nextToken();
    NSString* pMainString=[rhPtr get_ExpressionString];
    nextToken();
    NSString* pSubString=[rhPtr get_ExpressionString];
    nextToken();
    
    int firstChar=[rhPtr get_ExpressionInt];
    if (firstChar>[pMainString length])
    {
        firstChar=(int)[pMainString length];
    }
    
    int oldPos;
    int pos=-1;
    NSRange rangeSearch;
    NSRange found;
    while(YES)
    {
        oldPos=pos;
        rangeSearch.location=pos+1;
        rangeSearch.length=[pMainString length]-pos-1;
        found=[pMainString rangeOfString:pSubString options:0 range:rangeSearch];
        if (found.location==NSNotFound)
        {
            break;
        }
        pos=(int)found.location;
        if (pos>firstChar)
            break;
    }
    [getCurrentResult() forceInt:oldPos];
}

void expSys_RuntimeName(CRun* rhPtr)
{
    [getCurrentResult() forceString:@"iOS"];
}

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// OBJECT TEXTE
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------

// -------------------------
// ACTION : DISPLAY TEXT
// -------------------------

// PROCEDURE D'AFFICHAGE DE UN TEXTE DONT AUQUEL C'EST ALORS
short txtDisplay(event* pe, CRun* rhPtr, short oi, int txtNumber)
{
    // Cherche la position de creation
    int x, y, dir;
    BOOL bRepeat;
    CText* pText;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);                //; Pointe le parametre
    if (read_Position(rhPtr, (LPPOS)&pEvp->evp.evpW.evpW0, 0x10, &x, &y, &dir, &bRepeat, nil))
    {
        // Regarde si le meme text n'existe pas deja
        int no;
        int count=0;
        for (no=0; no<rhPtr->rhNObjects; no++)
        {
            while(rhPtr->rhObjectList[count]==nil) count++;
            LPHO pHo=rhPtr->rhObjectList[count];
            count++;
            
            if (pHo->hoType==OBJ_TEXT && pHo->hoOi==oi && [pHo getX]==x && [pHo getY]==y)
            {
                // Le texte existe deja a la meme position, SECURITE, on fait un SET TEXT
                [pHo->ros obShow];                                // On le montre!
                pHo->hoFlags&=~HOF_NOCOLLISION;                //; Des collisions de nouveau
                pText=(CText*)pHo;
                pText->rsMini=-2;                                // Force la copie
                [pText txtChange:txtNumber];
                pHo->roc->rcChanged=YES;
                [pHo modif];
                pHo->ros->rsFlash=0;                            //; Arrete le flash!
                pHo->ros->rsFlags|=RSFLAG_VISIBLE;
                return pHo->hoNumber;
            }
        }
        // Cree l'objet
        int num=[rhPtr f_CreateObject:-1 withOIHandle:oi andX:x andY:y andDir:0 andFlags:0 andLayer:rhPtr->rhFrame->nLayers-1 andNumCreation:-1];
        if (num>=0)
        {
            pText=(CText*)rhPtr->rhObjectList[num];
            [pText txtChange:txtNumber];
            return num;
        }
    }
    return -1;
}

// APPEL DE LA CREATION DE TOUS LES TEXTE
short txtDoDisplay(event* pe, CRun* rhPtr, int txtNumber)
{
    if (pe->evtOiList>=0)
    {
        return txtDisplay(pe, rhPtr, pe->evtOi, txtNumber);
    }
    
    // Un qualifier: on explore les listes
    if (pe->evtOiList==-1) return -1;
    int qoi=pe->evtOiList&0x7FFF;
    CQualToOiList* qoil=rhPtr->rhEvtProg->qualToOiList[qoi];
    int count=0;
    while(count<qoil->nQoi)
    {
        txtDisplay(pe, rhPtr, qoil->qoiList[count], txtNumber);
        count+=2;
    };
    return -1;
}

// ENTREE DE L'ACTION
void actTxtDisplay(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    txtDoDisplay(pe, rhPtr, pEvp2->evp.evpW.evpW0);            // trouve le numero du texte
}

// -----------------------------
// ACTION : FLASH TEXT
// -----------------------------
void actTxtDisplayDuring(event* pe, CRun* rhPtr)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    LPEVP pEvp3=(LPEVP)((LPBYTE)pEvp2+pEvp2->evpSize);
    short num=txtDoDisplay(pe, rhPtr, pEvp2->evp.evpW.evpW0);
    
    if (num>=0)
    {
        LPHO pHo=rhPtr->rhObjectList[num];
        pHo->ros->rsFlash=pEvp3->evp.evpL.evpL0;
        pHo->ros->rsFlashCpt=pEvp3->evp.evpL.evpL0;
    }
}

// -------------------------
// ACTION :     PREVIOUS TEXT
// -------------------------
void actTxtPrevious(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo!=nil)
    {
        CText* pText=(CText*)pHo;
        int num=pText->rsMini-1;
        if (num<0) num=0;
        if ([pText txtChange:num])
        {
            pHo->roc->rcChanged=YES;
            [pHo modif];
        }
    }
}

// -------------------------
// ACTION :     NEXT TEXT
// -------------------------
void actTxtNext(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo!=nil)
    {
        CText* pText=(CText*)pHo;
        int num=pText->rsMini+1;
        if ([pText txtChange:num])
        {
            pHo->roc->rcChanged=YES;
            [pHo modif];
        }
    }
}

// -------------------------
// ACTION : SET TEXT
// -------------------------
void actTxtSet(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo!=nil)
    {
        CText* pText=(CText*)pHo;
        LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
        int n=pEvp->evp.evpW.evpW0;
        if (pEvp->evpCode!=PARAM_TEXTNUMBER)
        {
            n=[rhPtr get_EventExpressionInt:pEvp]-1;
        }
        if ([pText txtChange:n])
        {
            pHo->roc->rcChanged=YES;
            [pHo modif];
        }
    }
}

// ---------------------------------
// ACTION : DISPLAY ALTERABLE STRING
// ---------------------------------
void actTxtDisplayString(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo!=nil)
    {
        CText* pText=(CText*)pHo;
        if ([pText txtChange:-1])
        {
            pHo->roc->rcChanged=YES;
            [pHo modif];
        }
    }
}

// -------------------------
// ACTION : SET STRING
// -------------------------
void actTxtSetString(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo!=nil)
    {
        CText* pText=(CText*)pHo;
        LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
        NSString* pString=[rhPtr get_EventExpressionStringNoCopy:pEvp];
        [pText txtSetString:pString];
        [pText txtChange:-1];
        if ( (pHo->ros->rsFlags&RSFLAG_HIDDEN)==0)
        {
            pHo->roc->rcChanged=YES;
            [pHo modif];
        }
    }
}

// -------------------------
// ACTION : SET COLOUR
// -------------------------
void actTxtSetColour(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo!=nil)
    {
        CText* pText=(CText*)pHo;
        LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
        int rgb;
        if (pEvp->evpCode==PARAM_COLOUR)
            rgb=pEvp->evp.evpL.evpL0;
        else
            rgb=[rhPtr get_EventExpressionInt:pEvp];
        pText->rsTextColor=rgb;
//        pText->bTxtChanged=YES;
        [pHo modif];
    }
}

// -------------------------
// ACTION : DESTROY TEXTE
// -------------------------
void actTxtDestroy(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo!=nil)
    {
        CText* pText=(CText*)pHo;
        
        if (pText->rsHidden&COF_FIRSTTEXT)                        //; Le dernier objet texte?
        {
            [pHo->ros obHide];                                        //; Cache pour le moment
            pHo->ros->rsFlags&=~RSFLAG_VISIBLE;
            pHo->hoFlags|=HOF_NOCOLLISION;
        }
        else
        {
            pHo->hoFlags|=HOF_DESTROYED;                        //; NON: on le detruit!
            [rhPtr destroy_Add:pHo->hoNumber];
        }
    }
}

// ---------------------------------------------------------------------------
// OPERANDE : text number
// ---------------------------------------------------------------------------
void expTxtNumber(CRun* rhPtr)
{
    CText* pRs=(CText*)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pRs==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:pRs->rsMini+1];
}

// ---------------------------------------------------------------------------
// OPERANDE : =text
// ---------------------------------------------------------------------------
void expTxtGetCurrent(CRun* rhPtr)
{
    CText* pRs=(CText*)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pRs==nil)
    {
        [getCurrentResult() forceString:chaineVide];
        return;
    }
    if (pRs->rsTextBuffer!=nil)
        [getCurrentResult() forceString:pRs->rsTextBuffer];
    else
        [getCurrentResult() forceString:chaineVide];
}

// ---------------------------------------------------------------------------
// OPERANDE: =VALUE(x)
// ---------------------------------------------------------------------------
void expTxtGetNumeric(CRun* rhPtr)
{
    CText* pRs=(CText*)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pRs==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    if (pRs->rsTextBuffer!=nil)
    {
        funcVal(pRs->rsTextBuffer, getCurrentResult());
    }
    else
        [getCurrentResult() forceInt:0];
}


// ---------------------------------------------------------------------------
// OPERANDE : =text(number)
// ---------------------------------------------------------------------------
void expTxtGetNumber(CRun* rhPtr)
{
    CText* pRs=(CText*)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    nextToken();
    if (pRs==nil)
    {
        [getCurrentResult() forceString:chaineVide];
        return;
    }
    int num=[rhPtr get_ExpressionInt];                // Demande le numero du texte
    
    // Le texte courant
    if (num<0)
    {
        if (pRs->rsTextBuffer!=nil)
            [getCurrentResult() forceString:pRs->rsTextBuffer];
        else
            [getCurrentResult() forceString:chaineVide];
        return;
    }
    
    // Un texte stocke
    if (num>=pRs->rsMaxi)
        num=pRs->rsMaxi-1;
    CDefTexts* txt=(CDefTexts*)pRs->hoCommon->ocObject;
    [getCurrentResult() forceString:txt->otTexts[num]->tsText];
}

// ---------------------------------------------------------------------------
// OPERANDE: = n/a
// ---------------------------------------------------------------------------
void expTxtGetNPara(CRun* rhPtr)
{
    CText* pRs=(CText*)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pRs==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:pRs->rsMaxi];
}



// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// GESTION DES OBJETS QUESTION
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------

// -------------------------------------
// ACTION : ASK QUESTION / DISPLAY TEXT
// -------------------------------------

int qstCreate(event* pe, CRun* rhPtr, short oi)
{
    // Cherche la position de creation
    int x, y, dir;
    BOOL bRepeat;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);                //; Pointe le parametre
    if (read_Position(rhPtr, (LPPOS)&pEvp->evp.evpW.evpW0, 0x10, &x, &y, &dir, &bRepeat, nil))
    {
        LPCDP pCdp=(LPCDP)&pEvp->evp.evpW.evpW0;
        return [rhPtr f_CreateObject:pCdp->cdpHFII withOIHandle:oi andX:x andY:y andDir:dir andFlags:0 andLayer:rhPtr->rhFrame->nLayers-1 andNumCreation:-1];
    }
    return -1;
}

void actQstAsk(event* pe, CRun* rhPtr)
{
    int oil=pe->evtOiList;
    if (oil>=0)
    {
        qstCreate(pe, rhPtr, pe->evtOi);
        return;
    }
    
    // Un qualifier: on explore les listes
    if (oil!=-1)
    {
        CQualToOiList* qoil=rhPtr->rhEvtProg->qualToOiList[oil&0x7FFF];
        int qoi;
        for (qoi=0; qoi<qoil->nQoi; qoi++)
        {
            qstCreate(pe, rhPtr, qoil->qoiList[qoi]);
        }
    }
}

// -------------------------------------------------    *** boucler
// CONDITION: reponse == valeur
// -------------------------------------------------
BOOL eva1QstEqual(event* pe, CRun* rhPtr, LPHO pHo)
{
    // Le parametre
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    int num=[rhPtr get_EventExpressionInt:pEvp];
    
    // Compare
    if (rhPtr->rhEvtProg->rhCurParam[0]==num) return YES;
    return NO;
}

BOOL eva2QstEqual(event* pe, CRun* rhPtr, LPHO pHo)
{
    return FALSE;
}
BOOL eva2QstExact(event* pe, CRun* rhPtr, LPHO pHo)
{
    return FALSE;
}
BOOL eva2QstFalse(event* pe, CRun* rhPtr, LPHO pHo)
{
    return FALSE;
}

// -------------------------------------------------
// CONDITION: reponse exacte
// -------------------------------------------------
BOOL eva1QstExact(event* pe, CRun* rhPtr, LPHO pHo)
{
    return TRUE;                        //; Car appele directement
}

// -------------------------------------------------
// CONDITION: reponse fausse
// -------------------------------------------------
BOOL eva1QstFalse(event* pe, CRun* rhPtr, LPHO pHo)
{
    return TRUE;                        //; Car appele directement
}

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// GESTION DES OBJETS COUNTER
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------

// CONDITION : tests de la valeur
// ------------------------------
BOOL evaCounter(event* pe, CRun* rhPtr, LPHO pHoDummy)
{
    LPHO pHo=[rhPtr->rhEvtProg evt_FirstObject:pe->evtOiList];
    int cpt=rhPtr->rhEvtProg->evtNSelectedObjects;
    CValue* evaTmp = rhPtr->evaTmp;
    while(pHo!=nil)
    {
        [evaTmp forceValue:[((CCounter*)pHo) cpt_GetValue]];
        LPEVP pp=(LPEVP)((LPBYTE)pe+CND_SIZE);
        CValue* value2=[rhPtr get_EventExpressionAnyNoCopy:pp];
        if (compareTo(evaTmp, value2, pp->evp.evpW.evpW0)==NO)
        {
            cpt--;
            [rhPtr->rhEvtProg evt_DeleteCurrentObject];
        }
        
        pHo=[rhPtr->rhEvtProg evt_NextObject];
    }while(pHo!=nil);
    return (cpt!=0);
}
        

// EXPRESSION : retourne la valeur d'un compteur
// ---------------------------------------------
void expCpt_GetValue(CRun* rhPtr)
{
    CCounter* pHo=(CCounter*)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceValue:pHo->rsValue];
}

// ACTION : change la valeur du compteur
// -------------------------------------
void actCpt_SetValue(event* pe, CRun* rhPtr)
{
    CCounter* rsPtr=(CCounter*)[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (rsPtr==nil) return;
    
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    CValue* pValue=[rhPtr get_EventExpressionAny:pp];
    [rsPtr cpt_ToFloat:pValue];
    [rsPtr cpt_Change:pValue];
}

// ACTION : change la valeur du compteur
// -------------------------------------
void actCpt_AddValue(event* pe, CRun* rhPtr)
{
    CCounter* rsPtr=(CCounter*)[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (rsPtr==nil) return;
    
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    CValue* pValue2=[rhPtr get_EventExpressionAny:pp];
    [rsPtr cpt_ToFloat:pValue2];
    CValue* evaTmp = rhPtr->evaTmp;
    [evaTmp forceValue:rsPtr->rsValue];
    [evaTmp add:pValue2];
    [rsPtr cpt_Change:evaTmp];
}

// ACTION : change la valeur du compteur
// -------------------------------------
void actCpt_SubValue(event* pe, CRun* rhPtr)
{
    CCounter* rsPtr=(CCounter*)[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (rsPtr==nil) return;
    
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    CValue* pValue2=[rhPtr get_EventExpressionAny:pp];
    [rsPtr cpt_ToFloat:pValue2];
    CValue* evaTmp = rhPtr->evaTmp;
    [evaTmp forceValue:rsPtr->rsValue];
    [evaTmp sub:pValue2];
    [rsPtr cpt_Change:evaTmp];
}

// EXPRESSION : retourne la valeur mini du compteur
// ------------------------------------------------
void expCpt_GetMin(CRun* rhPtr)
{
    CCounter* rsPtr=(CCounter*)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (rsPtr==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    if ([rsPtr->rsValue getType]==TYPE_INT)
        [getCurrentResult() forceInt:rsPtr->rsMini];
    else
        [getCurrentResult() forceDouble:rsPtr->rsMiniDouble];
}

// EXPRESSION : retourne la valeur mini du compteur
// ------------------------------------------------
void expCpt_GetMax(CRun* rhPtr)
{
    CCounter* rsPtr=(CCounter*)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (rsPtr==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    if ([rsPtr->rsValue getType]==TYPE_INT)
        [getCurrentResult() forceInt:rsPtr->rsMaxi];
    else
        [getCurrentResult() forceDouble:rsPtr->rsMaxiDouble];
}

// ACTION : change la valeur mini du compteur
// ------------------------------------------
void actCpt_SetMin(event* pe, CRun* rhPtr)
{
    CCounter* rsPtr=(CCounter*)[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (rsPtr==nil) return;
    
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    CValue* pValue=[rhPtr get_EventExpressionAnyNoCopy:pp];
    [rsPtr cpt_SetMin:pValue];
}

// ACTION : change la valeur maxi du compteur
// ------------------------------------------
void actCpt_SetMax(event* pe, CRun* rhPtr)
{
    CCounter* rsPtr=(CCounter*)[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (rsPtr==nil) return;
    
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    CValue* pValue=[rhPtr get_EventExpressionAnyNoCopy:pp];
    [rsPtr cpt_SetMax:pValue];
}

// EXPRESSION : retourne la couleur 1 du compteur
// ----------------------------------------------
void expCpt_GetColor1(CRun* rhPtr)
{
    int clr = 0;
    CCounter* rsPtr=(CCounter*)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if ( rsPtr != nil )
        clr = rsPtr->rsColor1;
    [getCurrentResult() forceInt:clr];
}

// EXPRESSION : retourne la couleur 2 du compteur
// ----------------------------------------------
void expCpt_GetColor2(CRun* rhPtr)
{
    int clr = 0;
    CCounter* rsPtr=(CCounter*)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if ( rsPtr != nil )
        clr = rsPtr->rsColor2;
    [getCurrentResult() forceInt:clr];
}

// ACTION : change la couleur 1 du compteur
// ----------------------------------------
void actCpt_SetColor1(event* pe, CRun* rhPtr)
{
    CCounter* rsPtr=(CCounter*)[rhPtr->rhEvtProg get_ActionObjects:pe];
    if ( rsPtr != nil )
    {
        int rgb;
        LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
        if (pEvp->evpCode==PARAM_EXPRESSION)
            rgb=[rhPtr get_EventExpressionInt:pEvp];
        else
            rgb=pEvp->evp.evpL.evpL0;
        [rsPtr cpt_SetColor1:rgb];
    }
}

// ACTION : change la couleur 2 du compteur
// ----------------------------------------
void actCpt_SetColor2(event* pe, CRun* rhPtr)
{
    CCounter* rsPtr=(CCounter*)[rhPtr->rhEvtProg get_ActionObjects:pe];
    if ( rsPtr != nil )
    {
        int rgb;
        LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
        if (pEvp->evpCode==PARAM_EXPRESSION)
            rgb=[rhPtr get_EventExpressionInt:pEvp];
        else
            rgb=pEvp->evp.evpL.evpL0;
        [rsPtr cpt_SetColor2:rgb];
    }
}


// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// GESTION DES OBJETS SPRITES
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------

// ---------------------------------------------------
// ---------------------------------------------------
// Procedure generale exploration d'un objet
// ---------------------------------------------------
// ---------------------------------------------------


BOOL evaObject(event* pe, CRun* rhPtr, EVAOROUTINE pRoutine)
{
    LPHO pHo=[rhPtr->rhEvtProg evt_FirstObject:pe->evtOiList];
    int cpt=rhPtr->rhEvtProg->evtNSelectedObjects;
    while(pHo!=nil)
    {
        if (pRoutine(pe, rhPtr, pHo)==NO)
        {
            cpt--;
            [rhPtr->rhEvtProg evt_DeleteCurrentObject];            // On le vire!
        }
        pHo=[rhPtr->rhEvtProg evt_NextObject];
    }
    // Vrai / Faux?
    if (cpt!=0)
        return YES;
    return NO;
}


// -------------------------------------------------
// CONDITION: object arrive pres d'une bordure...
// -------------------------------------------------
BOOL NearBord(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    int bord=[rhPtr get_EventExpressionInt:pEvp];            //; Cherche la bordure
    
    int xw=rhPtr->rhWindowX+bord;                        // Compare en X
    int x=[pHo getX]-pHo->hoImgXSpot;
    if (x<=xw) return negaTRUE(pe);
    
    xw=rhPtr->rhWindowX+rhPtr->rh3WindowSx-bord;
    x+=pHo->hoImgWidth;
    if (x>=xw) return negaTRUE(pe);
    
    int yw=rhPtr->rhWindowY+bord;                        // Compare en Y
    int y=[pHo getY]-pHo->hoImgYSpot;
    if (y<=yw) return negaTRUE(pe);
    
    yw=rhPtr->rhWindowY+rhPtr->rh3WindowSy-bord;
    y+=pHo->hoImgHeight;
    if (y>=yw) return negaTRUE(pe);
    
    return negaFALSE(pe);
}
BOOL evaNearBorders(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, NearBord);
}

// ---------------------
// Verifie une checkmark
// ---------------------
BOOL checkMarkEvt(int mark, CRun* rhPtr)
{
    if (mark==0) return NO;                // Pas la premiere boucle
    if (mark==rhPtr->rhLoopCount) return YES;
    if (mark==rhPtr->rhLoopCount-1) return YES;
    return NO;
}

// -------------------------------------------------
// CONDITION: node reached
// -------------------------------------------------
BOOL NPath(event* pe, CRun* rhPtr, LPHO pHo)
{
    if (pHo->roc->rcMovementType!=MVTYPE_TAPED) return NO;
    return checkMarkEvt(pHo->hoMark1, rhPtr);
}
BOOL evaNodePath(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, NPath);
}

// -------------------------------------------------
// CONDITION: name node reached
// -------------------------------------------------
BOOL NNPath(event* pe, CRun* rhPtr, LPHO pHo)
{
    if (pHo->roc->rcMovementType!=MVTYPE_TAPED) return NO;
    if (checkMarkEvt(pHo->hoMark1, rhPtr))
    {
        LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
        NSString* pName=[rhPtr get_EventExpressionStringNoCopy:pEvp];
        if (pHo->hoMT_NodeName!=nil)
        {
            if ([pName compare:pHo->hoMT_NodeName]==0)
            {
                return YES;
            }
        }
    }
    return NO;
}
BOOL evaPathNodeName2(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, NNPath);
}
BOOL evaPathNodeName1(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    NSString* pName=[rhPtr get_EventExpressionStringNoCopy:pEvp];
    if (pHo->hoMT_NodeName!=nil)
    {
        if ([pName compare:pHo->hoMT_NodeName]==0)
        {
            return YES;
        }
    }
    return NO;
}


// -------------------------------------------------
// CONDITION: end of path
// -------------------------------------------------
BOOL EPath(event* pe, CRun* rhPtr, LPHO pHo)
{
    if (pHo->roc->rcMovementType!=MVTYPE_TAPED) return NO;
    return checkMarkEvt(pHo->hoMark2, rhPtr);
}
BOOL evaEndPath(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, EPath);
}

// -------------------------------------------------------
// Procedure generale evaluation expression pour condition
// -------------------------------------------------------


BOOL evaExpObject(event* pe, CRun* rhPtr, EEOROUTINE pRoutine)
{
    // Boucle d'exploration
    CObject* pHo=[rhPtr->rhEvtProg evt_FirstObject:pe->evtOiList];
    int cpt=rhPtr->rhEvtProg->evtNSelectedObjects;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);

	// Test if object interdepence between condition object and objects in parameters
	if ((pe->evtFlags2 & EVFLAG2_NOOBJECTINTERDEPENDENCE) != 0)
	{
		// No interdependence, can evaluate value out of the loop
		int value;
		LPEXP pToken = (LPEXP)&pEvp->evp.evpW.evpW1;
		LPEXP pNextToken = (LPEXP)((LPBYTE)pToken+pToken->expSize);
		if ( (pToken->expCode.expLCode.expCode == EXPL_LONG || pToken->expCode.expLCode.expCode == EXPL_DOUBLE) && pNextToken->expCode.expLCode.expCode == 0 )
		{
			value = (pToken->expCode.expLCode.expCode == EXPL_LONG) ? pToken->expu.expl.expLParam : (int)pToken->expu.expd.expDouble;
			rhPtr->rh4ExpToken=pNextToken;           // I think it's not mandatory but just in case, as Get_EventExpressionInt does it...
		}
		else
			value = [rhPtr get_EventExpressionInt:pEvp];
        while(pHo!=nil)
        {
            if (pRoutine(pe, rhPtr, pHo, value)==NO)
            {
                cpt--;
                [rhPtr->rhEvtProg evt_DeleteCurrentObject];
            }
            pHo=[rhPtr->rhEvtProg evt_NextObject];
        }
	}
	else
    {
		// Object interdependence => evaluate value for each object
        int value;
        while(pHo!=nil)
        {
            value=[rhPtr get_EventExpressionInt:pEvp];
            if (pRoutine(pe, rhPtr, pHo, value)==NO)
            {
                cpt--;
                [rhPtr->rhEvtProg evt_DeleteCurrentObject];
            }
            pHo=[rhPtr->rhEvtProg evt_NextObject];
        }
    }
    if (cpt!=0) return YES;
    return NO;
}

BOOL evaExpObjectDouble(event* pe, CRun* rhPtr, EEOROUTINEDOUBLE pRoutine)
{
    // Boucle d'exploration
    CObject* pHo=[rhPtr->rhEvtProg evt_FirstObject:pe->evtOiList];
    int cpt=rhPtr->rhEvtProg->evtNSelectedObjects;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);

	// Test if object interdepence between condition object and objects in parameters
	if ((pe->evtFlags2 & EVFLAG2_NOOBJECTINTERDEPENDENCE) != 0)
	{
		// No interdependence, can evaluate value out of the loop
		double value;
		LPEXP pToken = (LPEXP)&pEvp->evp.evpW.evpW1;
		LPEXP pNextToken = (LPEXP)((LPBYTE)pToken+pToken->expSize);
		if ( (pToken->expCode.expLCode.expCode == EXPL_LONG || pToken->expCode.expLCode.expCode == EXPL_DOUBLE) && pNextToken->expCode.expLCode.expCode == 0 )
		{
			value = (pToken->expCode.expLCode.expCode == EXPL_LONG) ? (double)pToken->expu.expl.expLParam : pToken->expu.expd.expDouble;
			rhPtr->rh4ExpToken=pNextToken;           // I think it's not mandatory but just in case, as Get_EventExpressionInt does it...
		}
		else
			value = [rhPtr get_EventExpressionDouble:pEvp];
        while(pHo!=nil)
        {
            if (pRoutine(pe, rhPtr, pHo, value)==NO)
            {
                cpt--;
                [rhPtr->rhEvtProg evt_DeleteCurrentObject];
            }
            pHo=[rhPtr->rhEvtProg evt_NextObject];
        }
    }
    else
    {
        double value;
        while(pHo!=nil)
        {
            value=[rhPtr get_EventExpressionDouble:pEvp];
            if (pRoutine(pe, rhPtr, pHo, value)==NO)
            {
                cpt--;
                [rhPtr->rhEvtProg evt_DeleteCurrentObject];
            }
            pHo=[rhPtr->rhEvtProg evt_NextObject];
        }
    }
    if (cpt!=0) return YES;
    return NO;
}

// -------------------------------------------------
// CONDITION: variable/flag==
// -------------------------------------------------
BOOL CheckMultipleFlagAndVariableParam(multipleFlagAndVariableParam* pMultipleParam, LPHO pHo)
{
    if ( pHo->rov == nil )
        return NO;
    
    // Test multiple flags
    if ( pMultipleParam->flagMasks != 0 )
    {
        if ( (pHo->rov->rvValueFlags & pMultipleParam->flagMasks) != pMultipleParam->flagValues )
            return NO;
    }
    
    // Test values
    LPRH rhPtr = pHo->hoAdRunHeader;
    int mask = MULTIVARF_VALUE1;
    int maskGlobal = MULTIVARF_VALUE1ISGLOBAL;
    int maskDouble = MULTIVARF_VALUE1ISDOUBLE;
    for(int i=0; i<MULTIVAR_MAXVALUE; i++)
    {
        if ( (pMultipleParam->flags & mask) == 0 )
            break;
        evoValue* value = &pMultipleParam->values[i];
        
        // Global
        if ( (pMultipleParam->flags & maskGlobal) != 0 )
        {
            CValue* gValue = [rhPtr->rhApp getGlobalValueAt:value->valIndex];
            if ( pMultipleParam->flags & maskDouble )
            {
                if (compareToDouble(gValue, value->valCompareWithDouble, value->valCompareOp)==FALSE)
                    return NO;
            }
            else
            {
                if (compareToInt(gValue, value->valCompareWithLong, value->valCompareOp)==FALSE)
                    return NO;
            }
        }
        
        // Alterable
        else
        {
            if ( value->valIndex >= 0 && value->valIndex < pHo->rov->rvNumberOfValues )
            {
                if ( pMultipleParam->flags & maskDouble )
                {
                    if (compareToDouble([pHo->rov getValue:value->valIndex], value->valCompareWithDouble, value->valCompareOp)==FALSE)
                        return NO;
                }
                else
                {
                    if (compareToInt([pHo->rov getValue:value->valIndex], value->valCompareWithLong, value->valCompareOp)==FALSE)
                        return NO;
                }
            }
            else
            {
                CValue* evaTmp = rhPtr->evaTmp;
                [evaTmp forceInt:0];
                if ( pMultipleParam->flags & maskDouble )
                {
                    if (compareToDouble(evaTmp, value->valCompareWithDouble, value->valCompareOp)==FALSE)
                        return NO;
                }
                else
                {
                    if (compareToInt(evaTmp, value->valCompareWithLong, value->valCompareOp)==FALSE)
                        return NO;
                }
            }
        }
        mask <<= 4;
        maskGlobal <<= 4;
        maskDouble <<= 4;
    }
    return YES;
}

// The same without global values
BOOL CheckMultipleFlagAndVariableParamNoGlobalValue(multipleFlagAndVariableParam* pMultipleParam, LPHO pHo)
{
    if ( pHo->rov == nil )
        return NO;
    
    // Test multiple flags
    if ( pMultipleParam->flagMasks != 0 )
    {
        if ( (pHo->rov->rvValueFlags & pMultipleParam->flagMasks) != pMultipleParam->flagValues )
            return NO;
    }
    
    // Test values
    LPRH rhPtr = pHo->hoAdRunHeader;
    int mask = MULTIVARF_VALUE1;
    int maskDouble = MULTIVARF_VALUE1ISDOUBLE;
    for(int i=0; i<MULTIVAR_MAXVALUE; i++)
    {
        if ( (pMultipleParam->flags & mask) == 0 )
            break;
        evoValue* value = &pMultipleParam->values[i];
        
        if ( value->valIndex >= 0 && value->valIndex < pHo->rov->rvNumberOfValues )
        {
            if ( pMultipleParam->flags & maskDouble )
            {
                if (compareToDouble([pHo->rov getValue:value->valIndex], value->valCompareWithDouble, value->valCompareOp)==FALSE)
                    return NO;
            }
            else
            {
                if (compareToInt([pHo->rov getValue:value->valIndex], value->valCompareWithLong, value->valCompareOp)==FALSE)
                    return NO;
            }
        }
        else
        {
            CValue* evaTmp = rhPtr->evaTmp;
            [evaTmp forceInt:0];
            if ( pMultipleParam->flags & maskDouble )
            {
                if (compareToDouble(evaTmp, value->valCompareWithDouble, value->valCompareOp)==FALSE)
                    return NO;
            }
            else
            {
                if (compareToInt(evaTmp, value->valCompareWithLong, value->valCompareOp)==FALSE)
                    return NO;
            }
        }
        mask <<= 4;
        maskDouble <<= 4;
    }
    return YES;
}

BOOL FSet(event* pe, CRun* rhPtr, LPHO pHo, int value)
{
    value&=31;
    if (pHo->rov!=nil)
    {
        if ((pHo->rov->rvValueFlags&(1<<value))!=0) return YES;
    }
    return NO;
}
BOOL evaFlagSet(event* pe, CRun* rhPtr, LPHO _pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    if ( pEvp->evpCode != PARAM_MULTIPLEVAR )
        return evaExpObject(pe, rhPtr, FSet);
    
    // Parameter = mask and value of multiple flags
    multipleFlagAndVariableParam* pMultipleParam = (multipleFlagAndVariableParam*)&pEvp->evp.evpW.evpW0;
    CObject* pHo=[rhPtr->rhEvtProg evt_FirstObject:pe->evtOiList];
    int cpt=rhPtr->rhEvtProg->evtNSelectedObjects;
    while(pHo!=NULL)
    {
        if ( !CheckMultipleFlagAndVariableParamNoGlobalValue(pMultipleParam, pHo) )
        {
            cpt--;
            [rhPtr->rhEvtProg evt_DeleteCurrentObject];
        }
        pHo=[rhPtr->rhEvtProg evt_NextObject];
    }
    
    if (cpt!=0)
        return YES;
    return NO;
}

BOOL FReset(event* pe, CRun* rhPtr, LPHO pHo, int value)
{
    value&=31;
    if (pHo->rov!=nil)
    {
        if (pHo->rov->rvValueFlags&(1<<value)) return NO;
    }
    return YES;
}
BOOL evaFlagReset(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaExpObject(pe, rhPtr, FReset);
}
BOOL compFixed(event* pe, CRun* rhPtr, LPHO pHo, int value)
{
    int fixed=(pHo->hoCreationId*65536)|(pHo->hoNumber&0xFFFF);
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    return compareTer(fixed, value, pEvp->evp.evpW.evpW0);
}
BOOL evaVarCompareFixed(event* pe, CRun* rhPtr, LPHO _pHo)
{
	// Test if object interdepence between condition object and objects in parameters
	//LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
	//if ((pe->evtFlags2 & EVFLAG2_NOOBJECTINTERDEPENDENCE) == 0 || pEvp->evp.evpW.evpW0 != COMPARE_EQ)
	//{
		// Interdependence, normal evaluation
		return evaExpObject(pe, rhPtr, compFixed);
	//}
	/*
	// No interdependence => optimization
	unsigned int fixedValue;
	LPEXP pToken = (LPEXP)&pEvp->evp.evpW.evpW1;
	LPEXP pNextToken = (LPEXP)((LPBYTE)pToken+pToken->expSize);
	if ( (pToken->expCode.expLCode.expCode == EXPL_LONG || pToken->expCode.expLCode.expCode == EXPL_DOUBLE) && pNextToken->expCode.expLCode.expCode == 0 )
	{
		fixedValue = (pToken->expCode.expLCode.expCode == EXPL_LONG) ? pToken->expu.expl.expLParam : (int)pToken->expu.expd.expDouble;
		rhPtr->rh4ExpToken = pNextToken;
	}
	else
		fixedValue = [rhPtr get_EventExpressionInt:pEvp];

	int honum = (fixedValue & 0xFFFF);
	LPHO pHo = nil;
	if (honum < rhPtr->rhMaxObjects)
		pHo = rhPtr->rhObjectList[honum];
	if (pHo == nil || pHo->hoCreationId != ((fixedValue >> 16) & 0xFFFF))
	{
		[rhPtr->rhEvtProg evt_DeselectObject:pe->evtOiList];
		return false;
	}
	
	// Verify if OIL is identical
	CObjInfo* oilPtr = pHo->hoOiList;
	if (oilPtr->oilIndex != pe->evtOiList)
	{
		// Nope, is evtOiList a qualifier?
		BOOL oilOK = NO;
		if (pe->evtOiList < 0)
		{
			// Yes, check if pHo has this qualifier
			short q = (pe->evtOiList & 0x7FFF);
			if (oilPtr->oilRealQualifiers != nil)
			{
				for(int qn = 0; oilPtr->oilRealQualifiers[qn] >= 0; qn++)
				{
					if (oilPtr->oilRealQualifiers[qn] == q)
					{
						oilOK =  YES;
						break;
					}
				}
			}
		}
		if (!oilOK)
		{
			[rhPtr->rhEvtProg evt_DeselectObject:pe->evtOiList];
			return false;
		}
	}
	
	// Verify if object is selected
	if (oilPtr->oilEventCount == rhPtr->rhEvtProg->rh2EventCount)
	{
		// CObjInfo partially selected => check if the object is in the selection list
		BOOL isSelected = NO;
		short ois = oilPtr->oilListSelected;
		if (ois >= 0)
		{
			CObject* pHo1;
			do {
				if (pHo->hoNumber == ois)
				{
					isSelected = YES;
					break;
				}
				pHo1 = rhPtr->rhObjectList[ois];
				if (pHo1 == nil)
					break;
				ois = pHo1->hoNextSelected;
			} while(ois >= 0);
			if (!isSelected)
			{
				[rhPtr->rhEvtProg evt_DeselectObject:pe->evtOiList];
				return false;
			}
		}
	}
	//else ; // ObjInfo fully selected
	//
	
	// Yes : select unique object
	[rhPtr->rhEvtProg evt_ForceOneObject:pe->evtOiList withObject:pHo];
	return true; */
}

BOOL XComp(event* pe, CRun* rhPtr, LPHO pHo, int value)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    return compareTer((int)[pHo getX], value, pEvp->evp.evpW.evpW0);
}
BOOL evaXCompare(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaExpObject(pe, rhPtr, XComp);
}
BOOL YComp(event* pe, CRun* rhPtr, LPHO pHo, int value)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    return compareTer((int)[pHo getY], value, pEvp->evp.evpW.evpW0);
}
BOOL evaYCompare(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaExpObject(pe, rhPtr, YComp);
}
BOOL SComp(event* pe, CRun* rhPtr, LPHO pHo, int value)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    return compareTer((int)pHo->roc->rcSpeed, value, pEvp->evp.evpW.evpW0);
}
BOOL evaSpeedCompare(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaExpObject(pe, rhPtr, SComp);
}
BOOL AccComp(event* pe, CRun* rhPtr, LPHO pHo, int value)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    return compareTer((int)pHo->rom->rmMovement->rmAcc, value, pEvp->evp.evpW.evpW0);
}
BOOL evaCmpAcc(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaExpObject(pe, rhPtr, AccComp);
}
BOOL DecComp(event* pe, CRun* rhPtr, LPHO pHo, int value)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    return compareTer((int)pHo->rom->rmMovement->rmDec, value, pEvp->evp.evpW.evpW0);
}
BOOL evaCmpDec(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaExpObject(pe, rhPtr, DecComp);
}
BOOL FrameComp(event* pe, CRun* rhPtr, LPHO pHo, int value)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    return compareTer((int)pHo->roa->raAnimFrame, value, pEvp->evp.evpW.evpW0);
}
BOOL evaCmpFrame(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaExpObject(pe, rhPtr, FrameComp);
}


// Procedure generale
// ~~~~~~~~~~~~~~~~~~
BOOL evaCmpVar(event* pe, CRun* rhPtr, LPHO pHoIn)
{
    // Boucle d'exploration
    CObject* pHo=[rhPtr->rhEvtProg evt_FirstObject:pe->evtOiList];
    if (pHo==nil) return NO;
    
    int cpt=rhPtr->rhEvtProg->evtNSelectedObjects;
    CValue* evaTmp = rhPtr->evaTmp;
    CValue* value2;
    LPEVP pp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    LPEVP pp2=(LPEVP)((LPBYTE)pp+pp->evpSize);
    
	// Test if object interdepence between condition object and objects in parameters
	if ((pe->evtFlags2 & EVFLAG2_NOOBJECTINTERDEPENDENCE) != 0)
	{
		// No interdependence, can evaluate index and value2 out of the loop
		int num;
		if (pp->evpCode==PARAM_ALTVALUE_EXP)
			num=[rhPtr get_EventExpressionInt:pp];
		else
			num=pp->evp.evpW.evpW0;

		value2=[rhPtr get_EventExpressionAnyNoCopy:pp2];
		
		do
		{
			if (num>=0 && pHo->rov!=nil)
			{
				if ( num<pHo->rov->rvNumberOfValues )
					[evaTmp forceValue:[pHo->rov getValue:num]];
				else
					[evaTmp forceInt:0];
				
				if (compareTo(evaTmp, value2, pp2->evp.evpW.evpW0)==NO)
				{
					cpt--;
					[rhPtr->rhEvtProg evt_DeleteCurrentObject];
				}
			}
			else
			{
				cpt--;
				[rhPtr->rhEvtProg evt_DeleteCurrentObject];
			}
			pHo=[rhPtr->rhEvtProg evt_NextObject];
		}while(pHo!=nil);
	}
	else
	{
		do
		{
			int num;
			if (pp->evpCode==PARAM_ALTVALUE_EXP)
				num=[rhPtr get_EventExpressionInt:pp];
			else
				num=pp->evp.evpW.evpW0;
			
			if (num>=0 && pHo->rov!=nil)
			{
				if ( num<pHo->rov->rvNumberOfValues )
					[evaTmp forceValue:[pHo->rov getValue:num]];
				else
					[evaTmp forceInt:0];
				
				value2=[rhPtr get_EventExpressionAnyNoCopy:pp2];
				
				if (compareTo(evaTmp, value2, pp2->evp.evpW.evpW0)==NO)
				{
					cpt--;
					[rhPtr->rhEvtProg evt_DeleteCurrentObject];
				}
			}
			else
			{
				cpt--;
				[rhPtr->rhEvtProg evt_DeleteCurrentObject];
			}
			pHo=[rhPtr->rhEvtProg evt_NextObject];
		}while(pHo!=nil);
	}

    return (cpt!=0);
}

BOOL evaCmpVarConst(event* pe, CRun* rhPtr, LPHO pHoIn)
{
    CObject* pHo=[rhPtr->rhEvtProg evt_FirstObject:pe->evtOiList];
    if (pHo==nil) return NO;
    
    int cpt=rhPtr->rhEvtProg->evtNSelectedObjects;
    CValue* evaTmp = rhPtr->evaTmp;
    LPEVP pp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    LPEVP pp2=(LPEVP)((LPBYTE)pp+pp->evpSize);
    int num=pp->evp.evpW.evpW0;
    LPEXP pToken = (LPEXP)&pp2->evp.evpW.evpW1;
    
    int valueInt;
    double valueDouble;
    if ( pToken->expCode.expLCode.expCode == EXPL_LONG )
        valueInt = pToken->expu.expl.expLParam;
    else
        valueDouble = pToken->expu.expd.expDouble;
    do
    {
        if (num>=0 && pHo->rov!=nil)
        {
            if ( num<pHo->rov->rvNumberOfValues )
                [evaTmp forceValue:[pHo->rov getValue:num]];
            else
                [evaTmp forceInt:0];
            
            if ( pToken->expCode.expLCode.expCode == EXPL_LONG )
            {
                if (compareToInt(evaTmp, valueInt, pp2->evp.evpW.evpW0)==NO)
                {
                    cpt--;
                    [rhPtr->rhEvtProg evt_DeleteCurrentObject];
                }
            }
            else
            {
                if (compareToDouble(evaTmp, valueDouble, pp2->evp.evpW.evpW0)==NO)
                {
                    cpt--;
                    [rhPtr->rhEvtProg evt_DeleteCurrentObject];
                }
            }
        }
        else
        {
            cpt--;
            [rhPtr->rhEvtProg evt_DeleteCurrentObject];
        }
        pHo=[rhPtr->rhEvtProg evt_NextObject];
    }while(pHo!=nil);
    return (cpt != 0);
}

BOOL evaCmpVarString(event* pe, CRun* rhPtr, LPHO pHoIn)
{
    // Boucle d'exploration
    CObject* pHo=[rhPtr->rhEvtProg evt_FirstObject:pe->evtOiList];
    if (pHo==nil) return NO;
    
    int cpt=rhPtr->rhEvtProg->evtNSelectedObjects;
    CValue* evaTmp = rhPtr->evaTmp;
    CValue* value2;
    LPEVP pp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    LPEVP pp2=(LPEVP)((LPBYTE)pp+pp->evpSize);

	// Test if object interdepence between condition object and objects in parameters
	if ((pe->evtFlags2 & EVFLAG2_NOOBJECTINTERDEPENDENCE) != 0)
	{
		// No interdependence, can evaluate index and value2 out of the loop
		int num;
		if (pp->evpCode==PARAM_ALTSTRING_EXP)
			num=[rhPtr get_EventExpressionInt:pp];
		else
			num=pp->evp.evpW.evpW0;
		
		value2=[rhPtr get_EventExpressionAnyNoCopy:pp2];

		do
		{
			if (num>=0 && pHo->rov!=nil && num<pHo->rov->rvNumberOfStrings)
			{
				NSString* varString = [pHo->rov getString:num];
				NSString* tmpString = evaTmp->stringValue;
				short tmpType = evaTmp->type;
				evaTmp->stringValue = varString;
				evaTmp->type = TYPE_STRING;
				
				if (compareTo(evaTmp, value2, pp2->evp.evpW.evpW0)==NO)
				{
					cpt--;
					[rhPtr->rhEvtProg evt_DeleteCurrentObject];
				}
				evaTmp->type = tmpType;
				evaTmp->stringValue = tmpString;
				
			}
			else
			{
				cpt--;
				[rhPtr->rhEvtProg evt_DeleteCurrentObject];
			}
			pHo=[rhPtr->rhEvtProg evt_NextObject];
		}while(pHo!=nil);
	}
	else
	{
		do
		{
			int num;
			if (pp->evpCode==PARAM_ALTSTRING_EXP)
				num=[rhPtr get_EventExpressionInt:pp];
			else
				num=pp->evp.evpW.evpW0;
			
			if (num>=0 && pHo->rov!=nil && num<pHo->rov->rvNumberOfStrings)
			{
				NSString* varString = [pHo->rov getString:num];
				NSString* tmpString = evaTmp->stringValue;
				short tmpType = evaTmp->type;
				evaTmp->stringValue = varString;
				evaTmp->type = TYPE_STRING;
				value2=[rhPtr get_EventExpressionAnyNoCopy:pp2];
				
				if (compareTo(evaTmp, value2, pp2->evp.evpW.evpW0)==NO)
				{
					cpt--;
					[rhPtr->rhEvtProg evt_DeleteCurrentObject];
				}
				evaTmp->type = tmpType;
				evaTmp->stringValue = tmpString;
				
			}
			else
			{
				cpt--;
				[rhPtr->rhEvtProg evt_DeleteCurrentObject];
			}
			pHo=[rhPtr->rhEvtProg evt_NextObject];
		}while(pHo!=nil);
	}
    return (cpt!=0);
}

// -------------------------------------------------
// CONDITION: Is object colliding
// -------------------------------------------------
BOOL evaIsColliding(event* pe, CRun* rhPtr, LPHO pHoIn)
{
    // Cas particulier lors de conditions OU, selectionne les deux listes d'objet
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    if (rhPtr->rhEvtProg->rh4ConditionsFalse)
    {
        [rhPtr->rhEvtProg evt_FirstObject:pe->evtOiList];
        [rhPtr->rhEvtProg evt_FirstObject:pEvp->evp.evpW.evpW0];
        return NO;
    }

    // Positionne le flag negate
    BOOL negate=NO;
    if ((pe->evtFlags2&EVFLAG2_NOT)!=0)
    negate=YES;
    
    // Un objet a voir?
    CObject* pHo=[rhPtr->rhEvtProg evt_FirstObject:pe->evtOiList];
    if (pHo==nil)
    return negaFALSE(pe);
    int cpt=rhPtr->rhEvtProg->evtNSelectedObjects;
    int cptTotal=cpt;
    
    short oi=pEvp->evp.evpW.evpW1;
    short oneObjectList[4];
    short* oi2List;
    if (oi>=0)
    {
        oneObjectList[0]=oi;
        oneObjectList[1]=pEvp->evp.evpW.evpW0;
        oneObjectList[2]=-1;
        oneObjectList[3]=-1;
        oi2List=oneObjectList;
    }
    else
    {
        CQualToOiList* qoil=rhPtr->rhEvtProg->qualToOiList[pEvp->evp.evpW.evpW0&0x7FFF];
        oi2List=qoil->qoiList;
    }
    
    // Boucle d'exploration
    BOOL bFlag=NO;
    CArrayList* list;
    CArrayList* list2=[[CArrayList alloc] init];
    int index;
    CObject* pHo2;
    do
    {
        int hoX;
        int hoY;
        if (pe->evtNParams >= 3)
        {
            /**
             *   Adding conversion from Global to Layer
             */
            LPEVP pp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
            hoX = [rhPtr get_EventExpressionInt:pp];
            pp=(LPEVP)((LPBYTE)pp+pp->evpSize);
            hoY = [rhPtr get_EventExpressionInt:pp];
            hoX = [pHo globalToLayerX:hoX];
            hoY = [pHo globalToLayerY:hoY];
        }
        else
        {
//            hoX = [pHo getX];
//            hoY = [pHo getY];
            hoX = pHo->hoX;
            hoY = pHo->hoY;
        }
        list=[rhPtr objectAllCol_IXY:pHo withImage:pHo->roc->rcImage andAngle:pHo->roc->rcAngle andScaleX:pHo->roc->rcScaleX andScaleY:pHo->roc->rcScaleY andX:hoX andY:hoY andColList:oi2List];
        
        if (list==nil)
        {
            if (negate==NO)
            {
                cpt--;
                [rhPtr->rhEvtProg evt_DeleteCurrentObject];
            }
        }
        else
        {
            // Explore la liste des sprites en collision a la recherche du deuxieme objet
            bFlag=NO;
            for (index=0; index<[list size]; index++)
            {
                pHo2=(CObject*)[list get:index];
                if ((pHo2->hoFlags&HOF_DESTROYED)==0)    // Detruit au cycle precedent?
                {
                    [list2 add:pHo2];
                    bFlag=YES;
                }
            }
            [list release];
                
            // Vire le sprite?
            if (negate==YES)
            {
                if (bFlag==YES)
                {
                    cpt--;
                    [rhPtr->rhEvtProg evt_DeleteCurrentObject];
                }
            }
            else
            {
                if (bFlag==NO)
                {
                    cpt--;
                    [rhPtr->rhEvtProg evt_DeleteCurrentObject];
                }
            }
        }
        pHo=[rhPtr->rhEvtProg evt_NextObject];
    } while(pHo!=nil);
    
    if (negate==NO)
    {
        if (cpt==0)
        {
            [list2 release];
            return NO;
        }
    }
    else
    {
        if (cpt<cptTotal)
        {
            [list2 release];
            return NO;
        }
    }

    // Fabrique la liste du sprite II
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    pHo=[rhPtr->rhEvtProg evt_FirstObject:pEvp->evp.evpW.evpW0];
    if (pHo==nil)
    {
        [list2 release];
        return NO;
    }
    cpt=rhPtr->rhEvtProg->evtNSelectedObjects;
    if (negate==NO)
    {
        do
        {
            for (index=0; index<[list2 size]; index++)
            {
                pHo2=(CObject*)[list2 get:index];
                if (pHo==pHo2)
                {
                    break;
                }
            }
            if (index==[list2 size])
            {
                cpt--;
                [rhPtr->rhEvtProg evt_DeleteCurrentObject];
            }
            pHo=[rhPtr->rhEvtProg evt_NextObject];
        }
        while(pHo!=nil);
        
        [list2 release];
        return (cpt!=0);
    }
    
    // Exploration avec negation
    do
    {
        for (index=0; index<[list2 size]; index++)
        {
            pHo2=(CObject*)[list2 get:index];
            if (pHo==pHo2)
            {
                cpt--;
                [rhPtr->rhEvtProg evt_DeleteCurrentObject];
                break;
            }
        }
        pHo=[rhPtr->rhEvtProg evt_NextObject];
    }
    while(pHo!=nil);
    
    [list2 release];
    return (cpt!=0);
}
        
        

// -------------------------------------------------
// CONDITION: Collision avec un autre sprite
// -------------------------------------------------
// Procedure d'exploration d'un qualifier
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
BOOL colGetList(CRun* rhPtr, short oiList, short lookFor)
{
    if (oiList==-1) return NO;
    CQualToOiList* qoil=rhPtr->rhEvtProg->qualToOiList[oiList&0x7FFF];
    int index;
    for (index=0; index<qoil->nQoi; index+=2)
    {
        if (qoil->qoiList[index]==lookFor) return YES;
    };
    return NO;
}


BOOL compute_GlobalNoRepeat(CRun* rhPtr)
{
    LPEVG evgPtr=rhPtr->rhEvtProg->rhEventGroup;
    DWORD inhibit=evgPtr->evgInhibit;
    evgPtr->evgInhibit=rhPtr->rhLoopCount;
    DWORD loopCount=rhPtr->rhLoopCount;
    if (loopCount==inhibit)
        return FALSE;
    loopCount--;
    if (loopCount==inhibit)
        return FALSE;
    return TRUE;
}

BOOL compute_NoRepeatCol(int identifier, LPHO pHo)
{
    int sid=0;
    int n;
    CArrayList* pArray=pHo->hoBaseNoRepeat;
    if (pArray==nil)
    {
        pArray=[[CArrayList alloc] init];
        pHo->hoBaseNoRepeat=pArray;
    }
    else
    {
        for (n=0; n<[pArray size]; n++)
        {
            sid=(int)[pArray getInt:n];
            if (sid==identifier)
            {
                return NO;
            }
        }
    }
    [pArray addInt:identifier];
        
    pArray=pHo->hoPrevNoRepeat;
    if (pArray==nil)
    {
        return YES;
    }
    for (n=0; n<[pArray size]; n++)
    {
        sid=[pArray getInt:n];
        if (sid==identifier)
        {
            return NO;
        }
    }
    return YES;
}
BOOL eva1Collision(event* pe, CRun* rhPtr, LPHO pHo)
{
    CObject* pHo1=rhPtr->rhObjectList[rhPtr->rhEvtProg->rh1stObjectNumber];
    short oiEvent=pe->evtOi;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    short oiParam=pEvp->evp.evpW.evpW1;
    
    while(YES)
    {
        if (oiEvent==pHo->hoOi)                            // Event== courant
        {
            // 1er=courant
            if (oiParam==pHo1->hoOi)
                break;
            if (oiParam>=0)
                return NO;                // Un qualifier?
            if (colGetList(rhPtr, pEvp->evp.evpW.evpW0, pHo1->hoOi))
                break;
            return NO;
        }
        if (oiParam==pHo->hoOi)                            // parametre== courant
        {
            // 2eme=courant
            if (oiEvent==pHo1->hoOi)
                break;
            if (oiEvent>=0)
                return NO;
            if (colGetList(rhPtr, pe->evtOiList, pHo1->hoOi))
                break;
            return NO;
        }
        if (oiEvent<0)
        {
            // 1er=liste
            if (oiParam<0)
            {
                // 1er=liste, 2eme=liste
                if (colGetList(rhPtr, pe->evtOiList, pHo->hoOi))    // Le courant fait-il partie de la liste 1
                {
                    if (colGetList(rhPtr, pEvp->evp.evpW.evpW0, pHo1->hoOi))    //; Courant dans liste 1, collision dans liste 2?
                        break;
                    if (colGetList(rhPtr, pEvp->evp.evpW.evpW0, pHo->hoOi)==false)  //; Derniere chance, courant dans liste 2?
                        return NO;
                    if (colGetList(rhPtr, pe->evtOiList, pHo1->hoOi))
                        break;
                    return NO;
                }
                else
                {
                    if (colGetList(rhPtr, pe->evtOiList, pHo1->hoOi))        //; Courant dans liste 2, collision dans liste 1?
                        break;
                    return NO;
                }
            }
            else
            {
                if (oiParam==pHo1->hoOi)
                    break;
                return NO;
            }
        }
        if (oiParam>=0)
            return NO;
        // 1er=oi, 2eme=qualif
        if (oiEvent!=pHo1->hoOi)
            return NO;
        break;
    }
    
    // Collision detectee, on ne veut pas de repeat
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    int id=( ((int)pHo1->hoCreationId)*65536)|(((int)pe->evtIdentifier)&0x0000FFFF);    //; Prend le numero de l'objet en collision
    if (compute_NoRepeatCol(id, pHo)==NO)
    {
        // Si une action STOP dans le groupe, il faut la faire!!!
        if ((rhPtr->rhEvtProg->rhEventGroup->evgFlags&EVGFLAGS_STOPINGROUP)==0)
            return NO;
        rhPtr->rhEvtProg->rh3DoStop=YES;
    }
    id=( ((int)pHo->hoCreationId)*65536)|(((int)pe->evtIdentifier)&0x0000FFFF);        //; Prend le numero de l'objet en collision
    if (compute_NoRepeatCol(id, pHo1)==NO)            // Deja fait B et A?
    {
        // Si une action STOP dans le groupe, il faut la faire!!!
        if ((rhPtr->rhEvtProg->rhEventGroup->evgFlags&EVGFLAGS_STOPINGROUP)==0)
            return NO;
        rhPtr->rhEvtProg->rh3DoStop=YES;
    }
    
    // Stocke le deuxieme sprite dans la list courante
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (oiEvent<0)
        [rhPtr->rhEvtProg evt_DeleteCurrentQualifier:pe->evtOiList];
    if (oiParam<0)
        [rhPtr->rhEvtProg evt_DeleteCurrentQualifier:pEvp->evp.evpW.evpW0];
    [rhPtr->rhEvtProg evt_AddCurrentObject:pHo];
    [rhPtr->rhEvtProg evt_AddCurrentObject:pHo1];
    
    if (pHo1->rom->rmMovement->rmCollisionCount==rhPtr->rh3CollisionCount)
        pHo->rom->rmMovement->rmCollisionCount=rhPtr->rh3CollisionCount;
    else if (pHo->rom->rmMovement->rmCollisionCount==rhPtr->rh3CollisionCount)
        pHo1->rom->rmMovement->rmCollisionCount=rhPtr->rh3CollisionCount;
    
    return YES;
}


// -----------------------------------------------------
// CONDITION: Selection d'un objet au hasard parmi un OI
// ----------------------------------------------------
BOOL evaChoose(event* pe, CRun* rhPtr, LPHO pHoIn)
{
    [rhPtr->rhEvtProg count_ObjectsFromOiList:pe->evtOiList withStop:-1];        // Combien d'objets?
    int count=rhPtr->rhEvtProg->evtNSelectedObjects;
    if (count==0) return NO;
    unsigned short rnd=[rhPtr random:count];
    LPHO pHo=[rhPtr->rhEvtProg count_ObjectsFromOiList:pe->evtOiList withStop:rnd];    // Va choisir
    
    if ( pe->evtNParams > 0 )
    {
        LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
        multipleFlagAndVariableParam* pMultipleParam = (multipleFlagAndVariableParam*)&pEvp->evp.evpW.evpW0;
        if ( !CheckMultipleFlagAndVariableParam(pMultipleParam, pHo) )
            return NO;
    }
    
    [rhPtr->rhEvtProg evt_ForceOneObject:pe->evtOiList withObject:pHo];
    return YES;
}

// ----------------------------------------------------
// CONDITION: Pick closest Object 1 from Object 2 objects
// ----------------------------------------------------
BOOL evaPickClosest(event* pe, CRun* rhPtr, LPHO pHoIn)
{
    CObject* pHo=[rhPtr->rhEvtProg evt_FirstObject:pe->evtOiList];
    if (pHo==nil)
        return NO;
    //int cpt=rhPtr->rhEvtProg->evtNSelectedObjects;

    // Get list of OIs for the second object (can be a qualifier)
    short* oi2List;
    short oneObjectList[4];
    LPEVP pEvp = (LPEVP)((LPBYTE)pe + CND_SIZE);
    short oi = pEvp->evp.evpW.evpW1;
    if (oi >= 0)
    {
        // Normal object
        oneObjectList[0] = oi;
        oneObjectList[1] = pEvp->evp.evpW.evpW0;
        oneObjectList[2] = -1;
        oneObjectList[3] = -1;
        oi2List = oneObjectList;
    }
    else
    {
        // Qualifier
        CQualToOiList* qoil=rhPtr->rhEvtProg->qualToOiList[pEvp->evp.evpW.evpW0&0x7FFF];
        oi2List=qoil->qoiList;
    }

    // For each object 1
    double minDistance;
	CArrayList* hoList = [[CArrayList alloc] init];
    do {
        // Check if it's closer from object(s) 2 than previous objects 1
        short nOIL;
        short* pShort = oi2List + 1;
        while ((nOIL = *pShort) >= 0)
        {
            CObjInfo* poil = rhPtr->rhOiList[nOIL];

            // Already selected in event?
            if (poil->oilEventCount == rhPtr->rhEvtProg->rh2EventCount)
            {
                // Explore selected object list
                short num = poil->oilListSelected;
                while (num >= 0)
                {
                    CObject* pHo2 = rhPtr->rhObjectList[num];
                    if (pHo2 == NULL)
                        break;
                    if ((pHo2->hoFlags & HOF_DESTROYED) == 0 && pHo2 != pHo)
                    {
                        double distance = (pHo2->hoX - pHo->hoX) * (pHo2->hoX - pHo->hoX) + (pHo2->hoY - pHo->hoY) * (pHo2->hoY - pHo->hoY);
						if ([hoList size] == 0)
						{
							minDistance = distance;
							[hoList add:pHo];
						}
						else if (distance <= minDistance)
						{
							if (distance == minDistance)
								[hoList add:pHo];
							else
							{
								minDistance = distance;
								[hoList clear];
								[hoList add:pHo];
							}
						}
                    }
                    num = pHo2->hoNextSelected;
                }
            }

            // Not selected => take full list
            else
            {
                if (poil->oilNObjects != 0)
                {
                    short nObl = poil->oilObject;
                    do {
                        LPHO pHo2 = rhPtr->rhObjectList[nObl];
                        if (pHo2 == NULL)
                            break;
                        if ((pHo2->hoFlags & HOF_DESTROYED) == 0 && pHo2 != pHo)
                        {
                            double distance = (pHo2->hoX - pHo->hoX) * (pHo2->hoX - pHo->hoX) + (pHo2->hoY - pHo->hoY) * (pHo2->hoY - pHo->hoY);
							if ([hoList size] == 0)
							{
								minDistance = distance;
								[hoList add:pHo];
							}
							else if (distance <= minDistance)
							{
								if (distance == minDistance)
									[hoList add:pHo];
								else
								{
									minDistance = distance;
									[hoList clear];
									[hoList add:pHo];
								}
							}
                        }

                        nObl = pHo2->hoNumNext;
                    } while (nObl >= 0);
                }
            }

            pShort += 2;
        }

        // Next object 1
        pHo=[rhPtr->rhEvtProg evt_NextObject];

    } while (pHo != NULL);

	if ([hoList size] == 0)
	{
		[hoList release];
		return NO;
	}

	if ([hoList size] == 1)
		[rhPtr->rhEvtProg evt_ForceOneObject:pe->evtOiList withObject:(CObject*)[hoList get:0]];
	else
		[rhPtr->rhEvtProg SelectObjects:pe->evtOiList  withHoList:hoList];

	[hoList release];
    return YES;
}

// -------------------------------------------------------
// CONDITION: Pick Object with minimum value of expression
// -------------------------------------------------------
BOOL evaPickMinimumExpressionValue(event* pe, CRun* rhPtr, LPHO pHoIn)
{
    CObject* pHo=[rhPtr->rhEvtProg evt_FirstObject:pe->evtOiList];
    if (pHo==nil)
        return NO;
    //int cpt=rhPtr->rhEvtProg->evtNSelectedObjects;

    // Qualifier?
    int* pQualifierFirstObject = nil;
    int saveQualifierFirstObject;
    if (pe->evtOi < 0)
    {
        // Modify first object in qualifier object list as Get_CurrentExpressionObjects takes the first selected object from this list

        // This is not a very good way of doing things, but it's fast.
        // A more correct way would be to add a special variable in qualToOi and retrieve this in Get_CurrentExpressionObjects,
        // this variable would always point to the first object except in this condition.
        //
        // An even better way would be to add qoiEventCount and qoiFirstSelected variables to qualToOi, those variables would work like oilEventCount and oilFirstSelected,
        // and this would avoid Get_CurrentExpressionObjects to search for the first selected object in qualToOi. But implementing this is another story...

        int nQualifier = (pe->evtOiList & 0x7FFF);
        CQualToOiList* pQoi=rhPtr->rhEvtProg->qualToOiList[nQualifier & 0x7FFF];
        //qualToOi* pQoi = (qualToOi*)((LPBYTE)pRh->rhQualToOiList + (nQualifier & 0x7FFF));
        pQualifierFirstObject = (int*)pQoi->qoiList;
        saveQualifierFirstObject = *pQualifierFirstObject;        // save qoiOi and qoiOiList at the same time (as it's shorts)
    }

    // For each object
    LPEVP pp = (LPEVP)((LPBYTE)pe + CND_SIZE);
    CValue* minValue = rhPtr->evaTmp;
    minValue->type = TYPE_INT;
	CArrayList* hoList = [[CArrayList alloc] init];
    do {
        if ((pHo->hoFlags & HOF_DESTROYED) == 0)
        {
            // Save selection and set current object as first selected (warning: selection chain is broken, this is just for GetExpression)
            CObjInfo* poil = pHo->hoOiList;
            int saveOILEventCount = poil->oilEventCount;
            poil->oilEventCount = rhPtr->rhEvtProg->rh2EventCount;
            short saveOILListSelected = poil->oilListSelected;
            poil->oilListSelected = pHo->hoNumber;
            short saveHONextSelected = pHo->hoNextSelected;        // this is not required for GetExpression but this is in case some extension objects scan the object list in expressions
            pHo->hoNextSelected = -1;
            if (pQualifierFirstObject != nil)
            {
                // Qualifier? force first OI
                short* pQualifierFirstObjectShort = (short*)pQualifierFirstObject;
                *pQualifierFirstObjectShort = pHo->hoOi;
                *(pQualifierFirstObjectShort + 1) = (short)(poil->oilIndex);
            }

            // Evaluate and compare expression
            CValue* value = [rhPtr get_EventExpressionAnyNoCopy:pp];
			if ([hoList size] == 0)
			{
				[minValue forceValue:value];
				[hoList add:pHo];
			}
			else if ([value equal:minValue])
			{
				[hoList add:pHo];
			}
			else if ([value lowerThan:minValue])
			{
				[minValue forceValue:value];
				[hoList clear];
				[hoList add:pHo];
			}

            // Restore selection
            poil->oilEventCount = saveOILEventCount;
            poil->oilListSelected = saveOILListSelected;
            pHo->hoNextSelected = saveHONextSelected;
        }

        // Next object
        pHo=[rhPtr->rhEvtProg evt_NextObject];

    } while (pHo != nil);

    // Restore qualifier object list
    if (pQualifierFirstObject != nil)
    {
        *pQualifierFirstObject = saveQualifierFirstObject;
    }

	if ([hoList size] == 0)
	{
		[hoList release];
		return NO;
	}

	if ([hoList size] == 1)
		[rhPtr->rhEvtProg evt_ForceOneObject:pe->evtOiList withObject:(CObject*)[hoList get:0]];
	else
		[rhPtr->rhEvtProg SelectObjects:pe->evtOiList  withHoList:hoList];

	[hoList release];
    return YES;
}

// -------------------------------------------------------
// CONDITION: Pick Object with maximum value of expression
// -------------------------------------------------------
BOOL evaPickMaximumExpressionValue(event* pe, CRun* rhPtr, LPHO pHoIn)
{
    CObject* pHo=[rhPtr->rhEvtProg evt_FirstObject:pe->evtOiList];
    if (pHo==nil)
        return NO;
    //int cpt=rhPtr->rhEvtProg->evtNSelectedObjects;

    // Qualifier?
    int* pQualifierFirstObject = nil;
    int saveQualifierFirstObject;
    if (pe->evtOi < 0)
    {
        // Modify first object in qualifier object list as Get_CurrentExpressionObjects takes the first selected object from this list

        // This is not a very good way of doing things, but it's fast.
        // A more correct way would be to add a special variable in qualToOi and retrieve this in Get_CurrentExpressionObjects,
        // this variable would always point to the first object except in this condition.
        //
        // An even better way would be to add qoiEventCount and qoiFirstSelected variables to qualToOi, those variables would work like oilEventCount and oilFirstSelected,
        // and this would avoid Get_CurrentExpressionObjects to search for the first selected object in qualToOi. But implementing this is another story...

        int nQualifier = (pe->evtOiList & 0x7FFF);
        //qualToOi* pQoi = (qualToOi*)((LPBYTE)pRh->rhQualToOiList + (nQualifier & 0x7FFF));
        //pQualifierFirstObject = (int*)&pQoi->qoiOi;
        CQualToOiList* pQoi=rhPtr->rhEvtProg->qualToOiList[nQualifier & 0x7FFF];
        pQualifierFirstObject = (int*)pQoi->qoiList;
        saveQualifierFirstObject = *pQualifierFirstObject;        // save qoiOi and qoiOiList at the same time (as it's shorts)
    }

    // For each object
    LPEVP pp = (LPEVP)((LPBYTE)pe + CND_SIZE);
    CValue* maxValue = rhPtr->evaTmp;
    maxValue->type = TYPE_INT;
	CArrayList* hoList = [[CArrayList alloc] init];
    do {
        if ((pHo->hoFlags & HOF_DESTROYED) == 0)
        {
            // Save selection and set current object as first selected (warning: selection chain is broken, this is just for GetExpression)
            CObjInfo* poil = pHo->hoOiList;
            int saveOILEventCount = poil->oilEventCount;
            poil->oilEventCount = rhPtr->rhEvtProg->rh2EventCount;
            short saveOILListSelected = poil->oilListSelected;
            poil->oilListSelected = pHo->hoNumber;
            short saveHONextSelected = pHo->hoNextSelected;        // this is not required for GetExpression but this is in case some extension objects scan the object list in expressions
            pHo->hoNextSelected = -1;
            if (pQualifierFirstObject != nil)
            {
                // Qualifier? force first OI
                short* pQualifierFirstObjectShort = (short*)pQualifierFirstObject;
                *pQualifierFirstObjectShort = pHo->hoOi;
                *(pQualifierFirstObjectShort + 1) = (short)(poil->oilIndex);
            }

            // Evaluate and compare expression
            CValue* value = [rhPtr get_EventExpressionAnyNoCopy:pp];
			if ([hoList size] == 0)
			{
				[maxValue forceValue:value];
				[hoList add:pHo];
			}
			else if ([value equal:maxValue])
			{
				[hoList add:pHo];
			}
			else if ([value greaterThan:maxValue])
			{
				[maxValue forceValue:value];
				[hoList clear];
				[hoList add:pHo];
			}

            // Restore selection
            poil->oilEventCount = saveOILEventCount;
            poil->oilListSelected = saveOILListSelected;
            pHo->hoNextSelected = saveHONextSelected;
        }

        // Next object
        pHo=[rhPtr->rhEvtProg evt_NextObject];

    } while (pHo != nil);

    // Restore qualifier object list
    if (pQualifierFirstObject != nil)
    {
        *pQualifierFirstObject = saveQualifierFirstObject;
    }

	if ([hoList size] == 0)
	{
		[hoList release];
		return NO;
	}

	if ([hoList size] == 1)
		[rhPtr->rhEvtProg evt_ForceOneObject:pe->evtOiList withObject:(CObject*)[hoList get:0]];
	else
		[rhPtr->rhEvtProg SelectObjects:pe->evtOiList  withHoList:hoList];

	[hoList release];
    return YES;
}

// Condition: compare object expression
BOOL evaExtCompare(event* pe, CRun* rhPtr, LPHO pHoIn)
{
    CObject* pHo=[rhPtr->rhEvtProg evt_FirstObject:pe->evtOiList];
    if (pHo==nil)
        return NO;
    int cpt=rhPtr->rhEvtProg->evtNSelectedObjects;

    LPEVP pp = (LPEVP)((LPBYTE)pe + CND_SIZE);
    LPEVP pp2 = (LPEVP)((LPBYTE)pp + pp->evpSize);
    int comp = pp2->evp.evpW.evpW0;

    // Qualifier?
    int* pQualifierFirstObject = NULL;
    int saveQualifierFirstObject;
    if (pe->evtOi < 0)
    {
        // Modify first object in qualifier object list as Get_CurrentExpressionObjects takes the first selected object from this list

        // This is not a very good way of doing things, but it's fast.
        // A more correct way would be to add a special variable in qualToOi and retrieve this in Get_CurrentExpressionObjects,
        // this variable would always point to the first object except in this condition.
        //
        // An even better way would be to add qoiEventCount and qoiFirstSelected variables to qualToOi, those variables would work like oilEventCount and oilFirstSelected,
        // and this would avoid Get_CurrentExpressionObjects to search for the first selected object in qualToOi. But implementing this is another story...

        int nQualifier = (pe->evtOiList & 0x7FFF);
        //qualToOi* pQoi = (qualToOi*)((LPBYTE)pRh->rhQualToOiList + (nQualifier & 0x7FFF));
        //pQualifierFirstObject = (int*)&pQoi->qoiOi;
        CQualToOiList* pQoi=rhPtr->rhEvtProg->qualToOiList[nQualifier & 0x7FFF];
        pQualifierFirstObject = (int*)pQoi->qoiList;
        saveQualifierFirstObject = *pQualifierFirstObject;        // save qoiOi and qoiOiList at the same time (as it's shorts)
    }

    // Optimization if second expression is constant
    CValue* value2 = rhPtr->evaTmp;
    LPEXP pToken = (LPEXP)&pp2->evp.evpW.evpW1;
    LPEXP pNextToken = (LPEXP)((LPBYTE)pToken + pToken->expSize);
    if ((pToken->expCode.expLCode.expCode == EXPL_LONG || pToken->expCode.expLCode.expCode == EXPL_DOUBLE || pToken->expCode.expLCode.expCode == EXPL_VARGLONAMED) && pNextToken->expCode.expLCode.expCode == 0)
    {
        [value2 forceValue:[rhPtr get_EventExpressionAnyNoCopy:pp2]];
        while (pHo != NULL)
        {
            // Save selection and set current object as first selected (warning: selection chain is broken, this is just for GetExpression)
            // We must do this here if the event concerns a qualifier
            CObjInfo* poil = pHo->hoOiList;
            int saveOILEventCount = poil->oilEventCount;
            poil->oilEventCount = rhPtr->rhEvtProg->rh2EventCount;
            short saveOILListSelected = poil->oilListSelected;
            poil->oilListSelected = pHo->hoNumber;
            short saveHONextSelected = pHo->hoNextSelected;        // this is not required for GetExpression but this is in case some extension objects scan the object list in expressions
            pHo->hoNextSelected = -1;
            if (pQualifierFirstObject)
            {
                // Qualifier? force first OI
                short* pQualifierFirstObjectShort = (short*)pQualifierFirstObject;
                *pQualifierFirstObjectShort = pHo->hoOi;
                *(pQualifierFirstObjectShort + 1) = (short)(poil->oilIndex);
            }

            // Get expressions
            CValue* value1 = [rhPtr get_EventExpressionAnyNoCopy:pp];

            // Restore selection
            poil->oilEventCount = saveOILEventCount;
            poil->oilListSelected = saveOILListSelected;
            pHo->hoNextSelected = saveHONextSelected;

            // Compare expressions
            if (!compareTo(value1, value2, comp))
            {
                cpt--;
                [rhPtr->rhEvtProg evt_DeleteCurrentObject];
            }

            pHo = [rhPtr->rhEvtProg evt_NextObject];
        }
    }

    // No optimization => evaluate both expressions for each object
    else
    {
        while (pHo != NULL)
        {
            // Save selection and set current object as first selected (warning: selection chain is broken, this is just for GetExpression)
            CObjInfo* poil = pHo->hoOiList;
            int saveOILEventCount = poil->oilEventCount;
            poil->oilEventCount = rhPtr->rhEvtProg->rh2EventCount;
            short saveOILListSelected = poil->oilListSelected;
            poil->oilListSelected = pHo->hoNumber;
            short saveHONextSelected = pHo->hoNextSelected;        // this is not required for GetExpression but this is in case some extension objects scan the object list in expressions
            pHo->hoNextSelected = -1;
            if (pQualifierFirstObject)
            {
                // Qualifier? force first OI
                short* pQualifierFirstObjectShort = (short*)pQualifierFirstObject;
                *pQualifierFirstObjectShort = pHo->hoOi;
                *(pQualifierFirstObjectShort + 1) = (short)(poil->oilIndex);
            }

            // Get expressions
            CValue* value1 = [rhPtr get_EventExpressionAny:pp];
            [value2 forceValue:[rhPtr get_EventExpressionAnyNoCopy:pp2]];

            // Restore selection
            poil->oilEventCount = saveOILEventCount;
            poil->oilListSelected = saveOILListSelected;
            pHo->hoNextSelected = saveHONextSelected;

            // Compare expressions
            if (!compareTo(value1, value2, comp))
            {
                cpt--;
                [rhPtr->rhEvtProg evt_DeleteCurrentObject];
            }

            pHo = [rhPtr->rhEvtProg evt_NextObject];
        }
    }

    // Restore qualifier object list
    if (pQualifierFirstObject != nil)
    {
        *pQualifierFirstObject = saveQualifierFirstObject;
    }
    return (cpt != 0);
}

// Condition: Compare Layer
BOOL LayerComp(event* pe, CRun* rhPtr, LPHO pHo, int value)
{
    LPEVP pEvp = (LPEVP)((LPBYTE)pe + CND_SIZE);
    return compareTer(pHo->hoLayer + 1, value, pEvp->evp.evpW.evpW0);        // +1 because layer indexes are 1-based
}
BOOL evaExtCmpLayer(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaExpObject(pe, rhPtr, LayerComp);
}

// Condition: compare instance value
BOOL InstanceValueComp(event* pe, CRun* rhPtr, LPHO pHo, int _value)
{
    LPEVP pEvp = (LPEVP)((LPBYTE)pe + CND_SIZE);
    int instanceValue = 0;
    short hlo = pHo->hoHFII;
    if (hlo != (short)-1)
    {
        CLO* loPtr = [rhPtr->rhFrame->LOList getLOFromHandle:hlo];
        if (loPtr != nil)
        {
            instanceValue = loPtr->loValue;
        }
    }
    return compareTer(instanceValue, _value, pEvp->evp.evpW.evpW0);        // +1 because layer indexes are 1-based
}
BOOL evaExtCmpInstanceValue(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaExpObject(pe, rhPtr, InstanceValueComp);
}

// ----------------------------------------------------
// CONDITION: goes Out/In of the playfield avec precision
// ----------------------------------------------------
BOOL eva1GoesInPlayfield(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    
    if ( (pEvp->evp.evpW.evpW0&((short)rhPtr->rhEvtProg->rhCurParam[0]))==0 )    //; Prend le deuxieme parametre (directions)
        return NO;
    
    if (compute_NoRepeatCol(pe->evtIdentifier, pHo))
    {
        [rhPtr->rhEvtProg evt_AddCurrentObject:pHo];                        // Stocke l'objet courant
        return YES;
    }
    
    // Si une action STOP dans le groupe, il faut la faire!!!
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    LPEVG pEvg=rhPtr->rhEvtProg->rhEventGroup;
    if ((pEvg->evgFlags&EVGFLAGS_STOPINGROUP)==0) return NO;
    rhPtr->rhEvtProg->rh3DoStop=YES;
    return YES;
}

BOOL GOut(event* pe, CRun* rhPtr, LPHO pHo)
{
    if ( pHo->rom->rmEventFlags&EF_GOESOUTPLAYFIELD ) return negaTRUE(pe);
    return negaFALSE(pe);
}
BOOL eva2GoesOutPlayfield(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, GOut);
}
BOOL GIn(event* pe, CRun* rhPtr, LPHO pHo)
{
    if ( pHo->rom->rmEventFlags&EF_GOESINPLAYFIELD ) return negaTRUE(pe);
    return negaFALSE(pe);
}
BOOL eva2GoesInPlayfield(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, GIn);
}

// ----------------------------------------------------
// CONDITION: is Out/In of the playfield
// ----------------------------------------------------
BOOL IsOut(event* pe, CRun* rhPtr, LPHO pHo)
{
    int x1=[pHo getX]-pHo->hoImgXSpot;
    int x2=x1+pHo->hoImgWidth;
    int y1=[pHo getY]-pHo->hoImgYSpot;
    int y2=y1+pHo->hoImgHeight;
    if ([rhPtr quadran_In:x1 withY1:y1 andX2:x2 andY2:y2]) return negaTRUE(pe);
    return negaFALSE(pe);
}
BOOL evaIsOutPlayfield(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, IsOut);
}

BOOL IsIn(event* pe, CRun* rhPtr, LPHO pHo)
{
    int x1=[pHo getX]-pHo->hoImgXSpot;
    int x2=x1+pHo->hoImgWidth;
    int y1=[pHo getY]-pHo->hoImgYSpot;
    int y2=y1+pHo->hoImgHeight;
    if ([rhPtr quadran_In:x1 withY1:y1 andX2:x2 andY2:y2]) return negaFALSE(pe);
    return negaTRUE(pe);
}
BOOL evaIsInPlayfield(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, IsIn);
}

// ------------------------------------
// CONDITION: collision with background
// ------------------------------------
// Si appele par le sprite, toujours VRAI car stocke dans la table!
BOOL eva1ColBack(event* pe, CRun* rhPtr, LPHO pHo)
{
    if (compute_NoRepeatCol(pe->evtIdentifier, pHo))                // One shot
    {
        [rhPtr->rhEvtProg evt_AddCurrentObject:pHo];                //; Stocke l'objet courant
        return YES;
    }
    
    // Si une action STOP dans le groupe, il faut la faire!!!
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    LPEVG pEvg=rhPtr->rhEvtProg->rhEventGroup;
    if ((pEvg->evgFlags&EVGFLAGS_STOPINGROUP)==0) return NO;
    rhPtr->rhEvtProg->rh3DoStop=YES;
    return YES;
}

// ----------------------
// En second: continuelle
// ----------------------
BOOL IsColBack(event* pe, CRun* rhPtr, LPHO pHo)
{
    int hoX;
    int hoY;
    if (pe->evtNParams >= 2)
    {
        LPEVP pp=(LPEVP)((LPBYTE)pe+CND_SIZE);
        hoX = [rhPtr get_EventExpressionInt:pp];
        pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
        hoY = [rhPtr get_EventExpressionInt:pp];
    }
    else
    {
        hoX = [pHo getX];
        hoY = [pHo getY];
    }
    if ([rhPtr colMask_TestObject_IXY:pHo withImage:pHo->roc->rcImage andAngle:pHo->roc->rcAngle andScaleX:pHo->roc->rcScaleX andScaleY:pHo->roc->rcScaleY andX:hoX andY:hoY andFoot:0 andPlane:CM_TEST_PLATFORM]) // FRAROT
        return negaTRUE(pe);
    
    return negaFALSE(pe);
}
BOOL eva2ColBack(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, IsColBack);
}

// ----------------------------
// CONDITION: no more of one object
// ----------------------------
BOOL evaNoMoreObject(event* pe, CRun* rhPtr, int sub)
{
    short oil=pe->evtOiList;
    
    if (oil>=0)
    {
        // Un objet normal
        CObjInfo* poil;
        poil=rhPtr->rhOiList[oil];
        if (poil->oilNObjects==0)
            return YES;
        return NO;
    }
    
    // Un qualifier
    if (oil==-1)
        return NO;
    CQualToOiList* pqoi=rhPtr->rhEvtProg->qualToOiList[oil&0x7FFF];
    CObjInfo* poil;
    int count=0;
    int qoi;
    for (qoi=0; qoi<pqoi->nQoi; qoi+=2)
    {
        poil=rhPtr->rhOiList[pqoi->qoiList[qoi+1]];
        count+=poil->oilNObjects;
    };
    count-=sub;                                    //; Moins un si appel lors de killobject qualifier!
    if (count==0)
        return YES;
    return NO;
}
BOOL eva1NoMore(event* pe, CRun* rhPtr, LPHO pHo)
{
    short oi=pe->evtOi;                            // Le bon objet?
    if (oi>=0)
    {
        if (pHo->hoOi!=oi)
            return NO;
        return YES;
    }
    return evaNoMoreObject(pe, rhPtr, 1);
}
BOOL eva2NoMore(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaNoMoreObject(pe, rhPtr, 0);
}


// ------------------------------------------
// CONDITION: no more of one object in a zone
// ------------------------------------------
BOOL evaNoMoreZone(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
	int zone[4];
	GetZoneCoordinates(pEvp, rhPtr, zone);
    int count;
    
    count=[rhPtr->rhEvtProg count_ZoneOneObject:pe->evtOiList withZone:zone];
    if (count!=0) return NO;
    return YES;
}

// ------------------------------------------
// CONDITION: number of objects in a zone=
// ------------------------------------------
BOOL evaNumberZone(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
	int zone[4];
	LPEVP pEvp2 = GetZoneCoordinates(pEvp, rhPtr, zone);
    int count=[rhPtr->rhEvtProg count_ZoneOneObject:pe->evtOiList withZone:zone];    // Pointe la zone
    
    int number=[rhPtr get_EventExpressionInt:pEvp2];                // Evalue l'expression
    return compareTer(count, number, pEvp2->evp.evpW.evpW0);    // Appelle l'operateur
}

// -----------------------------
// CONDITION: number of one objects=
// -----------------------------
BOOL evaNumOfObject(event* pe, CRun* rhPtr, LPHO pHo)
{
    int count=0;
    
    short oil=pe->evtOiList;
    CObjInfo* poil;
    if (oil>=0)
    {
        // Un objet normal
        poil=rhPtr->rhOiList[oil];
        count=poil->oilNObjects;
    }
    else
    {
        // Un qualifier
        if (oil!=-1)
        {
            CQualToOiList* pqoi=rhPtr->rhEvtProg->qualToOiList[oil&0x7FFF];
            int qoi;
            for (qoi=0; qoi<pqoi->nQoi; qoi+=2)
            {
                poil=rhPtr->rhOiList[pqoi->qoiList[qoi+1]];
                count+=poil->oilNObjects;
            }
        }
    }
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    int value=[rhPtr get_EventExpressionInt:pEvp];
    return compareTer(count, value, pEvp->evp.evpW.evpW0);
}

// ---------------------------------------------------------
// CONDITION: object shown
// ---------------------------------------------------------
BOOL IsShown(event* pe, CRun* rhPtr, LPHO pHo)
{
    if (pHo->ros->rsFlags&RSFLAG_HIDDEN) return NO;
    return YES;
}
BOOL evaShown(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, IsShown);
}

// ---------------------------------------------------------
// CONDITION: object hidden
// ---------------------------------------------------------
BOOL IsHidden(event* pe, CRun* rhPtr, LPHO pHo)
{
    if (pHo->ros->rsFlags&RSFLAG_HIDDEN) return YES;
    return NO;
}
BOOL evaHidden(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, IsHidden);
}

// -------------------------------------------------
// CONDITION: object is stopped
// -------------------------------------------------
BOOL IsStopped(event* pe, CRun* rhPtr, LPHO pHo)
{
    if (pHo->roc->rcSpeed==0)
        return negaTRUE(pe);
    return negaFALSE(pe);
}
BOOL evaStopped(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, IsStopped);
}

// -------------------------------------------------
// CONDITION: object is bouncing
// -------------------------------------------------
BOOL IsBouncing(event* pe, CRun* rhPtr, LPHO pHo)
{
    if (pHo->rom->rmBouncing==0) return negaFALSE(pe);
    return negaTRUE(pe);
}
BOOL evaBouncing(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, IsBouncing);
}

// -------------------------------------------------
// CONDITION: object is reversed
// -------------------------------------------------
BOOL IsReversed(event* pe, CRun* rhPtr, LPHO pHo)
{
    if (pHo->rom->rmReverse==0) return negaFALSE(pe);
    return negaTRUE(pe);
}
BOOL evaReversed(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, IsReversed);
}

// -------------------------------------------------
// CONDITION: object facing a direction
// -------------------------------------------------
BOOL IsFacing2(event* pe, CRun* rhPtr, LPHO pHo, int value)
{
    value&=31;
    if ([rhPtr getDir:pHo]==value) return negaTRUE(pe);
    return negaFALSE(pe);
}
BOOL IsFacing1(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    
    int mask=pEvp->evp.evpL.evpL0;
    int dir;
    for (dir=0; dir<32; dir++)
    {
        if ( (1<<dir)&mask )
        {
            if ([rhPtr getDir:pHo]==dir) return negaTRUE(pe);
        }
    }
    return negaFALSE(pe);
}
BOOL evaFacing(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    
    if (pEvp->evpCode==PARAM_NEWDIRECTION)
        return evaObject(pe, rhPtr, IsFacing1);
    
    return evaExpObject(pe, rhPtr, IsFacing2);
}

// ---------------------------------------------------------
// CONDITION: animation is over
// ---------------------------------------------------------
BOOL eva1AnOver(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    
    int ani;
    if (pEvp->evpCode==PARAM_ANIMATION)
    {
        ani=pEvp->evp.evpW.evpW0;                        //; Comparee au parametre animation
    }
    else
    {
        ani=[rhPtr get_EventExpressionInt:pEvp];            // &31 virÈ dans le build 247
    }
    
    if (ani!=rhPtr->rhEvtProg->rhCurParam[0]) return NO;                // L'animation courante
    [rhPtr->rhEvtProg evt_AddCurrentObject:pHo];                            // Stocke l'objet courant
    return YES;
}

BOOL IsOver2(event* pe, CRun* rhPtr, LPHO pHo, int value)
{
    if (value!=pHo->roa->raAnimOn) return NO;
    if (pHo->roa->raAnimNumberOfFrame==0) return YES;
    return NO;
}
BOOL IsOver1(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    if (pEvp->evp.evpW.evpW0!=pHo->roa->raAnimOn) return NO;
    if (pHo->roa->raAnimNumberOfFrame==0) return YES;
    return NO;
}
BOOL eva2AnOver(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    
    if (pEvp->evpCode==PARAM_ANIMATION)                    // Le parametre direction?
        return evaObject(pe, rhPtr, IsOver1);
    
    return evaExpObject(pe, rhPtr, IsOver2);                    // Une expression
}

// ---------------------------------------------------------
// CONDITION: animation is playing
// ---------------------------------------------------------
BOOL IsPlaying2(event* pe, CRun* rhPtr, LPHO pHo, int value)
{
    if (value!=pHo->roa->raAnimOn) return negaFALSE(pe);
    if (pHo->roa->raAnimNumberOfFrame!=0) return negaTRUE(pe);
    return negaFALSE(pe);;
}
BOOL IsPlaying1(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    if (pEvp->evp.evpW.evpW0!=pHo->roa->raAnimOn) return negaFALSE(pe);
    if (pHo->roa->raAnimNumberOfFrame!=0) return negaTRUE(pe);
    return negaFALSE(pe);
}
BOOL evaAnPlaying(event* pe, CRun* rhPtr, LPHO pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    
    if (pEvp->evpCode==PARAM_ANIMATION)                    // Le parametre direction?
        return evaObject(pe, rhPtr, IsPlaying1);
    
    return evaExpObject(pe, rhPtr, IsPlaying2);                // Une expression
}





// ROUTINE: Cree la balle
// ----------------------
void shtCreate(event* pe, CRun* rhPtr, LPHO pHoSource, int x, int y, int dir)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPCDP pCdp=(LPCDP)&pEvp->evp.evpW.evpW0;
    int nLayer = -1;
    if ( pHoSource != nil )
        nLayer = pHoSource->hoLayer;
    int num=[rhPtr f_CreateObject:pCdp->cdpHFII withOIHandle:pCdp->cdpOi andX:x andY:y andDir:dir andFlags:COF_NOMOVEMENT|COF_HIDDEN andLayer:nLayer andNumCreation:-1];
    
    if (num>=0)
    {
        // Cree le movement
        // ----------------
        LPHO pHo=rhPtr->rhObjectList[num];
        pHo->roc->rcDir=dir;                                // Met la direction de depart
        [pHo->rom initSimple:pHo withType:MVTYPE_BULLET andFlag:NO];
        pHo->roc->rcSpeed=((LPSHT)pCdp)->shtSpeed;        // Met la vitesse
        if (pHoSource != nil)
            pHoSource->hoFlags |= HOF_SHOOTER;
        CMoveBullet* mBullet=(CMoveBullet*)pHo->rom->rmMovement;
        [mBullet init2:pHoSource];
        
        // Hide object if layer hidden
        // ---------------------------
        if (nLayer!=-1)
        {
            if ( (pHo->hoOEFlags & OEFLAG_SPRITES) != 0 )
            {
                // Hide object if layer hidden
                CLayer* pLayer = rhPtr->rhFrame->layers[nLayer];
                if ( (pLayer->dwOptions & (FLOPT_TOHIDE|FLOPT_VISIBLE)) != FLOPT_VISIBLE )
                {
                    [pHo->ros obHide];
                }
            }
        }
        
        // Met l'objet dans la liste des objets selectionnes
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        [rhPtr->rhEvtProg evt_AddCurrentObject:pHo];
        
        // Force l'animation SHOOT si definie
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        if (pHoSource->hoOEFlags&OEFLAG_ANIMATIONS)
        {
            if ([pHoSource->roa anim_Exist:ANIMID_SHOOT])
            {
                [pHoSource->roa animation_Force:ANIMID_SHOOT];
                [pHoSource->roa animation_OneLoop];
            }
        }
    }
}

// -------------------------
// ACTION : SHOOT LOOKING AT
// -------------------------
void actShootToward(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    // Peut-on tirer?
    // ~~~~~~~~~~~~~~
//    if (pHo->roa->raAnimOn==ANIMID_SHOOT) return;                //; Deja en train de tirer?
    
    // Cherche la position de creation
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);    // Pointe la deuxieme direction
    int x, y, dir;
    BOOL bRepeat;
    if (read_Position(rhPtr, (LPPOS)&pEvp->evp.evpW.evpW0, 0x10, &x, &y, &dir, &bRepeat, nil))    // Pas de direction / controle coords
    {
        // Trouve la bonne direction
        int x2, y2;
        if (read_Position(rhPtr, (LPPOS)&pEvp2->evp.evpW.evpW0, 0, &x2, &y2, &dir, &bRepeat, nil))
        {
            dir=[CRun get_DirFromPente:x2-x withY:y2-y];                // Calcul des pentes
            
            // Va creer la balle
            shtCreate(pe, rhPtr, pHo, x, y, dir);
        }
    }
}

// -------------------------
// ACTION : SHOOT
// -------------------------
void actShoot(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    // Peut-on tirer?
    // ~~~~~~~~~~~~~~
//    if (pHo->roa->raAnimOn==ANIMID_SHOOT) return;                //; Deja en train de tirer?
    
    // Cherche la position de creation
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    int x, y, dir;
    BOOL bRepeat;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    if (read_Position(rhPtr, (LPPOS)&pEvp->evp.evpW.evpW0, 0x11, &x, &y, &dir, &bRepeat, nil))
    {
        shtCreate(pe, rhPtr, pHo, x, y, dir);                            // Va tout creer
    }
}



// --------------
// ACTION SHUFFLE
// --------------


// Execution des actions : stocke les adresses
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void actShuffle(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    [rhPtr->rhEvtProg->rh2ShuffleBuffer add:pHo];
}

// -------------------------
// ACTION : STOP ANIMATION
// -------------------------
void actAnStop(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    pHo->roa->raAnimStopped=1;
}
// -------------------------
// ACTION : START ANIMATION
// -------------------------
void actAnStart(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    pHo->roa->raAnimStopped=0;
}
// -------------------------
// ACTION : FORCE ANIMATION
// -------------------------
void actAnForce(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int ani;
    if (pEvp->evpCode==PARAM_ANIMATION)
        ani=pEvp->evp.evpW.evpW0;
    else
        ani=[rhPtr get_EventExpressionInt:pEvp];
    
    if (ani < 0)
        ani = 0;
    [pHo->roa animation_Force:ani];
    pHo->roc->rcChanged=YES;                // Build 243
}
// -------------------------
// ACTION : RESTORE ANIMATION
// -------------------------
void actAnRestore(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    [pHo->roa animation_Restore];
    pHo->roc->rcChanged=YES;                 // Build 243
}
// ----------------------------------
// ACTION : FORCE ANIMATION DIRECTION
// ----------------------------------
void actAnDirForce(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int dir;
    if (pEvp->evpCode==PARAM_NEWDIRECTION)
        dir=[rhPtr get_Direction:pEvp->evp.evpL.evpL0];
    else
        dir=[rhPtr get_EventExpressionInt:pEvp];
    
    [pHo->roa animDir_Force:dir];
    pHo->roc->rcChanged=YES;                 // Build 243
}
// ----------------------------------
// ACTION : RESTORE ANIMATION DIRECTION
// ----------------------------------
void actAnDirRestore(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    [pHo->roa animDir_Restore];
    pHo->roc->rcChanged=YES;                 // Build 243
}
// ------------------------------
// ACTION : FORCE ANIMATION SPEED
// ------------------------------
void actAnSpeedForce(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int speed=[rhPtr get_EventExpressionInt:pEvp];
    [pHo->roa animSpeed_Force:speed];
}
// ------------------------------
// ACTION : FORCE ANIMATION FRAME
// ------------------------------
void actAnFrameForce(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int frame=[rhPtr get_EventExpressionInt:pEvp];
    [pHo->roa animFrame_Force:frame];
    pHo->roc->rcChanged=YES;                 // Build 243
}
// ------------------------------
// ACTION : RESTORE ANIMATION SPEED
// ------------------------------
void actAnFrameRestore(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    [pHo->roa animFrame_Restore];
    pHo->roc->rcChanged=YES;                 // Build 243
}
// ------------------------------
// ACTION : RESTORE ANIMATION SPEED
// ------------------------------
void actAnSpeedRestore(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    [pHo->roa animSpeed_Restore];
}
// ------------------------------
// ACTION : RESTART ANIMATION
// ------------------------------
void actAnRestart(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    [pHo->roa anim_Restart];
}

// Condition: Compare angle
BOOL AngleComp(event* pe, CRun* rhPtr, LPHO pHo, double value)
{
    LPEVP pEvp = (LPEVP)((LPBYTE)pe + CND_SIZE);

    double angle = pHo->roc->rcAngle;
    CRunMBase* pMovement = (CRunMBase*)[rhPtr GetMBase:pHo];
    if (pMovement != NULL)
    {
        angle = ((CRunMvtPhysics*)pMovement->m_movement)->GetAngle();
        if (angle == ANGLE_MAGIC)
            angle = pHo->roc->rcAngle;
    }

    return compareTerDouble(angle, value, pEvp->evp.evpW.evpW0);
}
BOOL evaSpr_CmpAngle(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaExpObjectDouble(pe, rhPtr, AngleComp);
}

// Condition: Compare X scale
BOOL XScaleComp(event* pe, CRun* rhPtr, LPHO pHo, double value)
{
    LPEVP pEvp = (LPEVP)((LPBYTE)pe + CND_SIZE);
    return compareTerDouble(pHo->roc->rcScaleX, value, pEvp->evp.evpW.evpW0);
}
BOOL evaSpr_CmpScaleX(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaExpObjectDouble(pe, rhPtr, XScaleComp);
}

// Condition: Compare Y scale
BOOL YScaleComp(event* pe, CRun* rhPtr, LPHO pHo, double value)
{
    LPEVP pEvp = (LPEVP)((LPBYTE)pe + CND_SIZE);
    return compareTerDouble(pHo->roc->rcScaleY, value, pEvp->evp.evpW.evpW0);
}
BOOL evaSpr_CmpScaleY(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaExpObjectDouble(pe, rhPtr, YScaleComp);
}

// -------------------------------
// ACTION : PASTE SPRITE
// -------------------------------

void actPasteSprite(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    // Un cran d'animation sans effet
    if (pHo->roa!=nil)
    {
        [pHo->roa animIn:0];
    }
    
    // Build 241: redraw sprite si paste dans layer 0 : dans MMF 1 on n'avait pas faire Áa, c'est bizarre mais peut-Ítre normal...
    if ( pHo->hoLayer == 0 )
    {
        if (pHo->roc->rcSprite!=nil )
        {
            [rhPtr->rhApp->run->spriteGen activeSprite:pHo->roc->rcSprite withFlags:AS_REDRAW andRect:CRectNil];
        }
    }
    
    // Layer0 ? Stocke dans une table
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    [rhPtr activeToBackdrop:pHo withObstacle:(int)pEvp->evp.evpW.evpW0 andFlag:YES];
}

// -------------------------------
// ACTION : ADD BACKDROP
// -------------------------------
void actSpriteAddBkd(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    // Un cran d'animation sans effet
    if (pHo->roa!=nil)
    {
        [pHo->roa animIn:0];
    }
    
    // Layer 0 ? Stocke dans une table
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    [rhPtr activeToBackdrop:pHo withObstacle:(int)pEvp->evp.evpW.evpW0 andFlag:YES];
}

// -------------------------------
// ACTION : REPLACE COLOR
// -------------------------------
void actReplaceColor(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    // Un cran d'animation sans effet
    if (pHo->roa!=nil)
    {
        [pHo->roa animIn:0];
    }
    
    // Recupere parametres
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    int color1;
    if (pEvp->evpCode==PARAM_COLOUR)
        color1=pEvp->evp.evpL.evpL0;
    else
        color1=[rhPtr get_EventExpressionInt:pEvp];
    color1=swapRGB(color1);
    
    int color2;
    if (pEvp2->evpCode==PARAM_COLOUR)
        color2=pEvp2->evp.evpL.evpL0;
    else
        color2=[rhPtr get_EventExpressionInt:pEvp2];
    color2=swapRGB(color2);

    actSpriteReplaceColor((CObject*)pHo, rhPtr, color1, color2);
    
    //[rhPtr->rhApp->OIList setToReload:pHo->hoOi];
    
    pHo->roc->rcChanged = YES;                    // Build 243 force le redraw
}

void actSpriteReplaceColor(CObject* pHo, CRun* rhPtr, int color1, int color2)
{
    // Build 286.5: colors must be replaced in all animations, not only the current one
    // Also added a flag in images to avoid processing multiple times the same image in this operation
    // And protected image::replacecolors if the image was not yet loaded
    
    // Note: this routine doesn't work like the other runtimes. The other runtimes create
    // new images and modify the image handles in the animations of the object, so that if another
    // object shares images with this one it's not modified.
    
    //if(pHo->roa != nil && pHo->roa->raAnimOffset != nil)
    //{
    //    CAnim* anim = pHo->roa->raAnimOffset;
    //  ...
    //}
    
    CObjectCommon* ocPtr = pHo->hoCommon;
    if ( ocPtr != nil && ocPtr->ocAnimations != nil )
    {
        int a;
        for (a=0; a<ocPtr->ocAnimations->ahAnimMax; a++)
        {
            if ( ocPtr->ocAnimations->ahAnimExists[a] != 0 )
            {
                CAnim* anim = ocPtr->ocAnimations->ahAnims[a];
                for(int d=0; d<32; ++d)
                {
                    CAnimDir* dir = anim->anDirs[d];
                    if(dir != nil)
                    {
                        for(int i=0; i<dir->adNumberOfFrame; ++i)
                        {
                            short handle = dir->adFrames[i];

                            CImage* image = [rhPtr->rhApp->imageBank getImageFromHandle:handle];
//                            CColMask* colMask = rhPtr->rhFrame->colMask;
//                            short* obstacle = colMask->platform + COLMASK_YMARGIN * colMask->lineWidth + COLMASK_XMARGIN/16;
//                            [image loadMask:obstacle withWidth:rhPtr->rhFrame->colMask->width andHeight:rhPtr->rhFrame->colMask->height];

                            if ( ![image isReplacedColorFlag] )
                            {
                                ReplacedColor* replace = (ReplacedColor*)malloc(sizeof(ReplacedColor));
                                replace->oR = getR(color1); replace->oG = getG(color1); replace->oB = getB(color1);
                                replace->rR = getR(color2); replace->rG = getG(color2); replace->rB = getB(color2);
                                replace->replaced = NO;
                                [image->replacedColors add:(void*)replace];
                                [image replaceColors];
                                [image setReplacedColorFlag:YES];
                            }
                        }
                    }
                }
            }
        }
        
        // Rset temporary flag
        for (a=0; a<ocPtr->ocAnimations->ahAnimMax; a++)
        {
            if ( ocPtr->ocAnimations->ahAnimExists[a] != 0 )
            {
                CAnim* anim = ocPtr->ocAnimations->ahAnims[a];
                for(int d=0; d<32; ++d)
                {
                    CAnimDir* dir = anim->anDirs[d];
                    if(dir != nil)
                    {
                        for(int i=0; i<dir->adNumberOfFrame; ++i)
                        {
                            short handle = dir->adFrames[i];
                            CImage* image = [rhPtr->rhApp->imageBank getImageFromHandle:handle];
                            [image setReplacedColorFlag:NO];
                        }
                    }
                }
            }
        }
    }
}

// -------------------------------
// ACTIONS : SET SCALE
// -------------------------------
void SetScale(LPHO pHo, CRun* rhPtr, float fScaleX, float fScaleY, BOOL bResample)
{
    int bOldResample = ((pHo->ros->rsFlags & RSFLAG_SCALE_RESAMPLE) != 0);
    if ( pHo->roc->rcScaleX != fScaleX || pHo->roc->rcScaleY != fScaleY || bOldResample != bResample )
    {
        pHo->roc->rcScaleX = fScaleX;
        pHo->roc->rcScaleY = fScaleY;
        pHo->ros->rsFlags &= ~RSFLAG_SCALE_RESAMPLE;
        if ( bResample )
            pHo->ros->rsFlags |= RSFLAG_SCALE_RESAMPLE;
        
        // Faut-il faire Áa l‡...
        if ( (pHo->hoFlags & HOF_DESTROYED) == 0 )
        {
            ImageInfo ifo=[rhPtr->rhApp->imageBank getImageInfoEx:pHo->roc->rcImage withAngle:pHo->roc->rcAngle andScaleX:fScaleX andScaleY:fScaleY];
            if (ifo.isFound)
            {
                pHo->hoImgWidth = ifo.width;
                pHo->hoImgHeight = ifo.height;
                pHo->hoImgXSpot = ifo.xSpot;
                pHo->hoImgYSpot = ifo.ySpot;
            }
        }
        pHo->roc->rcChanged = YES;
    }
}

void actSetScale(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    // Recupere parametres
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    double fScale = [rhPtr get_EventExpressionDouble:pEvp];
    int bResample = [rhPtr get_EventExpressionInt:pEvp2];
    SetScale(pHo, rhPtr, (float)fScale, (float)fScale, bResample);
}

void actSetScaleX(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    // Recupere parametres
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    double fScale = [rhPtr get_EventExpressionDouble:pEvp];
    int bResample = [rhPtr get_EventExpressionInt:pEvp2];
    SetScale(pHo, rhPtr, (float)fScale, pHo->roc->rcScaleY, bResample);
}

void actSetScaleY(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    // Recupere parametres
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    double fScale = [rhPtr get_EventExpressionDouble:pEvp];
    int bResample = [rhPtr get_EventExpressionInt:pEvp2];
    SetScale(pHo, rhPtr, pHo->roc->rcScaleX, (float)fScale, bResample);
}

// -------------------------------
// ACTION : SET ANGLE
// -------------------------------
void actSetAngle(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    // Recupere parametres
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    float nAngle = [rhPtr get_EventExpressionDouble:pEvp];
    int bAntiA = [rhPtr get_EventExpressionInt:pEvp2];

    CRunMvtPhysics* pMovement = [rhPtr GetPhysicMovement:pHo];
    if (pMovement != nil)
    {
        pMovement->SetAngle(nAngle);
        return;
    }

    nAngle = fmodf(nAngle, 360);
    if ( nAngle < 0 )
        nAngle += 360;
    
    int bOldAntiA = ((pHo->ros->rsFlags & RSFLAG_ROTATE_ANTIA) != 0);
    if ( pHo->roc->rcAngle != nAngle || bOldAntiA != bAntiA )
    {
        pHo->roc->rcAngle = nAngle;
        pHo->ros->rsFlags &= ~RSFLAG_ROTATE_ANTIA;
        if ( bAntiA )
            pHo->ros->rsFlags |= RSFLAG_ROTATE_ANTIA;
        
        // Faut-il faire Áa l‡...
        if ( (pHo->hoFlags & HOF_DESTROYED) == 0 )
        {
            ImageInfo ifo=[rhPtr->rhApp->imageBank getImageInfoEx:pHo->roc->rcImage withAngle:nAngle andScaleX:pHo->roc->rcScaleX andScaleY:pHo->roc->rcScaleY];
            if (ifo.isFound)
            {
                pHo->hoImgWidth = ifo.width;
                pHo->hoImgHeight = ifo.height;
                pHo->hoImgXSpot = ifo.xSpot;
                pHo->hoImgYSpot = ifo.ySpot;
            }
        }
        
        pHo->roc->rcChanged = YES;
    }
}

// -------------------------------
// ACTION : SET DIRECTION
// -------------------------------
void actSetDirection(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    
    int dir;
    if (pEvp->evpCode==PARAM_NEWDIRECTION)
        dir=[rhPtr get_Direction:pEvp->evp.evpL.evpL0];
    else
        dir=[rhPtr get_EventExpressionInt:pEvp];
    
    dir&=31;
    if ([rhPtr getDir:pHo]!=dir)
    {
        pHo->roc->rcDir=dir;
        pHo->roc->rcChanged=YES;
        [pHo->rom->rmMovement setDir:dir];
        
        if (pHo->hoType==OBJ_SPR)
        {
            [pHo->roa animIn:0];
        }
    }
}


// -------------------------------
// ACTION : LOOK AT
// -------------------------------
void actLookAt(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    
    int x, y, dir;
    BOOL bRepeat;
    if (read_Position(rhPtr, (LPPOS)&pEvp->evp.evpW.evpW0, 0, &x, &y, &dir, &bRepeat, nil))
    {
        x-=[pHo getX];
        y-=[pHo getY];
        CRunMvtPhysics* pMovement = [rhPtr GetPhysicMovement:pHo];
        if (pMovement == nil)
        {
            dir=[CRun get_DirFromPente:x withY:y];
            dir&=31;
            if ([rhPtr getDir:pHo]!=dir)
            {
                pHo->roc->rcDir=dir;
                pHo->roc->rcChanged=YES;
                [pHo->rom->rmMovement setDir:dir];
            }
        }
        else
        {
            double angle = atan2(-y, x) * 180.0 / b2_pi;
            if (angle < 0)
                angle += 360.0;
            pMovement->SetAngle((float)angle);
        }
    }
}

// -------------------------------
// ACTION : SET POSITION OF OBJECT
// -------------------------------
void actSetPosition(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    
    int x, y, dir;
    BOOL bRepeat;
    if (read_Position(rhPtr, (LPPOS)&pEvp->evp.evpW.evpW0, 1, &x, &y, &dir, &bRepeat, nil))
    {
        [pHo setPosition:x withY:y];
        //NSLog(@"Dir: %d", dir);
        if(dir!=-1)
        {
            dir &= 31;
            if([rhPtr getDir:pHo] != dir)
            {
                pHo->roc->rcDir = dir;
                pHo->roc->rcChanged = true;
                [pHo->rom->rmMovement setDir:dir];
                if(pHo->hoType == 2)
                    [pHo->roa animIn:0];
                
            }
        }
    }
}

// -------------------------------
// ACTION : SET X POSITION
// -------------------------------
void actSetXPosition(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    
    int x=[rhPtr get_EventExpressionInt:pEvp];
    [pHo setX:x];
}

// -------------------------------
// ACTION : SET Y POSITION
// -------------------------------
void actSetYPosition(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    
    int y=[rhPtr get_EventExpressionInt:pEvp];
    [pHo setY:y];
}

// --------------------------------------------
// ACTION : Wrap this object, et lui seulement!
// --------------------------------------------
void actWrap(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    pHo->rom->rmEventFlags|=EF_WRAP;                // Il faut wrapper
}

// ---------------
// ACTION : Bounce
// ---------------
void actBounce(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    [pHo->rom->rmMovement bounce];
}

// ---------------
// ACTION : Reverse
// ---------------
void actReverse(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    [pHo->rom->rmMovement reverse];
}

// ----------------
// ACTION : Stop
// ----------------
void actStop(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    [pHo->rom->rmMovement stop];
}

// -------------------------
// ACTION : Set speed
// -------------------------
void actSetSpeed(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int speed=[rhPtr get_EventExpressionInt:pEvp];
    
    [pHo->rom->rmMovement setSpeed:speed];
}

// -------------------------
// ACTION : Set acceleration
// -------------------------
void actMvSetAcc(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int acc=[rhPtr get_EventExpressionInt:pEvp];
    [pHo->rom->rmMovement setAcc:acc];
}

// -------------------------
// ACTION : Set deceleration
// -------------------------
void actMvSetDec(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int dec=[rhPtr get_EventExpressionInt:pEvp];
    [pHo->rom->rmMovement setDec:dec];
}

// ---------------------------
// ACTION : Set rotating speed
// ---------------------------
void actMvSetRotSpeed(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int dec=[rhPtr get_EventExpressionInt:pEvp];
    [pHo->rom->rmMovement setRotSpeed:dec];
}

// -----------------------------
// ACTION : Authorised direction
// -----------------------------
void actMvSet8Dirs(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int dirs=pEvp->evp.evpL.evpL0;
    [pHo->rom->rmMovement set8Dirs:dirs];
}

// --------------------------
// ACTION : Set maximum speed
// --------------------------
void actSetMaxSpeed(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int speed=[rhPtr get_EventExpressionInt:pEvp];
    
    [pHo->rom->rmMovement setMaxSpeed:speed];
}

// ---------------------------
// ACTION : Set rotating speed
// ---------------------------
void actSetGravity(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int grav=[rhPtr get_EventExpressionInt:pEvp];
    [pHo->rom->rmMovement setGravity:grav];
}


// ----------------
// ACTION : Start
// ----------------
void actStart(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    [pHo->rom->rmMovement start];
}

// ----------------------
// ACTION : NEXT MOVEMENT
// ----------------------
void actNextMovement(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    [pHo->rom nextMovement:pHo];
}

// --------------------------
// ACTION : PREVIOUS MOVEMENT
// --------------------------
void actPreviousMovement(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    [pHo->rom previousMovement:pHo];
}

// ------------------------
// ACTION : SELECT MOVEMENT
// ------------------------
void actSelectMovement(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    int n;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    if (pEvp->evpCode==PARAM_EXPRESSION)
    {
        n=[rhPtr get_EventExpressionInt:pEvp];
    }
    else
    {
        LPMVTP pMvt=(LPMVTP)&pEvp->evp.evpW.evpW0;
        n=pMvt->mvtNumber;
    }
    [pHo->rom selectMovement:pHo withNumber:n];
}

// -------------------
// ACTION: BRANCH NODE
// -------------------
void actBranchNode(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    NSString* pName=[rhPtr get_EventExpressionString:pEvp];
    
    if (pHo->roc->rcMovementType==MVTYPE_TAPED)
    {
        CMovePath* pPath=(CMovePath*)pHo->rom->rmMovement;
        [pPath mtBranchNode:pName];
    }
}

// -----------------
// ACTION: GOTO NODE
// -----------------
void actGotoNode(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    NSString* pName=[rhPtr get_EventExpressionString:pEvp];
    
    if (pHo->roc->rcMovementType==MVTYPE_TAPED)
    {
        CMovePath* pPath=(CMovePath*)pHo->rom->rmMovement;
        [pPath mtGotoNode:pName];
    }
}

// -------------------------------------------------
// EXPRESSION : GETNMOVEMENT
// -------------------------------------------------
void exp_GetNMovement(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:pHo->rom->rmMvtNum];
}

// ------------------
// ACTION : DISAPPEAR
// ------------------
void actDisappear(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    if (pHo->hoType==OBJ_TEXT)
    {
        CText* pText=(CText*)pHo;
        if (pText->rsHidden&COF_FIRSTTEXT)                //; Le dernier objet texte?
        {
            [pHo->ros obHide];                                        //; Cache pour le moment
            pHo->ros->rsFlags&=~RSFLAG_VISIBLE;
            pHo->hoFlags|=HOF_NOCOLLISION;
        }
        else
        {
            pHo->hoFlags|=HOF_DESTROYED;                        //; NON: on le detruit!
            [rhPtr destroy_Add:pHo->hoNumber];
        }
        return;
    }
    if ((pHo->hoFlags&HOF_DESTROYED)==0)
    {
        pHo->hoFlags|=HOF_DESTROYED;
        if ( (pHo->hoOEFlags&OEFLAG_ANIMATIONS)!=0 || (pHo->hoOEFlags&OEFLAG_SPRITES)!=0)
        {
            // Jouer l'anim disappear
            [rhPtr init_Disappear:pHo];
        }
        else
        {
            // Pas un objet avec animation : destroy
            int number=pHo->hoNumber;
            pHo->hoCallRoutine=NO;
            [rhPtr destroy_Add:number];
        }
    }
}

// -------------------
// ACTION: SHOW
// -------------------
void actShow(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    pHo->ros->rsFlags|=RSFLAG_VISIBLE;
    [pHo->ros obShow];
    pHo->ros->rsFlash=0;
}


// -------------------------------------------------------------------
// SPRITE TO FRONT / BACK
// -------------------------------------------------------------------

// Change la priorite d'un sprite
// ------------------------------

void actSpriteBack(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    if ( pHo->roc->rcSprite!=nil )
    {
        [rhPtr->spriteGen moveSpriteToBack:pHo->roc->rcSprite];
    }
}
void actSpriteFront(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    if ( pHo->roc->rcSprite != nil )
    {
        [rhPtr->spriteGen moveSpriteToFront:pHo->roc->rcSprite];
    }
}

// -------------------
// EXPRESSION: GEt RGB AT
// -------------------
void expSpr_GetRGBAt(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    nextToken();
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    int x=[rhPtr get_ExpressionInt];
    nextToken();
    int y=[rhPtr get_ExpressionInt];
    
    int rgb = 0;
    short img = pHo->roc->rcImage;
    if ( img != 0 )
    {
        CImage* image=[rhPtr->rhApp->imageBank getImageFromHandle:img];
        if (image!=nil)
        {
            rgb=[image getPixel:x withY:y];
            rgb &= 0x00FFFFFF;
        }
    }
    [getCurrentResult() forceInt:rgb];
}

// -------------------------------------------------
// EXPRESSION : Get ScaleX
// -------------------------------------------------
void expSpr_GetScaleX(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    
    [getCurrentResult() forceDouble:pHo->roc->rcScaleX];
}

// -------------------------------------------------
// EXPRESSION : Get ScaleY
// -------------------------------------------------
void expSpr_GetScaleY(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    
    [getCurrentResult() forceDouble:pHo->roc->rcScaleY];
}

// -------------------------------------------------
// EXPRESSION : Get Angle
// -------------------------------------------------
void expSpr_GetAngle(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceDouble:0];
        return;
    }
    double angle = pHo->roc->rcAngle;
    CRunMvtPhysics* pMovement = [rhPtr GetPhysicMovement:pHo];
    if (pMovement != nil)
    {
        angle = pMovement->GetAngle();
        if (angle == ANGLE_MAGIC)
            angle = pHo->roc->rcAngle;
    }
    [getCurrentResult() forceDouble:angle];
}

// -------------------
// ACTION: HIDE
// -------------------
void actHide(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    [pHo->ros obHide];
    pHo->ros->rsFlags&=~RSFLAG_VISIBLE;
    pHo->ros->rsFlash=0;
}

// -----------------------------
// ACTION : FLASH
// -----------------------------
void actFlash(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    [pHo->ros obHide];
    pHo->ros->rsFlags&=~RSFLAG_VISIBLE;
    
    if (pEvp->evpCode == PARAM_TIME)
        pHo->ros->rsFlash=pEvp->evp.evpL.evpL0;
    else
        pHo->ros->rsFlash=[rhPtr get_EventExpressionInt:pEvp];
    pHo->ros->rsFlashCpt=pHo->ros->rsFlash;
}

// -------------------
// VARIABLE
// -------------------
void actSetVar(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    int num;
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    if (pp->evpCode==PARAM_ALTVALUE_EXP)
        num=[rhPtr get_EventExpressionInt:pp];
    else
        num=pp->evp.evpW.evpW0;
    
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    LPEXP pToken = (LPEXP)&pp->evp.evpW.evpW1;
    LPEXP pNextToken = (LPEXP)((LPBYTE)pToken+pToken->expSize);
    
    if (num>=0 && pHo->rov!=nil)
    {
        if ( num >= pHo->rov->rvNumberOfValues )
        {
            if (!GrowAlterableValues(pHo->rov, num+10))
                return;
        }
        
        CValue* value=[pHo->rov getValue:num];
        if ( (pNextToken->expCode.expLCode.expCode<=OPERATOR_START || pNextToken->expCode.expLCode.expCode>=OPERATOR_END) )
        {
            if ( pToken->expCode.expLCode.expCode == EXPL_LONG )
            {
                [value forceInt:pToken->expu.expl.expLParam];
                return;
            }
            if ( pToken->expCode.expLCode.expCode == EXPL_DOUBLE )
            {
                [value forceDouble:pToken->expu.expd.expDouble];
                return;
            }
        }
        CValue* pValue2=[rhPtr get_EventExpressionAnyNoCopy:pp];
        [value forceValue:pValue2];
    }
}

BOOL GrowAlterableValues(CRVal* pRVal, int newNumber)
{
    if(pRVal->rvNumberOfValues == newNumber)
        return true;

    CValue** ptr = (CValue**)realloc(pRVal->rvValues, sizeof(CValue*)*newNumber);
    if ( ptr != NULL )
    {
        if(newNumber > pRVal->rvNumberOfValues)
        {
            //size_t extraspace = newNumber - pRVal->rvNumberOfValues;
            //memset(&ptr[pRVal->rvNumberOfValues], 0, extraspace*sizeof(CValue*));

            for (int n=pRVal->rvNumberOfValues; n<newNumber; n++)
                ptr[n] = [[CValue alloc] initWithInt:0];
        }

        pRVal->rvValues = ptr;
        pRVal->rvNumberOfValues = newNumber;

        return true;
    }
    return false;
}

BOOL GrowAlterableStrings(CRVal* pRVal, int newNumber)
{
    if(pRVal->rvNumberOfStrings == newNumber)
        return true;

    NSString** ptr = (NSString**)realloc(pRVal->rvStrings, sizeof(NSString**)*newNumber);
    if ( ptr != NULL )
    {
        if(newNumber > pRVal->rvNumberOfStrings)
        {
            for (int n=pRVal->rvNumberOfStrings; n<newNumber; n++)
                ptr[n] = @"";
        }
        
        pRVal->rvStrings = ptr;
        pRVal->rvNumberOfStrings = newNumber;
        
        return true;
    }
    return false;
}

void actSetVarString(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int num;
    if (pp->evpCode==PARAM_ALTSTRING_EXP)
        num=[rhPtr get_EventExpressionInt:pp];
    else
        num=pp->evp.evpW.evpW0;
    
    if (num>=0 && pHo->rov!=nil)
    {
        if ( num >= pHo->rov->rvNumberOfStrings )
        {
            if (!GrowAlterableStrings(pHo->rov, num+10))
                return;
        }
        
        if (num<pHo->rov->rvNumberOfStrings)
        {
            pp=(LPEVP)((LPBYTE)pp+pp->evpSize);
            NSString* pString=[rhPtr get_EventExpressionStringNoCopy:pp];
            [pHo->rov setString:num withString:pString];
        }
    }
}

void actAddVar(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    int num;
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    if (pp->evpCode==PARAM_ALTVALUE_EXP)
        num=[rhPtr get_EventExpressionInt:pp];
    else
        num=pp->evp.evpW.evpW0;
    
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    LPEXP pToken = (LPEXP)&pp->evp.evpW.evpW1;
    LPEXP pNextToken = (LPEXP)((LPBYTE)pToken+pToken->expSize);
    
    if (num>=0 && pHo->rov!=nil)
    {
        if ( num >= pHo->rov->rvNumberOfValues )
        {
            if (!GrowAlterableValues(pHo->rov, num+10))
                return;
        }
        
        CValue* value=[pHo->rov getValue:num];
        if ( (pNextToken->expCode.expLCode.expCode<=OPERATOR_START || pNextToken->expCode.expLCode.expCode>=OPERATOR_END) )
        {
            if ( pToken->expCode.expLCode.expCode == EXPL_LONG )
            {
                [value addInt:pToken->expu.expl.expLParam];
                return;
            }
            if ( pToken->expCode.expLCode.expCode == EXPL_DOUBLE )
            {
                [value addDouble:pToken->expu.expd.expDouble];
                return;
            }
        }
        CValue* pValue2=[rhPtr get_EventExpressionAnyNoCopy:pp];
        [value add:pValue2];
    }
}

void actSubVar(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    int num;
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    if (pp->evpCode==PARAM_ALTVALUE_EXP)
        num=[rhPtr get_EventExpressionInt:pp];
    else
        num=pp->evp.evpW.evpW0;
    
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    LPEXP pToken = (LPEXP)&pp->evp.evpW.evpW1;
    LPEXP pNextToken = (LPEXP)((LPBYTE)pToken+pToken->expSize);
    
    if (num>=0 && pHo->rov!=nil)
    {
        if ( num >= pHo->rov->rvNumberOfValues )
        {
            if (!GrowAlterableValues(pHo->rov, num+10))
                return;
        }
        
        CValue* value=[pHo->rov getValue:num];
        if ( (pNextToken->expCode.expLCode.expCode<=OPERATOR_START || pNextToken->expCode.expLCode.expCode>=OPERATOR_END) )
        {
            if ( pToken->expCode.expLCode.expCode == EXPL_LONG )
            {
                [value subInt:pToken->expu.expl.expLParam];
                return;
            }
            if ( pToken->expCode.expLCode.expCode == EXPL_DOUBLE )
            {
                [value subDouble:pToken->expu.expd.expDouble];
                return;
            }
        }
        CValue* pValue2=[rhPtr get_EventExpressionAnyNoCopy:pp];
        [value sub:pValue2];
    }
}

// ------------------------
// ACTION: DISPATCH NUMBER
// ------------------------
void actDispatchVar(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    LPEVP pEvp3=(LPEVP)((LPBYTE)pEvp2+pEvp2->evpSize);
    
    int var;
    if (pEvp->evpCode==PARAM_ALTVALUE_EXP)
    {
        var=[rhPtr get_EventExpressionInt:pEvp];


    }
    else
        var=pEvp->evp.evpW.evpW0;

    if( var < 0 )
        return;

    if (rhPtr->rhEvtProg->rh2ActionLoopCount==0)
    {
        pEvp3->evp.evpL.evpL0=[rhPtr get_EventExpressionInt:pEvp2];
    }
    else
    {
        pEvp3->evp.evpL.evpL0++;
    }
    if (pHo->rov!=0)
    {
        if ( var >= pHo->rov->rvNumberOfValues )
        {
            if ( !GrowAlterableValues(pHo->rov, var+10) )  // C++
                return;
        }
        [[pHo->rov getValue:var] forceInt:pEvp3->evp.evpL.evpL0];
    }
}


// -------------------
// ACTION: CHG FLAG
// -------------------
void actSetFlag(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    if (pHo->rov!=nil)
    {
        DWORD mask;
        LPEXP pToken = (LPEXP)&pEvp->evp.evpW.evpW1;
        LPEXP pNextToken = (LPEXP)((LPBYTE)pToken+pToken->expSize);
        if ( pToken->expCode.expLCode.expCode == EXPL_LONG && (pNextToken->expCode.expLCode.expCode<=OPERATOR_START || pNextToken->expCode.expLCode.expCode>=OPERATOR_END) )
            mask = (1 << pToken->expu.expl.expLParam);
        else
            mask = (1 << [rhPtr get_EventExpressionInt:pEvp]);
        
        pHo->rov->rvValueFlags|=mask;
    }
}

// -------------------
// ACTION: CLR FLAG
// -------------------
void actChgFlag(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    if (pHo->rov!=nil)
    {
        DWORD mask;
        LPEXP pToken = (LPEXP)&pEvp->evp.evpW.evpW1;
        LPEXP pNextToken = (LPEXP)((LPBYTE)pToken+pToken->expSize);
        if ( pToken->expCode.expLCode.expCode == EXPL_LONG && (pNextToken->expCode.expLCode.expCode<=OPERATOR_START || pNextToken->expCode.expLCode.expCode>=OPERATOR_END) )
            mask = (1 << pToken->expu.expl.expLParam);
        else
            mask = (1 << [rhPtr get_EventExpressionInt:pEvp]);
        
        if (pHo->rov->rvValueFlags&mask)
            pHo->rov->rvValueFlags&=~mask;
        else
            pHo->rov->rvValueFlags|=mask;
    }
}

// -------------------
// ACTION: CLR FLAG
// -------------------
void actClrFlag(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    if (pHo->rov!=nil)
    {
        DWORD mask;
        LPEXP pToken = (LPEXP)&pEvp->evp.evpW.evpW1;
        LPEXP pNextToken = (LPEXP)((LPBYTE)pToken+pToken->expSize);
        if ( pToken->expCode.expLCode.expCode == EXPL_LONG && (pNextToken->expCode.expLCode.expCode<=OPERATOR_START || pNextToken->expCode.expLCode.expCode>=OPERATOR_END) )
            mask = (1 << pToken->expu.expl.expLParam);
        else
            mask = (1 << [rhPtr get_EventExpressionInt:pEvp]);
        pHo->rov->rvValueFlags&=~mask;
    }
}

// ----------------------
// ACTION: SET INK EFFECT
// -------------------
void actSetInkEffect(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==NULL) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    
    DWORD mask=pEvp->evp.evpW.evpW0;
    pHo->ros->rsEffect&=~EFFECT_MASK;
    pHo->ros->rsEffect|=mask;
    
    int param=pEvp->evp.evpW.evpW1;
    pHo->ros->rsEffectParam=(DWORD)param;
    
    if(pHo->ros->rsEffect != BOP_BLEND)
        pHo->ros->rsEffectParam = 0;
    
    pHo->roc->rcChanged=YES;
    if (pHo->roc->rcSprite!=nil)
    {
        [rhPtr->spriteGen modifSpriteEffect:pHo->roc->rcSprite withInkEffect:pHo->ros->rsEffect andInkEffectParam:pHo->ros->rsEffectParam andEffectShader:pHo->ros->rsEffectShader];
    }
}

void actSetEffect(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==NULL) return;

    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    char* pName=(char*)&pEvp->evp.evpW.evpW0;

    NSString* name;
    if(rhPtr->rhApp->bUnicode)
        name = [[NSString alloc] initWithCharacters:(unichar*)pName length:strUnicharLen((unichar*)pName)];
    else
        name = [[NSString alloc] initWithCString:pName encoding:NSWindowsCP1252StringEncoding];
        
    int effect=BOP_COPY;
    pHo->ros->rsEffectShader=-1;
    if ([name length] != 0 )
    {
        if ( [name compare:@"Add"] == 0 )
        {
            effect=BOP_ADD;
        }
        else if ( [name compare:@"Invert"] == 0 )
        {
            effect=BOP_INVERT;
        }
        else if ( [name compare:@"Sub"] == 0 )
        {
            effect=BOP_SUB;
        }
        else if ( [name compare:@"Mono"] == 0 )
        {
            effect=BOP_MONO;
        }
        else if ( [name compare:@"Blend"] == 0 )
        {
            effect=BOP_BLEND;
        }
        else if ( [name compare:@"XOR"] == 0 )
        {
            effect=BOP_XOR;
        }
        else if ( [name compare:@"OR"] == 0 )
        {
            effect=BOP_OR;
        }
        else if ( [name compare:@"AND"] == 0 )
        {
            effect=BOP_AND;
        }
        else
        {
            if([pHo checkOrCreateEffectIfNeededByName:name andEffectParam:pHo->ros->rsEffectParam] != -1)
            {
                effect=BOP_EFFECTEX;
                pHo->ros->rsEffectShader=[pHo->hoEffect getIndexShader];
            }
        }
    }
    if(name != nil)
        [name release];
    pHo->ros->rsEffect&=~BOP_MASK; //?? pHo->ros->rsEffect&=~EFFECT_MASK;
    pHo->ros->rsEffect|=effect;
    pHo->roc->rcChanged=YES;
    if (pHo->roc->rcSprite!=nil)
    {
        [rhPtr->spriteGen modifSpriteEffect:pHo->roc->rcSprite withInkEffect:pHo->ros->rsEffect andInkEffectParam:pHo->ros->rsEffectParam andEffectShader:pHo->ros->rsEffectShader];
    }
}
void actSetEffectParam(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==NULL) return;

    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    NSString* paramName=[rhPtr get_EventExpressionStringNoCopy:pp];
    pp = (LPEVP)((LPBYTE)pp+pp->evpSize);
    CValue* paramValue=[rhPtr get_EventExpressionAny:pp];
        
    if((pHo->ros->rsEffect & BOP_MASK) == BOP_EFFECTEX)
    {
       if(pHo->hoEffect != nil)
       {
           bool bModified = NO;
           int paramIndex = [pHo->hoEffect getParamIndex:paramName];
           if(paramIndex != -1)
           {
               bModified = [pHo->hoEffect setParamValue:paramIndex andValue:paramValue];
           }
           if(bModified)
           {
               pHo->roc->rcChanged=YES;
               if (pHo->roc->rcSprite!=nil)
               {
                   [rhPtr->spriteGen modifSpriteEffect:pHo->roc->rcSprite withInkEffect:pHo->ros->rsEffect andInkEffectParam:pHo->ros->rsEffectParam andEffectShader:pHo->ros->rsEffectShader];
               }
           }

       }
    }
}

void actSetEffectParamTexture(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==NULL) return;

    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    NSString* paramName=[rhPtr get_EventExpressionString:pEvp];
    pEvp = (LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    
    NSString* fileName = nil;
    if ( pEvp->evpCode == PARAM_FILENAME )
    {
        if (rhPtr->rhTempString!=nil)
            [rhPtr->rhTempString release];

        char* str = (char*)&pEvp->evp.evpW.evpW0;
        if(rhPtr->rhApp->bUnicode)
            fileName = [[NSString alloc] initWithCharacters:(unichar*)str length:strUnicharLen((unichar*)str)];
        else
            fileName = [[NSString alloc] initWithCString:str encoding:NSWindowsCP1252StringEncoding];
    }
    else
        fileName = [rhPtr get_EventExpressionStringNoCopy:pEvp];

    if(fileName == nil)
        return;

    if((pHo->ros->rsEffect & BOP_MASK) == BOP_EFFECTEX)
    {
       if(pHo->hoEffect != nil)
       {

           int paramIndex = [pHo->hoEffect getParamIndex:paramName];
           if(paramIndex != -1)
           {
               if(rhPtr->rhApp->embeddedFiles != nil)
               {
                   NSData* data = [rhPtr->rhApp loadResourceData:fileName];
                   if(data != nil)
                   {
                       CImage* img = nil;
                       UIImage* imageToLoad = [[UIImage alloc] initWithData:data];
                       if(imageToLoad != nil)
                           img = [CImage loadUIImage:imageToLoad];
                       
                       if(img != nil)
                       {
                           int handle = [rhPtr->rhApp->imageBank addImage:img withXSpot:0 andYSpot:0 andXAP:0 andYAP:0 andCount:0];
                           [pHo->hoEffect setParamAt:paramIndex withTexture:handle];
                       }
                   }
               }
           }
       }
    }
}

// -----------------------------
// ACTION: SET SEMI TRANSPARENCY
// -----------------------------
void actSetSemiTransparency(event* pe, CRun* rhPtr)
{
    CObject* pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==NULL) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int val=[rhPtr get_EventExpressionInt:pEvp];
    
    //Change semitransparency or alpha value?
    if((pHo->ros->rsEffect & BOP_RGBAFILTER) != 0)
    {
        val = clamp(255-val*2, 0, 255);
        pHo->ros->rsEffect = (pHo->ros->rsEffect & BOP_MASK) | BOP_RGBAFILTER;
        
        unsigned int rgbaCoeff = pHo->ros->rsEffectParam;
        unsigned int alphaPart = (unsigned int)val << 24;
        unsigned int rgbPart = (rgbaCoeff & 0x00FFFFFF);
        pHo->ros->rsEffectParam = alphaPart | rgbPart;
    }
    else
    {
        val = clamp(val, 0, 128);
        pHo->ros->rsEffect&=~EFFECT_MASK;
        pHo->ros->rsEffect|=EFFECT_SEMITRANSP;
        pHo->ros->rsEffectParam=(DWORD)val;
    }
    
    pHo->roc->rcChanged=YES;
    if (pHo->roc->rcSprite!=nil)
    {
        [rhPtr->spriteGen modifSpriteEffect:pHo->roc->rcSprite withInkEffect:pHo->ros->rsEffect andInkEffectParam:pHo->ros->rsEffectParam andEffectShader:pHo->ros->rsEffectShader];
    }
}

// ACTION: Set alpha coef
// ----------------------------------------------------------
void actSetAlphaCoef(event* pe, CRun* rhPtr)
{
    CObject* pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    unsigned char alpha = (unsigned char)clamp(255-[rhPtr get_EventExpressionInt:pEvp], 0, 255);
    
    BOOL wasSemi = ((pHo->ros->rsEffect & BOP_RGBAFILTER) == 0);
	if ((pHo->ros->rsEffect & BOP_MASK) == BOP_BLEND)
		pHo->ros->rsEffect = BOP_COPY | BOP_RGBAFILTER;
	else
		pHo->ros->rsEffect = (pHo->ros->rsEffect & BOP_MASK) | BOP_RGBAFILTER;
    unsigned int rgbaCoeff = 0x00FFFFFF;
    
    if(!wasSemi)
        rgbaCoeff = pHo->ros->rsEffectParam;
    
    unsigned int alphaPart = (unsigned int)alpha << 24;
    unsigned int rgbPart = (rgbaCoeff & 0x00FFFFFF);
    pHo->ros->rsEffectParam = alphaPart | rgbPart;
    
    pHo->roc->rcChanged=YES;
    if (pHo->roc->rcSprite!=nil)
        [rhPtr->spriteGen modifSpriteEffect:pHo->roc->rcSprite withInkEffect:pHo->ros->rsEffect andInkEffectParam:pHo->ros->rsEffectParam andEffectShader:pHo->ros->rsEffectShader];
}

// ACTION: Set RGB coef
// ----------------------------------------------------------
void actSetRGBCoef(event* pe, CRun* rhPtr)
{
    CObject* pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    unsigned int argb = (unsigned int)[rhPtr get_EventExpressionInt:pEvp];
    
    BOOL wasSemi = ((pHo->ros->rsEffect & BOP_RGBAFILTER) == 0);
    pHo->ros->rsEffect = (pHo->ros->rsEffect & BOP_MASK) | BOP_RGBAFILTER;
    
    unsigned int rgbaCoeff = pHo->ros->rsEffectParam;
    unsigned int alphaPart;
    if(wasSemi)
    {
        if(pHo->ros->rsEffectParam == -1)
            alphaPart = 0xFF000000;
        else
            alphaPart = (255-pHo->ros->rsEffectParam*2) << 24;
    }
    else
        alphaPart = (rgbaCoeff & 0xFF000000);
    
    unsigned int rgbPart = swapRGB((argb & 0x00FFFFFF));
    unsigned int filter = alphaPart | rgbPart;
    pHo->ros->rsEffectParam = filter;
    
    pHo->roc->rcChanged=YES;
    if (pHo->roc->rcSprite!=nil)
        [rhPtr->spriteGen modifSpriteEffect:pHo->roc->rcSprite withInkEffect:pHo->ros->rsEffect andInkEffectParam:pHo->ros->rsEffectParam andEffectShader:pHo->ros->rsEffectShader];
}

// -------------------------------------------------
// EXPRESSION : Get Semi transparency
// -------------------------------------------------
void exp_GetSemiTransparency(CRun* rhPtr)
{
    CObject* pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    
    int effect = pHo->ros->rsEffect;
    int effectParam = pHo->ros->rsEffectParam;
    unsigned int rgbaCoeff = pHo->ros->rsEffectParam;
    int semi = 0;
    
    if((effect & BOP_MASK)==BOP_EFFECTEX || (effect & BOP_RGBAFILTER) != 0)
    {
        semi = 127-(rgbaCoeff >> 24)/2;
    }
    else
    {
        if(effectParam == -1)
            semi = 0;
        else
            semi = pHo->ros->rsEffectParam;
    }
    [getCurrentResult() forceInt:semi];
}

// -------------------------------------------------
// EXPRESSION : Alpha Coef
// -------------------------------------------------
void exp_AlphaCoef(CRun* rhPtr)
{
    CObject* pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    
    int effect = pHo->ros->rsEffect;
    int effectParam = pHo->ros->rsEffectParam;
    int alpha = 0;
    unsigned int rgbaCoeff = effectParam;
    
    if((effect & BOP_MASK) == BOP_EFFECTEX || (effect & BOP_RGBAFILTER) != 0)
        alpha = 255-(rgbaCoeff >> 24);
    else
    {
        if(effectParam == -1)
            alpha = 0;
        else
            alpha = effectParam*2;
    }
    [getCurrentResult() forceInt:alpha];
}

// -------------------------------------------------
// EXPRESSION : RGB Coef
// -------------------------------------------------
void exp_RGBCoef(CRun* rhPtr)
{
    CObject* pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    
    int effect = pHo->ros->rsEffect;
    int effectParam = pHo->ros->rsEffectParam;
    int rgb = 0;
    unsigned int rgbaCoeff = effectParam;
    
    //Ignores shader effects
    if(((effect & BOP_MASK) >= BOP_EFFECTEX
            && (effect & BOP_MASK) <= BOP_EFFECTEX)
                || (effect & BOP_RGBAFILTER) != 0)
        rgb = swapRGB((rgbaCoeff & 0x00FFFFFF));
    else
        rgb = 0x00FFFFFF;
    [getCurrentResult() forceInt:rgb];
}

// -------------------------------------------------
// EXPRESSION : EffectParam
// -------------------------------------------------
void exp_EffectParam(CRun* rhPtr)
{
    CObject* pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    nextToken();
    NSString* paramName=[rhPtr get_ExpressionString];

    if (pHo==nil || paramName == nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    
    if((pHo->ros->rsEffect & BOP_MASK) == BOP_EFFECTEX)
    {
        if(pHo->hoEffect != nil)
        {
            int index = [pHo->hoEffect getParamIndex:paramName];
            if(index != -1)
            {
                switch ([pHo->hoEffect getParamType:index])
                {
                    case EFFECTPARAM_INTFLOAT4:
                    case EFFECTPARAM_INT:
                        [getCurrentResult() forceInt:[pHo->hoEffect getParamInt:index]];
                        return;
                    case EFFECTPARAM_FLOAT:
                        [getCurrentResult() forceDouble:[pHo->hoEffect getParamFloat:index]];
                        return;
                }
            }
        }
    }
    [getCurrentResult() forceInt:0];
}

// -------------------------------------------------
// EXPRESSION : =flag(n) ###
// -------------------------------------------------
void exp_Flag(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    nextToken();                            // Saute le token
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    int num=[rhPtr get_ExpressionInt];            // Le numero du flag
    num&=31;
    if (pHo->rov!=nil)
    {
        int result=0;
        if (((1<<num)&pHo->rov->rvValueFlags)!=0)
        {
            result=1;
        }
        [getCurrentResult() forceInt:result];
    }
    else
    {
        [getCurrentResult() forceInt:0];
    }
}

// -------------------------------------------------
// EXPRESSION : identifier
// -------------------------------------------------
void exp_Id(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    int id=(pHo->hoCreationId*65536)|(pHo->hoNumber&0xFFFF);
    [getCurrentResult() forceInt:id];
}

// -------------------------------------------------
// EXPRESSION : variable
// -------------------------------------------------
void exp_Var(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    if (pHo->rov!=nil)
    {
        int num=rhPtr->rh4ExpToken->expu.expv.expNum;
        [getCurrentResult() forceValue:[pHo->rov getValue:num]];
    }
    else
    {
        [getCurrentResult() forceInt:0];
    }
}

void exp_VarByIndex(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    nextToken();
    int nVar = [rhPtr get_ExpressionInt];
    if ( pHo != nil && pHo->rov!=nil )
    {
        if ( nVar >= 0 && nVar < pHo->rov->rvNumberOfValues )
        {
            [getCurrentResult() forceValue:[pHo->rov getValue:nVar]];
            return;
        }
    }
    [getCurrentResult() forceInt:0];
}

// -------------------------------------------------
// EXPRESSION : alterable string
// -------------------------------------------------
void exp_VarString(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceString:@""];
        return;
    }
    int num=rhPtr->rh4ExpToken->expu.expv.expNum;
    [getCurrentResult() forceString:[pHo->rov getString:num]];
}

void exp_VarStringByIndex(CRun* rhPtr)
{
    NSString* pStr = @"";
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    nextToken();
    int nVar = [rhPtr get_ExpressionInt];
    if ( pHo != nil )
        pStr = [pHo->rov getString:nVar];
    [getCurrentResult() forceString:pStr];
}

// -------------------------------------------------
// EXPRESSION : x
// -------------------------------------------------
void exp_X(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    // Position is transform to Global
    [getCurrentResult() forceInt:[pHo getX]];
}

// -------------------------------------------------
// EXPRESSION : y
// -------------------------------------------------
void exp_Y(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:[pHo getY]];
}

// -------------------------------------------------
// EXPRESSIONS : XLEFT XRIGHT YTOP YBOTTOM
// -------------------------------------------------
void exp_XLeft(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:[pHo getX]-pHo->hoImgXSpot];
}
void exp_XRight(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:[pHo getX]-pHo->hoImgXSpot+pHo->hoImgWidth];
}
void exp_YTop(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:[pHo getY]-pHo->hoImgYSpot];
}
void exp_YBottom(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:[pHo getY]-pHo->hoImgYSpot+pHo->hoImgHeight];
}

// -------------------------------------------------
// EXPRESSION : x of action point
// -------------------------------------------------
void exp_XAP(CRun* rhPtr)
{
    int x = 0;
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }

    x = [pHo getX];
    if (pHo->hoOEFlags&OEFLAG_ANIMATIONS)
    {
        if ( pHo->roc->rcImage >= 0 )
        {
            ImageInfo ifo=[rhPtr->rhApp->imageBank getImageInfoEx:pHo->roc->rcImage withAngle:pHo->roc->rcAngle andScaleX:pHo->roc->rcScaleX andScaleY:pHo->roc->rcScaleY];
            if (ifo.isFound)
                x += ifo.xAP - ifo.xSpot;
        }
    }
    [getCurrentResult() forceInt:x];
    return;
}

// -------------------------------------------------
// EXPRESSION : y of action point
// -------------------------------------------------
void exp_YAP(CRun* rhPtr)
{
    int y = 0;
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    y = [pHo getY];
    if (pHo->hoOEFlags&OEFLAG_ANIMATIONS)
    {
        if ( pHo->roc->rcImage >= 0 )
        {
            ImageInfo ifo=[rhPtr->rhApp->imageBank getImageInfoEx:pHo->roc->rcImage withAngle:pHo->roc->rcAngle andScaleX:pHo->roc->rcScaleX andScaleY:pHo->roc->rcScaleY];
            if (ifo.isFound)
                y += ifo.yAP - ifo.ySpot;
        }
    }
    [getCurrentResult() forceInt:y];
    return;
}



// -------------------------------------------------
// EXPRESSION : direction
// -------------------------------------------------
void exp_Dir(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:[rhPtr getDir:pHo]];
}

// -------------------------------------------------
// EXPRESSION : image
// -------------------------------------------------
void exp_Image(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:pHo->roa->raAnimFrame];
}

// -------------------------------------------------
// EXPRESSION : numero de l'animation
// -------------------------------------------------
void exp_NAni(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:pHo->roa->raAnimOn];
}

// -------------------------------------------------
// EXPRESSION : vitesse
// -------------------------------------------------
void exp_Speed(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:[pHo->rom->rmMovement getSpeed]];
}

// -------------------------------------------------
// EXPRESSION : acceleration
// -------------------------------------------------
void exp_Acc(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:[pHo->rom->rmMovement getAcc]];
}

// -------------------------------------------------
// EXPRESSION : deceleration
// -------------------------------------------------
void exp_Dec(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:[pHo->rom->rmMovement getDec]];
}

// -------------------------------------------------
// EXPRESSION : gravity
// -------------------------------------------------
void exp_Gravity(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:[pHo->rom->rmMovement getGravity]];
}

// -------------------------------------------------
// EXPRESSION : number of objects
// -------------------------------------------------
void exp_Number(CRun* rhPtr)
{
    // Cherche dans la liste des oi
    short qoil=rhPtr->rh4ExpToken->expu.expo.expOiList;
    CObjInfo* poil;
    if (qoil>=0)
    {
        // Un OI Normal
        poil=rhPtr->rhOiList[qoil];
        [getCurrentResult() forceInt:poil->oilNObjects];
    }
    else
    {
        // Un qualifier
        int count=0;
        if (qoil!=-1)
        {
            CQualToOiList* pqoi=rhPtr->rhEvtProg->qualToOiList[qoil&0x7FFF];
            int qoi;
            for (qoi=0; qoi<pqoi->nQoi; qoi+=2)
            {
                poil=rhPtr->rhOiList[pqoi->qoiList[qoi+1]];
                count+=poil->oilNObjects;
            }
        }
        [getCurrentResult() forceInt:count];
    }
}

// -------------------------------------------------
// EXPRESSION : number of selected objects
// -------------------------------------------------
void exp_NumberOfSelected(CRun* rhPtr)
{
    short qoil = rhPtr->rh4ExpToken->expu.expo.expOiList;
    if (qoil >= 0)
    {
        // Normal object
        CObjInfo* poil = rhPtr->rhOiList[qoil];
        int noSelected = poil->oilNObjects;
        if (poil->oilNObjects > 0)
        {
            // Selected in current event?
            if (poil->oilEventCount == rhPtr->rhEvtProg->rh2EventCount)
            {
                // Number of selected objects
                noSelected = poil->oilNumOfSelected;
                if (noSelected < 0)        // can this happen?
                    noSelected = 0;
            }
        }
        [getCurrentResult() forceInt:noSelected];
    }
    else
    {
        // Qualifier
        int count = 0;
        if (qoil != -1)
        {
            CQualToOiList* pqoi=rhPtr->rhEvtProg->qualToOiList[qoil&0x7FFF];
            int qoi;
            for (qoi=0; qoi<pqoi->nQoi; qoi+=2)
            {
                CObjInfo* poil=rhPtr->rhOiList[pqoi->qoiList[qoi+1]];
                int noSelected = poil->oilNObjects;
                if (poil->oilNObjects > 0)
                {
                    // Selected in current event?
                    if (poil->oilEventCount == rhPtr->rhEvtProg->rh2EventCount)
                    {
                        // Number of selected objects
                        noSelected = poil->oilNumOfSelected;
                        if (noSelected < 0)        // can this happen?
                            noSelected = 0;
                    }
                }
                count += noSelected;
            }
        }
        [getCurrentResult() forceInt:count];
    }
}

// -------------------------------------------------
// EXPRESSION : instance value
// -------------------------------------------------
void exp_InstanceValue(CRun* rhPtr)
{
    int value = 0;
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo != nil)
    {
        short hlo = pHo->hoHFII;
        if (hlo != (short)-1)
        {
            CLO* loPtr = [rhPtr->rhFrame->LOList getLOFromHandle:hlo];
            if (loPtr != nil)
            {
                value = loPtr->loValue;
            }
        }
    }
    [getCurrentResult() forceInt:value];
}

void REXP_WIDTH(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:pHo->hoImgWidth];
}

void REXP_HEIGHT(CRun* rhPtr)
{
    LPHO pHo=(LPHO)[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:pHo->hoImgHeight];
}

void REXP_EXTGETMASS(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    double value = 0;
    if (pHo != nil && [rhPtr GetMBase:pHo] != nil)
        value= [(CMoveExtension*)pHo->rom->rmMovement callMovement:EXP_EXTGETMASS param:0];
    [getCurrentResult() forceDouble:value];
}

void REXP_EXTGETANGULARVELOCITY(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    double value = 0;
    if (pHo != nil && [rhPtr GetMBase:pHo] != nil)
        value= [(CMoveExtension*)pHo->rom->rmMovement callMovement:EXP_EXTGETANGULARVELOCITY param:0];
    [getCurrentResult() forceDouble:value];
}

void REXP_EXTGETNAME(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo != nil)
        [getCurrentResult() forceString:pHo->hoOiList->oilName];
    else
        [getCurrentResult() forceString:@""];
}

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// OBJETS AYANT L'OEFLAG TEXT
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

// CONDITION: is font bold
// ---------------------------------------------------------
BOOL IsBold(event* pe, CRun* rhPtr, LPHO pHo)
{
    CFontInfo* lf;
    
    lf=[CRun getObjectFont:pHo];
    if (lf->lfWeight>=500)
        return YES;
    
    return NO;
}
BOOL evaIsBold(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, IsBold);
}

// CONDITION: is font italic
// ---------------------------------------------------------
BOOL IsItalic(event* pe, CRun* rhPtr, LPHO pHo)
{
    CFontInfo* lf;
    
    lf=[CRun getObjectFont:pHo];
    return lf->lfItalic!=0;
}
BOOL evaIsItalic(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, IsItalic);
}

// CONDITION: is font underline
// ---------------------------------------------------------
BOOL IsUnderline(event* pe, CRun* rhPtr, LPHO pHo)
{
    CFontInfo* lf;
    
    lf=[CRun getObjectFont:pHo];
    return lf->lfUnderline!=0;
}
BOOL evaIsUnderline(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, IsUnderline);
}

// CONDITION: is font strikeout
// ---------------------------------------------------------
BOOL IsStrikeOut(event* pe, CRun* rhPtr, LPHO pHo)
{
    CFontInfo* lf;
    
    lf=[CRun getObjectFont:pHo];
    return lf->lfStrikeOut!=0;
}
BOOL evaIsStrikeOut(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, IsStrikeOut);
}

// ACTION: set font name
// ----------------------------------------------------------
void actSetFontName(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    NSString* pName=[rhPtr get_EventExpressionStringNoCopy:pp];
    
    CFontInfo* lf;
    lf=[CRun getObjectFont:pHo];
    
    [lf setName:pName];
    
    [CRun setObjectFont:pHo withFontInfo:lf andRect:CRectNil];
}

// ACTION: set font size
// ----------------------------------------------------------
void actSetFontSize(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    int newSize=[rhPtr get_EventExpressionInt:pEvp];
    int bResize=[rhPtr get_EventExpressionInt:pEvp2];
    
    CFontInfo* lf;
    lf=[CRun getObjectFont:pHo];
    
    int oldSize=lf->lfHeight;
    if (oldSize<0)
        oldSize=-oldSize;
    
    lf->lfHeight = newSize;
    
    if (bResize==0)
    {
        [CRun setObjectFont:pHo withFontInfo:lf andRect:CRectNil];
    }
    else
    {
        CRect rc;
        float coef = 1.0f;
        if ( oldSize != 0 )
            coef=((float)newSize)/((float)oldSize);
        rc.right=(int)(pHo->hoImgWidth*coef);
        rc.bottom=(int)(pHo->hoImgHeight*coef);
        rc.left=0;
        rc.top=0;
        [CRun setObjectFont:pHo withFontInfo:lf andRect:rc];
    }
}

// ACTION: set bold
// ----------------------------------------------------------
void actSetBold(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int bFlag=[rhPtr get_EventExpressionInt:pp];
    
    CFontInfo* lf;
    lf=[CRun getObjectFont:pHo];
    
    if (bFlag)
        lf->lfWeight=600;
    else
        lf->lfWeight=400;
    
    [CRun setObjectFont:pHo withFontInfo:lf andRect:CRectNil];
}

// ACTION: set Italic
// ----------------------------------------------------------
void actSetItalic(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int bFlag=[rhPtr get_EventExpressionInt:pp];
    
    CFontInfo* lf;
    lf=[CRun getObjectFont:pHo];
    
    lf->lfItalic=(BYTE)bFlag;
    
    [CRun setObjectFont:pHo withFontInfo:lf andRect:CRectNil];
}

// ACTION: set underline
// ----------------------------------------------------------
void actSetUnderline(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int bFlag=[rhPtr get_EventExpressionInt:pp];
    
    CFontInfo* lf;
    lf=[CRun getObjectFont:pHo];
    
    lf->lfUnderline=(BYTE)bFlag;
    
    [CRun setObjectFont:pHo withFontInfo:lf andRect:CRectNil];
}

// ACTION: set strikeout
// ----------------------------------------------------------
void actSetStrikeOut(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    LPEVP pp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int bFlag=[rhPtr get_EventExpressionInt:pp];
    
    CFontInfo* lf;
    lf=[CRun getObjectFont:pHo];
    
    lf->lfStrikeOut=(BYTE)bFlag;
    
    [CRun setObjectFont:pHo withFontInfo:lf andRect:CRectNil];
}

// ACTION: set font color
// ----------------------------------------------------------
void actSetTextColor(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    
    int rgb;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    if (pEvp->evpCode==PARAM_EXPRESSION)
    {
        rgb=[rhPtr get_EventExpressionInt:pEvp];
    }
    else
    {
        rgb=pEvp->evp.evpL.evpL0;
    }
    [CRun setObjectTextColor:pHo withColor:rgb];
}

// EXPRESSION: get font name
// ----------------------------------------------------------
void exp_GetFontName(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceString:@""];
        return;
    }
    
    CFontInfo* lf;
    lf=[CRun getObjectFont:pHo];
    [getCurrentResult() forceString:lf->lfFaceName];
}

// EXPRESSION: get font size
// ----------------------------------------------------------
void exp_GetFontSize(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    
    CFontInfo* lf;
    lf=[CRun getObjectFont:pHo];
    [getCurrentResult() forceInt:lf->lfHeight];
}

// EXPRESSION: get font color
// ----------------------------------------------------------
void exp_GetFontColor(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    int rgb=[CRun getObjectTextColor:pHo];
    [getCurrentResult() forceInt:rgb];
}


// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// GESTION DE LA PRIORITE DES OBJETS SPRITES
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

// ACTION: Move to Front
// ----------------------------------------------------------
void actExtSprFront(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    if ( pHo->roc->rcSprite != nil )
    {
        [rhPtr->spriteGen moveSpriteToFront:pHo->roc->rcSprite];
    }
}

// ACTION: Move to back
// ----------------------------------------------------------
void actExtSprBack(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    if ( pHo->roc->rcSprite != nil )
    {
        [rhPtr->spriteGen moveSpriteToBack:pHo->roc->rcSprite];
    }
}

// ACTION: Move before object
// ----------------------------------------------------------
void actMoveBefore(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPHO pHo2=[rhPtr->rhEvtProg get_ParamActionObjects:pEvp->evp.evpW.evpW0 withAction:pe];
    if ( pHo2 == nil )
        return;
    
    CSprite* pSpr = pHo->roc->rcSprite;
    CSprite* pSpr2 = pHo2->roc->rcSprite;
    
    if ( pSpr != nil && pSpr2 != nil )
    {
        [rhPtr->spriteGen moveSpriteBefore:pSpr withSprite:pSpr2];
    }
}

// ACTION: Move after object
// ----------------------------------------------------------
void actMoveAfter(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPHO pHo2=[rhPtr->rhEvtProg get_ParamActionObjects:pEvp->evp.evpW.evpW0 withAction:pe];
    if ( pHo2 == nil )
        return;
    
    CSprite* pSpr = pHo->roc->rcSprite;
    CSprite* pSpr2 = pHo2->roc->rcSprite;
    
    if ( pSpr != nil && pSpr2 != nil )
    {
        [rhPtr->spriteGen moveSpriteAfter:pSpr withSprite:pSpr2];
    }
}

// ACTION: Move to layer
// ----------------------------------------------------------
void actMoveToLayer(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int nLayer = [rhPtr get_EventExpressionInt:pEvp];
    
    nLayer -= 1;
    if ( nLayer >= 0 && nLayer < rhPtr->rhFrame->nLayers && (int)pHo->hoLayer != nLayer )
    {
        CLayer* pLayer = rhPtr->rhFrame->layers[nLayer];
        pLayer->nZOrderMax++;    // B248
        
        [pHo setLayer:nLayer];
        
        // Show / hide sprite and update z-order index
        if ( (pHo->hoOEFlags & OEFLAG_SPRITES) != 0 )
        {
            // B248
            pHo->ros->rsLayer = nLayer;
            pHo->ros->rsZOrder = pLayer->nZOrderMax;
            
            if ( pHo->roc->rcSprite != nil )
            {
                [rhPtr->spriteGen setSpriteLayer:pHo->roc->rcSprite withLayer:nLayer];
                
                pHo->roc->rcSprite->sprZOrder = pLayer->nZOrderMax;
                
                // Update z-order
                if ( pHo->ros!=nil )
                {
                    // Update the zorder value in the runtime structure (not mandatory, done before DeleteSprite)
                    pHo->ros->rsZOrder = pHo->roc->rcSprite->sprZOrder;
                    
                    // Hide object if new layer is hidden
                    if ( (pLayer->dwOptions & (FLOPT_TOHIDE|FLOPT_VISIBLE)) != FLOPT_VISIBLE )
                    {
                        [rhPtr->spriteGen activeSprite:pHo->roc->rcSprite withFlags:AS_REDRAW andRect:CRectNil];    // AS_ACTIVATE);
                        [pHo->ros obHide];
                    }
                    else
                    {
                        // Show object if new layer is visible
                        if ( (pHo->ros->rsFlags&RSFLAG_VISIBLE) != 0 && (pHo->ros->rsFlags&RSFLAG_HIDDEN) != 0 &&
                            (pLayer->dwOptions & (FLOPT_TOHIDE|FLOPT_VISIBLE)) == FLOPT_VISIBLE )
                        {
                            [pHo->ros obShow];
                        }
                    }
                }
            }
        }
    }
}


// EXPRESSION: get layer
// ----------------------------------------------------------
void exp_GetLayer(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    [getCurrentResult() forceInt:pHo->hoLayer + 1];
}


// -----------------------------------------------------------------------
// CCA OBJECT
// -----------------------------------------------------------------------
BOOL CcaFrameChanged(event* pe, CRun* rhPtr, LPHO pHo)
{
    CCCA* pCca=(CCCA*)pHo;
    if ([pCca frameChanged])
        return negaTRUE(pe);
    else
        return negaFALSE(pe);
}
BOOL evaCCAFRAMECHANGED(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, CcaFrameChanged);
}
BOOL CcaAppFinished(event* pe, CRun* rhPtr, LPHO pHo)
{
    CCCA* pCca=(CCCA*)pHo;
    if ([pCca appFinished])
        return negaTRUE(pe);
    else
        return negaFALSE(pe);
}
BOOL evaCCAAPPFINISHED(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, CcaAppFinished);
}
BOOL CcaIsVisible(event* pe, CRun* rhPtr, LPHO pHo)
{
    CCCA* pCca=(CCCA*)pHo;
    if ([pCca isVisible])
        return negaTRUE(pe);
    else
        return negaFALSE(pe);
}
BOOL evaCCAISVISIBLE(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, CcaIsVisible);
}
BOOL CcaAppPaused(event* pe, CRun* rhPtr, LPHO pHo)
{
    CCCA* pCca=(CCCA*)pHo;
    if ([pCca isPaused])
        return negaTRUE(pe);
    else
        return negaFALSE(pe);
}
BOOL evaCCAAPPPAUSED(event* pe, CRun* rhPtr, LPHO pHo)
{
    return evaObject(pe, rhPtr, CcaAppPaused);
}

void actCCARESTARTAPP(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    CCCA* pCca=(CCCA*)pHo;
    [pCca restartApp];
}
void actCCARESTARTFRAME(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    CCCA* pCca=(CCCA*)pHo;
    [pCca restartFrame];
}
void actCCANEXTFRAME(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    CCCA* pCca=(CCCA*)pHo;
    [pCca nextFrame];
}
void actCCAPREVIOUSFRAME(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    CCCA* pCca=(CCCA*)pHo;
    [pCca previousFrame];
}
void actCCAENDAPP(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    CCCA* pCca=(CCCA*)pHo;
    [pCca endApp];
}
void actCCAJUMPFRAME(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    CCCA* pCca=(CCCA*)pHo;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int number=[rhPtr get_EventExpressionInt:pEvp];
    [pCca jumpFrame:number];
}
void RACT_CCASETWIDTH(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int width=[rhPtr get_EventExpressionInt:pEvp];
    [pHo setWidth:width];
}
void RACT_CCASETHEIGHT(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int height=[rhPtr get_EventExpressionInt:pEvp];
    [pHo setHeight:height];
}
void actCCASETGLOBALVALUE(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    CCCA* pCca=(CCCA*)pHo;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int number=[rhPtr get_EventExpressionInt:pEvp]-1;
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    CValue* value=[rhPtr get_EventExpressionAnyNoCopy:pEvp2];
    [pCca setGlobalValue:number withValue:value];
}
void actCCASHOW(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    CCCA* pCca=(CCCA*)pHo;
    [pCca show];
}
void actCCAHIDE(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    CCCA* pCca=(CCCA*)pHo;
    [pCca hide];
}
void actCCASETGLOBALSTRING(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    CCCA* pCca=(CCCA*)pHo;
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    int number=[rhPtr get_EventExpressionInt:pEvp]-1;
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    NSString* value=[rhPtr get_EventExpressionStringNoCopy:pEvp2];
    [pCca setGlobalString:number withString:value];
}

void actCCAPAUSEAPP(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    CCCA* pCca=(CCCA*)pHo;
    [pCca pause];
}
void actCCARESUMEAPP(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil) return;
    CCCA* pCca=(CCCA*)pHo;
    [pCca resume];
}
void expCCAGETFRAMENUMBER(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        [getCurrentResult() forceInt:0];
        return;
    }
    CCCA* pCca=(CCCA*)pHo;
    [getCurrentResult() forceInt:[pCca getFrameNumber]];
}
void expCCAGETGLOBALVALUE(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        nextToken();                        // Saute le token
        [rhPtr get_ExpressionInt];
        [getCurrentResult() forceInt:0];
        return;
    }
    CCCA* pCca=(CCCA*)pHo;
    nextToken();                        // Saute le token
    int num=[rhPtr get_ExpressionInt]-1;
    [getCurrentResult() forceValue:[pCca getGlobalValue:num]];
}
void expCCAGETGLOBALSTRING(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    if (pHo==nil)
    {
        nextToken();                        // Saute le token
        [rhPtr get_ExpressionInt];
        [getCurrentResult() forceString:@""];
        return;
    }
    CCCA* pCca=(CCCA*)pHo;
    nextToken();                        // Saute le token
    int num=[rhPtr get_ExpressionInt]-1;
    [getCurrentResult() forceString:[pCca getGlobalString:num]];
}


////////////////////////////////////////////////////////////////////////
//
// BOX2D MOVEMENTS
//
////////////////////////////////////////////////////////////////////////
void RACT_EXTSETFRICTION(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    if ([rhPtr GetMBase:pHo]!=nil)
    {
        LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
        int friction=[rhPtr get_EventExpressionInt:pEvp];
        [(CMoveExtension*)pHo->rom->rmMovement callMovement:ACT_EXTSETFRICTION param:friction];
    }
}
void RACT_EXTSETELASTICITY(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    if ([rhPtr GetMBase:pHo]!=nil)
    {
        LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
        int elasticity=[rhPtr get_EventExpressionInt:pEvp];
        [(CMoveExtension*)pHo->rom->rmMovement callMovement:ACT_EXTSETELASTICITY param:elasticity];
    }
}
void RACT_EXTAPPLYIMPULSE(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    if ([rhPtr GetMBase:pHo]!=nil)
    {
        LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
        int param0=[rhPtr get_EventExpressionInt:pEvp];
        pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
        int param1=[rhPtr get_EventExpressionInt:pEvp];
        [(CMoveExtension*)pHo->rom->rmMovement callMovement2:ACT_EXTAPPLYIMPULSE param:param0 param2:param1];
    }
}
void RACT_EXTAPPLYANGULARIMPULSE(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    if ([rhPtr GetMBase:pHo]!=nil)
    {
        LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
        int torque=[rhPtr get_EventExpressionInt:pEvp];
        [(CMoveExtension*)pHo->rom->rmMovement callMovement:ACT_EXTAPPLYANGULARIMPULSE param:torque];
    }
}
void RACT_EXTAPPLYFORCE(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    if ([rhPtr GetMBase:pHo]!=nil)
    {
        LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
        int param0=[rhPtr get_EventExpressionInt:pEvp];
        pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
        int param1=[rhPtr get_EventExpressionInt:pEvp];
        [(CMoveExtension*)pHo->rom->rmMovement callMovement2:ACT_EXTAPPLYFORCE param:param0 param2:param1];
    }
}
void RACT_EXTSTOPFORCE(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    if ([rhPtr GetMBase:pHo]!=nil)
    {
        [(CMoveExtension*)pHo->rom->rmMovement callMovement:ACT_EXTSTOPFORCE param:0];
    }
}
void RACT_EXTSTOPTORQUE(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    if ([rhPtr GetMBase:pHo]!=nil)
    {
        [(CMoveExtension*)pHo->rom->rmMovement callMovement:ACT_EXTSTOPTORQUE param:0];
    }
}
void RACT_EXTAPPLYTORQUE(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    if ([rhPtr GetMBase:pHo]!=nil)
    {
        LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
        int torque=[rhPtr get_EventExpressionInt:pEvp];
        [(CMoveExtension*)pHo->rom->rmMovement callMovement:ACT_EXTAPPLYTORQUE param:torque];
    }
}
void RACT_EXTSETLINEARVELOCITY(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    if ([rhPtr GetMBase:pHo]!=nil)
    {
        LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
        double param0=[rhPtr get_EventExpressionDouble:pEvp];
        pEvp=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
        double param1=[rhPtr get_EventExpressionDouble:pEvp];
        [(CMoveExtension*)pHo->rom->rmMovement callMovement2:ACT_EXTSETLINEARVELOCITY param:param0 param2:param1];
    }
}

void RACT_EXTSETANGULARVELOCITY(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    if ([rhPtr GetMBase:pHo]!=nil)
    {
        LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
        int torque=[rhPtr get_EventExpressionInt:pEvp];
        [(CMoveExtension*)pHo->rom->rmMovement callMovement:ACT_EXTSETANGULARVELOCITY param:torque];
    }
}

void REXP_EXTGETFRICTION(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    int value = 0;
    if (pHo != nil && [rhPtr GetMBase:pHo] != nil)
        value= [(CMoveExtension*)pHo->rom->rmMovement callMovement:EXP_EXTGETFRICTION param:0];
    [getCurrentResult() forceInt:value];
}
void REXP_EXTGETRESTITUTION(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    int value = 0;
    if (pHo != nil && [rhPtr GetMBase:pHo] != nil)
        value= [(CMoveExtension*)pHo->rom->rmMovement callMovement:EXP_EXTGETRESTITUTION param:0];
    [getCurrentResult() forceInt:value];
}
void REXP_EXTGETDENSITY(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    int value = 0;
    if (pHo != nil && [rhPtr GetMBase:pHo] != nil)
        value= [(CMoveExtension*)pHo->rom->rmMovement callMovement:EXP_EXTGETDENSITY param:0];
    [getCurrentResult() forceInt:value];
}
void REXP_EXTGETVELOCITY(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    double value = 0;
    if (pHo != nil && [rhPtr GetMBase:pHo] != nil)
        value= [(CMoveExtension*)pHo->rom->rmMovement callMovement:EXP_EXTGETVELOCITY param:0];
    [getCurrentResult() forceDouble:value];
}
void REXP_EXTGETANGLE(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    int value = 0;
    if (pHo != nil && [rhPtr GetMBase:pHo] != nil)
        value= [(CMoveExtension*)pHo->rom->rmMovement callMovement:EXP_EXTGETANGLE param:0];
    [getCurrentResult() forceInt:value];
}

void REXP_DISTANCE(CRun* rhPtr)
{
    nextToken();
    int x1=[rhPtr get_ExpressionInt];
    nextToken();
    int y1=[rhPtr get_ExpressionInt];
    nextToken();
    int x2=[rhPtr get_ExpressionInt];
    nextToken();
    int y2=[rhPtr get_ExpressionInt];
    double deltaX=x2-x1;
    double deltaY=y2-y1;
    [getCurrentResult() forceInt:(int)sqrt(deltaX*deltaX+deltaY*deltaY)];
}
void REXP_ANGLE(CRun* rhPtr)
{
    nextToken();
    int x1=[rhPtr get_ExpressionInt];
    nextToken();
    int y1=[rhPtr get_ExpressionInt];
    int angle=(int)(atan2((float)-y1, (float)x1)*180.0f/3.141592653589f);
    if (angle<0)
        angle=360+angle;
    [getCurrentResult() forceInt:angle];
}
void REXP_EXTDISTANCE(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    nextToken();
    int x2 = [rhPtr get_ExpressionInt];
    nextToken();
    int y2 = [rhPtr get_ExpressionInt];
    if ( pHo != nil )
    {
        double deltaX=x2-[pHo getX];
        double deltaY=y2-[pHo getY];
        [getCurrentResult() forceInt:(int)sqrt(deltaX*deltaX+deltaY*deltaY)];
        return;
    }
    [getCurrentResult() forceInt:0];
}
void REXP_EXTANGLE(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    nextToken();
    int x2=[rhPtr get_ExpressionInt];
      nextToken();
    int y2=[rhPtr get_ExpressionInt];
    if ( pHo != nil )
    {
        int angle=(int)(atan2((float)-(y2-[pHo getY]), (float)(x2-[pHo getX]))*180.0f/3.141592653589f);
        if (angle<0)
            angle=360+angle;
        [getCurrentResult() forceInt:angle];
        return;
    }
    [getCurrentResult() forceInt:0];
}
void REXP_RANGE(CRun* rhPtr)
{
    nextToken();
    CValue* value=[rhPtr get_ExpressionAny];
    nextToken();
    CValue* minimum=[rhPtr get_ExpressionAny];
    nextToken();
    CValue* maximum=[rhPtr get_ExpressionAny];
    
    if ([value getType]==TYPE_DOUBLE || [minimum getType]==TYPE_DOUBLE || [maximum getType]==TYPE_DOUBLE)
    {
        double dValue=[value getDouble];
        double dMinimum=[minimum getDouble];
        double dMaximum=[maximum getDouble];
        if (dValue < dMinimum)
            dValue = dMinimum;
        if (dValue > dMaximum)
            dValue = dMaximum;
        [getCurrentResult() forceDouble:dValue];
    }
    else
    {
        int lValue=[value getInt];
        int lMinimum=[minimum getInt];
        int lMaximum=[maximum getInt];
        if (lValue < lMinimum)
            lValue = lMinimum;
        if (lValue > lMaximum)
            lValue = lMaximum;
        [getCurrentResult() forceInt:lValue];
    }
}
void REXP_RANDOMRANGE(CRun* rhPtr)
{
    nextToken();
    int minimum=[rhPtr get_ExpressionInt];
    nextToken();
    int maximum=[rhPtr get_ExpressionInt];
    [getCurrentResult() forceInt:(int)minimum+[rhPtr random:maximum-minimum+1]];
}

//int countForEach = 0;
void endForEach(CRun* rhPtr)
{
    rhPtr->rhEvtProg->bEndForEach = NO;
    
    LPFOREACH saveForEach = rhPtr->rh4CurrentForEach;
    LPFOREACH saveForEach2 = rhPtr->rh4CurrentForEach2;
    
    LPFOREACH pForEach2=nil;
    LPFOREACH pPrevious = nil;
    while(TRUE)
    {
        LPFOREACH pForEach=rhPtr->rh4ForEachs;
        while(pForEach!=nil)
        {
            if (pForEach->index<0)
            {
                pForEach2 = (LPFOREACH)pForEach->next;
                if (pForEach2 != nil)
                {
                    if ([pForEach->name caseInsensitiveCompare:pForEach2->name]!=0)
                        pForEach2 = nil;
                }
                break;
            }
            pPrevious = pForEach;
            pForEach=(LPFOREACH)pForEach->next;
        }
        if (pForEach == nil)
            break;
        
		int nCondition = CNDL_EXTONLOOP;
		int nCondition2 = CNDL_EXTONLOOP;
		NSMutableDictionary* pOnEachLoopConditionIndexes = nil;
		if (pForEach->number > 0)
		{
			LPHO pHo = pForEach->objects[0];
			pOnEachLoopConditionIndexes = (pHo->hoType == OBJ_SPR) ? rhPtr->rhEvtProg->onEachLoopConditionIndexesActives : rhPtr->rhEvtProg->onEachLoopConditionIndexes;
		}
		if (pOnEachLoopConditionIndexes != nil)
		{
			NSNumber* value = [pOnEachLoopConditionIndexes objectForKey:pForEach->name];
			if (value != nil)
				nCondition = -[value intValue] * 65536;
			if (pForEach2)
			{
				pOnEachLoopConditionIndexes = NULL;
				if (pForEach2->number > 0)
				{
					LPHO pHo2 = pForEach2->objects[0];
					pOnEachLoopConditionIndexes = (pHo2->hoType == OBJ_SPR) ? rhPtr->rhEvtProg->onEachLoopConditionIndexesActives : rhPtr->rhEvtProg->onEachLoopConditionIndexes;
				}
				if (pOnEachLoopConditionIndexes != nil && (value = [pOnEachLoopConditionIndexes objectForKey:pForEach2->name]) != nil)
					nCondition2 = -[value intValue] * 65536;
			}
		}

		pForEach->stop=NO;
        for (pForEach->index=0; pForEach->index<pForEach->number; pForEach->index++)
        {
            rhPtr->rh4CurrentForEach=pForEach;
            rhPtr->rh4CurrentForEach2=pForEach2;
            if (pForEach2)
                pForEach2->index = pForEach->index;
            rhPtr->rhEvtProg->rh2ActionOn=0;
            [rhPtr->rhEvtProg handle_Event:pForEach->objects[pForEach->index] withCode:nCondition];
            if (pForEach->stop)
                break;
        }
        if (pForEach2)
        {
            pForEach2->stop = NO;
            for (pForEach2->index=0; pForEach2->index<pForEach2->number; pForEach2->index++)
            {
                rhPtr->rh4CurrentForEach2=pForEach2;
                rhPtr->rh4CurrentForEach=pForEach;
                if (pForEach)
                    pForEach->index = pForEach2->index;
                rhPtr->rhEvtProg->rh2ActionOn=0;
                [rhPtr->rhEvtProg handle_Event:pForEach2->objects[pForEach2->index] withCode:nCondition2];
                if (pForEach2->stop)
                    break;
            }
        }
        if (pForEach2)
        {
            [pForEach2->name release];
            pForEach->next = pForEach2->next;
            free(pForEach2);
        }
        [pForEach->name release];
        if (pPrevious==nil)
            rhPtr->rh4ForEachs = (LPFOREACH)pForEach->next;
        else
            pPrevious->next = pForEach->next;
        free(pForEach);
    }
    rhPtr->rh4CurrentForEach=saveForEach;
    rhPtr->rh4CurrentForEach2=saveForEach2;
}
void REXP_EXTLOOPINDEX(CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
    LPFOREACH pForEach=rhPtr->rh4CurrentForEach;
    if (pForEach!=nil)
    {
        BOOL flag = NO;
        if (pForEach->oi >= 0)
        {
            if (pHo->hoOi==pForEach->oi)
            {
                flag = YES;
            }
        }
        else
        {
            if (pForEach->oi == rhPtr->rh4ExpToken->expu.expo.expOi)
            {
                flag = YES;
            }
        }
        if (flag)
        {
            [getCurrentResult() forceInt:pForEach->index];
            return;
        }
    }
    pForEach=rhPtr->rh4CurrentForEach2;
    if (pForEach!=nil)
    {
        BOOL flag = NO;
        if (pForEach->oi >= 0)
        {
            if (pHo->hoOi==pForEach->oi)
            {
                flag = YES;
            }
        }
        else
        {
            if (pForEach->oi == rhPtr->rh4ExpToken->expu.expo.expOi)
            {
                flag = YES;
            }
        }
        if (flag)
        {
            [getCurrentResult() forceInt:pForEach->index%pForEach->number];
            return;
        }
    }
    [getCurrentResult() forceInt:0];
}

BOOL RCND_EXTONLOOP(event* pe, CRun* rhPtr, CObject* pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    
    NSString* pName;
    LPEXP pToken = (LPEXP)&pEvp->evp.evpW.evpW1;
    if (pToken->expCode.expSCode.expType==-1 && pToken->expCode.expSCode.expNum==3 && ((LPEXP)((LPBYTE)pToken+pToken->expSize))->expCode.expLCode.expCode==0)
        pName=(NSString*)[rhPtr->rhEvtProg->allocatedStrings get:pToken->expu.expw.expWParam0];
    else
        pName=[rhPtr get_EventExpressionStringNoCopy:pEvp];
    if (pName==nil)
        return NO;
    
    multipleFlagAndVariableParam* pMultipleParam = NULL;
    if ( pe->evtNParams > 1 )
    {
        LPEVP pEvp2 = EVPNEXT(pEvp);
        pMultipleParam = (multipleFlagAndVariableParam*)&pEvp2->evp.evpW.evpW0;
    }
    
    if (rhPtr->rh4CurrentForEach!=nil)
    {
        if ([rhPtr->rh4CurrentForEach->name caseInsensitiveCompare:pName]==0)
        {
            if ( pMultipleParam )
            {
                if ( !CheckMultipleFlagAndVariableParam(pMultipleParam, pHo) )
                    return NO;
            }
            [rhPtr->rhEvtProg evt_ForceOneObject:pe->evtOiList withObject:pHo];
            return YES;
        }
    }
    if (rhPtr->rh4CurrentForEach2!=nil)
    {
        if ([rhPtr->rh4CurrentForEach2->name caseInsensitiveCompare:pName]==0)
        {
            if ( pMultipleParam )
            {
                if ( !CheckMultipleFlagAndVariableParam(pMultipleParam, pHo) )
                    return NO;
            }
            [rhPtr->rhEvtProg evt_ForceOneObject:pe->evtOiList withObject:pHo];
            return YES;
        }
    }
    return NO;
}

BOOL RCND_EXTONLOOP_INTERNAL(event* pe, CRun* rhPtr, CObject* pHo)
{
	if (rhPtr->rh4CurrentForEach!=nil || rhPtr->rh4CurrentForEach2!=nil)
	{
		multipleFlagAndVariableParam* pMultipleParam = NULL;
		if ( pe->evtNParams > 1 )
		{
			LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
			LPEVP pEvp2 = EVPNEXT(pEvp);
			pMultipleParam = (multipleFlagAndVariableParam*)&pEvp2->evp.evpW.evpW0;
		}
    
		if ( pMultipleParam )
		{
			if ( !CheckMultipleFlagAndVariableParam(pMultipleParam, pHo) )
				return NO;
		}
		[rhPtr->rhEvtProg evt_ForceOneObject:pe->evtOiList withObject:pHo];
		return YES;
    }
    return NO;
}

BOOL RCND_EXTONLOOP2(event* pe, CRun* rhPtr, CObject* pHo)
{
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
    NSString* pName=[rhPtr get_EventExpressionString:pEvp];
    LPHO pHo2=nil;
    LPFOREACH pForEach=rhPtr->rh4CurrentForEach;
    if (pForEach!=nil)
    {
        if ([pForEach->name caseInsensitiveCompare:pName]==0)
        {
            if (pForEach->oi==pe->evtOi)
            {
                int index=pForEach->index%pForEach->number;
                pHo2=pForEach->objects[index];
            }
        }
    }
    pForEach=rhPtr->rh4CurrentForEach2;
    if (pForEach!=nil)
    {
        if ([pForEach->name caseInsensitiveCompare:pName]==0)
        {
            if (pForEach->oi==pe->evtOi)
            {
                int index=pForEach->index%pForEach->number;
                pHo2=pForEach->objects[index];
            }
        }
    }
    if (pHo2!=nil)
    {
        if ( pe->evtNParams > 1 )
        {
            LPEVP pEvp=(LPEVP)((LPBYTE)pe+CND_SIZE);
            LPEVP pEvp2 = EVPNEXT(pEvp);
            multipleFlagAndVariableParam* pMultipleParam = (multipleFlagAndVariableParam*)&pEvp2->evp.evpW.evpW0;
            if ( !CheckMultipleFlagAndVariableParam(pMultipleParam, pHo2) )
                return NO;
        }
        [rhPtr->rhEvtProg evt_ForceOneObject:pe->evtOiList withObject:pHo2];
        return YES;
    }
    return NO;
}

void addForEach(NSString* pName, LPHO pHo, OINUM oil, CRun* rhPtr)
{
    LPFOREACH pForEach=rhPtr->rh4ForEachs;
    LPFOREACH pForEachPrevious=nil;
    while(pForEach!=nil)
    {
        if ([pName caseInsensitiveCompare:pForEach->name] == 0 && pForEach->oi==oil)
        {
            if (pForEach->number+1>=pForEach->length)
            {
                pForEach->length+=STEPFOREACH;
                LPFOREACH temp=(LPFOREACH)realloc(pForEach, sizeof(ForEach) + (pForEach->length-STEPFOREACH)*sizeof(LPHO));
                if (rhPtr->rh4ForEachs==pForEach)
                    rhPtr->rh4ForEachs=temp;
                pForEach=temp;
                if (pForEachPrevious==nil)
                    rhPtr->rh4ForEachs=pForEach;
                else
                    pForEachPrevious->next=pForEach;
            }
            pForEach->objects[pForEach->number++]=pHo;
            return;
        }
        pForEachPrevious=pForEach;
        pForEach=(LPFOREACH)pForEach->next;
    }
    pForEach=(LPFOREACH)malloc(sizeof(ForEach));
    if (pForEachPrevious==nil)
        rhPtr->rh4ForEachs=pForEach;
    else
        pForEachPrevious->next=pForEach;
    pForEach->next=nil;
    pForEach->length=STEPFOREACH;
    pForEach->number=1;
    pForEach->oi=oil;
    pForEach->objects[0]=pHo;
    pForEach->index=-1;
    pForEach->toDelete=NO;
    pForEach->name=[[[[NSString alloc] initWithString:pName] uppercaseString] retain];
    rhPtr->rhEvtProg->bEndForEach = YES;
}

void RACT_EXTFOREACH(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    NSString* pName=[rhPtr get_EventExpressionString:pEvp];
    addForEach(pName, pHo, pe->evtOi, rhPtr);
}

void RACT_EXTFOREACH2(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    LPEVP pEvp2=(LPEVP)((LPBYTE)pEvp+pEvp->evpSize);
    NSString* pName=[rhPtr get_EventExpressionString:pEvp2];
    addForEach(pName, pHo, pe->evtOi, rhPtr);
    
    pHo=[rhPtr->rhEvtProg get_CurrentObjects:pEvp->evp.evpW.evpW0];
    if (pHo!=nil)
        addForEach(pName, pHo, pEvp->evp.evpW.evpW1, rhPtr);
}

void actExtraAction(event* pe, CRun* rhPtr)
{
    LPHO pHo=[rhPtr->rhEvtProg get_ActionObjects:pe];
    if (pHo==nil)
        return;
    
    LPEVP pEvp=(LPEVP)((LPBYTE)pe+ACT_SIZE);
    switch(pEvp->evp.evpW.evpW0) {
        case SUBACT_SETFLAG:
            if ( pHo->rov != nil )
            {
                pEvp = (LPEVP)((LPBYTE)pEvp+pEvp->evpSize);        // Next param (flag index)
                LPEXP pToken = (LPEXP)&pEvp->evp.evpW.evpW1;
                LPEXP pNextToken = (LPEXP)((LPBYTE)pToken + pToken->expSize);
                DWORD mask;
                if ( pToken->expCode.expLCode.expCode == EXPL_LONG && (pNextToken->expCode.expLCode.expCode <= OPERATOR_START || pNextToken->expCode.expLCode.expCode >= OPERATOR_END) )
                    mask = (1 << pToken->expu.expl.expLParam);
                else
                    mask = (1 << [rhPtr get_EventExpressionInt:pEvp]);

                pEvp = (LPEVP)((LPBYTE)pEvp+pEvp->evpSize);        // Next param (value)
                int newValue = [rhPtr get_EventExpressionInt:pEvp];
                pHo->rov->rvValueFlags &= ~mask;
                if ( newValue )
                    pHo->rov->rvValueFlags |= mask;
            }
            break;
    }
}

////// Clipboard //////
BOOL evaClipboard(event* pe, CRun* rhPtr, LPHO pHo)
{
    return [rhPtr->rhApp cndClipboard];
}

void actSendClipboard(event* pe, CRun* rhPtr)
{
    LPEVP pEvp = (LPEVP)((LPBYTE)pe+ACT_SIZE);
    NSString* pString = [rhPtr get_EventExpressionStringNoCopy:pEvp];
    
    if ( pString == nil )
        return;
    [rhPtr->rhApp setClipboard:pString];
    
}
void actClearClipboard(event* pe, CRun* rhPtr)
{
    [rhPtr->rhApp setClipboard:@""];
    
}
void exp_Clipboard(CRun* rhPtr)
{
    [getCurrentResult() forceString:[rhPtr->rhApp getClipboard]];
}



// -----------------------------------------------------------------------
// EVALUATION D'EXPRESSION
// -----------------------------------------------------------------------
void OInvertSign(CRun* rhPtr)
{
    nextToken();
    callTable_Expression[rhPtr->rh4ExpToken->expCode.expSCode.expType+NUMBEROF_SYSTEMTYPES](rhPtr);

    //    NextToken();
    [getCurrentResult() negate];
}
void OParenthOpen(CRun* rhPtr)
{
    nextToken();                        // Saute la parenthese ouvrante
    CValue* pResult=[rhPtr getExpression];    // Evalue le contenu de la parenthese
    
    [getCurrentResult() forceValue:pResult];
}
void opePlus(CRun* rhPtr)
{
    [getCurrentResult() add:getNextResult()];
}
void opeMoins(CRun* rhPtr)
{
    [getCurrentResult() sub:getNextResult()];
}
void opeMult(CRun* rhPtr)
{
    [getCurrentResult() mul:getNextResult()];
}
void opeDiv(CRun* rhPtr)
{
    [getCurrentResult() div:getNextResult()];
}
void opeMod(CRun* rhPtr)
{
    [getCurrentResult() mod:getNextResult()];
}
void opePow(CRun* rhPtr)
{
    [getCurrentResult() pow:getNextResult()];
}
void opeOr(CRun* rhPtr)
{
    [getCurrentResult() orLog:getNextResult()];
}
void opeAnd(CRun* rhPtr)
{
    [getCurrentResult() andLog:getNextResult()];
}
void opeXor(CRun* rhPtr)
{
    [getCurrentResult() xorLog:getNextResult()];
}

// Table de saut aux operateurs
CALLOPERATOR_ROUTINE expCallOperators[]=
{
0,
opePlus,
opeMoins,
opeMult,
opeDiv,
opeMod,
opePow,
opeAnd,
opeOr,
opeXor
};


// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// Tables de saut aux conditions / actions / expressions
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
BOOL evaTRUE(event* pe, CRun* rhPtr, LPHO pHo)
{
    return YES;
}
BOOL evaFALSE(event* pe, CRun* rhPtr, LPHO pHo)
{
    return NO;
}
void actRien(event* pe, CRun* rhPtr)
{
}
void expRien(CRun* rhPtr)
{
    [getCurrentResult() forceInt:0];
}

// ---------------------------------------------------------------------------
// TABLES DE SAUT COMMUNUES
// ---------------------------------------------------------------------------
CONDROUTINE jump1Common[EVENTS_EXTBASE]={
evaCmpFrame                ,    // CND_EXTCMPFRAME
eva1AnOver                ,    // CND_EXTANIMENDOF
evaAnPlaying            ,    // CND_EXTANIMPLAYING
evaIsColliding            ,    // CND_EXTISCOLLIDING
evaReversed                ,    // CND_EXTREVERSED
evaBouncing                ,    // CND_EXTBOUNCING
evaStopped                ,    // CND_EXTSTOPPED
evaFacing                ,    // CND_EXTFACING
evaIsInPlayfield        ,    // CND_EXTISIN
evaIsOutPlayfield        ,    // CND_EXTISOUT
eva1GoesInPlayfield        ,    // CND_EXTINPLAYFIELD
eva1GoesInPlayfield        ,    // CND_EXTOUTPLAYFIELD - idem eva1GoesOutPlayfield
eva1ColBack                ,    // CND_EXTCOLBACK
eva1Collision            ,    // CND_EXTCOLLISION
evaSpeedCompare              ,    // CND_EXTCMPSPEED
evaYCompare                  ,    // CND_EXTCMPY
evaXCompare                ,    // CND_EXTCMPX
evaCmpDec                ,    // CND_EXTCMPDEC
evaCmpAcc                ,    // CND_EXTCMPACC
evaTRUE                     ,    // CND_EXTPATHNODE
evaTRUE                     ,    // CND_EXTENDPATH
evaNearBorders             ,    // CND_EXTNEARBORDERS
eva2ColBack                ,    // CND_EXTISCOLBACK
evaFlagReset            ,    // CND_EXTFLAGRESET
evaFlagSet                ,    // CND_EXTFLAGSET
evaVarCompareFixed         ,    // CND_EXTCMPVARFIXED
evaCmpVar                ,    // CND_EXTCMPVAR
evaHidden                ,    // CND_EXTHIDDEN
evaShown                ,    // CND_EXTSHOWN
evaNumberZone            ,    // CND_EXTNUMBERZONE
evaNoMoreZone            ,    // CND_EXTNOMOREZONE
evaNumOfObject            ,    // CND_EXTNUMOFOBJECT
eva1NoMore                ,    // CND_EXTNOMOREOBJECT
evaChoose                ,    // CND_EXTCHOOSE
evaPathNodeName1        ,    // CND_EXTPATHNODENAME=-35
evaCmpVarString         ,   // CND_EXTCMPVARSTRING
evaIsBold                ,    // CND_EXTISBOLD
evaIsItalic                ,    // CND_EXTISITALIC
evaIsUnderline            ,    // CND_EXTISUNDERLINE
evaIsStrikeOut            ,    // CND_EXTISSTRIKEOUT
RCND_EXTONLOOP            ,
evaCmpVarConst            ,    // CND_EXTCMPVARINT
evaCmpVarConst            ,    // CND_EXTCMPVARDBL
evaPickClosest            ,    // CND_EXTPICKCLOSEST
evaExtCompare            ,    // CND_EXTCOMPARE
evaExtCmpLayer            ,    // CND_EXTCMPLAYER
evaPickMinimumExpressionValue,    // CND_EXTPICKMINVALUE
evaPickMaximumExpressionValue,    // CND_EXTPICKMAXVALUE
evaExtCmpInstanceValue,        // CND_EXTCMPINSTANCEDATA
evaIsColliding            ,    // CND_EXTISCOLLIDINGAT
eva2ColBack                ,    // CND_EXTISCOLBACKAT
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
};

CONDROUTINE jump2Common[EVENTS_EXTBASE]={
evaCmpFrame                ,    // CND_EXTCMPFRAME
eva2AnOver                ,    // CND_EXTANIMENDOF
evaAnPlaying            ,    // CND_EXTANIMPLAYING
evaIsColliding            ,    // CND_EXTISCOLLIDING
evaReversed                ,    // CND_EXTREVERSED
evaBouncing                ,    // CND_EXTBOUNCING
evaStopped                ,    // CND_EXTSTOPPED
evaFacing                ,    // CND_EXTFACING
evaIsInPlayfield        ,    // CND_EXTISIN
evaIsOutPlayfield        ,    // CND_EXTISOUT
eva2GoesInPlayfield          ,    // CND_EXTINPLAYFIELD
eva2GoesOutPlayfield      ,    // CND_EXTOUTPLAYFIELD
eva2ColBack                ,    // CND_EXTCOLBACK
evaIsColliding            ,    // CND_EXTCOLLISION
evaSpeedCompare              ,    // CND_EXTCMPSPEED
evaYCompare                  ,    // CND_EXTCMPY
evaXCompare                ,    // CND_EXTCMPX
evaCmpDec                ,    // CND_EXTCMPDEC
evaCmpAcc                ,    // CND_EXTCMPACC
evaNodePath                ,    // CND_EXTPATHNODE
evaEndPath                 ,    // CND_EXTENDPATH
evaNearBorders             ,    // CND_EXTNEARBORDERS
eva2ColBack                ,    // CND_EXTISCOLBACK
evaFlagReset            ,    // CND_EXTFLAGRESET
evaFlagSet                ,    // CND_EXTFLAGSET
evaVarCompareFixed         ,    // CND_EXTCMPVARFIXED
evaCmpVar                ,    // CND_EXTCMPVAR
evaHidden                ,    // CND_EXTHIDDEN
evaShown                ,    // CND_EXTSHOWN
evaNumberZone            ,    // CND_EXTNUMBERZONE
evaNoMoreZone            ,    // CND_EXTNOMOREZONE
evaNumOfObject            ,    // CND_EXTNUMOFOBJECT
eva2NoMore                ,    // CND_EXTNOMOREOBJECT
evaChoose                ,    // CND_EXTCHOOSE
evaPathNodeName2        ,    // CND_EXTPATHNODENAME
evaCmpVarString            ,    // CND_EXTCMPVARSTRING
evaIsBold                ,    // CND_EXTISBOLD
evaIsItalic                ,    // CND_EXTISITALIC
evaIsUnderline            ,    // CND_EXTISUNDERLINE
evaIsStrikeOut            ,    // CND_EXTISSTRIKEOUT
RCND_EXTONLOOP2            ,
evaCmpVarConst            ,    // CND_EXTCMPVARINT
evaCmpVarConst            ,    // CND_EXTCMPVARDBL
evaPickClosest            ,    // CND_EXTPICKCLOSEST
evaExtCompare            ,    // CND_EXTCOMPARE
evaExtCmpLayer            ,    // CND_EXTCMPLAYER
evaPickMinimumExpressionValue,    // CND_EXTPICKMINVALUE
evaPickMaximumExpressionValue,    // CND_EXTPICKMAXVALUE
evaExtCmpInstanceValue,        // CND_EXTCMPINSTANCEDATA
evaIsColliding            ,    // CND_EXTISCOLLIDINGAT
eva2ColBack                ,    // CND_EXTISCOLBACKAT
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
};

ACTROUTINE actCommon[]={
actExtraAction            ,    // ACT_EXTRA
actSetPosition            ,    // ACT_EXTSETPOS
actSetXPosition            ,    // ACT_EXTSETX
actSetYPosition            ,    // ACT_EXTSETY
actStop                    ,    // ACT_EXTSTOP
actStart                ,    // ACT_EXTSTART
actSetSpeed                ,    // ACT_EXTSPEED
actSetMaxSpeed            ,    // ACT_EXTMAXSPEED
actWrap                    ,    // ACT_EXTWRAP
actBounce                ,    // ACT_EXTBOUNCE
actReverse                ,    // ACT_EXTREVERSE
actNextMovement            ,    // ACT_EXTNEXTMOVE
actPreviousMovement        ,    // ACT_EXTPREVMOVE
actSelectMovement        ,    // ACT_EXTSELMOVE
actLookAt                ,    // ACT_EXTLOOKAT
actAnStop                ,    // ACT_EXTSTOPANIM
actAnStart                ,    // ACT_EXTSTARTANIM
actAnForce                ,    // ACT_EXTFORCEANIM
actAnDirForce            ,    // ACT_EXTFORCEDIR
actAnSpeedForce            ,    // ACT_EXTFORCESPEED
actAnRestore            ,    // ACT_EXTRESTANIM
actAnDirRestore            ,    // ACT_EXTRESTDIR
actAnSpeedRestore        ,    // ACT_EXTRESTSPEED
actSetDirection            ,    // ACT_EXTSETDIR
actDisappear            ,    // ACT_EXTDESTROY
actShuffle                ,    // ACT_EXTSHUFFLE
actHide                    ,    // ACT_EXTHIDE
actShow                    ,    // ACT_EXTSHOW
actFlash                ,    // ACT_EXTDISPLAYDURING
actShoot                ,    // ACT_EXTSHOOT
actShootToward            ,    // ACT_EXTSHOOTTOWARD
actSetVar                ,    // ACT_EXTSETVAR
actAddVar                ,    // ACT_EXTADDVAR
actSubVar                ,    // ACT_EXTSUBVAR
actDispatchVar            ,    // ACT_EXTDISPATCHVAR
actSetFlag                ,    // ACT_EXTSETFLAG
actClrFlag                ,    // ACT_EXTCLRFLAG
actChgFlag                ,    // ACT_EXTCHGFLAG
actSetInkEffect            ,    // ACT_EXTINKEFFECT
actSetSemiTransparency    ,    // ACT_EXTSETSEMITRANSPARENCY=39
actAnFrameForce            ,    // ACT_EXTFORCEFRAME
actAnFrameRestore        ,    // ACT_EXTRESTFRAME
actMvSetAcc                ,    // ACT_EXTSETACCELERATION
actMvSetDec                ,    // ACT_EXTSETDECELERATION
actMvSetRotSpeed        ,    // ACT_EXTSETROTATINGSPEED
actMvSet8Dirs            ,    // ACT_EXTSETDIRECTIONS
actBranchNode            ,   // ACT_EXTBRANCHNODE
actSetGravity            ,    // ACT_EXTSETGRAVITY
actGotoNode                ,    // ACT_EXTGOTONODE
actSetVarString            ,    // ACT_EXTSETVARSTRING
actSetFontName            ,    // ACT_EXTSETFONTNAME
actSetFontSize            ,    // ACT_EXTSETFONTSIZE
actSetBold                ,    // ACT_EXTSETBOLD
actSetItalic            ,    // ACT_EXTSETITALIC
actSetUnderline            ,    // ACT_EXTSETUNDERLINE
actSetStrikeOut            ,    // ACT_EXTSETSRIKEOUT
actSetTextColor            ,    // ACT_EXTSETTEXTCOLOR
actExtSprFront            ,    // ACT_EXTSPRFRONT
actExtSprBack            ,    // ACT_EXTSPRBACK
actMoveBefore            ,    // ACT_EXTMOVEBEFORE
actMoveAfter            ,   // ACT_EXTMOVEAFTER
actMoveToLayer            ,    // ACT_EXTMOVETOLAYER
actRien                    ,    // ACT_EXTADDTODEBUGGER
actSetEffect            ,    // ACT_EXTSETEFFECT
actSetEffectParam        ,    // ACT_EXTSETEFFECTPARAM
actSetAlphaCoef            ,    // ACT_EXTSETALPHACOEF
actSetRGBCoef            ,    // ACT_EXTSETRGBCOEF
actSetEffectParamTexture       ,    // ACT_EXTSETEFFECTPARAMTEXTURE
RACT_EXTSETFRICTION            ,
RACT_EXTSETELASTICITY        ,
RACT_EXTAPPLYIMPULSE        ,
RACT_EXTAPPLYANGULARIMPULSE    ,
RACT_EXTAPPLYFORCE            ,
RACT_EXTAPPLYTORQUE            ,
RACT_EXTSETLINEARVELOCITY    ,
RACT_EXTSETANGULARVELOCITY    ,
RACT_EXTFOREACH                ,
RACT_EXTFOREACH2            ,
RACT_EXTSTOPFORCE            ,
RACT_EXTSTOPTORQUE            ,
};

EXPROUTINE expCommon[]={
0                        ,    // 0
exp_Y                      ,    // EXP_EXTYSPR
exp_Image                 ,    // EXP_EXTISPR
exp_Speed               ,    // EXP_EXTSPEED
exp_Acc                    ,    // EXP_EXTACC
exp_Dec                 ,    // EXP_EXTDEC
exp_Dir                    ,    // EXP_EXTDIR
exp_XLeft                ,    // EXP_EXTXLEFT
exp_XRight                ,    // EXP_EXTXRIGHT
exp_YTop                ,    // EXP_EXTYTOP
exp_YBottom                ,    // EXP_EXTYBOTTOM
exp_X                      ,    // EXP_EXTXSPR
exp_Id                    ,    // EXP_EXTIDENTIFIER
exp_Flag                ,    // EXP_EXTFLAG
exp_NAni                ,    // EXP_EXTNANI
exp_Number                ,    // EXP_EXTNOBJECTS            ??? Verifier validite !!!
exp_Var                    ,    // EXP_EXTVAR
exp_GetSemiTransparency    ,    // EXP_EXTGETSEMITRANSPARENCY
exp_GetNMovement        ,    // EXP_EXTGETNMOVEMENT=18
exp_VarString            ,    // EXP_EXTVARSTRING
exp_GetFontName            ,    // EXP_EXTGETFONTNAME
exp_GetFontSize            ,    // EXP_EXTGETFONTSIZE
exp_GetFontColor        ,    // EXP_EXTGETFONTCOLOR
exp_GetLayer            ,    // EXP_EXTGETLAYER
exp_Gravity                ,    // EXP_EXTGETGRAVITY
exp_XAP                    ,    // EXP_EXTXAP
exp_YAP                    ,    // EXP_EXTYAP
exp_AlphaCoef            ,    // EXP_EXTALPHACOEF
exp_RGBCoef                ,    // EXP_EXTRGBCOEF
exp_EffectParam            ,    // EXP_EXTEFFECTPARAM
exp_VarByIndex            ,    // EXP_EXTVARBYINDEX
exp_VarStringByIndex    ,    // EXP_EXTVARSTRINGBYINDEX
REXP_EXTDISTANCE        ,    // EXP_EXTDISTANCE
REXP_EXTANGLE            ,    // EXP_EXTANGLE
REXP_EXTLOOPINDEX        ,    // EXP_EXTLOOPINDEX
REXP_EXTGETFRICTION        ,
REXP_EXTGETRESTITUTION    ,
REXP_EXTGETDENSITY        ,
REXP_EXTGETVELOCITY        ,
REXP_EXTGETANGLE        ,
REXP_WIDTH                ,
REXP_HEIGHT             ,
REXP_EXTGETMASS            ,
REXP_EXTGETANGULARVELOCITY,
REXP_EXTGETNAME            ,
exp_NumberOfSelected,        // EXP_NUMBEROFSELECTED
exp_InstanceValue,            // EXP_EXTINSTANCEDATA
};




// ---------------------------------------------------------------------------
// TABLES DE SAUT OBJETS SYSTEME
// ---------------------------------------------------------------------------

// OBJET SPEAKER
CONDROUTINE jumpSpeaker[]={
cndNoSpSamPlaying        ,    // CND_NOSPSAMPLAYING
evaFALSE                ,    // CND_NOSPMUSPLAYING
cndNoSamPlaying         ,    // CND_NOSAMPLAYING
evaFALSE                ,    // CND_NOMUSPLAYING
evaFALSE                ,    // CND_MUSICENDS
cndSpSamPaused            ,    // CND_SPSAMPAUSED
evaFALSE                ,    // CND_MUSPAUSED
cndNoSpChannelPlaying    ,    // CND_NOSPCHANNELPLAYING
cndSpChannelPaused        ,    // CND_SPCHANNELPAUSED
};
ACTROUTINE actSpeaker[]={
actPlaySample            ,    // ACT_PLAYSAMPLE
actStopAllSamples        ,    // ACT_STOPSAMPLE
actRien                    ,    // ACT_PLAYMUSIC
actRien                    ,    // ACT_STOPMUSIC
actPlayLoopSample          ,    // ACT_PLAYLOOPSAMPLE
actRien                    ,    // ACT_PLAYLOOPMUSIC
actStopSpeSample        ,    // ACT_STOPSPESAMPLE
actPauseSample            ,    // ACT_PAUSESAMPLE
actResumeSample            ,    // ACT_RESUMESAMPLE
actRien                    ,    // ACT_PAUSEMUSIC
actRien                    ,    // ACT_RESUMEMUSIC
actPlayChannel            ,    // ACT_PLAYCHANNEL
actPlayLoopChannel        ,    // ACT_PLAYLOOPCHANNEL
actPauseChannel            ,    // ACT_PAUSECHANNEL
actResumeChannel        ,    // ACT_RESUMECHANNEL
actStopChannel            ,    // ACT_STOPCHANNEL
actSetPosChannel        ,    // ACT_SETCHANNELPOS
actSetVolumeChannel        ,    // ACT_SETCHANNELVOL
actSetPanChannel        ,    // ACT_SETCHANNELPAN
actSetPosSample            ,    // ACT_SETSAMPLEPOS
actSetSampleMainVolume    ,    // ACT_SETSAMPLEMAINVOL
actSetSampleVolume        ,    // ACT_SETSAMPLEVOL
actSetSampleMainPan        ,    // ACT_SETSAMPLEMALNPAN
actSetSamplePan            ,    // ACT_SETSAMPLEPAN
actPauseAllChannels        ,    // ACT_PAUSEALLCHANNELS
actResumeAllChannels    ,    // ACT_RESUMEALLCHANNELS
actRien                    ,    // ACT_PLAYMUSICFILE
actRien                    ,    // ACT_PLAYLOOPMUSICFILE
actRien                    ,    // ACT_PLAYFILECHANNEL
actRien                    ,    // ACT_PLAYLOOPFILECHANNEL
actLockChannel            ,    // ACT_LOCKCHANNEL
actUnlockChannel        ,    // ACT_UNLOCKCHANNEL
actSetFreqChannel        ,    // ACT_SETCHANNELFREQ
actSetFreqSample        ,    // ACT_SETSAMPLEFREQ
actRien                    ,    // ACT_PRELOADSAMPLEFILE
actRien                    ,    // ACT_DISCARDSAMPLEFILE
actPlaySample2            ,    // ACT_PLAYSAMPLE2
};

EXPROUTINE expSpeaker[]={
expSampleMainVolume        ,    // EXP_GETSAMPLEMAINVOL
expSampleVolume            ,    // EXP_GETSAMPLEVOL
expChannelVolume        ,    // EXP_GETCHANNELVOL
expSampleMainPan        ,    // EXP_GETSAMPLEMAINPAN
expSamplePan            ,    // EXP_GETSAMPLEPAN
expChannelPan            ,    // EXP_GETCHANNELPAN
expSamplePosition        ,    // EXP_GETSAMPLEPOS
expChannelPosition        ,    // EXP_GETCHANNELPOS
expSampleDuration        ,    // EXP_GETSAMPLEDUR
expChannelDuration        ,    // EXP_GETCHANNELDUR
expSampleFrequency        ,    // EXP_GETSAMPLEFREQ
expChannelFrequency        ,    // EXP_GETCHANNELFREQ
expChannelSampleName    ,    // EXP_GETCHANNELSNDNAME
};

// OBJET KEYBOARD
CONDROUTINE jump1Keyboard[]={
evaPressKey,
evaKeyDepressed,
evaMInZone,
evaMOnObject,
eva1MClick,
eva1MClickInZone,
eva1MClickOnObject,
evaOnMousePressed,    //evaFALSE,
evaTRUE,
evaFALSE,
evaTRUE,                    // CND_ONMOUSEWHEELUP
evaTRUE                        // CND_ONMOUSEWHEELDOWN
};
CONDROUTINE jump2Keyboard[]={
evaPressKey,
evaKeyDepressed,
evaMInZone,
evaMOnObject,
eva2MClick,
eva2MClickInZone,
eva2MClickOnObject,
evaOnMousePressed,    //evaFALSE,
evaFALSE,                        // *** BUG A CHANGER!
evaFALSE,
evaFALSE,
evaFALSE,
};
ACTROUTINE actKeyboard[]={
actRien,
actRien
};
EXPROUTINE expKeyboard[]={
expXMouse,
expYMouse,
nil
};

// OBJET TIMER
CONDROUTINE jump2Timer[]={
evaTimerSup                ,    // CND_TIMERSUP
evaTimerInf                ,    // CND_TIMERINF
evaFALSE                ,    // CND_TIMER
evaEvery                ,    // CND_EVERY
evaTimeOut                ,    // CND_TIMEOUT
RCND_ONEVENT            ,
evaTimerEquals            ,    // CND_TIMEREQUALS
evaEvery2                ,    // CND_EVERY2
};
CONDROUTINE jump1Timer[]={
evaTimerSup                ,    // CND_TIMERSUP
evaTimerInf                ,    // CND_TIMERINF
evaTimerEqu                ,    // CND_TIMER
evaEvery                ,    // CND_EVERY
evaTimeOut                ,    // CND_TIMEOUT
RCND_ONEVENT            ,
evaTimerEquals            ,    // CND_TIMEREQUALS
evaEvery2                ,    // CND_EVERY2
};
ACTROUTINE actTimer[]={
actSetTimer                ,    // ACT_SETTIMER
RACT_EVENTAFTER            ,
RACT_NEVENTSAFTER        ,
};
EXPROUTINE expTimer[]={
expTim_Value               ,    // EXP_TIMVALUE
expTim_Cent             ,    // EXP_TIMCENT
expTim_Sec              ,    // EXP_TIMSECONDS
expTim_Hour             ,    // EXP_TIMHOURS
expTim_Min                 ,    // EXP_TIMMINITS
REXP_EVENTAFTER            ,
};

// OBJET STORYBOARD
CONDROUTINE jump1Game[]={
evaStart                ,    // CND_START
evaEnd                    ,    // CND_END
evaLevel                ,    // CND_LEVEL
evaTRUE                    ,    // CND_QUITAPPLICATION
evaIsObstacle            ,    // CND_ISOBSTACLE
evaIsLadder                ,    // CND_ISLADDER
evaFALSE                ,    // CND_ISVSYNCON
evaTRUE                    ,    // CND_ENDOFPAUSE
evaFrameLoaded            ,   // CND_FRAMELOADED
evaFrameSaved            ,   // CND_FRAMESAVED
};
CONDROUTINE jump2Game[]={
evaStart                ,    // CND_START
evaEnd                    ,    // CND_END
evaLevel                ,    // CND_END
evaFALSE                ,    // CND_QUITAPPLICATION
evaIsObstacle            ,    // CND_ISOBSTACLE
evaIsLadder                ,    // CND_ISLADDER
evaFALSE                ,    // CND_ISVSYNCON
evaEndOfPause2            ,    // CND_ENDOFPAUSE
evaFrameLoaded            ,   // CND_FRAMELOADED
evaFrameSaved            ,   // CND_FRAMESAVED
};
ACTROUTINE actGame[]={
actNextLevel            ,    // ACT_NEXTLEVEL
actPrevLevel            ,    // ACT_PREVLEVEL
actGotoLevel            ,    // ACT_GOLEVEL
actPauseGame            ,    // ACT_PAUSE
actEndGame                ,    // ACT_ENDGAME
actRestartGame               ,    // ACT_RESTARTGAME
actRestartLevel               ,    // ACT_RESTARTLEVEL
actCDisplay                ,    // ACT_DISPLAYPOS
actCDisplayX            ,    // ACT_DISPLAYX
actCDisplayY            ,    // ACT_DISPLAYY
actRien                    ,    // ACT_LOADGAME
actRien                    ,    // ACT_SAVEGAME
actCls                    ,    // ACT_CLS
actClearZone            ,    // ACT_CLEARZONE
actRien                    ,    // ACT_FULLSCREENMODE
actRien                    ,    // ACT_WINDOWEDMODE
actSetFrameRate            ,    // ACT_SETFRAMERATE
actPauseGame            ,    // ACT_PAUSEKEY
actPauseAnyKey            ,    // ACT_PAUSEANYKEY
actRien                    ,    // ACT_SETVSYNCON
actRien                    ,    // ACT_SETVSYNCOFF
actSetVirtualWidth        ,    // ACT_SETVIRTUALWIDTH
actSetVirtualHeight        ,    // ACT_SETVIRTUALHEIGHT
actSetFrameBkdColor        ,    // ACT_SETFRAMEBDKCOLOR
actDelCreatedBkdAt        ,    // ACT_DELCREATEDBKDAT
actDelAllCreatedBkd        ,    // ACT_DELALLCREATEDBKD
actSetFrameWidth        ,    // ACT_SETFRAMEWIDTH
actSetFrameHeight        ,    // ACT_SETFRAMEEHEIGHT
actSaveFrame            ,    // ACT_SAVEFRAME
actLoadFrame            ,    // ACT_LOADFRAME
actLoadApplication        ,    // ACT_LOADAPPLICATION
actPlayDemo                ,    // ACT_PLAYDEMO
actSetFrameEffect          ,    // ACT_SETFRAMEEFFECT
actSetFrameEffectParam     ,    // ACT_SETFRAMEEFFECTPARAM
actSetFrameEffectParamTexture    ,    // ACT_SETFRAMEEFFECTPARAMTEXTURE
actSetFrameAlphaCoef             ,    // ACT_SETFRAMEALPHACOEF
actSetFrameRGBCoef               ,    // ACT_SETFRAMERGBCOEF
actSetStretchResampling ,   // ACT_SETSTRETCHRESAMPLING
};
EXPROUTINE expGame[]={
expGam_NLevelOld        ,    // EXP_GAMLEVEL
expGam_NPlayer            ,    // EXP_GAMNPLAYER
expGam_PlayXLeft        ,    // EXP_PLAYXLEFT
expGam_PlayXRight        ,    // EXP_PLAYXRIGHT
expGam_PlayYTop            ,    // EXP_PLAYYTOP
expGam_PlayYBottom        ,    // EXP_PLAYYBOTTOM
expGam_PlayWidth        ,    // EXP_PLAYWIDTH
expGam_PlayHeight        ,    // EXP_PLAYHEIGHT
expGam_NLevel            ,    // EXP_GAMLEVELNEW
expGam_GetCollisionMask    ,    // EXP_GETCOLLISIONMASK
expGam_FrameRate        ,    // EXP_FRAMERATE
expGam_GetVirtualWidth    ,    // EXP_GETVIRTUALWIDTH
expGam_GetVirtualHeight    ,    // EXP_GETVIRTUALHEIGHT
expGam_GetFrameBkdColor    ,    // EXP_GETFRAMEBKDCOLOR
expGam_GraphicMode        ,    // EXP_GRAPHICMODE
expGam_PixelShaderV        ,    // EXP_PIXELSHADERVERSION
expGam_FrameAlphaCoef    ,    // EXP_FRAMEALPHACOEF
expGam_FrameRGBCoef        ,    // EXP_FRAMERGBCOEF
expGam_FrameEffectParam    ,    // EXP_FRAMEEFFECTPARAM
};

// OBJET CREATE
CONDROUTINE jumpCreate[]={
evaNoMoreAllZone_old    ,    // CND_NOMOREALLZONE_OLD
evaNumOfAllZone_old        ,    // CND_NUMOFALLZONE_OLD
evaNumOfAllObjects_old    ,    // CND_NUMOFALLOBJECT_OLD
evaChooseZone_old        ,    // CND_CHOOSEZONE_OLD
evaChooseAll_old        ,    // CND_CHOOSEALL_OLD
evaChooseAllInZone_old    ,    // CND_CHOOSEALLINZONE_OLD
evaPickFromId            ,    // CND_PICKFROMID_OLD
evaChooseValue_old        ,    // CND_CHOOSEVALUEA_OLD
evaFALSE                ,    // OLDCND_CHOOSEVALUEB
evaFALSE                ,    // OLDCND_CHOOSEVALUEC
evaChooseFlagSet_old    ,    // CND_CHOOSEFLAGSET_OLD
evaChooseFlagReset_old    ,    // CND_CHOOSEFLAGRESET_OLD
evaNoMoreAllZone        ,    // CND_NOMOREALLZONE
evaNumOfAllZone            ,    // CND_NUMOFALLZONE
evaNumOfAllObjects        ,    // CND_NUMOFALLOBJECT
evaChooseZone            ,    // CND_CHOOSEZONE
evaChooseAll            ,    // CND_CHOOSEALL
evaChooseAllInZone        ,    // CND_CHOOSEALLINZONE
evaPickFromId            ,    // CND_PICKFROMID
evaChooseValue            ,    // CND_CHOOSEVALUE
evaChooseFlagSet        ,    // CND_CHOOSEFLAGSET
evaChooseFlagReset        ,    // CND_CHOOSEFLAGRESET
evaChooseAllInLine            // CND_CHOOSEALLINLINE
};
ACTROUTINE actCreate[]={
actCreateObject,			// ACT_CREATE
actCreateByName,			// ACT_CREATEBYNAME
actCreateObjectExp,			// ACT_CREATEEXP
actCreateByNameExp			// ACT_CREATEBYNAMEEXP
};
EXPROUTINE expCreate[]={
expCre_NumberAll,           // EXP_CRENUMBERALL
expCre_LastFixedValue		// EXP_LASTFIXEDVALUE
};

// OBJET PLAYER
CONDROUTINE jump1Player[]={
evaFALSE                ,    // CND_PLAYERPLAYING
evaScores                ,    // CND_SCORE
evaLives                ,    // CND_LIVE
eva1JoyPressed            ,    // CND_JOYPRESSED
evaNoMoreLive            ,    // CND_NOMORELIVE
evaJoyPushed                // CND_JOYPUSHED
};
CONDROUTINE jump2Player[]={
evaFALSE                ,    // CND_PLAYERPLAYING
evaScores                ,    // CND_SCORE
evaLives                ,    // CND_LIVE
eva2JoyPressed            ,    // CND_JOYPRESSED
evaNoMoreLive            ,    // CND_NOMORELIVE
evaJoyPushed                // CND_JOYPUSHED
};
ACTROUTINE actPlayer[]={
actPla_SetScore            ,    // ACT_SETSCORE
actPla_SetLives            ,    // ACT_SETLIVES
actNoInput                ,    // ACT_NOINPUT
actRestoreInput            ,    // ACT_RESTINPUT
actPla_AddScore            ,    // ACT_ADDSCORE
actPla_AddLives            ,    // ACT_ADDLIVES
actPla_SubScore            ,    // ACT_SUBSCORE
actPla_SubLives            ,    // ACT_SUBLIVES
actRien                    ,    // ACT_SETINPUT
actRien                    ,    // ACT_SETINPUTKEY
actPla_SetPlayerName    ,    // ACT_SETPLAYERNAME
};
EXPROUTINE expPlayer[]={
expPla_GetScore            ,    // EXP_SCORE
expPla_GetLives            ,    // EXP_LIVES
nil                        ,    // EXP_GETINPUT
nil                        ,    // EXP_GETINPUTKEY
expPla_GetPlayerName    ,    // EXP_GETPLAYERNAME
};

// OBJET SYSTEME
CONDROUTINE jump1Systeme[]={
evaTRUE                    ,    //  1 CND_ALWAYS
evaFALSE                ,    //  2 CND_NEVER
evaCompare              ,    //  3 CND_COMPARE
evaNoMore                ,    //  4 CND_NOMORE
evaRepeat                ,    //  5 CND_REPEAT
evaOnce                    ,    //  6 CND_ONCE
evaNotAlways            ,    //  7 CND_NOTALWAYS
evaCompareGlobal        ,    //  8 CND_COMPAREG
evaFALSE                 ,    //  9 CND_REMARK
evaFALSE                 ,    // 10 CND_GROUP
evaFALSE                ,    // 11 CND_ENDGROUP
evaGrpActivated            ,    // 12 CND_GRPACTIVATED
evaFALSE                ,    // 13 CND_TIMEEVENT
evaFALSE                ,    // 14 CND_MENUSELECTED
evaTRUE                    ,    // 15 CND_DROPFILES
evaOnLoop                ,    // 16 CND_ONLOOP
evaFALSE                ,    // 17 CND_MENUCHECKED
evaFALSE                ,    // 18 CND_MENUENABLED
evaFALSE                ,    // 19 CND_MENUVISIBLE
evaCompareGlobalString    ,    // 20 CND_COMPAREGSTRING
evaFALSE                ,    // 21 CND_ONCLOSE
evaFALSE                ,    // 22 CND_CLIPBOARD
evaOnGroupStart            ,    // 23 CND_GROUPSTART
evaFALSE                ,    // 24 CND_OR
evaFALSE                ,    // 25 CND_ORLOGICAL
evaChance                ,    // 26 CND_CHANCE
evaFALSE                ,    // 27 CND_ELSEIF

evaCompareGlobalIntEQ    ,    // 28 CND_COMPAREGINT_EQ
evaCompareGlobalIntNE    ,    // 29 CND_COMPAREGINT_NE
evaCompareGlobalIntLE    ,    // 30 CND_COMPAREGINT_LE
evaCompareGlobalIntLT    ,    // 31 CND_COMPAREGINT_LT
evaCompareGlobalIntGE    ,    // 32 CND_COMPAREGINT_GE
evaCompareGlobalIntGT    ,    // 33 CND_COMPAREGINT_GT

evaCompareGlobalDblEQ    ,    // 34 CND_COMPAREGDBL_EQ
evaCompareGlobalDblNE    ,    // 35 CND_COMPAREGDBL_NE
evaCompareGlobalDblLE    ,    // 36 CND_COMPAREGDBL_LE
evaCompareGlobalDblLT    ,    // 37 CND_COMPAREGDBL_LT
evaCompareGlobalDblGE    ,    // 38 CND_COMPAREGDBL_GE
evaCompareGlobalDblGT    ,    // 39 CND_COMPAREGDBL_GT

evaRunningAs            ,    // 40 CND_RUNNINGAS
evaFALSE                ,   // 41 CND_ISPROFILING
evaFALSE                ,   // 42 CND_ENDCHILDEVENT
evaStartChildEvent      ,   // 43 CND_STARTCHILDEVENT
};
CONDROUTINE jump2Systeme[]={
evaTRUE                    ,    //  1 CND_ALWAYS
evaFALSE                ,    //  2 CND_NEVER
evaCompare              ,    //  3 CND_COMPARE
evaNoMore                ,    //  4 CND_NOMORE
evaRepeat                ,    //  5 CND_REPEAT
evaOnce                    ,    //  6 CND_ONCE
evaNotAlways            ,    //  7 CND_NOTALWAYS
evaCompareGlobal        ,    //  8 CND_COMPAREG
evaFALSE                 ,    //  9 CND_REMARK
evaFALSE                 ,    // 10 CND_GROUP
evaFALSE                ,    // 11 CND_ENDGROUP
evaGrpActivated            ,    // 12 CND_GRPACTIVATED
evaFALSE                ,    // 13 CND_TIMEEVENT
evaFALSE                ,    // 14 CND_MENUSELECTED
evaFALSE                ,    // 15 CND_DROPFILES
evaFALSE                ,    // 16 CND_ONLOOP
evaFALSE                ,    // 17 CND_MENUCHECKED
evaFALSE                ,    // 18 CND_MENUENABLED
evaFALSE                ,    // 19 CND_MENUVISIBLE
evaCompareGlobalString    ,    // 20 CND_COMPAREGSTRING
evaFALSE                ,    // 21 CND_ONCLOSE
evaClipboard            ,    // 22 CND_CLIPBOARD
evaOnGroupStart            ,    // 23 CND_GROUPSTART
evaFALSE                ,    // 24 CND_OR
evaFALSE                ,    // 25 CND_ORLOGICAL
evaChance                ,    // 26 CND_CHANCE
evaFALSE                ,    // 27 CND_ELSEIF

evaCompareGlobalIntEQ    ,    // 28 CND_COMPAREGINT_EQ
evaCompareGlobalIntNE    ,    // 29 CND_COMPAREGINT_NE
evaCompareGlobalIntLE    ,    // 30 CND_COMPAREGINT_LE
evaCompareGlobalIntLT    ,    // 31 CND_COMPAREGINT_LT
evaCompareGlobalIntGE    ,    // 32 CND_COMPAREGINT_GE
evaCompareGlobalIntGT    ,    // 33 CND_COMPAREGINT_GT

evaCompareGlobalDblEQ    ,    // 34 CND_COMPAREGDBL_EQ
evaCompareGlobalDblNE    ,    // 35 CND_COMPAREGDBL_NE
evaCompareGlobalDblLE    ,    // 36 CND_COMPAREGDBL_LE
evaCompareGlobalDblLT    ,    // 37 CND_COMPAREGDBL_LT
evaCompareGlobalDblGE    ,    // 38 CND_COMPAREGDBL_GE
evaCompareGlobalDblGT    ,    // 39 CND_COMPAREGDBL_GT

evaRunningAs            ,    // 40 CND_RUNNINGAS
evaFALSE                ,   // 41 CND_ISPROFILING
evaFALSE                ,   // 42 CND_ENDCHILDEVENT
evaStartChildEvent      ,   // 43 CND_STARTCHILDEVENT
};
ACTROUTINE actSysteme[]={
actRien                    ,    // ACT_SKIP
actRien                    ,    // ACT_SKIPMONITOR
actRien                    ,    // ACT_EXECPROGRAM
actSetGlobal            ,    // ACT_SETGLOBAL
actSubGlobal            ,    // ACT_SUBGLOBAL
actAddGlobal            ,    // ACT_ADDGLOBAL
actGrpActivate            ,    // ACT_GRPACTIVATE
actGrpDesactivate        ,    // ACT_GRPDEACTIVATE
actRien                    ,    // ACT_MENUACTIVATE
actRien                    ,    // ACT_MENUDEACTIVATE
actRien                    ,    // ACT_MENUCHECK
actRien                    ,    // ACT_MENUUNCHECK
actRien                    ,    // ACT_MENUSHOW
actRien                    ,    // ACT_MENUHIDE
actStartLoop            ,    // ACT_STARTLOOP
actStopLoop                ,    // ACT_STOPLOOP
actSetLoopIndex            ,    // ACT_SETLOOPINDEX
ActRandomize            ,    // ACT_RANDOMIZE
actRien                    ,    // ACT_MENUSENDCMD
actSetGlobalString        ,    // ACT_SETGLOBALSTRING
actSendClipboard        ,    // ACT_SENDCLIPBOARD
actClearClipboard        ,    // ACT_CLEARCLIPBOARD
actRien                    ,    // ACT_EXECPROGRAM2
actRien                    ,    // ACT_OPENDEBUGGER
actRien                    ,    // ACT_PAUSEDEBUGGER
actExtractBinFile        ,    // ACT_EXTRACTBINFILE
actReleaseBinFile        ,    // ACT_RELEASEBINFILE
actSetGlobalInt,            // ACT_SETVARGINT (hidden)
actSetGlobalIntNumExp,        // ACT_SETVARGINTNUMEXP (hidden)
actSetGlobalDbl,            // ACT_SETVARGDBL (hidden)
actSetGlobalDblNumExp,        // ACT_SETVARGDBLNUMEXP (hidden)
actAddGlobalInt,            // ACT_ADDVARGINT (hidden)
actAddGlobalIntNumExp,        // ACT_ADDVARGINTNUMEXP (hidden)
actAddGlobalDbl,            // ACT_ADDVARGDBL (hidden)
actAddGlobalDblNumExp,        // ACT_ADDVARGDBLNUMEXP (hidden)
actSubGlobalInt,            // ACT_SUBVARGINT (hidden)
actSubGlobalIntNumExp,        // ACT_SUBVARGINTNUMEXP (hidden)
actSubGlobalDbl,            // ACT_SUBVARGDBL (hidden)
actSubGlobalDblNumExp,        // ACT_SUBVARGDBLNUMEXP (hidden)
actRien,                    // ACT_STARTPROFILING
actRien,                    // ACT_STOPPROFILING
actRien,                    // ACT_CLEARDEBUGOUTPUT
actRien,                    // ACT_DEBUGOUTPUT
actExecuteChildEvents,      // ACT_EXECUTECHILDEVENTS
actRien,                    // ACT_BREAK
};
EXPROUTINE expSysteme[]={
0                        ,    // -3EXP_VIRGULE
0                        ,    // -2EXP_PARENTH2
OParenthOpen            ,    // -1EXP_PARENTH1

expSys_Long                  ,    // 0LONG
expSys_Random              ,    // 1Random(LONG)
expSys_GlobalValue        ,    // 2EXP_VARGLO
expSys_String            ,    // 3EXP_STRING
expSys_Str                ,    // 4EXP_STR
expSys_Val                ,    // 5EXP_VAL
expSys_Empty            ,    // 6EXP_DRIVE
expSys_Empty            ,    // 7EXP_DIR
expSys_Empty            ,    // 8EXP_PATH
expSys_Empty            ,    // 9EXP_APPNAME
expSys_SIN                ,    // 10EXP_SIN
expSys_COS                ,    // 11EXP_COS
expSys_TAN                ,    // 12EXP_TAN
expSys_SQR                ,    // 13EXP_SQR
expSys_LOG                ,    // 14EXP_LOG
expSys_LN                ,    // 15EXP_LN
expSys_HEX                ,    // 16EXP_HEX
expSys_BIN                ,    // 17EXP_BIN
expSys_EXP                ,    // 18EXP_EXP
expSys_LEFT                ,    // 19EXP_LEFT
expSys_RIGHT            ,    // 20EXP_RIGHT
expSys_MID                ,    // 21EXP_MID
expSys_LEN                ,    // 22EXP_LEN
expSys_DOUBLE            ,    // 23EXP_DOUBLE
expSys_GlobalValueNamed    ,    // 24EXP_VARGLONAMED
expSys_Rien                ,    // 25EXP_ENTERSTRINGHERE
expSys_Rien                ,    // 26EXP_ENTERVALUEHERE
expSys_Rien                ,    // 27EXP_FLOAT
expSys_INT                ,    // 28EXP_INT
expSys_ABS                ,    // 29EXP_ABS
expSys_CEIL                ,    // 30EXP_CEIL
expSys_FLOOR            ,    // 31EXP_FLOOR
expSys_ACOS                ,    // 32EXP_ACOS
expSys_ASIN                ,    // 33EXP_ASIN
expSys_ATAN                ,    // 34EXP_ATAN
expSys_NOT                ,    // 35EXP_NOT
nil                        ,    // 36EXP_NDROPFILES
nil                        ,    // 37EXP_DROPFILE
nil                        ,    // 38EXP_GETCOMMANDLINE
nil                        ,    // 39EXP_GETCOMMANDITEM
expSys_Min                ,    // 40EXP_MIN
expSys_Max                ,    // 41EXP_MAX
expSys_GetRGB            ,    // 42EXP_GETRGB
expSys_GetRed            ,    // 43EXP_GETRED
expSys_GetGreen            ,    // 44EXP_GETGREEN
expSys_GetBlue            ,    // 45EXP_GETBLUE
expSys_LoopIndex        ,    // 46EXP_LOOPINDEX
expSys_NewLine            ,    // 47EXP_NEWLINE
expSys_Round            ,    // 48EXP_ROUND
expSys_GlobalString        ,    // 49EXP_STRINGGLO
expSys_GlobalStringNamed,    // 50EXP_STRINGGLONAMED
expSys_Lower            ,    // 51EXP_LOWER
expSys_Upper            ,    // 52EXP_UPPER
expSys_Find                ,    // 53EXP_FIND
expSys_FindReverse        ,    // 54EXPFINDREVERSE
exp_Clipboard            ,    // 55EXP_GETCLIPBOARD
nil                        ,    // 56EXP_TEMPPATH
nil                        ,    // 57EXP_BINFILETEMPNAME
expSys_FloatStr            ,    // 58EXP_FLOATSTR
expSys_ATAN2            ,    // 59EXP_ATAN2
expSys_Zero             ,   // EXP_ZERO
expSys_Empty            ,   // EXP_EPTY
REXP_DISTANCE            ,    // 62EXP_DISTANCE
REXP_ANGLE                ,    // 63EXP_ANGLE
REXP_RANGE                ,    // 64EXP_RANGE
REXP_RANDOMRANGE        ,    // 65EXP_RANDOMRANGE
expSys_LoopIndexByIndex    ,    // 66EXP_LOOPINDEXBYINDEX
expSys_RuntimeName        ,    // 67EXP_RUNTIMENAME
expSys_StringReplace	,	// 68EXP_STRINGREPLACE
};

// FAUX OBJET OPERATOR
EXPROUTINE expOperators[]={
0,                        // EXP_END
0,                        // EXP_PLUS
OInvertSign,            // EXP_MOINS
0,                        // EXP_MULT
0,                        // EXP_DIV
0,                        // EXP_MOD
0,                        // EXP_POW
0,                        // EXP_AND
0,                        // EXP_OR
0,                        // EXP_XOR
};

// OBJET TEXTE
CONDROUTINE jump1Text[]={
NULL
};
CONDROUTINE jump2Text[]={
NULL
};
ACTROUTINE actText[]={
actTxtDestroy          ,    // ACT_TXTDESTROY
actTxtDisplay          ,    // ACT_TXTDISPLAY
actTxtDisplayDuring    ,    // ACT_TXTDISPLAY
actTxtSetColour        ,    // ACT_TXTSETCOLOUR
actTxtSet              ,    // ACT_TXTSET
actTxtPrevious         ,    // ACT_TXTPREV
actTxtNext             ,    // ACT_TXTNEXT
actTxtDisplayString    ,    // ACT_TXTDISPLAYSTRING
actTxtSetString                // ACT_TXTSETSTRING
};
EXPROUTINE expText[]={
expTxtNumber           ,    // EXP_TXTNUMBER
expTxtGetCurrent       ,    // EXP_TXTGETCURRENT
expTxtGetNumber        ,    // EXP_TXTGETNUMBER
expTxtGetNumeric       ,    // EXP_TXTGETNUMERIC
expTxtGetNPara                // EXP_STRGETNPARA
};

// OBJET QUESTION
CONDROUTINE jump1Quest[]={
eva1QstExact                ,    // CND_QSTEXACT
eva1QstFalse                ,    // CND_QSTEXACT
eva1QstEqual                    // CND_QSTEQUAL
};
CONDROUTINE jump2Quest[]={
eva2QstExact                ,    // CND_QSTEXACT
eva2QstFalse                ,    // CND_QSTEXACT
eva2QstEqual                    // CND_QSTEQUAL
};
ACTROUTINE actQuest[]={
actQstAsk                        // CND_QSTASK
};
EXPROUTINE expQuest[]={NULL};


// OBJET SCORE
CONDROUTINE jump1Score[]={NULL};
CONDROUTINE jump2Score[]={NULL};
ACTROUTINE actScore[]={NULL};
EXPROUTINE expScore[]={NULL};

// OBJET LIVES
CONDROUTINE jump1Lives[]={NULL};
CONDROUTINE jump2Lives[]={NULL};
ACTROUTINE actLives[]={NULL};
EXPROUTINE expLives[]={NULL};

// OBJET COUNTER
CONDROUTINE jump1Counter[]={
evaCounter
};
CONDROUTINE jump2Counter[]={
evaCounter
};
ACTROUTINE actCounter[]={
actCpt_SetValue                ,    // ACT_CSETVALUE
actCpt_AddValue                ,    // ACT_CADDVALUE
actCpt_SubValue                ,    // ACT_CSUBVALUE
actCpt_SetMin                ,    // ACT_CSETMIN
actCpt_SetMax                ,    // ACT_CSETMAX
actCpt_SetColor1            ,    // ACT_CSETCOLOR1
actCpt_SetColor2            ,    // ACT_CSETCOLOR2
};
EXPROUTINE expCounter[]={
expCpt_GetValue                ,    // EXP_CVALUE
expCpt_GetMin                ,    // EXP_CGETMIN
expCpt_GetMax                ,    // EXP_CGETMAX
expCpt_GetColor1            ,    // EXP_CGETCOLOR1
expCpt_GetColor2            ,    // EXP_CGETCOLOR1
};

// OBJET SPRITE
CONDROUTINE jump1Sprite[]={
evaFALSE,                            // CND_SPRCLICK (bsolete!)
evaSpr_CmpAngle,                    // CND_CMPANGLE
evaSpr_CmpScaleX,                    // CND_CMPSCALEX
evaSpr_CmpScaleY,                    // CND_CMPSCALEY
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
};
CONDROUTINE jump2Sprite[]={
evaFALSE,                            // CND_SPRCLICK (bsolete!)
evaSpr_CmpAngle,                    // CND_CMPANGLE
evaSpr_CmpScaleX,                    // CND_CMPSCALEX
evaSpr_CmpScaleY,                    // CND_CMPSCALEY
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
	RCND_EXTONLOOP_INTERNAL    ,
};
ACTROUTINE actSprite[]={
actPasteSprite            ,    // ACT_SPRPASTE
actSpriteFront            ,    // ACT_SPRFRONT
actSpriteBack            ,    // ACT_SPRBACK
actSpriteAddBkd            ,    // ACT_SPRADDBKD
actReplaceColor            ,    // ACT_SPRREPLACECOLOR
actSetScale                ,    // ACT_SPRSETSCALE
actSetScaleX            ,    // ACT_SPRSETSCALEX
actSetScaleY            ,    // ACT_SPRSETSCALEY
actSetAngle                ,    // ACT_SPRSETANGLE
actRien                    ,    // ACT_SPRLOADFRAME
};
EXPROUTINE expSprite[]={
expSpr_GetRGBAt            ,    // EXP_GETRGBAT
expSpr_GetScaleX        ,    // EXP_GETSCALEX
expSpr_GetScaleY        ,    // EXP_GETSCALEY
expSpr_GetAngle                // EXP_GETANGLE
};

// OBJET CCA
CONDROUTINE jump1CCA[]={
    evaCCAFRAMECHANGED,
    evaCCAAPPFINISHED,
    evaCCAISVISIBLE,
    evaCCAAPPPAUSED,
};
CONDROUTINE jump2CCA[]={
    evaCCAFRAMECHANGED,
    evaCCAAPPFINISHED,
    evaCCAISVISIBLE,
    evaCCAAPPPAUSED,
};
ACTROUTINE actCCA[]={
    actCCARESTARTAPP,
    actCCARESTARTFRAME,
    actCCANEXTFRAME,
    actCCAPREVIOUSFRAME,
    actCCAENDAPP,
    actRien,
    actCCAJUMPFRAME,
    actCCASETGLOBALVALUE,
    actCCASHOW,
    actCCAHIDE,
    actCCASETGLOBALSTRING,
    actCCAPAUSEAPP,
    actCCARESUMEAPP,
    RACT_CCASETWIDTH,
    RACT_CCASETHEIGHT
};
EXPROUTINE expCCA[]={
    expCCAGETFRAMENUMBER,
    expCCAGETGLOBALVALUE,
    expCCAGETGLOBALSTRING
};




// ----------------------------------------------------------------------------------
// SAUTS AUX ACTIONS
// ----------------------------------------------------------------------------------
void callAction_Player(event* pe, CRun* rhPtr)
{
    actPlayer[pe->evtCode.evtSCode.evtNum](pe, rhPtr);
}
void callAction_Keyboard(event* pe, CRun* rhPtr)
{
    actKeyboard[pe->evtCode.evtSCode.evtNum](pe, rhPtr);
}
void callAction_Create(event* pe, CRun* rhPtr)
{
    actCreate[pe->evtCode.evtSCode.evtNum](pe, rhPtr);
}
void callAction_Timer(event* pe, CRun* rhPtr)
{
    actTimer[pe->evtCode.evtSCode.evtNum](pe, rhPtr);
}
void callAction_Game(event* pe, CRun* rhPtr)
{
    actGame[pe->evtCode.evtSCode.evtNum](pe, rhPtr);
}
void callAction_Speaker(event* pe, CRun* rhPtr)
{
    actSpeaker[pe->evtCode.evtSCode.evtNum](pe, rhPtr);
}
void callAction_Systeme(event* pe, CRun* rhPtr)
{
    actSysteme[pe->evtCode.evtSCode.evtNum](pe, rhPtr);
}
void callAction_Sprite(event* pe, CRun* rhPtr)
{
    int num=pe->evtCode.evtSCode.evtNum;
    if (num<EVENTS_EXTBASE)
        actCommon[num](pe, rhPtr);
    else
        actSprite[num-EVENTS_EXTBASE](pe, rhPtr);
}
void callAction_Text(event* pe, CRun* rhPtr)
{
    int num=pe->evtCode.evtSCode.evtNum;
    if (num<EVENTS_EXTBASE)
        actCommon[num](pe, rhPtr);
    else
        actText[num-EVENTS_EXTBASE](pe, rhPtr);
}
void callAction_Quest(event* pe, CRun* rhPtr)
{
    int num=pe->evtCode.evtSCode.evtNum;
    if (num<EVENTS_EXTBASE)
        actCommon[num](pe, rhPtr);
    else
        actQuest[num-EVENTS_EXTBASE](pe, rhPtr);
}
void callAction_Score(event* pe, CRun* rhPtr)
{
    int num=pe->evtCode.evtSCode.evtNum;
    if (num<EVENTS_EXTBASE)
        actCommon[num](pe, rhPtr);
    else
        actScore[num-EVENTS_EXTBASE](pe, rhPtr);
}
void callAction_Lives(event* pe, CRun* rhPtr)
{
    int num=pe->evtCode.evtSCode.evtNum;
    if (num<EVENTS_EXTBASE)
        actCommon[num](pe, rhPtr);
    else
        actLives[num-EVENTS_EXTBASE](pe, rhPtr);
}
void callAction_Counter(event* pe, CRun* rhPtr)
{
    int num=pe->evtCode.evtSCode.evtNum;
    if (num<EVENTS_EXTBASE)
        actCommon[num](pe, rhPtr);
    else
        actCounter[num-EVENTS_EXTBASE](pe, rhPtr);
}
void callAction_Rtf(event* pe, CRun* rhPtr)
{
/*    int num=pe->evtNum;
    if (num<EVENTS_EXTBASE)
        actCommon[num](pe);
    else
    {
        EXTACTROUTINE pRout=actRtf[num-EVENTS_EXTBASE];
        actCallRoutine(pe, pRout);
    }
*/
}
void callAction_Cca(event* pe, CRun* rhPtr)
{
    int num=pe->evtCode.evtSCode.evtNum;
    if (num<EVENTS_EXTBASE)
        actCommon[num](pe, rhPtr);
    else
        actCCA[num-EVENTS_EXTBASE](pe, rhPtr);
}

// APPEL D'UNE ACTION EXTENSION
void callAction_Ext(event* pe, CRun* rhPtr)
{
    int num=pe->evtCode.evtSCode.evtNum;
    if (num<EVENTS_EXTBASE)
        actCommon[num](pe, rhPtr);
    else
    {
        CObject* pHo = [rhPtr->rhEvtProg get_ActionObjects:pe];
        if (pHo == nil)
        {
            return;
        }
        if (rhPtr->pActExtension==nil)
        {
            rhPtr->pActExtension=[[CActExtension alloc] init];
        }
        [rhPtr->pActExtension initialize:pe];
        CExtension* pExt = (CExtension*)pHo;
        [pExt action:num-EVENTS_EXTBASE withActExtension:rhPtr->pActExtension];
    }
}

// ----------------------------------------------------------------------------------
// SAUTS AUX CONDITIONS EVENEMENTIELLES
// ----------------------------------------------------------------------------------
BOOL callCond1_Player(event* pe, CRun* rhPtr, LPHO pHo)
{
    return jump1Player[-pe->evtCode.evtSCode.evtNum-1](pe, rhPtr, pHo);
}
BOOL callCond1_Keyboard(event* pe, CRun* rhPtr, LPHO pHo)
{
    return jump1Keyboard[-pe->evtCode.evtSCode.evtNum-1](pe, rhPtr, pHo);
}
BOOL callCond1_Create(event* pe, CRun* rhPtr, LPHO pHo)
{
    return jumpCreate[-pe->evtCode.evtSCode.evtNum-1](pe, rhPtr, pHo);
}
BOOL callCond1_Timer(event* pe, CRun* rhPtr, LPHO pHo)
{
    return jump1Timer[-pe->evtCode.evtSCode.evtNum-1](pe, rhPtr, pHo);
}
BOOL callCond1_Game(event* pe, CRun* rhPtr, LPHO pHo)
{
    return jump1Game[-pe->evtCode.evtSCode.evtNum-1](pe, rhPtr, pHo);
}
BOOL callCond1_Speaker(event* pe, CRun* rhPtr, LPHO pHo)
{
    return jumpSpeaker[-pe->evtCode.evtSCode.evtNum-1](pe, rhPtr, pHo);
}
BOOL callCond1_Systeme(event* pe, CRun* rhPtr, LPHO pHo)
{
    return jump1Systeme[-pe->evtCode.evtSCode.evtNum-1](pe, rhPtr, pHo);
}
BOOL callCond1_Sprite(event* pe, CRun* rhPtr, LPHO pHo)
{
    int num=-pe->evtCode.evtSCode.evtNum-1;
    if (num<EVENTS_EXTBASE)
        return jump1Common[num](pe, rhPtr, pHo);
    else
        return jump1Sprite[num-EVENTS_EXTBASE](pe, rhPtr, pHo);
}
BOOL callCond1_Text(event* pe, CRun* rhPtr, LPHO pHo)
{
    int num=-pe->evtCode.evtSCode.evtNum-1;
    if (num<EVENTS_EXTBASE)
        return jump1Common[num](pe, rhPtr, pHo);
    else
        return jump1Text[num-EVENTS_EXTBASE](pe, rhPtr, pHo);
}
BOOL callCond1_Quest(event* pe, CRun* rhPtr, LPHO pHo)
{
    int num=-pe->evtCode.evtSCode.evtNum-1;
    if (num<EVENTS_EXTBASE)
        return jump1Common[num](pe, rhPtr, pHo);
    else
        return jump1Quest[num-EVENTS_EXTBASE](pe, rhPtr, pHo);
}
BOOL callCond1_Score(event* pe, CRun* rhPtr, LPHO pHo)
{
    int num=-pe->evtCode.evtSCode.evtNum-1;
    if (num<EVENTS_EXTBASE)
        return jump1Common[num](pe, rhPtr, pHo);
    else
        return jump1Score[num-EVENTS_EXTBASE](pe, rhPtr, pHo);
}
BOOL callCond1_Lives(event* pe, CRun* rhPtr, LPHO pHo)
{
    int num=-pe->evtCode.evtSCode.evtNum-1;
    if (num<EVENTS_EXTBASE)
        return jump1Common[num](pe, rhPtr, pHo);
    else
        return jump1Lives[num-EVENTS_EXTBASE](pe, rhPtr, pHo);
}
BOOL callCond1_Counter(event* pe, CRun* rhPtr, LPHO pHo)
{
    int num=-pe->evtCode.evtSCode.evtNum-1;
    if (num<EVENTS_EXTBASE)
        return jump1Common[num](pe, rhPtr, pHo);
    else
        return jump1Counter[num-EVENTS_EXTBASE](pe, rhPtr, pHo);
}

BOOL callCond1_Cca(event* pe, CRun* rhPtr, LPHO pHo)
{
    int num=-pe->evtCode.evtSCode.evtNum-1;
    if (num<EVENTS_EXTBASE)
        return jump1Common[num](pe, rhPtr, pHo);
    else
        return jump1CCA[num-EVENTS_EXTBASE](pe, rhPtr, pHo);
}

void eva1Routine(event* pe, CRun* rhPtr, CObject* pHo)
{
}

BOOL callCond1_Ext(event* pe, CRun* rhPtr, LPHO pHo)
{
    int num=-pe->evtCode.evtSCode.evtNum-1;
    if (num<EVENTS_EXTBASE)
        return jump1Common[num](pe, rhPtr, pHo);
    else
    {
        if (rhPtr->pCndExtension==nil)
        {
            rhPtr->pCndExtension=[[CCndExtension alloc] init];
        }
        [rhPtr->pCndExtension initialize:pe];
        
        CExtension* extPtr = (CExtension*) pHo;
        pHo->hoFlags |= HOF_TRUEEVENT;
        num-=EVENTS_EXTBASE;
        if ([extPtr condition:num withCndExtension:rhPtr->pCndExtension])
        {
            [rhPtr->rhEvtProg evt_AddCurrentObject:pHo];
            return YES;
        }
    }
    return NO;
}

// ----------------------------------------------------------------------------------
// SAUTS AUX CONDITIONS NON EVENEMENTIELLES
// ----------------------------------------------------------------------------------
BOOL callCond2_Player(event* pe, CRun* rhPtr)
{
    return jump2Player[-pe->evtCode.evtSCode.evtNum-1](pe, rhPtr, nil);
}
BOOL callCond2_Keyboard(event* pe, CRun* rhPtr)
{
    return jump2Keyboard[-pe->evtCode.evtSCode.evtNum-1](pe, rhPtr, nil);
}
BOOL callCond2_Create(event* pe, CRun* rhPtr)
{
    return jumpCreate[-pe->evtCode.evtSCode.evtNum-1](pe, rhPtr, nil);
}
BOOL callCond2_Timer(event* pe, CRun* rhPtr)
{
    return jump2Timer[-pe->evtCode.evtSCode.evtNum-1](pe, rhPtr, nil);
}
BOOL callCond2_Game(event* pe, CRun* rhPtr)
{
    return jump2Game[-pe->evtCode.evtSCode.evtNum-1](pe, rhPtr, nil);
}
BOOL callCond2_Speaker(event* pe, CRun* rhPtr)
{
    return jumpSpeaker[-pe->evtCode.evtSCode.evtNum-1](pe, rhPtr, nil);
}
BOOL callCond2_Systeme(event* pe, CRun* rhPtr)
{
    return jump2Systeme[-pe->evtCode.evtSCode.evtNum-1](pe, rhPtr, nil);
}
BOOL callCond2_Sprite(event* pe, CRun* rhPtr)
{
    int num=-pe->evtCode.evtSCode.evtNum-1;
    if (num<EVENTS_EXTBASE)
        return jump2Common[num](pe, rhPtr, nil);
    else
        return jump2Sprite[num - EVENTS_EXTBASE](pe, rhPtr, nil);
}
BOOL callCond2_Text(event* pe, CRun* rhPtr)
{
    int num=-pe->evtCode.evtSCode.evtNum-1;
    if (num<EVENTS_EXTBASE)
        return jump2Common[num](pe, rhPtr, nil);
    else
        return jump2Text[num - EVENTS_EXTBASE](pe, rhPtr, nil);
}
BOOL callCond2_Quest(event* pe, CRun* rhPtr)
{
    int num=-pe->evtCode.evtSCode.evtNum-1;
    if (num<EVENTS_EXTBASE)
        return jump2Common[num](pe, rhPtr, nil);
    else
        return jump2Quest[num - EVENTS_EXTBASE](pe, rhPtr, nil);
}
BOOL callCond2_Score(event* pe, CRun* rhPtr)
{
    int num=-pe->evtCode.evtSCode.evtNum-1;
    if (num<EVENTS_EXTBASE)
        return jump2Common[num](pe, rhPtr, nil);
    else
        return jump2Score[num - EVENTS_EXTBASE](pe, rhPtr, nil);
}
BOOL callCond2_Lives(event* pe, CRun* rhPtr)
{
    int num=-pe->evtCode.evtSCode.evtNum-1;
    if (num<EVENTS_EXTBASE)
        return jump2Common[num](pe, rhPtr, nil);
    else
        return jump2Lives[num - EVENTS_EXTBASE](pe, rhPtr, nil);
}
BOOL callCond2_Counter(event* pe, CRun* rhPtr)
{
    int num=-pe->evtCode.evtSCode.evtNum-1;
    if (num<EVENTS_EXTBASE)
        return jump2Common[num](pe, rhPtr, nil);
    else
        return jump2Counter[num - EVENTS_EXTBASE](pe, rhPtr, nil);
}
BOOL callCond2_Cca(event* pe, CRun* rhPtr)
{
    int num=-pe->evtCode.evtSCode.evtNum-1;
    if (num<EVENTS_EXTBASE)
        return jump2Common[num](pe, rhPtr, nil);
    else
        return jump2CCA[num - EVENTS_EXTBASE](pe, rhPtr, nil);
}
BOOL callCond2_Ext(event* pe, CRun* rhPtr)
{
    int num=-pe->evtCode.evtSCode.evtNum-1;
    if (num<EVENTS_EXTBASE)
        return jump2Common[num](pe, rhPtr, nil);
    else
    {
        if (rhPtr->pCndExtension==nil)
        {
            rhPtr->pCndExtension=[[CCndExtension alloc] init];
        }
        [rhPtr->pCndExtension initialize:pe];
        
        // Boucle d'exploration
        CObject* pHo = [rhPtr->rhEvtProg evt_FirstObject:pe->evtOiList];
        int cpt = rhPtr->rhEvtProg->evtNSelectedObjects;
        num-=EVENTS_EXTBASE;
        
        while (pHo != nil)
        {
            CExtension* pExt = (CExtension*) pHo;
            pHo->hoFlags &= ~HOF_TRUEEVENT;
            if ([pExt condition:num withCndExtension:rhPtr->pCndExtension])
            {
                if ((pe->evtFlags2 & EVFLAG2_NOT) != 0)
                {
                    cpt--;
                    [rhPtr->rhEvtProg evt_DeleteCurrentObject];            // On le vire!
                }
            }
            else
            {
                if ((pe->evtFlags2 & EVFLAG2_NOT) == 0)
                {
                    cpt--;
                    [rhPtr->rhEvtProg evt_DeleteCurrentObject];            // On le vire!
                }
            }
            pHo = [rhPtr->rhEvtProg evt_NextObject];
        }
        // Vrai / Faux?
        if (cpt != 0)
        {
            return YES;
        }
    }
    return NO;
}



// ----------------------------------------------------------------------------------
// SAUTS AUX EXPRESSIONS
// ----------------------------------------------------------------------------------
void callExp_Player(CRun* rhPtr)
{
    expPlayer[rhPtr->rh4ExpToken->expCode.expSCode.expNum](rhPtr);
}
void callExp_Keyboard(CRun* rhPtr)
{
    expKeyboard[rhPtr->rh4ExpToken->expCode.expSCode.expNum](rhPtr);
}
void callExp_Create(CRun* rhPtr)
{
    expCreate[rhPtr->rh4ExpToken->expCode.expSCode.expNum](rhPtr);
}
void callExp_Timer(CRun* rhPtr)
{
    expTimer[rhPtr->rh4ExpToken->expCode.expSCode.expNum](rhPtr);
}
void callExp_Game(CRun* rhPtr)
{
    expGame[rhPtr->rh4ExpToken->expCode.expSCode.expNum](rhPtr);
}
void callExp_Speaker(CRun* rhPtr)
{
    expSpeaker[rhPtr->rh4ExpToken->expCode.expSCode.expNum](rhPtr);
}
void callExp_Systeme(CRun* rhPtr)
{
    expSysteme[rhPtr->rh4ExpToken->expCode.expSCode.expNum+3](rhPtr);        // Pour sauter les tokens expression negatifs
}
void callExp_Operators(CRun* rhPtr)
{
    expOperators[rhPtr->rh4ExpToken->expCode.expSCode.expNum/2](rhPtr);
}
void callExp_Sprite(CRun* rhPtr)
{
    int num=rhPtr->rh4ExpToken->expCode.expSCode.expNum;
    if (num<EVENTS_EXTBASE)
        expCommon[num](rhPtr);
    else
        expSprite[num-EVENTS_EXTBASE](rhPtr);
}
void callExp_Text(CRun* rhPtr)
{
    int num=rhPtr->rh4ExpToken->expCode.expSCode.expNum;
    if (num<EVENTS_EXTBASE)
        expCommon[num](rhPtr);
    else
        expText[num-EVENTS_EXTBASE](rhPtr);
}
void callExp_Quest(CRun* rhPtr)
{
    int num=rhPtr->rh4ExpToken->expCode.expSCode.expNum;
    if (num<EVENTS_EXTBASE)
        expCommon[num](rhPtr);
    else
        expQuest[num-EVENTS_EXTBASE](rhPtr);
}
void callExp_Score(CRun* rhPtr)
{
    int num=rhPtr->rh4ExpToken->expCode.expSCode.expNum;
    if (num<EVENTS_EXTBASE)
        expCommon[num](rhPtr);
    else
        expScore[num-EVENTS_EXTBASE](rhPtr);
}
void callExp_Lives(CRun* rhPtr)
{
    int num=rhPtr->rh4ExpToken->expCode.expSCode.expNum;
    if (num<EVENTS_EXTBASE)
        expCommon[num](rhPtr);
    else
        expLives[num-EVENTS_EXTBASE](rhPtr);
}
void callExp_Counter(CRun* rhPtr)
{
    int num=rhPtr->rh4ExpToken->expCode.expSCode.expNum;
    if (num<EVENTS_EXTBASE)
        expCommon[num](rhPtr);
    else
        expCounter[num-EVENTS_EXTBASE](rhPtr);
}
void callExp_Cca(CRun* rhPtr)
{
    int num=rhPtr->rh4ExpToken->expCode.expSCode.expNum;
    if (num<EVENTS_EXTBASE)
        expCommon[num](rhPtr);
    else
        expCCA[num-EVENTS_EXTBASE](rhPtr);
}

// APPEL D'UNE EXPRESSION EXTENSION
void callExp_Ext(CRun* rhPtr)
{
    int num=rhPtr->rh4ExpToken->expCode.expSCode.expNum;
    if (num<EVENTS_EXTBASE)
        expCommon[num](rhPtr);
    else
    {
        CObject* pHo=[rhPtr->rhEvtProg get_ExpressionObjects:rhPtr->rh4ExpToken->expu.expo.expOiList];
        if (pHo==nil)
        {
            [getCurrentResult() forceInt:0];
            return;
        }
        CExtension* pExt=(CExtension*)pHo;
        CValue* result=[pExt expression:num-EVENTS_EXTBASE];
        [getCurrentResult() forceValue:result];
    }
}




// TABLE DE SAUT AUX CONDITIONS EVENEMENTIELLES
// -----------------------------------------------

CALLCOND1_ROUTINE callTable_Condition1[]={
callCond1_Player,            // -7 PLAYER
callCond1_Keyboard,            // -6 KEYBOARD
callCond1_Create,            // -5 CREATE
callCond1_Timer,            // -4 TIMER
callCond1_Game,                // -3 GAME
callCond1_Speaker,            // -2 SPEAKER
callCond1_Systeme,            // -1 SYSTEME
0,                            //  0 OBJ_BOX
0,                            //  1 OBJ_BKD
callCond1_Sprite,             //  2 OBJ_SPR
callCond1_Text,                //  3 OBJ_TEXT
callCond1_Quest,            //  4 OBJ_QUEST
callCond1_Score,            //  5 OBJ_SCORE
callCond1_Lives,            //  6 OBJ_LIVES
callCond1_Counter,            //  7 OBJ_COUNTER
nil,                        //  8 OBJ_RTF
callCond1_Cca,                //  9 OBJ_CCA
0,0,0,0,0,0,
0,0,0,0,0,0,0,0,            //  16
0,0,0,0,0,0,0,0,
callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext,    //32
callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext,
callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext,    //48
callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext,
callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext,    //64
callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext,
callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext,    //80
callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext,
callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext,    //96
callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext,
callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext,    //112
callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext, callCond1_Ext
};

// TABLE DE SAUT AUX CONDITIONS NON EVENEMENTIELLES
// ------------------------------------------------
CALLCOND2_ROUTINE callTable_Condition2[]={
callCond2_Player,            // -7 PLAYER
callCond2_Keyboard,            // -6 KEYBOARD
callCond2_Create,            // -5 CREATE
callCond2_Timer,            // -4 TIMER
callCond2_Game,                // -3 GAME
callCond2_Speaker,            // -2 SPEAKER
callCond2_Systeme,            // -1 SYSTEME
0,                            //  0 OBJ_BOX
0,                            //  1 OBJ_BKD
callCond2_Sprite,             //  2 OBJ_SPR
callCond2_Text,                //  3 OBJ_TEXT
callCond2_Quest,            //  4 OBJ_QUEST
callCond2_Score,            //  5 OBJ_SCORE
callCond2_Lives,            //  6 OBJ_LIVES
callCond2_Counter,            //  7 OBJ_COUNTER
nil,                        //  8 OBJ_RTF
callCond2_Cca,                //  9 OBJ_CCA
0,0,0,0,0,0,
0,0,0,0,0,0,0,0,            //  16
0,0,0,0,0,0,0,0,
callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext,    //32
callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext,
callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext,    //48
callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext,
callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext,    //64
callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext,
callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext,    //80
callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext,
callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext,    //96
callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext,
callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext,    //112
callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext, callCond2_Ext
};

// TABLE DE SAUT AUX ACTIONS
// -----------------------------------------------
CALLACTION_ROUTINE callTable_Action[]={
callAction_Player,            // -7 PLAYER
callAction_Keyboard,        // -6 KEYBOARD
callAction_Create,            // -5 CREATE
callAction_Timer,            // -4 TIMER
callAction_Game,            // -3 GAME
callAction_Speaker,            // -2 SPEAKER
callAction_Systeme,            // -1 SYSTEME
0,                            //  0 OBJ_BOX
0,                            //  1 OBJ_BKD
callAction_Sprite,             //  2 OBJ_SPR
callAction_Text,                //  3 OBJ_TEXT
callAction_Quest,            //  4 OBJ_QUEST
callAction_Score,            //  5 OBJ_SCORE
callAction_Lives,            //  6 OBJ_LIVES
callAction_Counter,            //  7 OBJ_COUNTER
nil,                        //  8 OBJ_RTF
callAction_Cca,                //  9 OBJ_CCA
0,0,0,0,0,0,
0,0,0,0,0,0,0,0,            //  16
0,0,0,0,0,0,0,0,
callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext,    //32
callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext,
callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext,    //48
callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext,
callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext,    //64
callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext,
callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext,    //80
callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext,
callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext,    //96
callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext,
callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext,    //112
callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext, callAction_Ext
};

// TABLE DE SAUT AUX EXPRESSIONS
// -----------------------------------------------
CALLEXP_ROUTINE callTable_Expression[]={
callExp_Player,                // -7 PLAYER
callExp_Keyboard,            // -6 KEYBOARD
callExp_Create,                // -5 CREATE
callExp_Timer,                // -4 TIMER
callExp_Game,                // -3 GAME
callExp_Speaker,            // -2 SPEAKER
callExp_Systeme,            // -1 SYSTEME
callExp_Operators,            //  0 OBJ_BOX
0,                            //  1 OBJ_BKD
callExp_Sprite,                //  2 OBJ_SPR
callExp_Text,                //  3 OBJ_TEXT
callExp_Quest,                //  4 OBJ_QUEST
callExp_Score,                //  5 OBJ_SCORE
callExp_Lives,                //  6 OBJ_LIVES
callExp_Counter,            //  7 OBJ_COUNTER
nil,                        //  8 OBJ_RTF
callExp_Cca,                //  9 OBJ_CCA
0,0,0,0,0,0,
0,0,0,0,0,0,0,0,            //  16
0,0,0,0,0,0,0,0,
callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext,    //32
callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext,
callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext,    //48
callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext,
callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext,    //64
callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext,
callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext,    //80
callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext,
callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext,    //96
callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext,
callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext,    //112
callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext, callExp_Ext
};





@implementation CEvents

@end
