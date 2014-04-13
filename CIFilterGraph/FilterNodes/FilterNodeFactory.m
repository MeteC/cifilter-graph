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
#import "ListedNodeManager.h"
#import "UXHighlightingImageView.h"


static const CGFloat kDefaultImageViewDim = 225; // default dimension size (in points) for output panes

@implementation FilterNodeFactory



+ (FilterNode*) generateNodeForNodeClassName:(NSString*) nodeClassName
{
	NSMutableString* msg = [NSMutableString stringWithFormat:@"Generate: %@.", nodeClassName];
	Class nodeClass = NSClassFromString(nodeClassName);
	__block id newNode = nil;
	
	// Got an actual FilterNode class?
	if(nodeClass && [nodeClass isSubclassOfClass:[FilterNode class]])
		newNode = [[nodeClass alloc] init];
	
	else 
	{
		// not an actual class, so it might be a FilterNode registered in a ListedNodeManager
		NSArray* allListedNodeMgrs = [AppDelegate listedNodeManagers];
		
		[allListedNodeMgrs enumerateObjectsUsingBlock:^(ListedNodeManager* mgr, NSUInteger idx, BOOL *stop) {
			
			newNode = [mgr createFilterNodeForNameKey:nodeClassName];
			
			if(newNode) *stop = YES;
		}];
	}
	
	if([newNode isKindOfClass:[FilterNode class]])
	{
		[newNode setupDefaultGraphView];
		
		// if we have a node that displays an image - i.e. output or input node, we give it an image pane
		if([newNode conformsToProtocol:@protocol(FilterNodeSeenInOutputPane)])
		{
			// set up the output "pane"
			UXHighlightingImageView* pane = [[UXHighlightingImageView alloc] initWithFrame:
											 NSMakeRect(0, 0, 
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
		[msg setString:[NSString stringWithFormat:@"ERROR: %@ is not a FilterNode class or a listed node", nodeClassName]];
	}
		 
	[AppDelegate log:msg];
	
	return newNode;
}



@end
