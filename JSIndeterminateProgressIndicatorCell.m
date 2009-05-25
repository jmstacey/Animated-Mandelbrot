//
//  JSIndeterminateProgressIndicatorCell.m
//  A more flexible indeterminate progress indicator
//
//  Created by Andreas on 23.01.07.
//  Copyright 2007 Andreas Mayer. All rights reserved.
//
//	Modified by Jon on 18.03.09.
//	Copyright 2009 Jon Stacey. All rights reserved.
//

//	2007-03-10	Andreas Mayer
//	- removed -keyEquivalent and -keyEquivalentModifierMask methods
//		(I thought those were required by NSTableView/Column. They are not.
//		Instead I was using NSButtons as a container for the cells in the demo project.
//		Replacing those with plain NSControls did fix the problem.)
//	2007-03-24	Andreas Mayer
//	- will now spin in the same direction in flipped and not flipped views
//	2008-09-03	Andreas Mayer
//	- restore default settings for NSBezierPath after drawing
//	- instead of the saturation, we now modify the lines' opacity; does look better on colored
//		backgrounds
//  2009-03-17  Jon Stacey
//  - Added built-in animation timer based on Dallas Brown's modifications
//		http://kdbdallas.com/2008/12/28/white-indeterminate-progress-indicator-aka-white-nsprogressindicator/
//  - Added initWithControlElement and old init method throws an exception
//  - Code restructuring, cleanup, and documentation
//		NOTE: The garbage collector is now needed

#import "JSIndeterminateProgressIndicatorCell.h"

#define ConvertAngle(a) (fmod((90.0-(a)), 360.0))

#define DEG2RAD  0.017453292519943295

@implementation JSIndeterminateProgressIndicatorCell

#pragma mark -
#pragma mark Initialization Methods

// -------------------------------------------------------------------------------
// Default initialization method that will throw an exception if used.
//	Use the other init method.
// -------------------------------------------------------------------------------
- (id)init
{
	@throw [NSException exceptionWithName:@"JSIndeterminateProgressIndicatorCellBadCall" reason:@"Use an alternative init method." userInfo:nil];
	
	return nil;
}

// -------------------------------------------------------------------------------
// Initialization method
// -------------------------------------------------------------------------------
- (id)initWithControlElement:(NSControl *)aControlElement
{
	if (self = [super initImageCell:nil])
	{
		animationDelay	= 5.0/60.0;
		doubleValue		= 0.0;
		color			= [NSColor blackColor];
		
		isDisplayedWhenStopped	= YES;		
		controlElement			= aControlElement;
	}
	return self;
}


#pragma mark -
#pragma mark Frame Methods

// -------------------------------------------------------------------------------
// Called by timer to update the progress indicator.
// -------------------------------------------------------------------------------
- (void)animate:(NSTimer *)aTimer
{
	doubleValue = fmod(([self doubleValue] + (5.0/60.0)), 1.0);
	
	if (controlElement == nil)
		@throw [NSException exceptionWithName:@"JSIndeterminateProgressIndicatorCellBadCall" reason:@"Missing control element" userInfo:nil];
	else
		[controlElement setNeedsDisplay:YES];
}

// -------------------------------------------------------------------------------
// Draw the frame in the view without a border.
// -------------------------------------------------------------------------------
- (void)drawWithFrame:(NSRect)cellFrame 
			   inView:(NSView *)controlView
{
	// cell has no border
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

// -------------------------------------------------------------------------------
// Draws the interior of the frame (the actual progress indicator).
// -------------------------------------------------------------------------------
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	if ([self isSpinning] || [self isDisplayedWhenStopped]) 
	{
		float angle;
		float outerRadius;
		float innerRadius;
		float flipFactor		= ([controlView isFlipped] ? 1.0 : -1.0);
		float cellSize			= MIN(cellFrame.size.width, cellFrame.size.height);
		float strokeWidth		= cellSize * 0.08;
		float previousLineWidth = [NSBezierPath defaultLineWidth]; 
		
		int	step = round([self doubleValue] / (5.0 / 60.0));

		NSPoint inner;
		NSPoint outer;
		NSPoint center = cellFrame.origin;
		
		NSLineCapStyle previousLineCapStyle = [NSBezierPath defaultLineCapStyle];
		
		center.x += cellSize / 2.0;
		center.y += cellFrame.size.height / 2.0;

		if (cellSize >= 32.0) 
		{
			outerRadius = cellSize * 0.38;
			innerRadius = cellSize * 0.23;
		} 
		else
		{
			outerRadius = cellSize * 0.48;
			innerRadius = cellSize * 0.27;
		}

		[NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
		[NSBezierPath setDefaultLineWidth:strokeWidth];
		
		if ([self isSpinning]) 
			angle = (270 + (step * 30)) * DEG2RAD;
		else
			angle = 270 * DEG2RAD;

		angle = flipFactor * angle;

		for (int i = 0; i < 12; i++) 
		{
			[[color colorWithAlphaComponent:1.0-sqrt(i) * 0.25] set];
			outer = NSMakePoint(center.x + cos(angle) * outerRadius, center.y + sin(angle) * outerRadius);
			inner = NSMakePoint(center.x + cos(angle) * innerRadius, center.y + sin(angle) * innerRadius);
			[NSBezierPath strokeLineFromPoint:inner toPoint:outer];
			angle -= flipFactor * 30 * DEG2RAD;
		}
		
		// restore previous defaults
		[NSBezierPath setDefaultLineCapStyle:previousLineCapStyle];
		[NSBezierPath setDefaultLineWidth:previousLineWidth];
	}
}

#pragma mark -
#pragma mark Synthesized Methods

@synthesize color;
@synthesize doubleValue;
@synthesize animationDelay;
@synthesize isDisplayedWhenStopped;

@synthesize isSpinning;
- (void)setIsSpinning:(BOOL)newValue
{
	if (isSpinning != newValue) 
	{
		isSpinning = newValue;
		
		if (newValue)
		{
			if (animationTimer == nil)
				animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationDelay target:self selector:@selector(animate:) userInfo:NULL repeats:YES];
			else
				[animationTimer fire];
		}
		else
		{
			[animationTimer invalidate];			// Stop the timer
			animationTimer = nil;					// Done with the animationTimer
			[controlElement setNeedsDisplay:YES];	// Refresh the display
		}
	}
}

@end
