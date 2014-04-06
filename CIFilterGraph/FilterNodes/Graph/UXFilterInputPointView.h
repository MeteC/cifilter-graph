//
//  UXFilterInputPointView.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 6/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

//	Input Connect Points only have 1 connection, so if you drag on them you disrupt the associated
//	connection and make a new one.


#import "UXFilterConnectPointView.h"


@class UXFilterConnectionView;


@interface UXFilterInputPointView : UXFilterConnectPointView

// Both connect points on either side of a connection view have a strong pointers to it.
// Input Points have one only, while Output Points may have many.
// Only when both connect points let go of a connection view, will it be released.
@property (strong) UXFilterConnectionView* connectionView;

@end
