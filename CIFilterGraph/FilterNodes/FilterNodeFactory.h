//
//  FilterNodeFactory.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 23/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

/*
 
 Used to create given node types. Creates their graph as well.
 
 */

#import <Foundation/Foundation.h>

@class FilterNode;

@interface FilterNodeFactory : NSObject


/**
 * Chuck a class name string in, get the filter node out, with it's associated filter graph
 * already set up, and if it's an output pane implementer, it's NSImageView attached too.
 */
+ (FilterNode*) generateNodeForNodeClassName:(NSString*) nodeClassName;


@end
