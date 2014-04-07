//
//  GenericEffectNode.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 21/03/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

#import "GenericCIEffectNode.h"


@implementation GenericCIEffectNode

- (NSString*) description
{
	// return display name or filter name if no display name attached
	return self.displayName ?: self.filterName;
}

/**
 * Common CI Effects can use this to initialise themselves very simply, by providing their filter
 * name, and the configuration options required.
 */
- (id) initWithCIFilterName:(NSString*) mFilterName configOptions:(NSArray*) mConfigKeys
{
    self = [super init];
    if (self) {
		
		// create the filter and set it's defaults, so we can read them out
		_filterName = mFilterName;
		CIFilter* filter = [CIFilter filterWithName:mFilterName];
		
		if(filter == nil) 
		{ 
			NSString* crashMsg = [NSString stringWithFormat:@"Crash in %s - bad CIFilter name '%@', doesn't exist as a CIFilter!", __PRETTY_FUNCTION__, mFilterName];
			[AppDelegate log:crashMsg];
			assert(filter != nil);
		}
		
		// defaults
		[filter setDefaults];
		
		[mConfigKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[_inputValues setValue:[filter valueForKey:obj] forKey:obj];
		}];
		
    }
    return self;
}


- (void) updateNode
{
	[super updateNode];
	
	// Make the corresponding CIFilter
	CIFilter* filter = [CIFilter filterWithName:_filterName];
	[filter setDefaults];
	
	__block BOOL gotInputImage = NO;
	
	// other configuration setup
	[self.inputValues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		
		if([key isEqualToString:kFilterInputKeyInputImageNode]) // input node case
		{
			// it's a FilterNode, so the CIFilter will want it's output CIImage
			[filter setValue:[[obj outputValues] valueForKey:kFilterOutputKeyImage] 
				  forKeyPath:@"inputImage"];
			gotInputImage = YES;
		}
		
		else 
		{
			// Generic CI Effects have their other inputValues applied direct to the filter
			[filter setValue:obj forKey:key];
		}
	}];
	
	// pass on the outputImage if we got it
	if(gotInputImage)
		[_outputValues setValue:[filter valueForKey:@"outputImage"] forKey:kFilterOutputKeyImage];
	
	else // no work done
		[_outputValues removeObjectForKey:kFilterOutputKeyImage];
}


#pragma mark - ListedNodeManager Delegate


/**
 * Create a filter node given the parameters in the listing.
 */
- (FilterNode*) createNodeWithName:(NSString*) name params:(NSDictionary*) params
{
	GenericCIEffectNode* node = nil;
	
	// expecting to find filter_name string and config_options array
	NSString* filterName	= params[@"filter_name"];
	NSArray* configOpts		= params[@"config_options"];
	
	if(filterName)
	{
		node = [[GenericCIEffectNode alloc] initWithCIFilterName:filterName configOptions:configOpts];
		node.displayName = name;
	}
	return node;
}

@end
