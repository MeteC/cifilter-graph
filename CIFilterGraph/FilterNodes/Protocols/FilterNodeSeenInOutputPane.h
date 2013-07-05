//
//  FilterNodeSeenInOutputPane.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

//	This protocol is empty at the moment, but used as a tag on FilterNode classes that should have their
//	output viewed in the GUI output view pane.

#import <Foundation/Foundation.h>

@protocol FilterNodeSeenInOutputPane <NSObject>

@required
- (NSMutableDictionary*) outputValues; // ensure it's a FilterNode

@end
