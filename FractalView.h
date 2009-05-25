//
//  FractalView.h
//  Animated Mandelbrot
//
//  Created by Jon Stacey on 2/7/09.
//  Copyright 2009 Jon Stacey. All rights reserved.
//


#import <Cocoa/Cocoa.h>
@class Mandelbrot;
@class FractalMovie;
@class ControlsController;


@interface FractalView : NSView {	
	BOOL   frameStale;
	BOOL   controlsEnabled;
	
	double viewX;
	double viewY;
	double viewStep;
	double movStartX;
	double movStartY;
	double movStartStep;
	
	NSBitmapImageRep		*curView;
	
	IBOutlet NSWindow		*aboutWindow;
	IBOutlet NSButton		*closeButtonOnAboutWindow;
	
	ControlsController		*controlsWindow;
	
	IBOutlet id objectController;
}

- (void)updateFrame;
- (void)resetFractalView:(id)sender;
- (void)saveFrameAsImage:(id)sender;

- (IBAction)showControlsWindow:(id)sender;

- (IBAction)showAboutWindow:(id)sender;
- (IBAction)closeAboutWindow:(id)sender;

- (IBAction)showGithubRepository:(id)sender;
- (IBAction)showDevBlog:(id)sender;
- (IBAction)showWikiPage:(id)sender;


@property(readonly) double viewX;
@property(readonly) double viewY;
@property(readonly) double viewStep;

@end
