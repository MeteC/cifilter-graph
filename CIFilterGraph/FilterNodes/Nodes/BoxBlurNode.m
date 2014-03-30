//
//  BoxBlur.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 30/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "BoxBlurNode.h"

@implementation BoxBlurNode

- (id)init
{
    return [self initWithCIFilterName:@"CIBoxBlur" configOptions:@[@"inputRadius"]];
}

// TODO: override setupDefaultGraphView


@end
