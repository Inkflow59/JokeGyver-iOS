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
//----------------------------------------------------------------------------------
//
// CQuestion : Objet question
//
//----------------------------------------------------------------------------------
#import "CQuestion.h"
#import "CRun.h"
#import "CObjectCommon.h"
#import "CCreateObjectInfo.h"
#import "CDefTexts.h"
#import "CDefText.h"
#import "CRunApp.h"
#import "CEventProgram.h"
#import "MainViewController.h"

@implementation CQuestion

-(void)initObject:(CObjectCommon*)ocPtr withCOB:(CCreateObjectInfo*)cob
{
}

-(void)handle
{
    if (bAsked==NO)
    {
        bAsked=YES;
        CDefTexts* defTexts = (CDefTexts*)hoCommon->ocObject;
    
        NSString* title = defTexts->otTexts[0]->tsText;
        //alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
        for (int i=1; i < defTexts->otNumberOfText; i++)
        {
            //[alert addButtonWithTitle:defTexts->otTexts[i]->tsText];
            UIAlertAction* action =  [UIAlertAction actionWithTitle:defTexts->otTexts[i]->tsText
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                    [self checkAnswer:action];
                                 }];
            [alertController addAction:action];
        }
    
        //[alert show];
        [hoAdRunHeader->rhApp->mainViewController presentViewController:alertController animated:YES];
        numReponses=defTexts->otNumberOfText;
        [hoAdRunHeader pause];
    }
}


//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSInteger current = buttonIndex+1;
//
//    CDefTexts* defTexts = (CDefTexts*)hoCommon->ocObject;
//    CDefText* ptts = defTexts->otTexts[current];
//    BOOL bCorrect=(ptts->tsFlags & TSF_CORRECT) != 0;
//
//    [hoAdRunHeader->rhEvtProg push_Event:1 withCode:(((-80 - 3) * 65536) | 4) andParam:(int)current andObject:self andOI:0]; // CNDL_QEQUAL
//
//    if (bCorrect)
//    {
//        int cond = ((-80-1) * 65536);        // CNDL_EXTANIMENDOF;
//        cond |= (((int)4) & 0xFFFF);
//         [hoAdRunHeader->rhEvtProg push_Event:1 withCode:cond andParam:0 andObject:self andOI:0];      // CNDL_QEXACT
//    }
//    else
//        [hoAdRunHeader->rhEvtProg push_Event:1 withCode:(((-80 - 2) * 65536) | 4) andParam:0 andObject:self andOI:0];      // CNDL_QFALSE
//
//    //[alert setDelegate:nil];
//    //[alert autorelease];
//    [hoAdRunHeader resume];
//    [hoAdRunHeader destroy_Add:hoNumber];
//}

-(void)checkAnswer:(UIAlertAction*) action
{
    CDefTexts* defTexts = (CDefTexts*)hoCommon->ocObject;
    int current = 0;
    
    for (int i=1; i < defTexts->otNumberOfText; i++)
    {
        if([action.title isEqualToString:defTexts->otTexts[i]->tsText])
        {
            current = i;
            break;
        }
    }
    
    CDefText* ptts = defTexts->otTexts[current];
    BOOL bCorrect=(ptts->tsFlags & TSF_CORRECT) != 0;
    
    [hoAdRunHeader->rhEvtProg push_Event:1 withCode:(((-80 - 3) * 65536) | 4) andParam:(int)current andObject:self andOI:0]; // CNDL_QEQUAL
    
    if (bCorrect)
    {
        int cond = ((-80-1) * 65536);        // CNDL_EXTANIMENDOF;
        cond |= (((int)4) & 0xFFFF);
         [hoAdRunHeader->rhEvtProg push_Event:1 withCode:cond andParam:0 andObject:self andOI:0];      // CNDL_QEXACT
    }
    else
        [hoAdRunHeader->rhEvtProg push_Event:1 withCode:(((-80 - 2) * 65536) | 4) andParam:0 andObject:self andOI:0];      // CNDL_QFALSE
    
    //[alert setDelegate:nil];
    //[alert autorelease];
    [alertController dismissViewControllerAnimated:YES completion:nil];
    [hoAdRunHeader resume];
    [hoAdRunHeader destroy_Add:hoNumber];
}

@end
