//
//  ProgressController.h
//  Animated Mandelbrot
//
//  Created by Jon Stacey on 2/13/09.
//  Copyright 2009 Jon Stacey. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ProgressController : NSWindowController {
	NSString *statusMessage;
	NSString *frameDetails;
	
	double	curProgress;
	
	BOOL	abort;
}

- (IBAction)abortMovie:(id)sender;

@property(readwrite, assign) NSString	*statusMessage;
@property(readwrite, assign) NSString	*frameDetails;
@property(readwrite, assign) double		curProgress;
@property(readwrite, assign) BOOL		abort;

@end
