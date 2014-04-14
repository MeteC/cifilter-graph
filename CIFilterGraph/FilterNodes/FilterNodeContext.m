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
	NSMutableSet* mNodes;
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
        mNodes = [NSMutableSet set];
    }
    return self;
}


#pragma mark - Registration


/**
 * Register a node
 */
- (void) registerOutputNode:(FilterNode*) outputNode
{
	[mNodes addObject:outputNode];
}

/**
 * Deregister a node, if it's in the set.
 */
- (void) deregisterOutputNode:(FilterNode*) outputNode
{
	[mNodes removeObject:outputNode];
}

- (NSSet*) registeredNodes
{
	return mNodes;
}

#pragma mark - Updates

/**
 * Update the entire scene (providing all downstream nodes are registered)
 */
- (void) smartUpdate
{
	
	// pull dependencies, update them in order if required
	NSMutableArray* orderedDependencies = [NSMutableArray array];
	
	[mNodes enumerateObjectsUsingBlock:^(FilterNode* node, BOOL *stop) {
		int guardCounter = 0;
		[self unravelRecurse:node intoOrderedArray:orderedDependencies guardCounter:&guardCounter];
	}];
	
	// mark updated nodes as we go
	NSMutableSet* updatedSet = [NSMutableSet set];
	
	// now we've unravelled everything from all downstream nodes into an ordered dependency list
	[orderedDependencies enumerateObjectsUsingBlock:^(FilterNode* node, NSUInteger idx, BOOL *stop) {
		
		// use the updated set to ensure a node is not updated more than once
		if(![updatedSet containsObject:node]) 
		{
			[node updateNode];
			[updatedSet addObject:node];
		}
	}];
	
	UXLog(@"Updating Filter Graph!");
}

/** 
 * Travel recursively up a node's dependencies, putting them into an array that show the order
 * in which you need to update them.
 *
 * implementing basic infinite loop protection - a loop limiter. Not very sophisticated but
 * does the job with a minimum of fuss.
 */
- (void) unravelRecurse:(FilterNode*) node intoOrderedArray:(NSMutableArray*) inputArray guardCounter:(int*) guardCounter
{
	static const int kMaxGuardCount = 256; // will never have even close to this number of nodes
	
	[inputArray insertObject:node atIndex:0];
	
	for(id input in node.inputValues.allValues)
	{
		if([input isKindOfClass:[FilterNode class]])
		{
			if(*guardCounter > kMaxGuardCount)
			{
				UXLog(@"ERROR: Infinite loop detected! Can't safely determine dependencies, aborting.");
				break;
			}
			
			else 
			{ 
				*guardCounter = *guardCounter + 1;
				[self unravelRecurse:input intoOrderedArray:inputArray guardCounter:guardCounter];
			}
		}
		
		
	}
}

#pragma mark - Removal

/**
 * Removes a node from the scene, including all references to it by downstream nodes.
 * Does nothing to graphics, just FilterNode layer stuff!
 */
- (void) removeNodeFromScene:(FilterNode*) deadNode
{
	// traverse the scene and find any nodes that have node as input
	
	// pull dependencies as with updates...
	NSMutableArray* orderedDependencies = [NSMutableArray array];
	
	[mNodes enumerateObjectsUsingBlock:^(FilterNode* aNode, BOOL *stop) {
		int guardCounter = 0;
		[self unravelRecurse:aNode intoOrderedArray:orderedDependencies guardCounter:&guardCounter];
	}];
	
	// mark updated nodes as we go
	NSMutableSet* updatedSet = [NSMutableSet set];
	
	// ... now we just traverse the list and remove node from inputValues
	[orderedDependencies enumerateObjectsUsingBlock:^(FilterNode* aNode, NSUInteger idx, BOOL *stop) {
		
		// as in update, no need to check out a node more than once
		if(![updatedSet containsObject:aNode]) 
		{
			
			[aNode.inputValues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
				
				if(obj == deadNode)
				{
					[aNode.inputValues removeObjectForKey:key];
					NSLog(@"Removed node %@ from input list for node %@", deadNode, aNode);
				}
				
			}];
			
			[updatedSet addObject:aNode];
		}
	}];
	
	// finally deregister the node and we're done
	[self deregisterOutputNode:deadNode];
}

@end
