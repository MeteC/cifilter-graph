//
//  FilterGraphView.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 5/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "FilterGraphView.h"
#import "CustomisedScrollView.h"
#import "FilterNodeSeenInOutputPane.h"
#import "NSScrollView+AutosizeContent.h"
#import "FilterConnectPointView.h"
#import "FilterConnectionView.h"


@interface FilterGraphView ()
{
	// Determined on init, how many connection points do we need to graphically represent?
	int mInputCount, mOutputCount;
	
	NSMutableDictionary* _inputConnectPoints;
	NSMutableDictionary* _outputConnectPoints;
	
	// array of input connections. the output connection would be owned and presented by the downstream graph
	
	// !!!: Starting to think that FilterGraphView should know nothing about connections, just connect points!
	//NSArray* inputConnections;
	
	NSPoint mousePointerAtDragStart;
	NSPoint originAtStart;
	
	// for mouse tracking
	NSTrackingArea* trackingArea;
	
	BOOL isDragging;
}
@property (nonatomic, strong) NSColor* backgroundColour;
@end

@implementation FilterGraphView


- (NSDictionary*) outputConnectPoints
{
	return _outputConnectPoints;
}

- (NSDictionary*) inputConnectPoints
{
	return _inputConnectPoints;
}


- (instancetype) init
{
	// Default frame 150x50
	defaultSize		= CGSizeMake(150, 50);
    return [self initWithFrame:NSMakeRect(0, 0, defaultSize.width, defaultSize.height)];
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


- (void) resetGraphConnects
{
	// clear old ones
	[_outputConnectPoints enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[obj removeFromSuperview];
	}];
	
	[_inputConnectPoints enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[obj removeFromSuperview];
	}];
	
	
	// Set up the connect point views...
	_outputConnectPoints = [NSMutableDictionary dictionary];
	FilterConnectPointView* outputConnectPoint = [[FilterConnectPointView alloc] initWithFrame:self.outputConnectionFrame];
	[self addSubview:outputConnectPoint];
	
	// just the one entry for now, using the one "image" output key
	// ???: Is this the right key to use?? It actually corresponds to a CIImage, not a FilterNode.
	[_outputConnectPoints setValue:outputConnectPoint forKey:kFilterOutputKeyImage];
	mOutputCount = 1;
	
	
	
	// For inputs, go through the parent node's input values, and make a connect point for each
	// FilterNode found there
	_inputConnectPoints = [NSMutableDictionary dictionary];
	
	// first pass to count up all FilterNode input values
	mInputCount = 0;
	[self.parentNode.inputValues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		
		if([obj isKindOfClass:[FilterNode class]])
		{
			mInputCount++;
		}
	}];
	
	// second pass to create connect points
	__block int i = 0;
	[self.parentNode.inputValues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		
		if([obj isKindOfClass:[FilterNode class]])
		{
			FilterConnectPointView* inputConnectPoint = [[FilterConnectPointView alloc] initWithFrame:[self inputConnectionFrame:i++]];
			[self addSubview:inputConnectPoint];
			
			[_inputConnectPoints setValue:inputConnectPoint forKey:key];
			NSLog(@"Added input point for %@, that's at key '%@'", self.parentNode.class, key);
		
			/*
			// TESTING: Remove this!!
			// adding a connection to each output connect point.. just to see something
			FilterConnectionView* connection = [[FilterConnectionView alloc] initWithFrame:NSZeroRect];
			connection.outputGraphConnect = inputConnectPoint;
			connection.inputGraphConnect = [self.parentNode.inputImageNode.graphView.outputConnectPoints valueForKey:kFilterOutputKeyImage]; // blimey!
			
			[connection updateConnection];
			[self.superview addSubview:connection];*/
		}
	}];
	
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

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
	//NSLog(@"Drawing %@ (%@)", self, self.parentNode.class);

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
	NSString* outputName = [NSString stringWithFormat:@"%@", self.parentNode.class];
	[outputName drawInRect:mainFillRect withAttributes:nil];

	// Check connections
///	[self updateConnections];
}

// NOPE: no longer have connections owned by FilterGraphView, rather by FilterConnectPoints.
- (void) updateConnections
{
	// Just dealing with the 1 input case for now, to see how things sit together.
	/*
	FilterNode* inputNode = [self.parentNode inputImageNode];
	FilterConnectionView* connect = inputConnections[0];
	
	if(inputNode)
	{
		connect.inputGraphConnect = inputNode.graphView.out;
		[connect updateConnection];
	}
	else // no input node! better hide the connection
	{
		[connect setHidden:YES];
	}*/
	
	
	/*
	// TODO: Case with more than 1 input!
	// loop all node inputs, to make a list of inputs that are FilterNodes (and therefore need arrows)
	
	// loop all input connections..
	
	for(int i = 0; i < inputConnections.count; i++)
	{
		FilterConnectionView* connection = inputConnections[i];
		self.parentNode.inputValues... urp
		
		if(connection.inputGraphView)
		{
			// we got a full connection
			
		}
		else 
		{
			[connection setHidden:YES];
		}
	}*/
}

/**
 * Draw all input connections, as black arrows. NOPE DONE BY FilterConnectionView
 */
/*
- (void) drawInputConnections
{
	[[NSColor redColor] set];
	
	int inputConnectionIndex = 0;
	
	for(id inputVal in self.parentNode.inputValues.allValues)
	{
		if([inputVal isKindOfClass:[FilterNode class]])
		{
			FilterNode* inputNode = inputVal;
			
			// For the input node, get it's output location. Only one is supported for now.
			NSRect outputConnectorFrame = inputNode.graphView.outputConnectionFrame; 
			
			// Get the correct input connection. Has the same index as the filter node.
			int myIndex = inputConnectionIndex++;
			NSRect inputConnectorFrame = [self inputConnectionFrame:myIndex];
			
			CGPoint startPoint = CGPointMake(CGRectGetMidX(outputConnectorFrame) - self.frame.origin.x,
											 CGRectGetMidY(outputConnectorFrame) - self.frame.origin.y);
			
			CGPoint endPoint = CGPointMake(CGRectGetMidX(inputConnectorFrame) - self.frame.origin.x,
										   CGRectGetMidY(inputConnectorFrame) - self.frame.origin.y);
			
			// Now draw the line
			NSBezierPath* linePath = [NSBezierPath bezierPath];
			[linePath moveToPoint:endPoint];
			[linePath lineToPoint:startPoint];
			
			[linePath stroke];
		}
	}
}*/


- (NSRect) inputConnectionFrame:(int) index
{
	NSAssert2(index < mInputCount, @"drawInputConnections: CRASH! Your FilterGraphView is only set up with %d input count, but you're trying to create input connection at index %d", mInputCount, index);
	
	// located along left side, spaced evenly according to mInputCount
	float centroidSpacing = self.frame.size.height / (mInputCount + 1);
	float xPos = 0;
	float yPos = ((index+1) * centroidSpacing) - defaultConnectionSize.height/2;
	
	return NSMakeRect(xPos, yPos, defaultConnectionSize.width, defaultConnectionSize.height);
}

- (NSRect) outputConnectionFrame
{
	// centered halfway down the right-hand side..
	return NSMakeRect(self.frame.size.width - defaultConnectionSize.width, 
					  self.frame.size.height/2 - defaultConnectionSize.height/2, 
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
		NSImageView* pane = [(id<FilterNodeSeenInOutputPane>)self.parentNode imageOutputView];
		
		// !!!: deprectaed frame styles
		[pane setImageFrameStyle:NSImageFrameButton];
	}
	
	[self setNeedsDisplay:YES];
}

- (void) mouseExited:(NSEvent *)theEvent
{
	self.backgroundColour = [NSColor whiteColor];
	
	if([self.parentNode conformsToProtocol:@protocol(FilterNodeSeenInOutputPane)])
	{
		// indicating which photo frame it owns
		NSImageView* pane = [(id<FilterNodeSeenInOutputPane>)self.parentNode imageOutputView];
		[pane setImageFrameStyle:NSImageFramePhoto];
	}
	
	[self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *) e 
{ 	
	//get the mouse point
	mousePointerAtDragStart = [NSEvent mouseLocation];
	originAtStart = self.frame.origin;
	
	isDragging = YES;
	
	// Indicate that configuration options should be set up for this node
	[_delegate clickedFilterGraph:self];
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
		if([parentScroller isKindOfClass:[CustomisedScrollView class]])
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
		
		[self setFrameOrigin:thisOrigin];
		
		// *
	}
}

/*
- (void) mouseMoved:(NSEvent *)theEvent
{
	NSLog(@"%@ move received", self.parentNode.className);
	
	NSPoint loc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	[self checkConnectionBoxHighlightsForMouse:loc];
}*/

@end
