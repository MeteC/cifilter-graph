//
//  UXFilterControlsFactory.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 14/04/14.
//  Copyright (c) 2014 Mete Cakman. All rights reserved.
//

#import "UXFilterControlsFactory.h"
#import "FilterNode.h"


@implementation UXFilterControlsFactory



/**
 * Code sugar to make a simple label, like a UILabel on iOS.
 */
+ (NSTextField*) makeLabelWithText:(NSString*) text
{
	NSTextField* label = [[NSTextField alloc] init];
	[label setBordered:NO];
	[label setEditable:NO];
	[label setBackgroundColor:[NSColor clearColor]];
	[label setStringValue:text];
	[label sizeToFit];
	
	return label;
}

/**
 * Creates a control panel for a given FilterNode, attaches it to a provided superview.
 * Provide a controls delegate - currently just needs NSTextFieldDelegate but may add protocols
 * as time goes on.
 */
+ (void) createControlPanelFor:(FilterNode*) node addToSuperview:(NSView*) superview controlsDelegate:(id<NSTextFieldDelegate>) delegate
{
	static const float margin = 10; // margin value
	__block float currentY = margin; // keep track of vertical layout.
	
	[node.inputValues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		
		if([obj isKindOfClass:[NSNumber class]])
		{
			// add a number field, with title
			NSTextField* label = [self makeLabelWithText:key];
			[label setFrameOrigin:CGPointMake(margin, currentY)];
			[superview addSubview:label];
			
			// add text field 
			// TODO: add number formatter?
			float currentX = margin + label.frame.size.width + margin;
			
			// !!!: Yucky magic numbers that don't move with the GUI!
			NSTextField* input = [[NSTextField alloc] initWithFrame:CGRectMake(currentX, currentY, 100, label.frame.size.height*1.2)];
			[superview addSubview:input];
			
			input.stringValue = [node.inputValues valueForKey:key];
			input.delegate = delegate;
			
			// associate the input key value with the input, so the FilterNode can look it up
			// Note: using weak references to avoid any memory loops. If there are strange crashes, try
			// OBJC_ASSOCIATION_RETAIN.. Or use a mutable association dictionary somewhere..
			objc_setAssociatedObject(input, kUIControlElementAssociatedInputKey, key,
									 OBJC_ASSOCIATION_ASSIGN);
			
			// TODO: all of this more generically
			
			currentY += input.frame.size.height + margin;
		}
		
		// NSURL as string, but with button for opening File Selector
		else if([obj isKindOfClass:[NSURL class]])
		{
			// add a string field
			NSTextField* label = [self makeLabelWithText:key];
			[label setFrameOrigin:CGPointMake(margin, currentY)];
			[superview addSubview:label];
			currentY += label.frame.size.height;
			
			// add text field 
			// !!!: Yucky magic numbers that don't move with the GUI!
			NSTextField* input = [[NSTextField alloc] initWithFrame:CGRectMake(margin, currentY, 300, label.frame.size.height*1.2)];
			[superview addSubview:input];
			currentY += input.frame.size.height + margin;
			
			input.stringValue = [node.inputValues valueForKey:key];
			input.delegate = delegate;
			
			objc_setAssociatedObject(input, kUIControlElementAssociatedInputKey, key,
									 OBJC_ASSOCIATION_ASSIGN);
			
			// Add button for file browser opening
			NSButton* fileBrowserButton = [[NSButton alloc] initWithFrame:NSMakeRect(margin, currentY, 40, 40)];
			[fileBrowserButton setImage:[NSImage imageNamed:@"NSComputer"]];
			[superview addSubview:fileBrowserButton];
			
			[fileBrowserButton setTarget:self];
			[fileBrowserButton setAction:@selector(pressFileBrowseButton:)];
			
			objc_setAssociatedObject(fileBrowserButton, kUIControlElementAssociatedInputKey, key,
									 OBJC_ASSOCIATION_ASSIGN);
			
			
			currentY += fileBrowserButton.frame.size.height + margin;
		}
		
		else if([obj isKindOfClass:[FilterNode class]]) {} // does nothing
		
		
		else {
			UXLog(@"WARNING: Config option class '%@' found - not yet implemented in setupFilterConfigPanel... (AppDelegate). So you won't see it in the filter config panel yet.", [obj className]);
		}
		
	}];
}

@end
