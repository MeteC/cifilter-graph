//
//  FilterConnectionView.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 28/03/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

#import "FilterConnectionView.h"
#import "FilterConnectPointView.h"

@implementation FilterConnectionView


// Note - far from done, all I'm doing now is highlighting the rect that this connection will take..
// can't see it until the rest of the prep is done.

- (void) updateConnection
{
	// Set the frame to encompass both begin and end points
	NSPoint beginPoint	= [self.inputGraphConnect connectEndPoint];
	NSPoint endPoint	= [self.outputGraphConnect connectEndPoint];
	
	// AAAAAAGH. Might be better to have connect points responsible for giving a superview friendly location
	
	int beginX	= MIN(beginPoint.x, endPoint.x);
	int endX	= MAX(beginPoint.x, endPoint.x);
	int beginY	= MIN(beginPoint.y, endPoint.y);
	int endY	= MAX(beginPoint.y, endPoint.y);
	
	NSRect encompassingRect = NSMakeRect(beginX, beginY, endX - beginX, endY - beginY);
	self.frame = encompassingRect;
	
	NSLog(@"updating connection view.");
	NSLog(@"new frame: %f,%f  %fx%f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void) drawRect:(NSRect)dirtyRect
{
	NSLog(@"redrawing connection view!");
	[[NSColor magentaColor] set];
	[NSBezierPath fillRect:self.bounds];
}

@end
