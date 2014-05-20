//
//  UXFilterControlsFactory.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 14/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

//	Another factory class, this one creates the control panel you see on the right-hand side of the
//	main app. This code was in AppDelegate but in the interests of leaner classes I'm creating this
//	factory class.

#import <Foundation/Foundation.h>

@class FilterNode;


/**
 * My controls delegate extends other protocols...
 */
@protocol UXControlsDelegate <NSTextFieldDelegate>

/**
 * Used for file-browse button clicks
 */
- (void) pressFileBrowseButton:(NSButton*) button;

@end


@interface UXFilterControlsFactory : NSObject


/**
 * Creates a control panel for a given FilterNode, attaches it to a provided superview.
 * Provide a controls delegate - currently just needs NSTextFieldDelegate but may add protocols
 * as time goes on.
 */
+ (void) createControlPanelFor:(FilterNode*) node 
				addToSuperview:(NSView*) superview
			  controlsDelegate:(id<UXControlsDelegate>) delegate;


@end
