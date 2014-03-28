//
//  FilterNode.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

//	The superclass of all filter nodes. Also contains handy keys list

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h> // using "associated objects"

@class FilterGraphView;

#define UPDATE_VERBOSE_DEFAULT YES // change this to NO eventually


@interface FilterNode : NSObject
{
	NSMutableDictionary* _outputValues;
	NSMutableDictionary* _inputValues;
	
	NSMutableDictionary* _configurationOptions;
}

@property (nonatomic, assign) BOOL verboseUpdate; // print stuff on each update

/**
 * Each FilterNode has an associated graph view with which it can be configured graphically.
 * If a subclass doesn't have it's own custom one, this will default to a basic rectangle with textual info. 
 * This is also set by the setupDefaultGraphView method.
 *
 * Remember - you need to set parentNode on the graphView you're assigning! Tried syncing automatically,
 * but this brings complexity in that might not be immediately obvious in case of bugs.
 */
@property (nonatomic, strong) FilterGraphView *graphView;

/**
 * Set up by each node class, reflects the configuration requirements of the node.
 * Keys = inputValue keys, Values = classname of input.
 * e.g. "inputRadius" : "NSNumber" , or "inputImage" : "CIImage"
 *
 * Primary use for this is interrogating a filter node for how to set up it's configuration panel.
 */
- (NSDictionary*) configurationOptions;

/**
 * Each node has a dictionary of potential output values. Image filters will have an output image,
 * data filters will have vectors, numbers, etc.
 *
 * Because of the "pull" design of the graph, output values should only ever be read (externally).
 */
- (NSDictionary*) outputValues;

/**
 * Each node has 1 or more FilterNode inputs, which it knows how to use. Dictionary keys helpfully listed
 * below as extern consts.
 *
 * Because the graph is implemented on a "pull" design, use inputValues to connect nodes together.
 */
- (NSMutableDictionary*) inputValues;

/**
 * Update the filter node, processing the input values through the appropriate algorithm and presenting
 * the result in outputValues. Only updates this node. This is what node subclasses should implement.
 */
- (void) updateSelf;

/**
 * Travels backwards up the hierarchy, calling update on all nodes connected as inputs to this one.
 * i.e. an output node could call this to be sure all it's dependencies were updated as well.
 */
- (void) update;

/**
 * Sets up a graph view for this node, based on its default properties. If you want to you can set up your
 * own external graph view, and attach it by setting this node as it's parent node.
 */
- (void) setupDefaultGraphView;

/**
 * Sets the "inputImage" provider node for this node. A convenience method really, as the same effect
 * can be achieved using the inputValues dictionary directly, but this gets called a lot.
 */
- (void) attachInputImageNode:(FilterNode*) upstreamNode;

/**
 * Comparable convenience method to get inputImage provider
 */
- (FilterNode*) inputImageNode;


// Keys list
#pragma mark - Input Keys

// references the fundamental input node providing input image. FilterNode type.
extern NSString* const kFilterInputKeyInputImageNode;

// the file URL for a raw input image. NSURL type.
extern NSString* const kFilterInputKeyFileURL;


#pragma mark - Output Keys

// the fundamental output image (CIImage)
extern NSString* const kFilterOutputKeyImage;



@end
