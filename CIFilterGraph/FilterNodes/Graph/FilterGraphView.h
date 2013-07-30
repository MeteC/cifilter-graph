//
//  FilterGraphView.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 5/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

//	Extending NSView to have a pointer back to it's FilterNode parent
//	Using FilterGraphView by itself will provide a default (crappy) graph view, good enough for development at least.

#import <Cocoa/Cocoa.h>
#import "FilterNode.h"
#import "FilterGraphViewDelegate.h"

@interface FilterGraphView : NSView
{
	CGSize defaultSize; // each graph view will have it's own default sizing
}
@property (nonatomic, assign) id<FilterGraphViewDelegate> delegate;

/** 
 * The node that owns this graph view. When you set this, be sure to set it going the other way too.
 * (Automatic syncing more potentially buggy than it's worth.)
 */
@property (nonatomic, assign) FilterNode* parentNode;

/**
 * Sets up a default filter graph view with variable number of input and output connections
 */
- (id) initWithInputCount:(uint) inputCount outputCount:(uint) outputCount;

@end
