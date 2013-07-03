//
//  FilterNode.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "FilterNode.h"

@implementation FilterNode


- (CIImage*) outputImage
{
	NSAssert(0, @"FilterNode superclass implementation of outputImage called - please override!");
	return nil;
}

@end
