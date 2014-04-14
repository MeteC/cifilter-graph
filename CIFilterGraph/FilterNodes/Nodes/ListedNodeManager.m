//
//  ListedNodeManager
//  CIFilterGraph
//
//  Created by Mete Cakman on 7/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

#import "ListedNodeManager.h"

@interface ListedNodeManager ()

// strong because I always need the instance to create filter nodes
@property (strong) id<ListedNodeManagerDelegate> delegate;
@end


@implementation ListedNodeManager


- (instancetype) initWithPlist:(NSString *)plistFilename 
					  ownedDelegate:(id<ListedNodeManagerDelegate>)delegate
{
	self = [super init];
    if (self) {
        
		_delegate = delegate;
		
		NSString* filepath = [[NSBundle mainBundle] pathForResource:plistFilename ofType:nil];
		
		NSAssert1(filepath != nil, @"FAIL: tried to init NodePlistManager with non-existant plist file %@", plistFilename);
		
		_plistDict = [NSDictionary dictionaryWithContentsOfFile:filepath];
		
		
    }
    return self;
}

- (NSString*) plistDisplayName
{
	return _plistDict[@"meta"][@"display_name"];
}

- (FilterNode*) createFilterNodeForNameKey:(NSString*) nodeName
{
	FilterNode* retVal = nil;
	
	NSDictionary* nodeDict = _plistDict[@"nodes"][nodeName];
	
	if(nodeDict)
	{
		// use delegate to create smart FilterNode
		retVal = [self.delegate createNodeWithName:nodeName params:nodeDict];
	}
	
	return retVal;
}

- (NSDictionary*) availableFilterNames
{
	return [self.delegate provideAvailableFilterNamesForMgr:self];
}

@end