//
//  Mandelbrot.m
//  Animated Mandelbrot
//
//  Created by Jon Stacey on 2/7/09.
//  Copyright 2009 Jon Stacey. All rights reserved.
//

#import "Mandelbrot.h"


@implementation Mandelbrot

#pragma mark -
#pragma mark Initialization Methods

// -------------------------------------------------------------------------------
// Default initialization method that will throw an exception if used.
//	Use the other init method.
// -------------------------------------------------------------------------------
- (id)init
{
	@throw [NSException exceptionWithName:@"MandelbrotBadCall" reason:@"Initialize using an alternative init method." userInfo:nil];
	return nil;
}

// -------------------------------------------------------------------------------
// Initialization method
// -------------------------------------------------------------------------------
- (id) initWithFrameHeight:(int)aFrameHeight
				frameWidth:(int)aFrameWidth
					 viewX:(double)aViewX
					 viewY:(double)aViewY
				  viewStep:(double)aViewStep
		  objectController:(id)aObjectController
{
	if (self != [super init]) 
		return nil;
	
	activeProcessors  = [[NSProcessInfo processInfo] activeProcessorCount];
	
	frameHeight		= aFrameHeight;
	frameWidth		= aFrameWidth;
	viewX			= aViewX;
	viewY			= aViewY;
	viewStep		= aViewStep;
	maxDwell		= [[aObjectController valueForKeyPath:@"selection.maxDwell"] intValue];
	escapeRadius	= [[aObjectController valueForKeyPath:@"selection.escapeRadius"] intValue];
	
	curView = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
													  pixelsWide:frameWidth
													  pixelsHigh:frameHeight
												   bitsPerSample:8 
												 samplesPerPixel:3 
														hasAlpha:NO 
														isPlanar:NO
												  colorSpaceName:NSCalibratedRGBColorSpace
													 bytesPerRow:(frameWidth * 3) 
													bitsPerPixel:0];
	
	bitmapData = [curView bitmapData]; // We're going to directly manipulate each pixel.
	
	return self;
}

#pragma mark -
#pragma mark Mandelbrot Methods


// -------------------------------------------------------------------------------
// Determines the number of dwell for given pixel.
// -------------------------------------------------------------------------------
- (int) dwellsForX:(double)x
			  forY:(double)y
{
	register double Zr = 0;
	register double Zi = 0;
	register double tmp1;
	register double tmp2;
	
	register int	dwell;
	
    for (dwell = 0; dwell <= maxDwell; dwell++)
    {
		tmp1 = Zr * Zr;
		tmp2 = Zi * Zi;
		Zi	 = ( 2.0 * Zr * Zi ) + y ;
		Zr	 = tmp1 - tmp2 + x ;
		
		if ((tmp1 + tmp2) > escapeRadius ) 
			break;
    }
	
    return dwell;
}

// -------------------------------------------------------------------------------
// This method works on the specified area of the screen. In this implementation,
//	this method is detached for ever available processor.
// -------------------------------------------------------------------------------
- (void) threadMain:(NSArray *)workController
{
	int startY  = [[workController objectAtIndex:0] intValue];
	int endY	= [[workController objectAtIndex:1] intValue];
	
	int	x;
	int	y;
	int dwell;
	int bitmapIndex;
	
	double ix;
	double iy;
	
	float red;
	float green;
	float blue;
	
	for (y = startY; y < endY; y++)
	{
		for (x = 0; x < frameWidth; x++)
		{
			ix = viewX + (viewStep * x);
			iy = viewY - (viewStep * y);
			
			dwell = [self dwellsForX:ix forY:iy];
			
			// TODO: Color smoothing
			
			if (dwell == maxDwell)
			{
				red		= 0;
				blue	= 0;
				green	= 0;
			}
			else
			{
                red		= ( dwell % 16) * 16;
                green	= (( dwell / 16 ) % 16 ) * 16;
                blue	= (( dwell / 256 ) % 16 ) * 16;
			}
			
			// Bitmap index equation: 3(x+w*y) + offset
			bitmapIndex = 3 * (x + frameWidth * y);
			
			bitmapData[bitmapIndex]		= red;
			bitmapData[bitmapIndex + 1] = green;
			bitmapData[bitmapIndex + 2] = blue;
		}
	}
}

#pragma mark -
#pragma mark Main Method

// -------------------------------------------------------------------------------
// Main (master) method. This is called when a new frame is needed. It breaks up
//	the work into manageable chunks based on the number of available processors
//	and delegates the work to multiple threads.
// -------------------------------------------------------------------------------
- (NSBitmapImageRep *) createFrame
{	
	int lineDelta;
	int remainder;
	int workingLine = 0;
	
	NSArray			*workController;
	NSMutableArray	*threadController = [[NSMutableArray alloc] init];
	
	remainder = frameHeight % activeProcessors;				  // In the event there's a remainder
	lineDelta = frameHeight / activeProcessors; // Break up the screen into parts (deltas)
	
	// Prepare threads
	for (int cpuCount = 0; cpuCount < activeProcessors; cpuCount++)
	{
		if (activeProcessors - cpuCount == 1)		// Last available processor/core
			lineDelta = lineDelta + remainder;		// The last thread will handle the remainder of lines.
		
		workController = [NSArray arrayWithObjects:[NSNumber numberWithInt:workingLine],
												   [NSNumber numberWithInt:workingLine + lineDelta],
													nil];
		
		[threadController addObject:[[NSThread alloc] initWithTarget:self selector:@selector(threadMain:) object:workController]];
		
		workingLine += lineDelta;
	}
	
	// Start threads
	for (int i = 0; i < [threadController count]; i++)
		[[threadController objectAtIndex:i] start];
	
	// Wait for all threads to finish before returning the frame
	for (int i = 0; i < [threadController count]; i++)
	{
		// TODO: Once a thread is done, we don't need to keep checking it....
		if (![[threadController objectAtIndex:i] isFinished])
			i = -1;
	}
	
	// Post notification that the frame is ready
	NSDictionary *frameInfo = [NSDictionary dictionaryWithObject:curView forKey:@"frame"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AMFrameIsReady" 
														object:self
													  userInfo:frameInfo];
	
	return curView;
}

#pragma mark -
#pragma mark Synthesized Methods

@synthesize curView;


#pragma mark -
#pragma mark Unused Code

/*
 * UNUSED as of 3/7/09
 * This causes a delay of almost a second from the time the frame is ready 
 * until the thread is finally exited. Checking for finished threads 
 * through a threadController yields better performance in the viewer.
 * * * * * * * * * * * * * * * * * * * * * 
 *
 * FROM: header
 *
 * BOOL	shouldKeepRunning; // global

 * FROM: init
 *
 * shouldKeepRunning = YES;
 * Register observer. Notify us when every thread is done.
 * [[NSNotificationCenter defaultCenter] addObserver:self
 *										 selector:@selector(NSThreadIsExiting)
 *											 name:@"NSThreadWillExitNotification" object:nil];

 * FROM: createFrame
 *
 * NSRunLoop *theRL = [NSRunLoop currentRunLoop];
 * while (shouldKeepRunning && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);

 *- (void)NSThreadIsExiting
 *{	
 *	debug_NSLog(@"Thread is exiting");
 *	doneThreadCount++;
 *	
 *	if (doneThreadCount == activeProcessors) {
 *		shouldKeepRunning = NO;
 *		debug_NSLog(@"Exiting RunLoop");
 *	}
 *}
 */

@end
