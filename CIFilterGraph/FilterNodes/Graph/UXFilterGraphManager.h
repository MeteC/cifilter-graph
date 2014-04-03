//
//  UXFilterGraphManager.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 4/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

//	Since there's only one graph, I'm making a singleton manager for dealing with graph-wide
//	events that I care about. E.g. When a connect point is highlighted or unhighlighted it gets
//	registered as such, then while making connections I can ask the manager who is currently highlighted

#import <Foundation/Foundation.h>

@class UXFilterConnectPointView;

@interface UXFilterGraphManager : NSObject

+ (instancetype) sharedInstance;

/**
 * Which connect points are registered as being highlighted right now?
 */
- (NSSet*) highlightedConnectPoints;

/**
 * Register or Deregister a connect point as being highlighted.
 */
- (void) registerConnectPoint:(UXFilterConnectPointView*) connectPoint asHighlighted:(BOOL) isHighlighted;

@end
