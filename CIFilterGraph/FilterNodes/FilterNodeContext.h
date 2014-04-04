//
//  FilterNodeContext.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 4/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

//	Because I'm using a "pull" graph structure, it could be easy to process a given node in the graph
//	multiple times per update, which is unneccessary. I'm creating a singleton context manager that
//	can be asked to do updates smartly.

//	v1: register output nodes. updates will mark upstream nodes as updated and if multiple output
//	branches use the same nodes they won't need to be updated twice

#import <Foundation/Foundation.h>

@class FilterNode;


@interface FilterNodeContext : NSObject

+ (instancetype) sharedInstance;

/**
 * Register a downstream node to be pulled from. Note - you can register any node actually, it will
 * always get dependencies correctly. It would be more efficient to only register outputs but that's
 * not the FilterNodeContext's responsibility!
 */
- (void) registerOutputNode:(FilterNode*) outputNode;

/**
 * Deregister a downstream node, if it's in the set.
 */
- (void) deregisterOutputNode:(FilterNode*) outputNode;

/**
 * Update the entire scene (providing all downstream nodes are registered)
 */
- (void) smartUpdate;

@end
