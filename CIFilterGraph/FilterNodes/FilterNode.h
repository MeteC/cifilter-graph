//
//  FilterNode.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

//	The superclass of all filter nodes. Also contains handy keys list

#import <Foundation/Foundation.h>

@class FilterGraphView;

#define UPDATE_VERBOSE_DEFAULT YES // change this to NO eventually

@interface FilterNode : NSObject
{
	NSMutableDictionary* _outputValues;
	NSMutableDictionary* _inputValues;
}

@property (nonatomic, assign) BOOL verboseUpdate; // print stuff on each update

/**
 * Each FilterNode has an associated graph view with which it can be configured graphically.
 * If a subclass doesn't have it's own custom one, this will default to a basic rectangle with textual info. 
 * This is set when you set this node as parentNode to a graphView object.
 */
@property (nonatomic, readonly) FilterGraphView *graphView;

/**
 * Each node has a dictionary of potential output values. Image filters will have an output image,
 * data filters will have vectors, numbers, etc
 */
- (NSMutableDictionary*) outputValues;

/**
 * Each node has 1 or more FilterNode inputs, which it knows how to use. Dictionary keys helpfully listed
 * below as extern consts.
 */
- (NSMutableDictionary*) inputValues;

/**
 * Update the filter node, processing the input nodes through the appropriate algorithm and presenting
 * the result in outputValues.
 */
- (void) update;


// Keys list
#pragma mark - Input Keys

// references the fundamental input node providing input image. FilterNode type.
extern NSString* const kFilterInputKeyInputImageNode;

// the file URL for a raw input image. NSURL type.
extern NSString* const kFilterInputKeyFileURL;


#pragma mark - Output Keys

// the fundamental output image
extern NSString* const kFilterOutputKeyImage;



@end
