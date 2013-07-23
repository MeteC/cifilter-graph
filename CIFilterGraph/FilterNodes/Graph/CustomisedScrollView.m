//
//  CustomisedScrollView.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 22/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "CustomisedScrollView.h"
#import "FilterGraphView.h"

@implementation CustomisedScrollView

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) setup
{
	NSLog(@"Setting up custom scroll view");
	CustomisedDocumentView* myDocView = [[[CustomisedDocumentView alloc] initWithFrame:self.bounds] autorelease];
	[self setDocumentView:myDocView];
}


@end


@implementation CustomisedDocumentView

#pragma mark - Drawing

/**
 * Just quick and dirty for now - lines from center to center. 
 * Will make this look nice at some point! Good to get some functionality in first.
 */
- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
	
	// Force the whole damn thing to be redrawn.
	[self setNeedsDisplay:YES];
	
	// For all dirty node children, go thru and recalculate their paths. All clean node children keep same
	// paths. Draw them all.
	
	// For starters - just do all recalculations here too
//	[[NSColor redColor] set];
  //  [NSBezierPath fillRect:self.bounds];
	
	[[NSColor blackColor] set];
	
	// Only calculate paths TO nodes, else we'll be doubling up
	for(FilterGraphView* nodeView in self.subviews)
	{
		FilterNode* node = nodeView.parentNode;
		
		if(node.inputValues.count > 0)
		{
			for(id inputValue in node.inputValues.allValues)
			{
				if([inputValue isKindOfClass:[FilterNode class]])
				{
					// we have a node input connection, so we draw between the two.
					
					// TODO: Start and end points! Just use center for first dev
					
					FilterNode* inputNode = (FilterNode*)inputValue;
					
					CGPoint startPoint = CGPointMake(CGRectGetMidX(inputNode.graphView.frame),
													 CGRectGetMidY(inputNode.graphView.frame));
					
					CGPoint endPoint = CGPointMake(CGRectGetMidX(node.graphView.frame),
												   CGRectGetMidY(node.graphView.frame));
					
					// draw dashed line between em
					NSBezierPath* linePath = [NSBezierPath bezierPath];
					[linePath moveToPoint:startPoint];
					[linePath lineToPoint:endPoint];
					
					[linePath stroke];
				}
			}
		}
	}
}


@end