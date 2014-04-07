//
//  GenericEffectNode.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 21/03/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

//	The base class of most CI effect filters - refactors out code replication and allows for node "classes" to be set up using a plist (i.e. runtime setup), which can also be used to set up GUI menus etc.

//	TODO: add availability to listed CI Effect Nodes. e.g. a dictionary with {'iOS' : '6.0', 'OSX' : '10.4'}

#import "FilterNode.h"
#import "ListedNodeManager.h"


@interface GenericCIEffectNode : FilterNode <ListedNodeManagerDelegate>

@property (readonly) NSString* filterName;
@property NSString* displayName; // if different from filterName

/**
 * Common CI Effects can use this to initialise themselves very simply, by providing their filter
 * name, and the CIFilter keys required. Default values will be pulled direct from the filter,
 * so just storing an array of config keys.
 */
- (id) initWithCIFilterName:(NSString*) mFilterName configOptions:(NSArray*) mConfigKeys;

@end
