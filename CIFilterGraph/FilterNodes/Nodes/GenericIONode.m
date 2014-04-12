//
//  GenericIONode.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 12/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

#import "GenericIONode.h"

@implementation GenericIONode

#pragma mark - ListedNodeManager Delegate


/**
 * Create a filter node given the parameters in the listing.
 */
- (FilterNode*) createNodeWithName:(NSString*) name params:(NSDictionary*) params
{
	// purely obj-C class based for now.
	Class nodeClass = NSClassFromString(params[@"class_name"]);
	return [[nodeClass alloc] init];
}



/**
 * Provide a menu of all the filter name arrays in the listing, keyed by their subcategories
 * Entries that don't belong in a subcategory must be keyed against "root"
 */
- (NSDictionary*) provideAvailableFilterNamesForMgr:(ListedNodeManager*) listMgr
{
	NSMutableDictionary* retVal = [NSMutableDictionary new];
	
	[listMgr.plistDict[@"nodes"] enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary* node, BOOL *stop) 
	 {
		 // no subcategory for now..
		 NSString* subcategoryString = @"root";
		 NSMutableArray* subcategoryList = [retVal objectForKey:subcategoryString];
		 
		 // first entry in the list - create a new list!
		 if(!subcategoryList) {
			 [retVal setObject:[NSMutableArray new] forKey:subcategoryString];
			 subcategoryList = [retVal objectForKey:subcategoryString];
		 }
		 
		 [subcategoryList addObject:key];
	 }];
	
	
	return retVal;
}


@end
