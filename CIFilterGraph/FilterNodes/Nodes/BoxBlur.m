//
//  BoxBlur.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 30/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "BoxBlur.h"

@implementation BoxBlur

- (id)init
{
    self = [super init];
    if (self) {
        [_configurationOptions setValue:@"CIImage" forKey:@"inputImage"];
        [_configurationOptions setValue:@"NSNumber" forKey:@"inputRadius"];
    }
    return self;
}


- (void) updateSelf
{
	[super updateSelf];
	
	FilterNode* inputNode = [_inputValues valueForKey:kFilterInputKeyInputImageNode];
	CIImage* inputImage = [[inputNode outputValues] valueForKey:kFilterOutputKeyImage];
	
	CIFilter* filter = [CIFilter filterWithName:@"CIBoxBlur"];
	[filter setDefaults];
	
	// pass the output of the previous node as input image
	[filter setValue:inputImage forKey:@"inputImage"];
	
	// other configuration
	NSNumber* inputRadius = [_inputValues valueForKey:@"inputRadius"];
	if(inputRadius)
		[filter setValue:inputRadius forKey:@"inputRadius"];
	
	
	if(self.verboseUpdate) 
		NSLog(@"Box Blur with radius %@", [filter valueForKey:@"inputRadius"]);
	
	
	// pass on the outputImage
	[[self outputValues] setValue:[filter valueForKey: @"outputImage"] forKey:kFilterOutputKeyImage];
}

// TODO: override setupDefaultGraphView


@end
