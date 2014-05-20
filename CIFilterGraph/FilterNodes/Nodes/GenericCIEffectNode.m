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
			UXLog(@"Crash in %s - bad CIFilter name '%@', doesn't exist as a CIFilter!", __PRETTY_FUNCTION__, mFilterName);
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
			// TODO: Only using one input filter node for GenericCIEffectNode. Will need to extend for multiple inputs
			
			// it's a FilterNode, so the CIFilter will want it's output CIImage
			CIImage* inputImage = [[obj outputValues] valueForKey:kFilterOutputKeyImage];
			[filter setValue:inputImage forKeyPath:@"inputImage"];
			gotInputImage = (inputImage != nil);
		}
		
		else 
		{
			// Generic CI Effects have their other inputValues applied direct to the filter
			[filter setValue:obj forKey:key];
		}
	}];
	
	// pass on the outputImage if we got it
	if(gotInputImage)
	{
		[_outputValues setValue:[filter valueForKey:@"outputImage"] forKey:kFilterOutputKeyImage];
	}
	else // no work done
		[_outputValues removeObjectForKey:kFilterOutputKeyImage];
}


#pragma mark - ListedNodeManager Delegate


/**
 * Create a filter node given the parameters in the listing.
 */
- (FilterNode*) createNodeWithTitle:(NSString*) title forList:(ListedNodeManager *)listMgr
{
	__block GenericCIEffectNode* node = nil;
    
    // find the node details by traversing subcategories
    [listMgr.plistDict[@"nodes"] enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary* subcategory, BOOL *stop) {
        
        NSDictionary* nodeDict = subcategory[title];
        
        if(nodeDict) // found it
        {
            
            // expecting to find filter_name string and config_options array
            NSString* filterName	= nodeDict[@"filter_name"];
            NSArray* configOpts		= nodeDict[@"config_options"];
            
            if(filterName)
            {
                node = [[GenericCIEffectNode alloc] initWithCIFilterName:filterName configOptions:configOpts];
                node.displayName = title;
            }
            
            *stop = YES; // we got our node, don't enumerate further
        }
    }];
	
	return node;
}



/**
 * Provide a menu of all the filter name arrays in the listing, keyed by their subcategories
 * Entries that don't belong in a subcategory must be keyed against "root"
 */
- (NSDictionary*) provideAvailableFilterNamesForList:(ListedNodeManager*) listMgr
{
	NSMutableDictionary* retVal = [NSMutableDictionary new];
	
	[listMgr.plistDict[@"nodes"] enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary* subcategory, BOOL *stop)
	{
        NSMutableArray* nameList = [NSMutableArray array];
        [retVal setObject:nameList forKey:key];
        
        [subcategory enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
           
            [nameList addObject:key]; // key is the name
            
        }];
	}];
	
	return retVal;
}


@end
