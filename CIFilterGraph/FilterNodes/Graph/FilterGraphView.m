//
//  FilterGraphView.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 5/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "FilterGraphView.h"

@interface FilterGraphView ()
{
	NSPoint mousePointerAtDragStart;
	NSPoint originAtStart;
}
@end

@implementation FilterGraphView

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
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.

	// fill it with red
	[[NSColor redColor] set];
    [NSBezierPath fillRect:self.bounds];
	
	// write it's filter node name in the middle
	NSString* outputName = [NSString stringWithFormat:@"%@", self.parentNode.class];
	[outputName drawInRect:self.bounds withAttributes:nil];
}



// -------------------- MOUSE EVENTS ------------------- \\ 

- (BOOL) acceptsFirstMouse:(NSEvent *)e {
	return YES;
}

- (void)mouseDown:(NSEvent *) e { 
	
	//get the mouse point
	mousePointerAtDragStart = [NSEvent mouseLocation];
	originAtStart = self.frame.origin;
}

- (void)mouseDragged:(NSEvent *)theEvent {
	
	NSPoint currentMousePointer = [NSEvent mouseLocation];
	NSPoint thisOrigin = NSMakePoint(originAtStart.x + (currentMousePointer.x - mousePointerAtDragStart.x), originAtStart.y + (currentMousePointer.y - mousePointerAtDragStart.y));
	
	[self setFrameOrigin:thisOrigin];
	
	// if (as) parent is scrollview, might need to resize it's content etc?
	id predictedScroller = self.superview.superview.superview; // there's probably a neater way..
	if([predictedScroller isKindOfClass:[NSScrollView class]])
	{
		// TODO: Scroller should have it's own autosizing method based on all it's children..
		[[predictedScroller documentView] setFrame:NSMakeRect(0, 0, self.frame.origin.x + self.frame.size.width, self.frame.origin.y + self.frame.size.height)];
		
		[self setNeedsDisplay:YES];
	}
	
}

@end
