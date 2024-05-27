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
// CMOVEDEF : classe abstraite base des definitions mouvements
//
//----------------------------------------------------------------------------------
#import "CMoveDef.h"
#import "CFile.h"

@implementation CMoveDef

-(void)load:(CFile*)file withLength:(int)length
{
	mvRuntimeFlags=0;
}
-(void)setData:(short)t withControl:(short)c andMoveAtStart:(unsigned char)m andDirAtStart:(int)d andOptions:(unsigned char)mo
{
	mvType=t;
	mvControl=c;
	mvMoveAtStart=m;
	mvDirAtStart=d;
	mvOpt=mo;
	mvRuntimeFlags=0;
}

@end