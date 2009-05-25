//
//  FractalView.m
//  Animated Mandelbrot
//
//  Created by Jon Stacey on 2/7/09.
//  Copyright 2009 Jon Stacey. All rights reserved.
//

#import "FractalView.h"
#import "Mandelbrot.h"
#import "ControlsController.h"
#import "JSIndeterminateProgressIndicatorCell.h"

// Hide controls if main window is minimized
// Fix movie zoom/time issue
// TODO: Release version 1.0
// TODO: Make modified AMIndeterminate code available
// TODO: Notify original authors: 
//		http://www.harmless.de/kommentare.php?x_topic=progressindicator#1 
//		http://kdbdallas.com/2008/12/28/white-indeterminate-progress-indicator-aka-white-nsprogressindicator/

@implementation FractalView

#pragma mark -
#pragma mark Initialization Methods

// -------------------------------------------------------------------------------
// Initialization method
// -------------------------------------------------------------------------------
- (id)initWithFrame:(NSRect)frame // Remember, this is run and then serialized in the nib. Use awakwFromNib for runtime uses.
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		viewStep =  4.0 / frame.size.width;
		
		viewX	 = -2.5;
		viewY	 = frame.size.height * viewStep * 0.5;
		
		frameStale		= YES;				// The frame is stale and needs to be created
	}
    return self;
}

// -------------------------------------------------------------------------------
// Called when the MainMenu.xib is opened
// -------------------------------------------------------------------------------
- (void)awakeFromNib
{
	// Set default values
	[objectController setValue:[NSNumber numberWithInt:512] forKeyPath:@"selection.maxDwell"];
	[objectController setValue:[NSNumber numberWithInt:4]	forKeyPath:@"selection.escapeRadius"];
	[objectController setValue:[NSNumber numberWithInt:24]  forKeyPath:@"selection.frameRate"];
	[objectController setValue:[NSNumber numberWithInt:10]  forKeyPath:@"selection.duration"];
	
	
	// Activate controls window
	controlsWindow = [[ControlsController alloc] initWithFractalView:self objectController:objectController];
	[controlsWindow showWindow:self];
	
	// Disable controls until everything is ready
	[controlsWindow setControlsEnabled:NO];
	
	// Make about window transparent
	[aboutWindow setOpaque:NO];
	[aboutWindow setBackgroundColor:[NSColor colorWithDeviceRed:0.9 green:0.9 blue:0.9 alpha:0.9]];

}

#pragma mark -
#pragma mark Frame/View Methods

// -------------------------------------------------------------------------------
// Method that handles drawing in FractalView
// -------------------------------------------------------------------------------
- (void)drawRect:(NSRect)frame 
{
	if ([self inLiveResize])		// Don't do anything if the window is being resized
		return;

	if (frameStale) 
	{
		[curView drawInRect:frame]; // Redraw old frame for aesthetics
		[self updateFrame];
	} 
	else 
	{
		[curView drawInRect:frame];
		frameStale = YES;
	}
}

// -------------------------------------------------------------------------------
// Called by drawRect:frame when the frame needs to be redrawn
// -------------------------------------------------------------------------------
- (void)updateFrame
{
	[controlsWindow setControlsEnabled:NO]; // Disable controls while the frame is being created
	
	// Update ending coordinates display with current position
	[controlsWindow updateCoordinatesDisplay];
	
	Mandelbrot *fractalFrame = [[Mandelbrot alloc] initWithFrameHeight:[self bounds].size.height 
															frameWidth:[self bounds].size.width 
																 viewX:viewX 
																 viewY:viewY 
															  viewStep:viewStep 
													  objectController:objectController];
	
	// Add observer
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(AMFrameIsReady:)
												 name:@"AMFrameIsReady" 
											   object:fractalFrame];
	
	// Detach thread
	[NSThread detachNewThreadSelector:@selector(createFrame) toTarget:fractalFrame withObject:nil];
}

// -------------------------------------------------------------------------------
// This delegate method is called when there is a left click within the view
// -------------------------------------------------------------------------------
- (void)mouseDown:(NSEvent *)theEvent
{	
	if (![controlsWindow controlsEnabled])
		return;	
	
	NSPoint mouseDownPoint;
	double	newX;
	double	newY;
	
	mouseDownPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	newX	 = viewX + ( viewStep * mouseDownPoint.x );
	newY	 = viewY - ( viewStep * ([self bounds].size.height - mouseDownPoint.y ));
	
	viewX	 = newX - ( viewStep * [self bounds].size.width  * 0.25 );
	viewY	 = newY + ( viewStep * [self bounds].size.height * 0.25 );
	viewStep = viewStep * 0.5 ;
	
	[self setNeedsDisplay:YES];
	
	//debug_NSLog(@"(newX/newY): (%f, %f); (viewX, viewY): (%f, %f)", newX, newY, viewX, viewY);
}

// -------------------------------------------------------------------------------
// This delegate method is called when there is a right click within the view
// -------------------------------------------------------------------------------
- (void)rightMouseDown:(NSEvent *)theEvent
{	
	if (![controlsWindow controlsEnabled])
		return;
	
	NSPoint mouseDownPoint;
	double	newX;
	double	newY;
	
	mouseDownPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	newX	 = viewX + ( viewStep * mouseDownPoint.x );
	newY	 = viewY - ( viewStep * ([self bounds].size.height - mouseDownPoint.y ));
	
	viewX	 = newX - ( viewStep * [self bounds].size.width  * 0.75 );
	viewY	 = newY + ( viewStep * [self bounds].size.height * 0.75 );
	viewStep = viewStep * 1.5 ;
	
	[self setNeedsDisplay:YES];
	
	//debug_NSLog(@"(newX/newY): (%f, %f); (viewX, viewY): (%f, %f)", newX, newY, viewX, viewY);
}

// -------------------------------------------------------------------------------
// Notified (called) when the frame has been calculated and ready to be drawn
//	as a result of our observer.
// -------------------------------------------------------------------------------
- (void)AMFrameIsReady:(NSNotification *)notification
{	
	curView = [[notification userInfo] objectForKey:@"frame"];
	
	frameStale = NO;
	[self setNeedsDisplay:YES];	
	
	[controlsWindow setControlsEnabled:YES];
	
	//Remove our observer
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"AMFrameIsReady" object:nil];
}

#pragma mark -
#pragma mark Window/View Delegate Methods

// -------------------------------------------------------------------------------
// This delegate method is called when the window is done being resized
// -------------------------------------------------------------------------------
- (void)viewDidEndLiveResize
{	
	[self setNeedsDisplay:YES];
}

// -------------------------------------------------------------------------------
// Called when the window is being minimized (miniaturized)
// -------------------------------------------------------------------------------
- (void)windowWillMiniaturize:(NSNotification *)notification
{
	NSLog(@"window minimized");
	[controlsWindow close]; 	// Close controls window
}

// -------------------------------------------------------------------------------
// Called when a minimized window has been expanded (deminiaturized)
// -------------------------------------------------------------------------------
- (void)windowDidDeminiaturize:(NSNotification *)notification
{
	NSLog(@"Window expanded");
	// Open controls window
	[controlsWindow showWindow:self];
}

// -------------------------------------------------------------------------------
// Called when fractal window is being closed allowing use to exit the program
// -------------------------------------------------------------------------------
- (void)windowWillClose:(NSNotification *)notification
{
	[NSApp terminate:self];
}

// -------------------------------------------------------------------------------
// View accepts the first mouse click, even if the window is not front and key
// -------------------------------------------------------------------------------
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

#pragma mark -
#pragma mark Other Methods

// -------------------------------------------------------------------------------
// Resets the fractal view and starting coordinates
// -------------------------------------------------------------------------------
- (void)resetFractalView:(id)sender
{
	// Reset settings
	viewStep = 4.0 / [self bounds].size.width;
	
	viewX	 = -2.5;
	viewY	 = [self bounds].size.height * viewStep * 0.5;
	
	[controlsWindow setMovieStartingCoords:sender];
	
	// Redraw the screen
	[self setNeedsDisplay:YES];
}

// -------------------------------------------------------------------------------
// Saves the current frame (fractal) as a PNG image
// -------------------------------------------------------------------------------
- (void)saveFrameAsImage:(id)sender
{
	debug_NSLog(@"saveFrameAsImage:");
	
	NSSavePanel		*savePanel;
	NSString		*filename;
	int				result;
	
	// Configure save panel
	savePanel = [NSSavePanel savePanel];
	[savePanel setRequiredFileType:@"png"];
	
	result = [savePanel runModal];
	if (result == NSFileHandlingPanelOKButton) 
	{
		filename = [savePanel filename];
		
		// Write image to disk
		[[curView representationUsingType:NSPNGFileType properties:nil] writeToFile:filename atomically:YES];
	}
}

#pragma mark -
#pragma mark IBAction Methods

// -------------------------------------------------------------------------------
// Shows the controls window (panel)
// -------------------------------------------------------------------------------
- (IBAction)showControlsWindow:(id)sender
{
	[controlsWindow showWindow:sender];
}

// -------------------------------------------------------------------------------
// Shows the About window
// -------------------------------------------------------------------------------
- (IBAction)showAboutWindow:(id)sender
{
	[aboutWindow makeKeyAndOrderFront:self];
}

// -------------------------------------------------------------------------------
// Closes the About Window
// -------------------------------------------------------------------------------
- (IBAction)closeAboutWindow:(id)sender
{
	[aboutWindow close];
}

// -------------------------------------------------------------------------------
// Opens the development blog URL in the default browser
// -------------------------------------------------------------------------------
- (IBAction)showDevBlog:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://jonsview.com"]];
}

// -------------------------------------------------------------------------------
// Opens the wikipediate Fractals URL in the default browser
// -------------------------------------------------------------------------------
- (IBAction)showWikiPage:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://en.wikipedia.org/wiki/Fractal"]];
}

#pragma mark -
#pragma mark Synthesized Methods

@synthesize viewX;
@synthesize viewY;
@synthesize viewStep;

@end
