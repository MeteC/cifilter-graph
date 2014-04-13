//
//  UXHighlightingImageView.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 13/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

#import "UXHighlightingImageView.h"

/**
 * Inner class for the highlighting view behaviour
 */
@interface FramingNSView : NSView
@end

@implementation FramingNSView

- (void) drawRect:(NSRect)dirtyRect
{
	// just a black border for now
	[[NSColor blackColor] set];
	NSRect mainFillRect = self.bounds;
    [NSBezierPath strokeRect:mainFillRect];
}

@end


@interface UXHighlightingImageView ()
{
	FramingNSView* frameView;
}
@end

@implementation UXHighlightingImageView

- (instancetype) initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if(self)
	{
		// add a highlighting frame layer
		frameView = [[FramingNSView alloc] initWithFrame:frameRect];
		[self addSubview:frameView];
		
		[self setHighlight:NO];
	}
	return self;
}


- (void) setHighlight:(BOOL) highlight
{
	[frameView setHidden:!highlight];
}
@end
