//
//  FilterConnectPointView.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 28/03/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

#import "UXFilterConnectPointView.h"
#import "UXFilterGraphManager.h"
//#import "UXFilterGraphView.h"


@interface UXFilterConnectPointView ()
{
	// for mouse tracking
	NSTrackingArea* trackingArea;
	NSColor* backgroundColour;
}

@property (readwrite) BOOL highlighted;

@end

@implementation UXFilterConnectPointView



- (instancetype) initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
    if (self) {
		
		[self createTrackingArea];
		
		// default colours
		normalColour = [NSColor grayColor];
		highlitColour = [NSColor blackColor];
		backgroundColour = normalColour;
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
	[backgroundColour set];
	
	// Every time we draw?
	NSRect mainFillRect = self.bounds;
    [NSBezierPath fillRect:mainFillRect];
}

- (void) highlightMe:(BOOL) highlight
{
	self.highlighted = highlight;
	
	if(highlight)
		backgroundColour = highlitColour;
	else
		backgroundColour = normalColour;
	
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
	// hover off
	[self highlightMe:NO];
}



@end
