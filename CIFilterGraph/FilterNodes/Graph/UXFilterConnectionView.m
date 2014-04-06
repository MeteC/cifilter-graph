//
//  FilterConnectionView.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 28/03/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

#import "UXFilterConnectionView.h"
#import "UXFilterInputPointView.h"
#import "UXFilterOutputPointView.h"


// Set to 1 to see class object count on init/dealloc. Use this to test for leaks..
#define MEMORY_TEST_CONNECTIONS 1


@interface UXFilterConnectionView ()
{
	NSPoint beginPoint, endPoint;
}
@end

@implementation UXFilterConnectionView

#if MEMORY_TEST_CONNECTIONS

static int debugCounter = 0;

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"%d: ConnectionView ALLOCED", ++debugCounter);
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%d: ConnectionView DEALLOCED", --debugCounter);
}

#endif

/**
 * Absolutely VITAL to ensure my drags on the connectPointViews below are all good.
 */
- (NSView*) hitTest:(NSPoint)aPoint
{
	return nil;
}



- (void) updateConnection
{
	// Set the frame to encompass both begin and end points
	beginPoint	= [self.inputPointProvider endPoint];
	endPoint	= self.isDragging ? self.currentDragOutputPoint : [self.outputPointProvider endPoint];
	
//	NSLog(@"%p: begin %f,%f .. end %@: %f,%f", self, beginPoint.x, beginPoint.y, self.outputPointProvider, endPoint.x, endPoint.y);
	
	const int margin = 5;
	
	int beginX	= MIN(beginPoint.x, endPoint.x);
	int endX	= MAX(beginPoint.x, endPoint.x);
	int beginY	= MIN(beginPoint.y, endPoint.y);
	int endY	= MAX(beginPoint.y, endPoint.y);
	
	NSRect encompassingRect = NSMakeRect(beginX-margin, beginY-margin, endX - beginX + margin*2, endY - beginY + margin*2);
	self.frame = encompassingRect;
	
	// ensure beginPoint and endPoint are relative to my frame now
	beginPoint.x -= self.frame.origin.x;
	beginPoint.y -= self.frame.origin.y;
	endPoint.x	 -= self.frame.origin.x;
	endPoint.y -=	self.frame.origin.y;
	
//	NSLog(@"updating connection view.");
//	NSLog(@"new frame: %f,%f  %fx%f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
	
	[self setNeedsDisplay:YES];
}

- (void) drawRect:(NSRect)dirtyRect
{
	//NSLog(@"redrawing connection view!");
	
	// Testing
	/*
	NSColor* bob = [[NSColor magentaColor] colorWithAlphaComponent:0.5];
	[bob set];
	[NSBezierPath fillRect:self.bounds];
	 */
	
	NSBezierPath* linePath = [NSBezierPath bezierPath];
	[linePath moveToPoint:beginPoint];
	[linePath lineToPoint:endPoint];
	
	[linePath stroke];
}

@end
