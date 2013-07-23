//
//  FilterNode.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "FilterNode.h"
#import "FilterGraphView.h"

#pragma mark - Input Keys

NSString* const kFilterInputKeyInputImageNode	= @"imageInputNode";
NSString* const kFilterInputKeyFileURL			= @"imageFileURLInput";

#pragma mark - Output Keys

NSString* const kFilterOutputKeyImage			= @"imageOutput";

#pragma mark - Filter Node

@implementation FilterNode

- (id)init
{
    self = [super init];
    if (self) {
        _inputValues	= [[NSMutableDictionary alloc] init];
		_outputValues	= [[NSMutableDictionary alloc] init];

		self.verboseUpdate = UPDATE_VERBOSE_DEFAULT;
    }
    return self;
}


- (void)dealloc
{
    [_inputValues release];
	[_outputValues release];
	
	self.graphView = nil;
	
    [super dealloc];
}

- (NSMutableDictionary*) inputValues
{
	return _inputValues;
}

- (NSMutableDictionary*) outputValues
{
	return _outputValues;
}

- (void) updateSelf
{
	if(self.verboseUpdate) NSLog(@"%@ called updateSelf", self);
}

- (void) update
{
	// recurse up the tree to ensure all dependencies update first
	for(id input in self.inputValues.allValues)
	{
		if([input isKindOfClass:[FilterNode class]])
		{
			[input update];
		}
	}
	
	// once all dependencies are updated, I can do my actual update
	[self updateSelf];
}

/**
 * Should be overridden by each FilterNode subclass else they'll all end up with default FilterGraph
 */
- (void) setupDefaultGraphView
{
	FilterGraphView* testGraphViewOut = [[FilterGraphView alloc] init];
	
	self.graphView = testGraphViewOut; // retains
	testGraphViewOut.parentNode = self; // assigns
	
	[testGraphViewOut release];
}

@end