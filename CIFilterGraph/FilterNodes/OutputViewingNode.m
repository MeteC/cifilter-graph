//
//  OutputViewingNode.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "OutputViewingNode.h"

@implementation OutputViewingNode


/**
 * For output viewing node, the only processing to do is pass through the image found in inputValues
 * to the outputValues dictionary
 */
- (void) update
{
	[super update];
	
	FilterNode* inputNode = [_inputValues valueForKey:kFilterInputKeyInputImageNode];
	CIImage* inputImage = [[inputNode outputValues] valueForKey:kFilterOutputKeyImage];
	
	[_outputValues setValue:inputImage forKey:kFilterOutputKeyImage];
}


@end
