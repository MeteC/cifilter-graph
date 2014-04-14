//
//  UXFilterInputPointView.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 6/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

#import "UXFilterInputPointView.h"
#import "UXFilterOutputPointView.h"
#import "UXFilterGraphManager.h"
#import "FilterNode.h"
#import "UXFilterConnectionView.h"
#import "UXFilterGraphView.h"
#import "FilterNodeContext.h"


@implementation UXFilterInputPointView


#pragma mark - Setup


#pragma mark - Connection Creation & Destruction


/**
 * Completely destroy the connection associated with this connect point and it's opposite end,
 * removing the underlying FilterNode links as well.
 */
- (void) destroyMyConnectionView
{
	// Kill underlying FilterNode connection and update the graph
	NSLog(@"-->>  destroying");
	[self wipeMyUnderlyingFilterNodeConnection];
	
	// Then kill my connection view graphics completely, remove from view and nilify its 2 retainers
	[self.connectionView removeFromSuperview];
	[self.connectionView.inputPointProvider setConnectionView:nil];
	[self.connectionView.outputPointProvider.connectionViews removeObject:self.connectionView];
}

/**
 * Doesn't touch graphics - just takes a live connection between two connect points, and
 * wipes out the FilterNode layer connection. Do this before clearing the graphics!
 */
- (void) wipeMyUnderlyingFilterNodeConnection
{
	if(self.connectionView.outputPointProvider)
	{
		// Grab the node and the right key by asking the graph view 
		FilterNode* downstreamNode = self.parentGraphView.parentNode;
		
		NSString* downstreamInputKey = [self.parentGraphView findKeyForConnectPoint:self];
		
		// disconnect em
		[downstreamNode.inputValues removeObjectForKey:downstreamInputKey];
		
		// Update filter node context
		[[FilterNodeContext sharedInstance] smartUpdate];
	}
	
	else
	{
		// This isn't an error, just do nothing
		//	UXLog(@"ERROR: Trying to wipe underlying filter node connection for a connection that isn't validly linked up to two connect points! Debug here...");
	}
}

/**
 * Join two connect points together, travel up the graph chain to the underlying node
 * and join them together too, and update the whole shebang.
 */
- (void) joinSelfToOutputPoint:(UXFilterOutputPointView*) outputPoint
{
	
	// Make the graphical connection first
	if(!self.connectionView) 
	{ 
		self.connectionView = [UXFilterConnectionView new];
		[self.superview addSubview:self.connectionView];
	}
	[outputPoint.connectionViews addObject:self.connectionView];
	
	self.connectionView.inputPointProvider = self;
	self.connectionView.outputPointProvider = outputPoint;
	
	// Now dig through into the FilterNode world and make the actual algorithmic connection
	
	// Grab the nodes and the right keys by asking the graph views 
	FilterNode* upstreamNode = outputPoint.parentGraphView.parentNode;
	FilterNode* downstreamNode = self.parentGraphView.parentNode;
	
	NSString* downstreamInputKey = [self.parentGraphView findKeyForConnectPoint:self];
	
	// now make the connect
	NSLog(@"Joining output of %@ to input %@ of %@", upstreamNode, downstreamInputKey, downstreamNode);
	[downstreamNode.inputValues setObject:upstreamNode forKey:downstreamInputKey];
	
	// And finally we need to update the entire graph!
	[[FilterNodeContext sharedInstance] smartUpdate];
}


#pragma mark - Mousey


/*
 Logic for dragging:
 
 - If connect point has no connectionView, create one and have it follow the mouse cursor around
 until mouse up. Then 
 - if you're hovering over another connect point, connect the two (if reasonable*)
 - if you're not hovering over another connect point, release the connection view
 
 - If connect point has a connectionView already, it must be attached to another connect point. 
 Cancel out that point and do as above.
 
 */


- (void)mouseDown:(NSEvent *) e 
{ 	
	if(!self.connectionView)
	{
		// make one and have it follow the mouse
		NSLog(@"Creating new connection view");
		self.connectionView = [UXFilterConnectionView new];
		self.connectionView.inputPointProvider = self;
		[self.superview addSubview:self.connectionView];
	}
	
	self.connectionView.isDragging = YES;
}

- (void) mouseUp:(NSEvent *)theEvent
{
	self.connectionView.isDragging = NO;
	
	// Establish whether we are hovering over another connect point or not...
	UXFilterConnectPointView* hoveringConnectPoint = [[[UXFilterGraphManager sharedInstance] highlightedConnectPoints] anyObject];
	
	// Are we hovering over an Output point belonging to a different graph view?
	BOOL isHoveringValidOutput = 
	(hoveringConnectPoint != nil) && 
	[hoveringConnectPoint isKindOfClass:[UXFilterOutputPointView class]] &&
	(hoveringConnectPoint.parentGraphView != self.parentGraphView);
	
	if(isHoveringValidOutput)
	{
		// connecting self with other - make the connection and get the underlying FilterNodes to connect too
		NSLog(@"Hovering over %@", hoveringConnectPoint);
		[self joinSelfToOutputPoint:(UXFilterOutputPointView*)hoveringConnectPoint];
	}
	else // hovering over something useless -  kill the connection view
	{
		NSLog(@"Killing connection view");
		[self destroyMyConnectionView];
	}
}

- (void)mouseDragged:(NSEvent *)theEvent 
{
	//NSLog(@"Dragging connection view %p", self);
	
	NSPoint mousePoint = [self.superview convertPoint:[theEvent locationInWindow] fromView:nil];
	self.connectionView.currentDragOutputPoint = mousePoint;
	
	// Since we're dragging, the output point may as well lose it's grasp on this connection now
	if([self.connectionView outputPointProvider] != nil)
	{
		// Kill the underlying filternode connection and update the graph
		[self wipeMyUnderlyingFilterNodeConnection];
		
		// do the graphics
		[self.connectionView.outputPointProvider.connectionViews removeObject:self.connectionView];
		self.connectionView.outputPointProvider = nil;
	}
	
	// get the connection to update it's drawing
	[self.connectionView updateConnection];
}




@end
