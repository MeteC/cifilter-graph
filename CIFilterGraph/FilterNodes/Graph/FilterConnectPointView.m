//
//  FilterConnectPointView.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 28/03/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

#import "FilterConnectPointView.h"
#import "FilterGraphView.h"


@interface FilterConnectPointView ()
{
	BOOL isDragging;
	
	// for mouse tracking
	NSTrackingArea* trackingArea;
}

@property BOOL highlighted;
@property NSColor* backgroundColour;

@end

@implementation FilterConnectPointView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
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

#pragma mark - Point stuff

- (NSPoint) connectEndPoint
{
	// this is now relative to the superview (ie the Graph View)
	NSPoint thePoint = [self.superview convertPoint:self.frame.origin fromView:self];
	
	// and now it's relative to the superview of that
	thePoint = [self.superview.superview convertPoint:thePoint fromView:self.superview];
	
	return thePoint;
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
	
	[self setNeedsDisplay:YES];
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
	if(!isDragging)
	{
		// hover off
		[self highlightMe:NO];
	}
}

- (void)mouseDown:(NSEvent *) e 
{ 	
	isDragging = YES;
}

- (void) mouseUp:(NSEvent *)theEvent
{
	if(self.highlighted)
	{
		NSLog(@"Mouse up from connect point drag");
		isDragging = NO;
		[self highlightMe:NO];
		
	}
}

- (void)mouseDragged:(NSEvent *)theEvent 
{
	
}


@end
