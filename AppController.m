//
//  AppController.m
//  Animated Mandelbrot
//
//  Created by Jon Stacey on 2/7/09.
//  Copyright 2009 Jon Stacey. All rights reserved.
//

#import "AppController.h"
#import "ControlsController.h"

@implementation AppController

#pragma mark -
#pragma mark Initialization Methods

// -------------------------------------------------------------------------------
// Initialization Methods
// -------------------------------------------------------------------------------
- (id)init
{
	if (self != [super init]) 
		return nil;
	
	// Set maximum and minimum default values
	minMaxDwell		=   128;
	maxMaxDwell		= 16384;
	
	minEscapeRadius =     2;
	maxEscapeRadius =   128;
	
	minFrameRate	=     1;
	maxFrameRate	=	 99;
	
	minDuration		=	  1;
	maxDuration		=	999;
	
	return self;
}


#pragma mark -
#pragma mark Validation Delegate Methods

// -------------------------------------------------------------------------------
// Validates maxDwell
// -------------------------------------------------------------------------------
- (BOOL)validateMaxDwell:(id *)ioValue
				   error:(NSError **)outError
{
	int value = [*ioValue intValue];
	
	[self willChangeValueForKey:@"maxDwell"];
	
	debug_NSLog(@"Changing maxDwell");
	
	if (value < minMaxDwell)
		maxDwell = minMaxDwell;
	else if (value > maxMaxDwell)
		maxDwell = maxMaxDwell;
	else
		maxDwell = value;
	
	[self didChangeValueForKey:@"maxDwell"];

	return YES;
}

// -------------------------------------------------------------------------------
// Validates escapeRadius
// -------------------------------------------------------------------------------
- (BOOL)validateEscapeRadius:(id *)ioValue
					   error:(NSError **)outError
{
	int value = [*ioValue intValue];
	
	[self willChangeValueForKey:@"escapeRadius"];
	
	debug_NSLog(@"Changing escapeRadius"); 
	
	if (value < minEscapeRadius)
		escapeRadius = minEscapeRadius;
	else if (value > maxEscapeRadius)
		escapeRadius = maxEscapeRadius;
	else
		escapeRadius = value;
	
	[self didChangeValueForKey:@"escapeRadius"];
	
	return YES;
}

// -------------------------------------------------------------------------------
// Validates frameRate
// -------------------------------------------------------------------------------
- (BOOL)validateFrameRate:(id *)ioValue
					error:(NSError **)outError
{
	int value = [*ioValue intValue];
	
	[self willChangeValueForKey:@"frameRate"];
	
	debug_NSLog(@"Changing frameRate"); 
	
	if (value < minFrameRate)
		frameRate = minFrameRate;
	else if (value > maxFrameRate)
		frameRate = maxFrameRate;
	else
		frameRate = value;
	
	[self didChangeValueForKey:@"frameRate"];
	
	return YES;
}

// -------------------------------------------------------------------------------
// Validates duration
// -------------------------------------------------------------------------------
- (BOOL)validateDuration:(id *)ioValue
					error:(NSError **)outError
{
	int value = [*ioValue intValue];
	
	[self willChangeValueForKey:@"duration"];
	
	debug_NSLog(@"Changing duration"); 
	
	if (value < minDuration)
		duration = minDuration;
	else if (value > maxDuration)
		duration = maxDuration;
	else
		duration = value;
	
	[self didChangeValueForKey:@"duration"];
	
	return YES;
}

#pragma mark -
#pragma mark Synthesized Methods

@synthesize maxDwell;
@synthesize escapeRadius;
@synthesize frameRate;
@synthesize duration;

@end
