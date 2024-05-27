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
// CSOUNDBANK : stockage des sons
//
//----------------------------------------------------------------------------------
#import "CSoundBank.h"
#import "CRunApp.h"
#import "CSound.h"
#import "CFile.h"

@implementation CSoundBank

-(id)initWithApp:(CRunApp*)app
{
	runApp=app;
	return self;
}
-(void)dealloc
{
	if (sounds!=nil)
	{
		int n;
		for (n=0; n<nSounds; n++)
		{
			if (sounds[n]!=nil)
			{
				[sounds[n] release];
			}
		}
		free(sounds);			
	}
	if (offsetsToSounds!=nil)
	{
		free(offsetsToSounds);
	}
	if (handleToIndex!=nil)
	{
		free(handleToIndex);
	}
	if (useCount!=nil)
	{
		free(useCount);
	}
	if (audioFlags!=nil)
	{
		free(audioFlags);
	}
	[super dealloc];
}
-(void)preLoad
{
	// Nombre de handles
	nHandlesReel=[runApp->file readAShort];
	offsetsToSounds=(NSUInteger*)malloc(nHandlesReel*sizeof(NSUInteger));
	
	// Repere les positions des images
	int nSnd=[runApp->file readAShort];
	NSUInteger offset;
	NSUInteger size;
	short handle;
	
	for (int n=0; n<nSnd; n++)
	{
		offset=[runApp->file getFilePointer];
		handle=[runApp->file readAShort];
		size=[runApp->file readAShort];
		if (runApp->bUnicode)
		{
			size*=2;
		}
		[runApp->file skipBytes:size];
        [runApp->file skipBytes:4];
		size=[runApp->file readAInt];
		[runApp->file skipBytes:size];
		offsetsToSounds[handle]=offset;
	}
	
	// Reservation des tables
	useCount=(short*)malloc(nHandlesReel*sizeof(short));
	audioFlags=(short*)malloc(nHandlesReel*sizeof(short));
	handleToIndex=(short*)malloc(nHandlesReel*sizeof(short));
	[self resetToLoad];
	nHandlesTotal=nHandlesReel;
	nSounds=0;
	sounds=nil;
}

-(CSound*)getSoundFromHandle:(short)handle
{
    if (handle>=0 && handle<nHandlesTotal)
        if (handleToIndex[handle]!=-1)
            return sounds[handleToIndex[handle]];
    return nil;
}
-(short)getSoundHandleFromName:(NSString*)soundName
{
    short h;
    for (h=0; h<nHandlesTotal; h++)
    {
        if (handleToIndex[h]!=-1)
        {
            CSound* snd = sounds[handleToIndex[h]];
            if (snd != nil && [snd->name compare:soundName]==0)
                return h;
        }
    }
    return -1;
}
-(CSound*)getSoundFromIndex:(short)index
{
	if (index>=0 && index<nSounds)
	    return sounds[index];
	return nil;
}
-(void)cleanMemory
{
	int index;
	for (index=0; index<nSounds; index++)
	{
		if (sounds[index]!=nil)
		{
			[sounds[index] cleanMemory];
		}
	}
}

-(void)resetToLoad
{
	int n;
	for (n=0; n<nHandlesReel; n++)
	{
	    useCount[n]=0;
	}
}
-(void)setToLoad:(short)handle
{
    if (offsetsToSounds[handle]!=0)
    {
        useCount[handle]++;
//        audioFlags[handle]=f;
    }
}
-(void)setFlags:(short)handle flags:(short)flag
{
    if (offsetsToSounds[handle]!=0)
    {
        audioFlags[handle]=flag;
    }
}

-(void)load
{
	int n;
	
	// Combien de sons?
	nSounds=0;
	for (n=0; n<nHandlesReel; n++)
	{
	    if (useCount[n]!=0)
			nSounds++;
	}
	
	// Charge les sons
	int id=0;
	CSound** newSounds=NULL;
	if(nSounds > 0)
		newSounds = (CSound**)calloc(nSounds, sizeof(CSound*));
	int count=0;

	for (int h=0; h<nHandlesReel; h++)
	{
		if (useCount[h]!=0)
		{
			short soundIndex = handleToIndex[h];
			if (sounds!=nil && handleToIndex[h] != -1 && sounds[soundIndex] != nil)
			{
				newSounds[count] = sounds[soundIndex];
			}
			else
			{
				newSounds[count]=[[CSound alloc] initWithSoundPlayer:runApp->soundPlayer andALPlayer:runApp->ALPlayer];
				[runApp->file seek:offsetsToSounds[h]];
				[newSounds[count] load:runApp->file flags:audioFlags[h]];
				id++;
			}
			count++;
		}
		else
		{
			if (sounds!=nil)
			{
				short index = handleToIndex[h];
				if(index>=0 && sounds[index]!=nil)
				{
					CSound* sound = sounds[index];
					[sound release];
					sounds[index]=nil;
				}
			}
		}
	}

	if (sounds!=nil)
	{
		free(sounds);
	}		
	sounds=newSounds;
	
	// Cree la table d'indirection
	if (handleToIndex!=nil)
	{
		free(handleToIndex);
	}
	handleToIndex=(short*)malloc(nHandlesReel*sizeof(short));
	for (n=0; n<nHandlesReel; n++)
	{
	    handleToIndex[n]=-1;
	}
	for (n=0; n<nSounds; n++)
	{
		CSound* sound = sounds[n];
		if(sound != nil)
			handleToIndex[sound->handle] = (short)n;
	}
	nHandlesTotal=nHandlesReel;
	
	// Plus rien a charger
	[self resetToLoad];
}


@end
