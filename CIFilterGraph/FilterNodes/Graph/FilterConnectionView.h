//
//  FilterConnectionView.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 28/03/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

//	A graphical link between FilterGraphViews. Dynamically rearranges it's frame and drawn content
//	as graph views move about.


#import <Cocoa/Cocoa.h>

@class FilterConnectPointView;


@interface FilterConnectionView : NSView


// Graph views connected. strong retention by each graph view, weak pointers from here.
@property (weak) FilterConnectPointView* outputGraphConnect;
@property (weak) FilterConnectPointView* inputGraphConnect; 

/**
 * When a related filter graph redraws itself, this is called to ensure the connection is updated too.
 */
- (void) updateConnection;

@end
