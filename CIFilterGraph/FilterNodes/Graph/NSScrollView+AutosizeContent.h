//
//  NSScrollView+AutosizeContent.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 23/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

//	Category on NSScrollView to allow autosizing content view more easily

#import <Cocoa/Cocoa.h>

@interface NSScrollView (AutosizeContent)

// based on it's children, set content size automatically
- (void) autoResizeContentView;

@end
