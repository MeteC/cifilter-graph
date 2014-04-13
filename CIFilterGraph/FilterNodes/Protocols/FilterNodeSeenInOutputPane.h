//
//  FilterNodeSeenInOutputPane.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

//	Used as a tag on FilterNode classes that should have their
//	output viewed in the GUI output view pane. 

#import <Foundation/Foundation.h>

@class UXHighlightingImageView;

@protocol FilterNodeSeenInOutputPane <NSObject>

@required
- (NSMutableDictionary*) outputValues; // ensure it's a FilterNode

// does it's own updates.
@property (nonatomic, retain) UXHighlightingImageView *imageOutputView;

@end
