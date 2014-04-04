//
//  FilterNodeContext.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 4/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

#import "FilterNodeContext.h"
#import "FilterNode.h"

@interface FilterNodeContext ()
{
	NSMutableSet* downstreamNodes;
}
@end

@implementation FilterNodeContext

#pragma mark - Setup


+ (instancetype) sharedInstance
{
	static dispatch_once_t once;
    static FilterNodeContext *shared;
    dispatch_once(&once, ^ { 
		NSLog(@"Setting up singleton FilterNodeContext (should be only once!)");
		
		shared = [[FilterNodeContext alloc] init]; 
		
	});
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        downstreamNodes = [NSMutableSet set];
    }
    return self;
}


#pragma mark - Methods


/**
 * Register a downstream node to be pulled from
 */
- (void) registerOutputNode:(FilterNode*) outputNode
{
	[downstreamNodes addObject:outputNode];
}

/**
 * Deregister a downstream node, if it's in the set.
 */
- (void) deregisterOutputNode:(FilterNode*) outputNode
{
	[downstreamNodes removeObject:outputNode];
}

/**
 * Update the entire scene (providing all downstream nodes are registered)
 */
- (void) smartUpdate
{
	// mark updated nodes as we go
	NSMutableSet* updatedSet = [NSMutableSet set];
	
	// pull dependencies, update them in order if required
	NSMutableArray* orderedDependencies = [NSMutableArray array];
	
	[downstreamNodes enumerateObjectsUsingBlock:^(FilterNode* node, BOOL *stop) {
		
		[self unravelRecurse:node intoOrderedArray:orderedDependencies];
	}];
	
	// now we've unravelled everything from all downstream nodes into an ordered dependency list
	[orderedDependencies enumerateObjectsUsingBlock:^(FilterNode* node, NSUInteger idx, BOOL *stop) {
		
		// use the updated set to ensure a node is not updated more than once
		if(![updatedSet containsObject:node]) 
		{
			[node updateSelf];
			[updatedSet addObject:node];
		}
	}];
}

/** 
 * Travel recursively up a node's dependencies, putting them into an array that show the order
 * in which you need to update them.
 */
- (void) unravelRecurse:(FilterNode*) node intoOrderedArray:(NSMutableArray*) inputArray
{
	[inputArray insertObject:node atIndex:0];
	
	for(id input in node.inputValues.allValues)
	{
		if([input isKindOfClass:[FilterNode class]])
		{
			[self unravelRecurse:input intoOrderedArray:inputArray];
		}
	}
}

@end
