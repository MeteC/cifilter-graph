//
//  FilterConnectPointView.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 28/03/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

#import "UXFilterConnectPointView.h"
#import "NSPointProvider.h"
#import "UXFilterGraphManager.h"
#import "UXFilterGraphView.h"
#import "FilterNodeContext.h"


@interface UXFilterConnectPointView ()
{
	// for mouse tracking
	NSTrackingArea* trackingArea;
}

@property (readwrite) BOOL highlighted;
@property NSColor* backgroundColour;

@end

@implementation UXFilterConnectPointView



- (id) initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
    if (self) {
		
		[self createTrackingArea];
		self.backgroundColour = [NSColor grayColor];
    }
    
    return self;
}


/**
 * Make a tracking area for mouseovers
 */
- (void) createTrackingArea
{
    int opts = (NSTrackingMouseEnteredAndExited | /*NSTrackingMouseMoved |*/ NSTrackingEnabledDuringMouseDrag | NSTrackingActiveAlways);
	
    trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
												 options:opts
												   owner:self
												userInfo:nil];
    [self addTrackingArea:trackingArea];
	
    NSPoint mouseLocation = [[self window] mouseLocationOutsideOfEventStream];
    mouseLocation = [self convertPoint: mouseLocation
                              fromView: nil];
	
    if (NSPointInRect(mouseLocation, [self bounds]))
	{
		[self mouseEntered: nil];
	}
	else
	{
		[self mouseExited: nil];
	}
}


// called when scrolling etc
- (void) updateTrackingAreas
{
	// Happens a lot when dragging...
	
    [self removeTrackingArea:trackingArea];
    [self createTrackingArea];
	
    [super updateTrackingAreas]; // Needed, according to the NSView documentation
}


#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
	[[self backgroundColour] set];
	
	// Every time we draw?
	NSRect mainFillRect = self.bounds;
    [NSBezierPath fillRect:mainFillRect];
}

- (void) highlightMe:(BOOL) highlight
{
	self.highlighted = highlight;
	
	if(highlight)
		self.backgroundColour = [NSColor blackColor];
	else
		self.backgroundColour = [NSColor grayColor];
	
	// Register the highlighting with the graph manager
	[[UXFilterGraphManager sharedInstance] registerConnectPoint:self asHighlighted:highlight];
	
	[self setNeedsDisplay:YES];
}

#pragma mark - Delegate

/**
 * Return my contact point for a connection view
 */
- (NSPoint) endPoint
{
	return NSMakePoint(NSMidX(self.frame), NSMidY(self.frame));
}

#pragma mark - Connection Creation & Destruction


/**
 * Completely destroy the connection associated with this connect point and it's opposite end,
 * removing the underlying FilterNode links as well.
 */
- (void) destroyMyConnectionView
{
	// Kill underlying FilterNode connection and update the graph
	NSLog(@"-->>  destroying");
	[self wipeUnderlyingFilterNodeConnectionForConnection:self.connectionView];
	
	// Then kill my connection view graphics completely
	[self.connectionView removeFromSuperview];
	[self.connectionView.inputPointProvider setConnectionView:nil];
	[self.connectionView.outputPointProvider setConnectionView:nil];
}

/**
 * Doesn't touch graphics - just takes a live connection between two connect points, and
 * wipes out the FilterNode layer connection. Do this before clearing the graphics!
 */
- (void) wipeUnderlyingFilterNodeConnectionForConnection:(UXFilterConnectionView*) aConnection
{
	if([aConnection.inputPointProvider isKindOfClass:[UXFilterConnectPointView class]] &&
	   [aConnection.outputPointProvider isKindOfClass:[UXFilterConnectPointView class]])
	{
		// we're good to go
		UXFilterConnectPointView* first = (UXFilterConnectPointView*)aConnection.inputPointProvider;
		UXFilterConnectPointView* second = (UXFilterConnectPointView*)aConnection.outputPointProvider;
		
		// figure out which is the input..
		UXFilterConnectPointView* inputConnectPoint = (first.type == UXFilterConnectPointTypeInput) ? first : second;
		
		// Grab the node and the right key by asking the graph view 
		FilterNode* downstreamNode = inputConnectPoint.parentGraphView.parentNode;
		
		NSString* downstreamInputKey = [inputConnectPoint.parentGraphView findKeyForConnectPoint:inputConnectPoint];
		
		// disconnect em
		[downstreamNode.inputValues removeObjectForKey:downstreamInputKey];
		
		// TODO: Update filter node context
		[[FilterNodeContext sharedInstance] smartUpdate];
	}
	
	else
	{
		// This isn't an error, just do nothing
	//	[AppDelegate log:@"ERROR: Trying to wipe underlying filter node connection for a connection that isn't validly linked up to two connect points! Debug here..."];
	}
}

/**
 * Join two connect points together, travel up the graph chain to the underlying node
 * and join them together too, and update the whole shebang.
 */
- (void) joinSelfToConnectPoint:(UXFilterConnectPointView*) otherPoint
{
	// error test for developer.. We want no unknown types and no same types!
	NSAssert2(self.type != UXFilterConnectPointTypeUnknown || 
			  otherPoint.type != UXFilterConnectPointTypeUnknown, 
			  
			  @"One of the two points you're trying to connect is of unknown type! We have %d and %d", self.type, otherPoint.type);
	
	if(self.type == otherPoint.type)
	{
		// TODO: properly
		NSString* msg = @"ERROR: Trying to hook up two connect points of the same type. Deal with this gracefully please!";
		[AppDelegate log:msg];
		return;
	}
	
	// figure out which is the input and which the output.
	UXFilterConnectPointView* inputConnectPoint = (self.type == UXFilterConnectPointTypeInput) ? self : otherPoint;
	UXFilterConnectPointView* outputConnectPoint = (self.type == UXFilterConnectPointTypeOutput) ? self : otherPoint;
	
	// Make the graphical connection first
	if(!self.connectionView) 
	{ 
		self.connectionView = [UXFilterConnectionView new];
		[self.superview addSubview:self.connectionView];
	}
	otherPoint.connectionView = self.connectionView;
	
	// Note this actually doesn't matter, connection views don't care who's "input" and who's "output",
	// they're just graphical conveniences. But I may as well use what I know so far for pedantry.
	self.connectionView.inputPointProvider = outputConnectPoint;
	self.connectionView.outputPointProvider = inputConnectPoint;
	
	// Now dig through into the FilterNode world and make the actual algorithmic connection
	
	// Grab the nodes and the right keys by asking the graph views 
	FilterNode* upstreamNode = outputConnectPoint.parentGraphView.parentNode;
	FilterNode* downstreamNode = inputConnectPoint.parentGraphView.parentNode;
	
	NSString* downstreamInputKey = [inputConnectPoint.parentGraphView findKeyForConnectPoint:inputConnectPoint];
	
	// We don't need the upstream output key because we're assuming just one output point
	// Note if we extended this, we'd need more information, because we're connecting entire nodes
	// to the input - if we had 2 output images we'd need to stop that
	
	//NSString* upstreamOutputKey = [outputConnectPoint.parentGraphView findKeyForConnectPoint:outputConnectPoint];
	
	// now make the connect
	NSLog(@"Joining output of %@ to input %@ of %@", upstreamNode, downstreamInputKey, downstreamNode);
	[downstreamNode.inputValues setObject:upstreamNode forKey:downstreamInputKey];
	
	// TODO: and finally we need to update the entire graph!
	[[FilterNodeContext sharedInstance] smartUpdate];
}

#pragma mark - Mousey


- (BOOL) acceptsFirstMouse:(NSEvent *)e 
{
	return YES;
}

- (void) mouseEntered:(NSEvent *)theEvent
{
	// indicating hover
	[self highlightMe:YES];
}

- (void) mouseExited:(NSEvent *)theEvent
{
	// hover off
	[self highlightMe:NO];
}



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
}

- (void) mouseUp:(NSEvent *)theEvent
{
	// Establish whether we are hovering over another connect point or not...
	UXFilterConnectPointView* hoveringConnectPoint = [[[UXFilterGraphManager sharedInstance] highlightedConnectPoints] anyObject];
	
	// Are we hovering over a different connect point?
	BOOL hoveringOverOther = (hoveringConnectPoint != nil) && (hoveringConnectPoint != self);
	
	// Is that connect point unconnected to others?
	BOOL hoveringOverSignificantOther = hoveringOverOther && (!hoveringConnectPoint.connectionView);
	
	if(hoveringOverSignificantOther)
	{
		// connecting self with other - make the connection and get the underlying FilterNodes to connect too
		NSLog(@"Hovering over %@", hoveringConnectPoint);
		[self joinSelfToConnectPoint:hoveringConnectPoint];
	}
	else // hovering over empty space, kill the connection view
	{
		NSLog(@"Killing connection view");
		[self destroyMyConnectionView];
	}
}

- (void)mouseDragged:(NSEvent *)theEvent 
{
	//NSLog(@"Dragging connection view %p", self);
	
	NSPoint mousePoint = [self.superview convertPoint:[theEvent locationInWindow] fromView:nil];
	
	NSPointProvider* outputPoint = [NSPointProvider pointProvider:mousePoint];
	
	// if the opposite point was a connect point view, remove it's grasp on the connection first
	id opposite = [self.connectionView oppositeConnectPointFrom:self];
	if([opposite isKindOfClass:[UXFilterConnectPointView class]])
	{
		// Kill the underlying filternode connection and update the graph
		[self wipeUnderlyingFilterNodeConnectionForConnection:self.connectionView];
		
		// do the graphics
		[opposite setConnectionView:nil];
		
	}
	
	// now set the opposite point to be our mouse pointer
	[self.connectionView setOppositeConnectPointFrom:self toBe:outputPoint]; // weak so only valid in this scope
	
	// get the connection to update it's drawing
	[self.connectionView updateConnection];
}


@end
