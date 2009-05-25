//
//  ControlsController.h
//  Animated Mandelbrot
//
//  Created by Jon Stacey on 3/18/09.
//  Copyright 2009 Jon Stacey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import <QuickTime/QuickTime.h>
@class FractalMovie;
@class JSIndeterminateProgressIndicatorCell;

@interface ControlsController : NSWindowController 
{
	BOOL	controlsEnabled;
	
	double	movStartX;
	double	movStartY;
	double	movStartStep;
	
	IBOutlet NSTextField	*startCoordsTextField;
	IBOutlet NSTextField	*endCoordsTextField;
	IBOutlet NSButton		*setCurCoordsButton;
	IBOutlet NSButton		*redrawButton;
	IBOutlet NSButton		*resetButton;
	IBOutlet NSButton		*createMovieButton;
	IBOutlet NSControl		*progressIndicatorControl;
	
	JSIndeterminateProgressIndicatorCell *progressIndicatorCell;

	id fractalView;
	id objectController;
}

- (id)initWithFractalView:(id)aFractalView
		 objectController:(id)anObjectController;

- (void)updateCoordinatesDisplay;

- (IBAction)redrawFractalView:(id)sender;
- (IBAction)setMovieStartingCoords:(id)sender;
- (IBAction)createMovie:(id)sender;
- (IBAction)resetFractalView:(id)sender;
- (IBAction)saveFractalViewAsImage:(id)sender;

@property(readwrite, assign) BOOL controlsEnabled;
//@property(readwrite, assign) id objectController;

@end
