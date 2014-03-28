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


@interface FilterGraphView : NSView
{
	CGSize defaultSize;				// each graph view will have it's own default sizing
	CGSize defaultConnectionSize;	// and default connection tag sizing
}
@property (nonatomic, weak) id<FilterGraphViewDelegate> delegate;

/** 
 * The node that owns this graph view. When you set this, be sure to set it going the other way too.
 * (Automatic syncing more potentially buggy than it's worth.)
 */
@property (nonatomic, weak) FilterNode* parentNode;


/**
 * Sets up a default filter graph view with variable number of input and output connections
 */
- (id) initWithInputCount:(uint) inputCount outputCount:(uint) outputCount;




/**
 * Provide a frame for my output connector box. At the moment only supporting the one output.
 * This frame is relative to the graph view coord system.
 */
- (NSRect) outputConnectionFrame;

/**
 * Create the frame for the connection box for a given input index. Better not overflow mInputCount!
 * This frame is relative to the graph view coord system.
 */
- (NSRect) inputConnectionFrame:(int) index;


@end


