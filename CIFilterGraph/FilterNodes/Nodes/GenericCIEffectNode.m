//
//  GenericEffectNode.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 21/03/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

#import "GenericCIEffectNode.h"


@implementation GenericCIEffectNode



/**
 * Common CI Effects can use this to initialise themselves very simply, by providing their filter
 * name, and the configuration options required.
 */
- (id) initWithCIFilterName:(NSString*) mFilterName configOptions:(NSDictionary*) mConfigOptions
{
    self = [super init];
    if (self) {
		
		// config options
        [_configurationOptions setValue:@"CIImage" forKey:@"inputImage"];
		
		// create the filter and set it's defaults, so we can read them out
		_filterName = mFilterName;
		CIFilter* filter = [CIFilter filterWithName:mFilterName];
		
		if(filter == nil) 
		{ 
			NSString* crashMsg = [NSString stringWithFormat:@"Crash in %s - bad CIFilter name '%@', doesn't exist as a CIFilter!", __PRETTY_FUNCTION__, mFilterName];
			[AppDelegate log:crashMsg];
			assert(filter != nil);
		}
		
		[filter setDefaults];
		
		NSEnumerator *enumerator = [mConfigOptions keyEnumerator];
		NSString* key;
		
		while ((key = [enumerator nextObject])) 
		{
			if(![key isEqualToString:@"inputImage"])
			{
				// store key and class in config options, and filter default in input values
				[_configurationOptions setValue:[mConfigOptions valueForKey:key] forKey:key];
				[_inputValues setValue:[filter valueForKey:key] forKey:key];
			}
		}
    }
    return self;
}


- (void) updateSelf
{
	[super updateSelf];
	
	// Grab the input image. We know all dependencies have been updated thanks to FilterNode's update
	// structure, so this is good.
	FilterNode* inputNode = [_inputValues valueForKey:kFilterInputKeyInputImageNode];
	CIImage* inputImage = [[inputNode outputValues] valueForKey:kFilterOutputKeyImage];
	
	CIFilter* filter = [CIFilter filterWithName:_filterName];
	[filter setDefaults];
	
	// pass the output of the previous node as input image
	[filter setValue:inputImage forKey:@"inputImage"];
	
	// other configuration setup
	NSEnumerator *enumerator = [self.configurationOptions keyEnumerator];
	NSString* key;
	
	while ((key = [enumerator nextObject])) 
	{
		id inputVal = [_inputValues valueForKey:key];
		
		// note, inputImage key returns nil from _inputValues, so the case we've already dealt with
		// doesn't get dealt with again (i.e. we don't apply FilterNode inputNode to filter key inputImage!)
		if(inputVal) 
		{
			if([inputVal isKindOfClass:[FilterNode class]])
			{
				// it's a FilterNode, so the CIFilter will want it's output CIImage
				[filter setValue:[[inputVal outputValues] valueForKey:kFilterOutputKeyImage] 
					  forKeyPath:key];
			}
			else // not a FilterNode so apply direct to CIFilter
			{
				[filter setValue:inputVal forKey:key];
			}
		}
	}
		
	//if(self.verboseUpdate) 
	//	NSLog(@"Box Blur with radius %@", [filter valueForKey:@"inputRadius"]);
	
	
	// pass on the outputImage
	[[self outputValues] setValue:[filter valueForKey: @"outputImage"] forKey:kFilterOutputKeyImage];
}

@end
