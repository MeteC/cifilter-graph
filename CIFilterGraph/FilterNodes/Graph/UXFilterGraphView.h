//
//  FilterGraphView.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 5/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

//	Extending NSView to have a pointer back to it's FilterNode parent
//	Using FilterGraphView by itself will provide a default (crappy) graph view, good enough for development at least.

//	!!!: Connections: Each node resposible to draw only its input connections...

#import <Cocoa/Cocoa.h>
#import "FilterNode.h"
#import "FilterGraphViewDelegate.h"


@class FilterGraphViewConnection;


@interface UXFilterGraphView : NSView
{
	CGSize defaultSize;				// each graph view will have it's own default sizing
	CGSize defaultConnectionSize;	// and default connection tag sizing
}
@property (nonatomic, weak) id<UXFilterGraphViewDelegate> delegate;

/** 
 * The node that owns this graph view. When you set this, be sure to set it going the other way too.
 * (Automatic syncing more potentially buggy than it's worth.)
 */
@property (nonatomic, weak) FilterNode* parentNode;


/**
 * (Re)set up connect points. call this after the node has been configured with its actual connections.
 * Since we want graph connect points and connection views to be on the same view layer as the GraphView
 * to avoid clipping (or the need to remove clipping), pass it in here please.
 *
 * Note - I'm re-creating all connect points and connections here. 
 * TODO: Need to test this extensively to make sure old connections are released each time.
 */
- (void) resetGraphConnectsOnSuperview:(NSView*) superview;


/**
 * Dictionary of output connect points, keyed the same as the parent node's outputValues (FilterNodes only)
 */
- (NSDictionary*) outputConnectPoints;

/**
 * Dictionary of input connect points, keyed the same as the parent node's inputValues (FilterNodes only)
 */
- (NSDictionary*) inputConnectPoints;


/**
 * Provide a frame for my output connector box. At the moment only supporting the one output.
 * This frame is relative to the superview coord system.
 */
- (NSRect) outputConnectionFrame;

/**
 * Create the frame for the connection box for a given input index. Better not overflow mInputCount!
 * This frame is relative to the superview coord system.
 */
- (NSRect) inputConnectionFrame:(int) index;


@end


