//
//  ProgressController.m
//  Animated Mandelbrot
//
//  Created by Jon Stacey on 2/13/09.
//  Copyright 2009 Jon Stacey. All rights reserved.
//

#import "ProgressController.h"


@implementation ProgressController

#pragma mark -
#pragma mark Initialization Methods

// -------------------------------------------------------------------------------
// Initialization method
// -------------------------------------------------------------------------------
- (id)init
{
	if (![super initWithWindowNibName:@"Progress"])
		return nil;
	
	// Set defaults
	[self setCurProgress:0.0];
	[self setStatusMessage:@""];
	[self setFrameDetails:@""];
	
	abort = FALSE;
	
	return self;
}

#pragma mark -
#pragma mark IBAction Methods

// -------------------------------------------------------------------------------
// Abort movie creation
// -------------------------------------------------------------------------------
- (IBAction)abortMovie:(id)sender
{
	abort = TRUE;
}

#pragma mark -
#pragma mark Synthesized Methods

@synthesize statusMessage;
@synthesize frameDetails;
@synthesize curProgress;
@synthesize abort;

@end
