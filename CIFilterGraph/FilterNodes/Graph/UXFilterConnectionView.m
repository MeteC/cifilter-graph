//
//  FilterConnectionView.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 28/03/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

#import "UXFilterConnectionView.h"
#import "UXFilterConnectPointView.h"

@interface UXFilterConnectionView ()
{
	NSPoint beginPoint, endPoint;
}
@end

@implementation UXFilterConnectionView


- (void) updateConnection
{
	// Set the frame to encompass both begin and end points
	beginPoint	= NSMakePoint(NSMidX(self.inputConnectPoint.frame), NSMidY(self.inputConnectPoint.frame));
	endPoint	= NSMakePoint(NSMidX(self.outputConnectPoint.frame), NSMidY(self.outputConnectPoint.frame));
	
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
//	NSLog(@"redrawing connection view!");
	
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
