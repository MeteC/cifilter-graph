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
- (void) updateSelf
{
	[super updateSelf];
	
	FilterNode* inputNode = [_inputValues valueForKey:kFilterInputKeyInputImageNode];
	CIImage* inputImage = [[inputNode outputValues] valueForKey:kFilterOutputKeyImage];
	
	[_outputValues setValue:inputImage forKey:kFilterOutputKeyImage];
	
	// update output view. Use CIImage representation.
	if(inputImage)
	{
		NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:inputImage];
		NSImage *nsImage = [[NSImage alloc] initWithSize:rep.size];
		[nsImage addRepresentation:rep];
		
		[self.imageOutputView setImage:nsImage];
	}
	else [self.imageOutputView setImage:nil];
}


@end
