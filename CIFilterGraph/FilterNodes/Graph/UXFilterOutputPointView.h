//
//  UXFilterOutputPointView.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 6/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

//	Output Points can have multiple connections to input points, since one filter node can feed it's
//	image to any number of downstream nodes

#import "UXFilterConnectPointView.h"

@interface UXFilterOutputPointView : UXFilterConnectPointView


@property (readonly) NSMutableSet* connectionViews;

@end
