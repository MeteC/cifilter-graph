//
//  FilterConnectPointView.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 28/03/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

//	A connection box, subview of a FilterGraphView


#import <Cocoa/Cocoa.h>
#import "UXFilterConnectionView.h"

@class UXFilterGraphView;


/**
 * Type of connect point - an input or an output? Also differentiate if we don't know yet.
 */
typedef enum 
{ 
	UXFilterConnectPointTypeUnknown, 
	UXFilterConnectPointTypeInput, 
	UXFilterConnectPointTypeOutput 
} UXFilterConnectPointType;

@interface UXFilterConnectPointView : NSView <UXConnectionEndPointProvider>

// Both connect points on either side of a connection view can have a strong pointer to it.
// Only when both connect points let go of a connection view, will it be released.
@property (strong) UXFilterConnectionView* connectionView;

// Are we highlighted now (i.e. mouse is registered as being over us?)
@property (readonly) BOOL highlighted;

// input? output?
@property UXFilterConnectPointType type;

// weak pointer back to my graph, makes life easy
@property (weak) UXFilterGraphView* parentGraphView;

@end
