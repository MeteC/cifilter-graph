//
//  FilterConnectionView.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 28/03/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

/**

 A graphical link between FilterGraphViews. Dynamically rearranges it's frame and drawn content
	as graph views move about.

 Note: connections are always made with the mouse from an input point to an output point, because
	inputs only have one connection, but outputs can have multiple. This means the connection always
	has a UXFilterInputPointView as its first point provider, and its second is either a 
	UX..OutputPointView or an overriding NSEvent (mouse event) which provides the end point during
	dragging.

 **/

#import <Cocoa/Cocoa.h>


@class UXFilterInputPointView;
@class UXFilterOutputPointView;


/**
 * The Connection View
 */
@interface UXFilterConnectionView : NSView


// Graph views connected. weak pointers to input and output providers
@property (weak) UXFilterOutputPointView*	outputPointProvider;
@property (weak) UXFilterInputPointView*	inputPointProvider;

// used to override outputPointProvider during dragging
@property NSPoint	currentDragOutputPoint;
@property BOOL		isDragging;

/**
 * When a related filter graph redraws itself, this is called to ensure the connection is updated too.
 */
- (void) updateConnection;

@end
