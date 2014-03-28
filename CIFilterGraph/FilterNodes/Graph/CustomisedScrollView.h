//
//  CustomisedScrollView.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 22/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

// Document view is a canvas for drawing connection arrows on..

// When this no longer draws any arrows or anything, can remove it from the project.


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