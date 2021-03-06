//
//  FilterGraphView.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 5/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "UXFilterGraphView.h"
#import "FilterNodeSeenInOutputPane.h"
#import "NSScrollView+AutosizeContent.h"

#import "UXFilterInputPointView.h"
#import "UXFilterOutputPointView.h"
#import "UXFilterConnectionView.h"
#import "UXHighlightingImageView.h"


@interface UXFilterGraphView ()
{
	// Determined on init, how many connection points do we need to graphically represent?
	int mInputCount, mOutputCount;
	
	// connect points. note at present outputConnectPoints only has one entry, but it's easy enough to keep
	// in a dictionary for now anyway.
	NSMutableDictionary* _inputConnectPoints;
	NSMutableDictionary* _outputConnectPoints;
	
	NSPoint mousePointerAtDragStart;
	NSPoint originAtStart;
	
	// for mouse tracking
	NSTrackingArea* trackingArea;
	
	BOOL isDragging;
}
@property (nonatomic, strong) NSColor* backgroundColour;
@end

@implementation UXFilterGraphView


#pragma mark - Setup


- (instancetype) init
{
	// Default frame 150x50
	defaultSize		= CGSizeMake(150, 50);
    return [self initWithFrame:NSMakeRect(0, 0, defaultSize.width, defaultSize.height)];
}

- (void)dealloc
{
    NSLog(@"Deallocing UXFilterGraphView %@", self);
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		self.backgroundColour = [NSColor whiteColor];
		[self createTrackingArea];
		
		// Set some defaults
		defaultConnectionSize = CGSizeMake(10, 10);
    }
    
    return self;
}


/**
 * Make a tracking area for mouseovers
 */
- (void) createTrackingArea
{
    int opts = (NSTrackingMouseEnteredAndExited | /*NSTrackingMouseMoved | NSTrackingEnabledDuringMouseDrag |*/ NSTrackingActiveAlways);
	
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


#pragma mark - Connection Points & Connections


- (NSDictionary*) outputConnectPoints
{
	return _outputConnectPoints;
}

- (NSDictionary*) inputConnectPoints
{
	return _inputConnectPoints;
}


- (NSString*) findKeyForConnectPoint:(UXFilterConnectPointView*) connectPoint
{
	// Now that we have two distinct classes for input and output, we can figure out which
	// array to search in
	// TODO: does this mean we can squash the two connect point dicts into one??
	
	// determine best order to search dictionaries based on connectPoint type
	BOOL isInput = [connectPoint isKindOfClass:[UXFilterInputPointView class]];
	NSDictionary* searchDict = isInput ? self.inputConnectPoints : self.outputConnectPoints;
	
	__block NSString* retVal = nil;
	
	[searchDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) 
	{
		if(obj == connectPoint)
		{
			retVal = key;
			*stop = YES;
		}
	}];
	
	return retVal;
}

- (void) resetGraphConnectsOnSuperview:(NSView*) superview
{
	// clear old ones
	[_outputConnectPoints enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[obj removeFromSuperview];
	}];
	
	[_inputConnectPoints enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) 
	{
		[[obj connectionView] removeFromSuperview];
		[obj removeFromSuperview];
	}];
	
	
	// Set up the connect point views...
	
	// I'll set up connection views when I set up input connect points, rather than output connect points.
	_outputConnectPoints = [NSMutableDictionary dictionary];
	mOutputCount = 1;
	
	UXFilterOutputPointView* outputConnectPointView = 
	[[UXFilterOutputPointView alloc] initWithFrame:self.outputConnectionFrame];
	
	// set pointer back to self
	outputConnectPointView.parentGraphView = self;
	[superview addSubview:outputConnectPointView];
	
	// just the one entry for now, using the one "image" output key
	// ???: Is this the right key to use?? It actually corresponds to a CIImage, not a FilterNode.
	[_outputConnectPoints setValue:outputConnectPointView forKey:kFilterOutputKeyImage];
	
	
	
	// For inputs, go through the parent node's input values, and make a connect point for each
	// FilterNode found there
	_inputConnectPoints = [NSMutableDictionary dictionary];
	mInputCount = (int)self.parentNode.filterNodeTypeInputKeys.count;
	
	[self.parentNode.filterNodeTypeInputKeys enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
		UXFilterInputPointView* inputConnectPointView = 
		[[UXFilterInputPointView alloc] initWithFrame:[self inputConnectionFrame:(int)idx]];
		
		// set pointer back to self
		inputConnectPointView.parentGraphView = self;
		[superview addSubview:inputConnectPointView];
		
		[_inputConnectPoints setValue:inputConnectPointView forKey:key];
		NSLog(@"Added input point for %@, that's at key '%@'", self.parentNode.class, key);
		
		
		
		// now we'll introduce a connection view with connected node's output connect point - if it exists
		
		
		FilterNode* connectedNode = [self.parentNode.inputValues objectForKey:key];
		if(connectedNode)
		{
			UXFilterGraphView* connectedGraphView = connectedNode.graphView;
			
			if(connectedGraphView)
			{
				// create a connection view and assign it to the input connect point, two-way pointers.
				inputConnectPointView.connectionView = [[UXFilterConnectionView alloc] init];
				inputConnectPointView.connectionView.inputPointProvider = inputConnectPointView;
				
				// there's only one FilterNode output for now!
				UXFilterOutputPointView* otherConnectingPoint = [connectedGraphView.outputConnectPoints valueForKey:kFilterOutputKeyImage];
				
				// introduce the output connect point of the connected node to the connection...
				inputConnectPointView.connectionView.outputPointProvider = otherConnectingPoint;
				[otherConnectingPoint.connectionViews addObject:inputConnectPointView.connectionView];
				
				// now we can update the connection view and add it to the UI
				[inputConnectPointView.connectionView updateConnection];
				
				// Add to the same view layer
				[superview addSubview:inputConnectPointView.connectionView];
			}
			
			else // connected node has no graph view
			{
				UXLog(@"ERROR: trying to reset graph UI connections, but a corresponding input FilterGraphView does not exist");
			}
		}
		
	}];
	
	NSLog(@"Reset graph connects for %@", self.parentNode.className);
}



#pragma mark - Drawing

- (void) setNeedsDisplay:(BOOL)flag
{
	[super setNeedsDisplay:flag];

	// Also call on all connect points to update their connections
	[_inputConnectPoints enumerateKeysAndObjectsUsingBlock:^(id key, UXFilterInputPointView* obj, BOOL *stop) {
		[[obj connectionView] updateConnection];
	}];
	
	[_outputConnectPoints enumerateKeysAndObjectsUsingBlock:^(id key, UXFilterOutputPointView* obj, BOOL *stop) {
		[[obj connectionViews] makeObjectsPerformSelector:@selector(updateConnection)];
	}];
 
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
	//NSLog(@"Drawing %@ (%@)", self, self.parentNode);

	// fill it with a colour
	[self.backgroundColour set];
	
	// Every time we draw?
	NSRect mainFillRect = self.bounds;
	
	// delete all this? - use subviews instead - but maybe they clip too?
	mainFillRect.origin.x += defaultConnectionSize.width/2;
	mainFillRect.origin.y += defaultConnectionSize.height/2;
	mainFillRect.size.width -= defaultConnectionSize.width;
	mainFillRect.size.height -= defaultConnectionSize.height;
	
	
    [NSBezierPath fillRect:mainFillRect];
	
	// write its filter node name in the middle
	NSString* outputName = [NSString stringWithFormat:@"%@", self.parentNode.description];
	[outputName drawInRect:mainFillRect withAttributes:nil];
}



- (NSRect) inputConnectionFrame:(int) index
{
	NSAssert2(index < mInputCount, @"drawInputConnections: CRASH! Your FilterGraphView is only set up with %d input count, but you're trying to create input connection at index %d", mInputCount, index);
	
	// located along left side, spaced evenly according to mInputCount
	float centroidSpacing = self.frame.size.height / (mInputCount + 1);
	float xPos = self.frame.origin.x;
	float yPos = self.frame.origin.y + ((index+1) * centroidSpacing) - defaultConnectionSize.height/2;
	
	return NSMakeRect(xPos, yPos, defaultConnectionSize.width, defaultConnectionSize.height);
}

- (NSRect) outputConnectionFrame
{
	// centered halfway down the right-hand side..
	return NSMakeRect(self.frame.origin.x + self.frame.size.width - defaultConnectionSize.width, 
					  self.frame.origin.y + self.frame.size.height/2 - defaultConnectionSize.height/2, 
					  defaultConnectionSize.width, 
					  defaultConnectionSize.height);
}

#pragma mark - Mouse Events


- (BOOL) acceptsFirstMouse:(NSEvent *)e 
{
	return YES;
}

- (void) mouseEntered:(NSEvent *)theEvent
{
	// indicating hover
	self.backgroundColour = [NSColor cyanColor];

	if([self.parentNode conformsToProtocol:@protocol(FilterNodeSeenInOutputPane)])
	{
		// indicating which photo frame it owns
		UXHighlightingImageView* pane = [(id<FilterNodeSeenInOutputPane>)self.parentNode imageOutputView];
		
		// This was extremely slow for complex filter chains, because CIFilter is lazy - it only
		// performs operations when something (like NSImageView) asks to use the image.
		// so setting the frame was getting NSImageView to ask to redraw the image, and filter
		// processing was being done again (image wasn't being cached, so to speak)
		//[pane setImageFrameStyle:NSImageFrameGrayBezel];
		[pane setHighlight:YES];
	}
	
	[self setNeedsDisplay:YES];
}

- (void) mouseExited:(NSEvent *)theEvent
{
	self.backgroundColour = [NSColor whiteColor];
	
	if([self.parentNode conformsToProtocol:@protocol(FilterNodeSeenInOutputPane)])
	{
		// indicating which photo frame it owns
		UXHighlightingImageView* pane = [(id<FilterNodeSeenInOutputPane>)self.parentNode imageOutputView];
		
		// Setting frame style can be very slow! Why??
		//[pane setImageFrameStyle:NSImageFrameNone];
		[pane setHighlight:NO];
		
	}
	
	[self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *) e 
{ 	
	//get the mouse point
	mousePointerAtDragStart = [NSEvent mouseLocation];
	originAtStart = self.frame.origin;
	
	isDragging = YES;
	
	// Tell delegate of left mouse click
	[_delegate clickedFilterGraph:self wasLeftClick:YES];
}

- (void) rightMouseDown:(NSEvent *)theEvent
{
	
	// Tell delegate of right mouse click
	[_delegate clickedFilterGraph:self wasLeftClick:NO];
}

- (void) mouseUp:(NSEvent *)theEvent
{
	isDragging = NO;
	
	// Tell parent to auto resize it's content
	// traverse parental hierarchy til we get the parent scroller
	// For continuous alteration could put this in mouseDragged at (// *) instead.
	id parentScroller = self;
	while(parentScroller != nil)
	{
		parentScroller = [parentScroller superview];
		if([parentScroller isKindOfClass:[NSScrollView class]])
		{
			[parentScroller autoResizeContentView];
			break;
		}
	}
}

- (void)mouseDragged:(NSEvent *)theEvent 
{
	if (isDragging) 
	{
		// Moving the whole filter node about	
		NSPoint currentMousePointer = [NSEvent mouseLocation];
		NSPoint thisOrigin = NSMakePoint(originAtStart.x + (currentMousePointer.x - mousePointerAtDragStart.x), originAtStart.y + (currentMousePointer.y - mousePointerAtDragStart.y));
		
		// no negatives (i.e. not off the left/bottom
		thisOrigin.x = MAX(0, thisOrigin.x);
		thisOrigin.y = MAX(0, thisOrigin.y);
		
		// update my frame
		[self setFrameOrigin:thisOrigin];
		
		// *
	}
}

/**
 * Extending this to move connect points around as well!
 */
- (void) setFrameOrigin:(NSPoint)newOrigin
{
	NSPoint delta = NSMakePoint(newOrigin.x - self.frame.origin.x, newOrigin.y - self.frame.origin.y);
	
	[super setFrameOrigin:newOrigin];
	
	// update connect point frames too, as they're attached to superview
	[_outputConnectPoints enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[obj setFrameOrigin:NSMakePoint([obj frame].origin.x + delta.x, 
										[obj frame].origin.y + delta.y)];
	}];
	
	[_inputConnectPoints enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[obj setFrameOrigin:NSMakePoint([obj frame].origin.x + delta.x, 
										[obj frame].origin.y + delta.y)];
	}];
}

/*
- (void) mouseMoved:(NSEvent *)theEvent
{
	NSLog(@"%@ move received", self.parentNode.className);
	
	NSPoint loc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	[self checkConnectionBoxHighlightsForMouse:loc];
}*/

@end
