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
- (void) updateNode
{
	[super updateNode];
	
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
		
		//[self.imageOutputView setImage:[self processedNSImageFromCIImage:inputImage]];
	}
	else [self.imageOutputView setImage:nil];
}


/**
 * Work in progress on one way to get a CIImage into an NSImage, in principle doing all the filtering
 * (CIFilter is lazy). I'm not completely satisfied yet..
 */
- (NSImage*) processedNSImageFromCIImage:(CIImage*) input
{
	// gonna create a CGImage from the CIImage, to ensure all processing is done just once,
	// then set up an NSImage wrapper around that CGImage and pass it back
	CGSize imageSize = [input extent].size;
	
	UInt32* myData = (UInt32*)malloc(imageSize.width*imageSize.height*4);
	
	CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef myDrawContext = CGBitmapContextCreate(myData, imageSize.width, imageSize.height, 8, imageSize.width*4, myColorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
	
	CIContext* ciContext = [CIContext contextWithCGContext:myDrawContext options:nil];
	
	CGRect bounds = {CGPointZero,imageSize};
	CGImageRef cgImage = [ciContext createCGImage:input fromRect:bounds];
	
	NSImage* retVal = [[NSImage alloc] initWithCGImage:cgImage size:imageSize];
	
	
	CFRelease(myDrawContext);
	CFRelease(myColorSpace);
	free(myData);
	
	return retVal;
}

@end
