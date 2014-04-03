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
@class UXFilterConnectionView;

/**
 * Connections use two end point providers to get their end points.
 */
@protocol UXConnectionEndPointProvider <NSObject>

- (NSPoint) endPoint;
@property (strong) UXFilterConnectionView* connectionView; // an end point retains a hold on it's connection

@end



/**
 * The Connection View
 */
@interface UXFilterConnectionView : NSView


// Graph views connected. weak pointers to input and output providers
@property (weak) id<UXConnectionEndPointProvider> outputPointProvider;
@property (weak) id<UXConnectionEndPointProvider> inputPointProvider; 

/**
 * When a related filter graph redraws itself, this is called to ensure the connection is updated too.
 */
- (void) updateConnection;

/**
 * Provide one of the end points, this will give you the other one, or nil if there isn't another one.
 * If you give an end point that doesn't belong here, you'll also get nil, but in debug mode it will
 * crash.
 */
- (id<UXConnectionEndPointProvider>) oppositeConnectPointFrom:(id<UXConnectionEndPointProvider>) connectPointProvider;

/**
 * Similarly helpful setter method
 */
- (void) setOppositeConnectPointFrom:(id<UXConnectionEndPointProvider>) connectPointProvider 
								toBe:(id<UXConnectionEndPointProvider>) newConnectPointProvider;

@end
