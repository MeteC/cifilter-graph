//
//  GenericEffectNode.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 21/03/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

//	The superclass of most effect filters - mostly just refactors out code replication

#import "FilterNode.h"

@interface GenericCIEffectNode : FilterNode

@property (readonly) NSString* filterName;

/**
 * Common CI Effects can use this to initialise themselves very simply, by providing their filter
 * name, and the configuration options required.
 */
- (id) initWithCIFilterName:(NSString*) mFilterName configOptions:(NSDictionary*) mConfigOptions;

@end
