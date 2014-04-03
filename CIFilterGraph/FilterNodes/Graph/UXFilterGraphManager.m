//
//  UXFilterGraphManager.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 4/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

#import "UXFilterGraphManager.h"

@interface UXFilterGraphManager ()
{
	NSMutableSet* highlightedConnectPoints;
}
@end

@implementation UXFilterGraphManager

#pragma mark - Setup

+ (instancetype) sharedInstance
{
    static dispatch_once_t once;
    static UXFilterGraphManager *shared;
    dispatch_once(&once, ^ { 
		NSLog(@"Setting up singleton UXFilterGraphManager (should be only once!)");
		
		shared = [[UXFilterGraphManager alloc] init]; 
		
	});
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        highlightedConnectPoints = [NSMutableSet set];
    }
    return self;
}

#pragma mark - Connect Point Highlight Registration

/**
 * Which connect points are registered as being highlighted right now?
 */
- (NSSet*) highlightedConnectPoints
{
	return highlightedConnectPoints;
}

/**
 * Register or Deregister a connect point as being highlighted.
 */
- (void) registerConnectPoint:(UXFilterConnectPointView*) connectPoint 
				asHighlighted:(BOOL) isHighlighted
{
	if(!isHighlighted)
	{
		[highlightedConnectPoints removeObject:connectPoint];
	}
	else 
	{
		[highlightedConnectPoints addObject:connectPoint];
	}
}


@end
