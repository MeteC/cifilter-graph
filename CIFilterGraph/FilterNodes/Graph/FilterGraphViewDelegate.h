//
//  FilterGraphViewDelegate.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 30/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UXFilterGraphView;

@protocol UXFilterGraphViewDelegate <NSObject>

/**
 * Indicate that this filter graph view was clicked, for further processing in the GUI
 */
- (void) clickedFilterGraph:(UXFilterGraphView*) graphView;

@end
