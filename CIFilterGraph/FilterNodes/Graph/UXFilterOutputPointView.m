//
//  UXFilterOutputPointView.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 6/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

#import "UXFilterOutputPointView.h"

@implementation UXFilterOutputPointView

#pragma mark - Setup

- (instancetype) initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
    if (self) {
		
		// default colours
		normalColour = [NSColor grayColor];
		highlitColour = [NSColor redColor]; // to indicate dragging from me won't do anything!
		
		_connectionViews = [NSMutableSet set];
    }
    
    return self;
}

#pragma mark - Mousey

/**
 * Swallow mouseDown to prevent dragging graph around
 */
- (void)mouseDown:(NSEvent *) e 
{ 
}

@end
