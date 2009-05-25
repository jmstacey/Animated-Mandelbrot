//
//  Movie.m
//  Animated Mandelbrot
//
//  Created by Jon Stacey on 2/13/09.
//  Copyright 2009 Jon Stacey. All rights reserved.
//

#import "FractalMovie.h"
#import "Mandelbrot.h"
#import "ProgressController.h"

@implementation FractalMovie

#pragma mark -
#pragma mark Initialization Methods

// -------------------------------------------------------------------------------
// Default initialization method that will throw an exception if used.
//	Use the other init method.
// -------------------------------------------------------------------------------
- (id)init
{
	@throw [NSException exceptionWithName:@"FractalMovieBadCall" reason:@"Initialize using an alternative init method." userInfo:nil];
	return nil;
}

// -------------------------------------------------------------------------------
// Initialization method
// -------------------------------------------------------------------------------
- (id)initWithQTMovie:(QTMovie *)aMovie
			movieName:(NSString *)aMovieName
		  movieHeight:(int)aFrameHeight
		   movieWidth:(int)aFrameWidth
		  movieStartX:(double)aStartX
		  movieStartY:(double)aStartY
	   movieStartStep:(double)aStartStep
			movieEndX:(double)aEndX
			movieEndY:(double)aEndY
		 movieEndStep:(double)aEndStep
	 objectController:(id)aObject
{
	if (self != [super init]) 
		return nil;
	
	// Inilialize instance variables
	movie		= aMovie;
	movieName	= aMovieName;
	
	frameHeight = aFrameHeight;
	frameWidth	= aFrameWidth;
	frameRate	= [[aObject valueForKeyPath:@"selection.frameRate"] intValue];
	duration	= [[aObject valueForKeyPath:@"selection.duration"]  intValue];
	
	startX		= aStartX;
	startY		= aStartY;
	endX		= aEndX;
	endY		= aEndY;
	startStep	= aStartStep;
	endStep		= aEndStep;
	
	objectController = aObject;
	
	progressWindow	 = [[ProgressController alloc] init]; // Prepare progress window instance	
	
	return self;
}

#pragma mark -
#pragma mark Other Methods

// TODO: Add distance/time factoring (option?) so that the zoom effect appears constant throughout the duration

// -------------------------------------------------------------------------------
// Thread is detached on this method. This method then carries out the process
//	of creating the movie.
// -------------------------------------------------------------------------------
- (void)createMovieBGThread
{
	NSBitmapImageRep	*frame;
	NSImage				*tmpFrame;
	NSData				*frameData;
	Mandelbrot			*fractalFrame;
	
	double	x; 
	double	y; 
	double	step;
	double	xDelta;
	double	yDelta;
	double	stepDelta;
	double	progressBarDelta;
	
	int		frameCount = frameRate * duration;
	
	// Prepare progress window
	[progressWindow setStatusMessage:[NSString stringWithFormat:@"Calculating frame deltas", movieName]];
	[progressWindow setFrameDetails:[NSString stringWithFormat:@""]];
	[progressWindow showWindow:self]; // Show progress window
	
	[QTMovie enterQTKitOnThread]; // We're using QTKit on a non-main thread
	
	// Prepare movie attributes
	NSDictionary *movieAttrs = [NSDictionary dictionaryWithObject:@"png " forKey:QTAddImageCodecType];
	
	// create a QTTime value to be used as a duration when adding the image to the movie
	long timeScale			= 600;
	long long timeValue		= timeScale / frameRate;
	QTTime movieDuration    = QTMakeTime(timeValue, timeScale);

	
	// Set current working position variables
	x		= startX;
	y		= startY;
	step	= startStep;
	
	// I need to figure out somehow what deltas to start with befor the quadratic part
	
	// Calculate deltas
	xDelta				= (startX - endX) / frameCount;
	yDelta				= (startY - endY) / frameCount;
	stepDelta			= (startStep - endStep) / frameCount;	
	progressBarDelta	= 100 / (double)frameCount;
	
	// Update progress window for next stage
	[progressWindow setStatusMessage:[NSString stringWithFormat:@"Creating movie %@", movieName]];
	[progressWindow setFrameDetails:[NSString stringWithFormat:@"%d / %d frames", 0, frameCount]];
	
	progressBarDelta = 100 / (double)frameCount;
	NSLog(@"starting: %e, %e, %e", x, y, step);
	NSLog(@"ending: %e, %e, %e", endX, endY, endStep);
	NSLog(@"delta: %e, %e, %e", xDelta, yDelta, stepDelta);
	
	// Generate frames
	for (int i = 0; i <= frameCount && ![progressWindow abort]; i++) 
	{
		//fractalFrame = [[Mandelbrot alloc] initWithFrameHeight:frameHeight frameWidth:frameWidth viewX:x viewY:y viewStep:step objectController:objectController];
		//frame		 = [fractalFrame createFrame];
//		
//		frameData = [[NSData alloc] initWithData:[frame representationUsingType:NSPNGFileType properties:nil]];
//		// Don't forget to change movieAttrs if there's a new codec
//		
//		tmpFrame = [[NSImage alloc] initWithData:frameData];
//		[movie addImage:tmpFrame forDuration:movieDuration withAttributes:movieAttrs];
		
		NSLog(@"");
		NSLog(@"d: %e, %e, %e", xDelta, yDelta, stepDelta);
		NSLog(@"%i: %e, %e, %e", i, x, y, step);
		NSLog(@"");
		
		xDelta		= xDelta	- [self quadraticX:xDelta];
		yDelta		= yDelta	- [self quadraticX:yDelta];
		stepDelta   = stepDelta	- [self quadraticX:stepDelta];
		
		// Update coordinates
		x		-= xDelta;
		y		-= yDelta;
		step	-= stepDelta;
		
		//NSString *filename = [NSString stringWithFormat:@"/Users/jon/Desktop/debug/%i.jpg", i];
		
		//[[frame representationUsingType:NSPNGFileType properties:nil] writeToFile:filename atomically:YES];
		
		
		
		// Update status window
		[progressWindow setCurProgress:[progressWindow curProgress] + progressBarDelta];
		[progressWindow setFrameDetails:[NSString stringWithFormat:@"%d / %d frames", i, frameCount]];
	}
	
	NSLog(@"ending: %e, %e, %e", endX, endY, endStep);
	
	if ([progressWindow abort]) 
	{
		[progressWindow setCurProgress:0.0];
		[progressWindow setStatusMessage:@"Operation Aborted. Cleaning Up."];
		// TODO: Remove the incomplete file
	}
	else 
	{
		[progressWindow setCurProgress:100.0];
		[progressWindow setStatusMessage:@"Finished creating movie"];
		[movie updateMovieFile];
	}
	
	[QTMovie exitQTKitOnThread];
	
	[progressWindow close];
}

#pragma mark -
#pragma mark Helper Methods

- (double)quadraticX:(double)x
{
	double y;
	
	y = pow(x, 2) + (0 * x);
	
	return y;
}

//- (double)powerOfValue:(double)value
//		 raisedToPower:(double)power
//{
//	while (power > 1)
//	{
//		value	= value * value;
//		power	= power - 1;
//	}
//	
//	return value;
//}


- (double)blasted:(double)value
{
	double retVal;
	if (value > 0)
	{
		retVal = sqrt(value);
	}
	else
	{
		retVal = sqrt(fabs(value));
		retVal *= -1;
	}
	
	return retVal;
}


@end
