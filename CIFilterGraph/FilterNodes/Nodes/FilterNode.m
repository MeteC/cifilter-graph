//
//  FilterNode.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "FilterNode.h"
#import "UXFilterGraphView.h"

#pragma mark - Input Keys

NSString* const kFilterInputKeyInputImageNode	= @"imageInputNode";
NSString* const kFilterInputKeyFileURL			= @"imageFileURLInput";

#pragma mark - Output Keys

NSString* const kFilterOutputKeyImage			= @"imageOutput";


#pragma mark - Filter Node

@implementation FilterNode

- (id)init
{
    self = [super init];
    if (self) {
        _inputValues	= [[NSMutableDictionary alloc] init];
		_outputValues	= [[NSMutableDictionary alloc] init];

		self.verboseUpdate = UPDATE_VERBOSE_DEFAULT;
		
		// default for all filter nodes to have the input image node key
		self.filterNodeTypeInputKeys = @[kFilterInputKeyInputImageNode];
    }
    return self;
}

- (void) dealloc
{
	NSLog(@"Deallocing filter node %@", [self class]);
}


- (NSString*) description
{
	return [[self class] description];
}

- (NSMutableDictionary*) inputValues
{
	return _inputValues;
}

- (NSDictionary*) outputValues
{
	return _outputValues;
}


- (void) attachInputImageNode:(FilterNode*) upstreamNode
{
	[self.inputValues setValue:upstreamNode forKey:kFilterInputKeyInputImageNode];
}

- (FilterNode*) inputImageNode
{
	return [self.inputValues valueForKey:kFilterInputKeyInputImageNode];
}

- (void) updateNode
{
	if(self.verboseUpdate) NSLog(@"%@ called updateNode", self);
}

/**
 * Should be overridden by each FilterNode subclass else they'll all end up with default FilterGraph
 TODO: Remove this from FilterNode completely so it's graphics agnostic.
 */
- (void) setupDefaultGraphView
{
	UXFilterGraphView* testGraphViewOut = [[UXFilterGraphView alloc] init];
	
	self.graphView = testGraphViewOut; // strong
	testGraphViewOut.parentNode = self; // weak
	
	// set delegate to main app delegate, easily accessed as singleton.
	id<UXFilterGraphViewDelegate> mainAppDelegate = (id<UXFilterGraphViewDelegate>)[[NSApplication sharedApplication] delegate];
	testGraphViewOut.delegate = mainAppDelegate;
	
}


#pragma mark - Templatey Stuff


/**
 * A general case CIFilter application from BoysNoize app (iOS). Note a few changes are required for Mac,
 * i.e. the outputImage property doesn't exist on filters, use [filter valueForKey:@"outputImage"] instead.
 */

/*
- (UIImage*) useCIFilterOnImage:(UIImage*) image 
					 filterName:(NSString*) filterName 
			filterKeysAndValues:(NSDictionary*) keysAndValues
{
	CIImage *beginImage = [CIImage imageWithCGImage:image.CGImage];
	
	CIFilter* bob = [CIFilter filterWithName:filterName];
	[bob setDefaults];
	
	[bob setValue:beginImage forKey:@"inputImage"];
	
	for(NSString* key in keysAndValues.allKeys)
	{
		[bob setValue:[keysAndValues valueForKey:key] forKey:key];
	}
	
	CIImage* output = bob.outputImage;
	
	// be sure to crop as the new image might actually be bigger
	output =[output imageByCroppingToRect:CGRectMake(0, 0, 
													 image.size.width * image.scale, 
													 image.size.height * image.scale)];
	
	CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgiimage = [context createCGImage:output fromRect:output.extent];
    UIImage *newImage = [UIImage imageWithCGImage:cgiimage 
											scale:image.scale 
									  orientation:UIImageOrientationUp];
	
    CGImageRelease(cgiimage);
	
    return newImage;
}
 */

@end

