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

@class UXFilterConnectPointView;


@interface UXFilterConnectionView : NSView


// Graph views connected. weak pointers to input and output connect points here.
@property (weak) UXFilterConnectPointView* outputConnectPoint;
@property (weak) UXFilterConnectPointView* inputConnectPoint; 

/**
 * When a related filter graph redraws itself, this is called to ensure the connection is updated too.
 */
- (void) updateConnection;

@end
