//
//  FilterConnectPointView.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 28/03/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

//	A connection box, subview of a FilterGraphView


#import <Cocoa/Cocoa.h>

@interface FilterConnectPointView : NSView

/**
 * Gives you a friendly end point you can use, relative to the superview of this connect point's
 * graph view.
 */
- (NSPoint) connectEndPoint;

@end
