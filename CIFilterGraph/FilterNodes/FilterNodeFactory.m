//
//  FilterNodeFactory.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 23/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "FilterNodeFactory.h"
#import "FilterNode.h"
#import "FilterNodeSeenInOutputPane.h"


static const CGFloat kDefaultImageViewDim = 225; // default dimension size (in points) for output panes

@implementation FilterNodeFactory



+ (FilterNode*) generateNodeForNodeClassName:(NSString*) nodeClassName
{
	Class nodeClass = NSClassFromString(nodeClassName);
	id newNode = [[nodeClass alloc] init];
	NSMutableString* msg = [NSMutableString stringWithFormat:@"Generate: %@.", nodeClassName];
	
	if([newNode isKindOfClass:[FilterNode class]])
	{
		[newNode setupDefaultGraphView];
		
		// if we have a node that displays an image - i.e. output or input node, we give it an image pane
		if([newNode conformsToProtocol:@protocol(FilterNodeSeenInOutputPane)])
		{
			// set up the output "pane"
			NSImageView* pane = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 
																			  kDefaultImageViewDim, 
																			  kDefaultImageViewDim)];
			
			[pane setImageFrameStyle:NSImageFrameNone];
			[newNode setImageOutputView:pane];
			
			[msg appendString:@" (Has output view.)"];
		}
	}
	else
	{
		newNode = nil;
		[msg setString:[NSString stringWithFormat:@"ERROR: %@ is not a FilterNode class", nodeClassName]];
	}
		 
	[AppDelegate log:msg];
	
	return newNode;
}



@end
