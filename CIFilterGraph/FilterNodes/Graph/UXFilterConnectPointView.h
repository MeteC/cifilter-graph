//
//  FilterConnectPointView.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 28/03/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

//	A connection box, subview of a FilterGraphView


#import <Cocoa/Cocoa.h>

@class UXFilterGraphView;


@interface UXFilterConnectPointView : NSView
{
	NSColor *normalColour, *highlitColour;
}

// Are we highlighted now (i.e. mouse is registered as being over us?)
@property (readonly) BOOL highlighted;

// weak pointer back to my graph, makes life easy
@property (weak) UXFilterGraphView* parentGraphView;

/**
 * Provide an end point location. e.g. center of the box.
 */
- (NSPoint) endPoint;

@end
