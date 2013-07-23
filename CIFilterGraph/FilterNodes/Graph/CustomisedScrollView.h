//
//  CustomisedScrollView.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 22/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

// Has function for auto-resizing based on children positions.
// Document view is a canvas for drawing connection arrows on..


#import <Cocoa/Cocoa.h>

@interface CustomisedScrollView : NSScrollView
{
	
}

@end


/**
 * Acts as canvas for drawing connections between filter nodes (which sit as its subviews)
 */
@interface CustomisedDocumentView : NSView
{
	
}

@end