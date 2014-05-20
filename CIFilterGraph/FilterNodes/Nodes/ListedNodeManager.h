//
//  ListedNodeManager
//  CIFilterGraph
//
//  Created by Mete Cakman on 7/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

//	Loads a plist of node descriptors, stores the data and maybe has useful "code-sugar" methods. If this is proving next to useless, can remove it later to minimise class count..

//	The idea is that each plist represents one 'submenu' worth of nodes. E.g. I'm starting with GenericCIEffectNode.

#import <Foundation/Foundation.h>

@class FilterNode;
@class ListedNodeManager;


/**
 * So that the Listed Node Managers can create their own filter nodes using nothing but the very
 * plastic description strings inside them, for each manager I'll assign a delegate instance of 
 * a class that knows how to actually create the different generic types. This will in practice be
 * an instance of the very generic class in question.
 */
@protocol ListedNodeManagerDelegate <NSObject>

/**
 * Create a filter node given its title.
 */
- (FilterNode*) createNodeWithTitle:(NSString*) title forList:(ListedNodeManager*) listMgr;

/**
 * Provide a menu of all the filter name arrays in the listing, keyed by their subcategories
 * Entries that don't belong in a subcategory must be keyed against "root"
 */
- (NSDictionary*) provideAvailableFilterNamesForList:(ListedNodeManager*) listMgr;

@end







@interface ListedNodeManager : NSObject

// Initialise with a node plist file and an owned delegate (strong retention)
- (instancetype) initWithPlist:(NSString*) plistFilename 
					  ownedDelegate:(id<ListedNodeManagerDelegate>) delegate;

// The plist data in dictionary form
@property (nonatomic, readonly) NSDictionary* plistDict;

// The display name as specified in the meta data
- (NSString*) plistDisplayName;

/**
 * Attempt to make a FilterNode from the directory with a given nodes key.
 */
- (FilterNode*) createFilterNodeForNameKey:(NSString*) nodeName;

/**
 * Provide a menu of filter name arrays, keyed by their subcategory
 * Entries that don't sit in a subcategory (rather in the top level) are keyed against "root"
 */
- (NSDictionary*) availableFilterNames;

@end
