//
//  JSIndeterminateProgressIndicatorCell.h
//  A more flexible indeterminate progress indicator
//
//  Created by Andreas on 23.01.07.
//  Copyright 2007 Andreas Mayer. All rights reserved.
//
//	Modified by Jon on 18.03.09.
//	Copyright 2009 Jon Stacey. All rights reserved.

#import <Cocoa/Cocoa.h>


@interface JSIndeterminateProgressIndicatorCell : NSCell 
{	
	NSTimeInterval	animationDelay;
	NSTimer			*animationTimer;
	NSColor			*color;
	
	BOOL			isDisplayedWhenStopped;
	BOOL			isSpinning;
	
	double			doubleValue;
	
	NSControl		*controlElement;
}

- (id)initWithControlElement:(NSControl *)aControlElement;

@property(readwrite, assign) NSColor *color;
@property(readwrite, assign) double	doubleValue;
@property(readwrite, assign) NSTimeInterval animationDelay;
@property(readwrite, assign) BOOL isDisplayedWhenStopped;
@property(readwrite, assign) BOOL isSpinning;

@end
