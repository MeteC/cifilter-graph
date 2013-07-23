//
//  ColorInvertNode.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 23/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "ColorInvertNode.h"
#import <QuartzCore/QuartzCore.h>

@implementation ColorInvertNode


- (void) updateSelf
{
	[super updateSelf];
	
	FilterNode* inputNode = [_inputValues valueForKey:kFilterInputKeyInputImageNode];
	CIImage* inputImage = [[inputNode outputValues] valueForKey:kFilterOutputKeyImage];
	
	CIFilter* filter = [CIFilter filterWithName:@"CIColorInvert"];
	[filter setDefaults];
	
	// pass the output of the previous node as input image
	[filter setValue:inputImage forKey:@"inputImage"];
	
	// pass on the outputImage
	[[self outputValues] setValue:[filter valueForKey: @"outputImage"] forKey:kFilterOutputKeyImage];
}

// TODO: override setupDefaultGraphView

@end
