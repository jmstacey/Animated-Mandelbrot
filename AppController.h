//
//  AppController.h
//  Animated Mandelbrot
//
//  Created by Jon Stacey on 2/7/09.
//  Copyright 2009 Jon Stacey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ControlsController;

@interface AppController : NSObject
{
	int maxDwell;
	int escapeRadius;
	int	frameRate;
	int duration;

	// Minimum and maximum defaults
	int		minMaxDwell;
	int		maxMaxDwell;
	
	int		minEscapeRadius;
	int		maxEscapeRadius;
	
	int		minFrameRate;
	int		maxFrameRate;
	
	int		minDuration;
	int		maxDuration;
}

@property(readwrite, assign) int maxDwell;
@property(readwrite, assign) int escapeRadius;
@property(readwrite, assign) int frameRate;
@property(readwrite, assign) int duration;

@end
