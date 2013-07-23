//
//  NSScrollView+AutosizeContent.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 23/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "NSScrollView+AutosizeContent.h"

@implementation NSScrollView (AutosizeContent)

// based on it's children, set content size automatically
- (void) autoResizeContentView
{
	CGSize fullContentSize = self.bounds.size; // setting a minimum as scroller bounds
	
	for(NSView* view in [self.documentView subviews])
	{
		if (!view.isHidden)
		{
			CGFloat y = view.frame.origin.y;
			CGFloat h = view.frame.size.height;
			if (y + h > fullContentSize.height)
			{
				fullContentSize.height = h + y;
			}
			
			CGFloat x = view.frame.origin.x;
			CGFloat w = view.frame.size.width;
			if (x + w > fullContentSize.width)
			{
				fullContentSize.width = w + x;
			}
		}
	}
	
	[[self documentView] setFrameSize:fullContentSize];
}

@end
