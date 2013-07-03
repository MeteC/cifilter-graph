//
//  AppDelegate.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "AppDelegate.h"

#import "FilterNode.h"
#import "RawImageInputFilterNode.h"
#import "OutputViewingNode.h"

@interface AppDelegate ()
{
	
}
@end

@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	
	
	// Testing input
	RawImageInputFilterNode* testNodeIn = [[RawImageInputFilterNode alloc] init];
	
	// add image file and update
	[testNodeIn setFileInputURL:[NSURL fileURLWithPath:@"/Users/mcakman/Desktop/Screen Shot 2013-06-28 at 2.01.47 PM.png"]];
	
	[testNodeIn update];
	NSLog(@"Test input dict: %@", testNodeIn.inputValues);
	
	// output
	OutputViewingNode* testNodeOut = [[OutputViewingNode alloc] init];
	
	// make connection
	[testNodeOut.inputValues setValue:testNodeIn forKey:kFilterInputKeyInputImageNode];
	
	[testNodeOut update];
	NSLog(@"Test output dict: %@", testNodeOut.outputValues);
}



#pragma mark - Delegate Methods

#pragma mark - Text Field

/**
 * For my debug input field, process commands when ending editing. As I write this I have no commands,
 * but who knows when this might be a quickly useful test tool.
 */
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	// Catch returns, do debug stuff with whatever has been entered
	if([[fieldEditor string] length] != 0)
	{
		NSString* command = fieldEditor.string;
		NSLog(@"Entered command: '%@'", command);
		
		// Can do what I like with those commands now
		
		// clear and return
		fieldEditor.string = @"";
	}
	
	return YES;
}

@end
