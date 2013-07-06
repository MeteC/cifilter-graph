//
//  FilterGraphView.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 5/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "FilterGraphView.h"

// Might need refactoring later but I'm gonna have distinct types of mouse-drag for moving and
// connecting nodes.
typedef enum
{
	FilterGraphViewDragTypeNull,
	FilterGraphViewDragTypeMove,
	FilterGraphViewDragTypeConnect
	
} FilterGraphViewDragType;


@interface FilterGraphView ()
{
	NSPoint mousePointerAtDragStart;
	NSPoint originAtStart;
	
	// for mouse tracking
	NSTrackingArea* trackingArea;
	
	FilterGraphViewDragType dragMode;
}
@property (nonatomic, retain) NSColor* backgroundColour;
@end

@implementation FilterGraphView


- (id) initWithInputCount:(uint) inputCount outputCount:(uint) outputCount
{
	// 
}

- (id)init
{
	// Default frame 150x50
    return [self initWithFrame:NSMakeRect(0, 0, 150, 50)];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		self.backgroundColour = [NSColor whiteColor];
		[self createTrackingArea];
    }
    
    return self;
}

- (void)dealloc
{
    self.backgroundColour = nil;
	[trackingArea release];
    [super dealloc];
}

/**
 * Make a tracking area for mouseovers
 */
- (void) createTrackingArea
{
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);

	[trackingArea release];
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
    // Drawing code here.

	// fill it with red
	[self.backgroundColour set];
    [NSBezierPath fillRect:self.bounds];
	
	// write it's filter node name in the middle
	NSString* outputName = [NSString stringWithFormat:@"%@", self.parentNode.class];
	[outputName drawInRect:self.bounds withAttributes:nil];
}



// -------------------- MOUSE EVENTS ------------------- \\ 

- (BOOL) acceptsFirstMouse:(NSEvent *)e {
	return YES;
}

- (void) mouseEntered:(NSEvent *)theEvent
{
	self.backgroundColour = [NSColor cyanColor];
	[self setNeedsDisplay:YES];
}

- (void) mouseExited:(NSEvent *)theEvent
{
	self.backgroundColour = [NSColor whiteColor];
	[self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *) e { 
	
	//get the mouse point
	mousePointerAtDragStart = [NSEvent mouseLocation];
	originAtStart = self.frame.origin;
	
	dragMode = FilterGraphViewDragTypeMove;
}

- (void) mouseUp:(NSEvent *)theEvent
{
	dragMode = FilterGraphViewDragTypeNull;
}

- (void)mouseDragged:(NSEvent *)theEvent 
{
	switch (dragMode) 
	{
		// Moving the whole filter node about	
		case FilterGraphViewDragTypeMove:
		{
			NSPoint currentMousePointer = [NSEvent mouseLocation];
			NSPoint thisOrigin = NSMakePoint(originAtStart.x + (currentMousePointer.x - mousePointerAtDragStart.x), originAtStart.y + (currentMousePointer.y - mousePointerAtDragStart.y));
			
			[self setFrameOrigin:thisOrigin];
			/*	
			 // if (as) parent is scrollview, might need to resize it's content etc?
			 id predictedScroller = self.superview.superview.superview; // there's probably a neater way..
			 if([predictedScroller isKindOfClass:[NSScrollView class]])
			 {
			 // TODO: Scroller should have it's own autosizing method based on all it's children..
			 [[predictedScroller documentView] setFrame:NSMakeRect(0, 0, self.frame.origin.x + self.frame.size.width, self.frame.origin.y + self.frame.size.height)];
			 
			 }
			 */	
		}
			break;
			
		// Connecting a filter node outlet
		case FilterGraphViewDragTypeConnect:
		{
			
		}
			break;
			
		default:
			break;
	}
}

@end
