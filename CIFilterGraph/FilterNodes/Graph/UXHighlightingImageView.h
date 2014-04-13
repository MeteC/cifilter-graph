//
//  UXHighlightingImageView.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 13/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

//	An NSImageView, with an extra layer that can be used for highlighting it.

#import <Cocoa/Cocoa.h>

@interface UXHighlightingImageView : NSImageView

- (void) setHighlight:(BOOL) highlight;

@end
