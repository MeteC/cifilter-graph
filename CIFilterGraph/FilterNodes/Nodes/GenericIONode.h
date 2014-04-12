//
//  GenericIONode.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 12/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

//	Provides the listing interface for listed node managers, and is the superclass to my i/o filter
//	nodes. They all conform to FilterNodeSeenInOutputPane protocol

#import "FilterNode.h"
#import "FilterNodeSeenInOutputPane.h"
#import "ListedNodeManager.h"

@interface GenericIONode : FilterNode <FilterNodeSeenInOutputPane,ListedNodeManagerDelegate>

@property (nonatomic, strong) NSImageView *imageOutputView;

@end
