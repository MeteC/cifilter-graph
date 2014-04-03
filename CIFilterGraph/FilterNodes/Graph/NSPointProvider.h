//
//  NSPointProvider.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

//	Simple wrapper of NSPoint into a UXConnectionEndPointProvider

#import <Foundation/Foundation.h>
#import "UXFilterConnectionView.h"

@interface NSPointProvider : NSObject <UXConnectionEndPointProvider>

// This class doesn't use this itself, but fulfils the interface requirements anyway
@property (strong) UXFilterConnectionView* connectionView;

+ (instancetype) pointProvider:(NSPoint) point;

@end
