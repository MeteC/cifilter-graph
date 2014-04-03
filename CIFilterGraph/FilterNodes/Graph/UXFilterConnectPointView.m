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


@interface UXFilterConnectPointView ()
{
	BOOL isDragging; // TODO: remove this?
	
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
//	if(!isDragging)
	{
		// hover off
		[self highlightMe:NO];
	}
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

- (void) destroyMyConnectionView
{
	// kill my connection view completely
	[self.connectionView removeFromSuperview];
	[self.connectionView.inputPointProvider setConnectionView:nil];
	[self.connectionView.outputPointProvider setConnectionView:nil];
	
	// TODO: kill underlying FilterNode connection too and update the graph
}

- (void)mouseDown:(NSEvent *) e 
{ 	
	isDragging = YES;
	
	
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
		[self destroyMyConnectionView];
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
		[opposite setConnectionView:nil];
		
		// TODO: Kill the underlying filternode connection and update the graph
	}
	
	// now set the opposite point to be our mouse pointer
	[self.connectionView setOppositeConnectPointFrom:self toBe:outputPoint]; // weak so only valid in this scope
	
	// get the connection to update it's drawing
	[self.connectionView updateConnection];
}


@end
