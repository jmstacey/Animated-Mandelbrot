//
//  Mandelbrot.h
//  Animated Mandelbrot
//
//  Created by Jon Stacey on 2/7/09.
//  Copyright 2009 Jon Stacey. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Mandelbrot : NSObject {
	int		frameHeight;
	int		frameWidth;
	int		maxDwell;
	int		escapeRadius;
	int		doneThreadCount;
	int		activeProcessors;
	
	double	viewX;
	double	viewY;
	double	viewStep;
	
	NSBitmapImageRep *curView;
	NSLock			 *workLock;
	
	unsigned char	 *bitmapData;
	
}

- (id) initWithFrameHeight:(int)aFrameHeight
				frameWidth:(int)aFrameWidth
					 viewX:(double)aViewX
					 viewY:(double)aViewY
				  viewStep:(double)aViewStep
		  objectController:(id)aObjectController;

- (void) threadMain:(NSArray *)workController;

- (NSBitmapImageRep *)createFrame;

- (int) dwellsForX:(double)x
			  forY:(double)y;

@property(readonly) NSBitmapImageRep *curView;

@end
