//
//  NSPointProvider.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

#import "NSPointProvider.h"

@interface NSPointProvider ()
@property NSPoint mPoint;
@end

@implementation NSPointProvider

+ (instancetype) pointProvider:(NSPoint) point
{
	NSPointProvider* pp = [NSPointProvider new];
	pp.mPoint = point;
	return pp;
}

- (NSPoint) endPoint
{
	return self.mPoint;
}

@end
