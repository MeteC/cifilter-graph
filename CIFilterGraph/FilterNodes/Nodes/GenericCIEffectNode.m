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
		
		// TODO: test bad filter names..
		
		// create the filter and set it's defaults, so we can read them out
		_filterName = mFilterName;
		CIFilter* filter = [CIFilter filterWithName:mFilterName];
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
		if(inputVal)
		{
			[filter setValue:inputVal forKey:key];
		}
	}
		
	//if(self.verboseUpdate) 
	//	NSLog(@"Box Blur with radius %@", [filter valueForKey:@"inputRadius"]);
	
	
	// pass on the outputImage
	[[self outputValues] setValue:[filter valueForKey: @"outputImage"] forKey:kFilterOutputKeyImage];
}

@end
