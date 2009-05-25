//
//  ControlsController.m
//  Animated Mandelbrot
//
//  Created by Jon Stacey on 3/18/09.
//  Copyright 2009 Jon Stacey. All rights reserved.
//

#import "ControlsController.h"
#import "FractalView.h"
#import "FractalMovie.h"
#import "JSIndeterminateProgressIndicatorCell.h"


@implementation ControlsController

#pragma mark -
#pragma mark Initialization Methods

// -------------------------------------------------------------------------------
// Default initialization method that will throw an exception if used.
//	Use the other init method.
// -------------------------------------------------------------------------------
- (id)init
{
	@throw [NSException exceptionWithName:@"ControlsControllerBadCall" reason:@"Initialize using an alternative init method." userInfo:nil];
	return nil;
}

// -------------------------------------------------------------------------------
// Initialization method
// -------------------------------------------------------------------------------
- (id)initWithFractalView:(id)aFractalView
		 objectController:(id)anObjectController
{
	if (![super initWithWindowNibName:@"Controls"])
		return nil;
	
	fractalView		 = aFractalView;
	objectController = anObjectController;
	
	return self;
}

// -------------------------------------------------------------------------------
// Called when the Controls window is loaded.
// -------------------------------------------------------------------------------
- (void)windowDidLoad
{
	[self setMovieStartingCoords:self];
	
	// Configure custom progress indicator
	progressIndicatorCell = [[JSIndeterminateProgressIndicatorCell alloc] initWithControlElement:progressIndicatorControl];
	
	[progressIndicatorCell		setColor:[NSColor colorWithDeviceRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
	[progressIndicatorCell		setIsDisplayedWhenStopped:NO];
	[progressIndicatorControl	setCell:progressIndicatorCell];
}

#pragma mark -
#pragma mark IBAction Methods

// -------------------------------------------------------------------------------
// Notifies the display that it needs to be redrawn
// -------------------------------------------------------------------------------
- (IBAction)redrawFractalView:(id)sender
{
	[fractalView setNeedsDisplay:YES];
}

// -------------------------------------------------------------------------------
// Sets the starting coordinates of the display
// -------------------------------------------------------------------------------
- (IBAction)setMovieStartingCoords:(id)sender
{
	movStartX		= [fractalView viewX];
	movStartY		= [fractalView viewY];
	movStartStep	= [fractalView viewStep];
	
	// Update starting coordinates display
	[self updateCoordinatesDisplay];
}

// -------------------------------------------------------------------------------
// Creates a movie from the starting coordinates to the end coordinates
// -------------------------------------------------------------------------------
- (IBAction)createMovie:(id)sender
{	
	FractalMovie	*fractalMovie;
	NSSavePanel		*savePanel;
	NSString		*filename;
	int				result;
	
	// Configure save panel
	savePanel = [NSSavePanel savePanel];
	[savePanel setTitle:@"Save Movie To:"];
	
	// Run the save panel
	result = [savePanel runModal]; 	
	if (result == NSFileHandlingPanelCancelButton)
		return; // Guess they decided not to save the movie after all
	
	filename = [savePanel filename];
	
	// QTMovie must be initilized on the main thread.
	QTMovie *movie	= [[QTMovie alloc] initToWritableFile:filename error:NULL];
	
	fractalMovie = [FractalMovie alloc];
	[fractalMovie initWithQTMovie:movie 
						movieName:filename
					  movieHeight:[fractalView frame].size.height
					   movieWidth:[fractalView frame].size.width 
					  movieStartX:movStartX 
					  movieStartY:movStartY 
				   movieStartStep:movStartStep 
						movieEndX:[fractalView viewX]
						movieEndY:[fractalView viewY]
					 movieEndStep:[fractalView viewStep]
				 objectController:objectController];
	
	[NSThread detachNewThreadSelector:@selector(createMovieBGThread) toTarget:fractalMovie withObject:nil];
}

// -------------------------------------------------------------------------------
// Resets the fractal view and starting coordinates
// -------------------------------------------------------------------------------
- (IBAction)resetFractalView:(id)sender
{
	[fractalView resetFractalView:sender];
}

// -------------------------------------------------------------------------------
// Saves the current frame (fractal) as a PNG image
// -------------------------------------------------------------------------------
- (IBAction)saveFractalViewAsImage:(id)sender
{
	[fractalView saveFractalViewAsImage:sender];
}

#pragma mark -
#pragma mark Other Methods

// -------------------------------------------------------------------------------
// Updates the starting and ending coordinates display
// -------------------------------------------------------------------------------
- (void)updateCoordinatesDisplay
{
	[startCoordsTextField	setStringValue:[NSString stringWithFormat:@"(%G, %G)", movStartX, movStartY]];
	[endCoordsTextField		setStringValue:[NSString stringWithFormat:@"(%G, %G)", [fractalView viewX], [fractalView viewY]]];
}

// -------------------------------------------------------------------------------
// Enables or disables controls. Also activates or deactives indeterminate
//	progress indicator.
// -------------------------------------------------------------------------------
@synthesize controlsEnabled;
- (void)setControlsEnabled:(BOOL)enabled
{	
	if (enabled)
		[progressIndicatorCell setIsSpinning:NO];
	else
		[progressIndicatorCell setIsSpinning:YES];
	
	[redrawButton		setEnabled:enabled];
	[setCurCoordsButton setEnabled:enabled];
	[resetButton		setEnabled:enabled];
	[createMovieButton	setEnabled:enabled];
	
	controlsEnabled = enabled;
}

//@synthesize objectController;

@end
