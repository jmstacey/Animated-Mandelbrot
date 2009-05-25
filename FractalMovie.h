//
//  Movie.h
//  Animated Mandelbrot
//
//  Created by Jon Stacey on 2/13/09.
//  Copyright 2009 Jon Stacey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import <QuickTime/QuickTime.h>
@class Mandelbrot;
@class QTMovieExtensions;
@class ProgressController;


@interface FractalMovie : NSObject {	
	QTMovie		*movie;
	NSString	*movieName;
	
	int		frameHeight;
	int		frameWidth;
	int		frameRate;
	int		duration;
	
	double	startX;
	double	startY;
	double	endX;
	double	endY;
	double	startStep;
	double	endStep;
	
	id		objectController;
	
	ProgressController *progressWindow;
}

- (id)initWithQTMovie:(QTMovie *)aMovie
			movieName:(NSString *)aMovieName
		  movieHeight:(int)aFrameHeight
		   movieWidth:(int)aFrameWidth
		  movieStartX:(double)aStartX
		  movieStartY:(double)aStartY
	   movieStartStep:(double)aStartStep
			movieEndX:(double)aEndX
			movieEndY:(double)aEndY
		 movieEndStep:(double)aEndStep
	 objectController:(id)aObject;

- (void)createMovieBGThread;

@end
