//
//  AppDelegate.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "AppDelegate.h"
#import "FilterNodeFactory.h"


#import "FilterNode.h"
#import "RawImageInputFilterNode.h"
#import "OutputViewingNode.h"
#import "FilterGraphView.h"


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
	[_messageLog setEditable:NO];
	
	// Testing factory
	RawImageInputFilterNode* testNodeIn = [(RawImageInputFilterNode*)[FilterNodeFactory generateNodeForNodeClassName:@"RawImageInputFilterNode"] retain];
	
	// add image file and update
	[testNodeIn setFileInputURL:[NSURL fileURLWithPath:@"/Users/mcakman/Desktop/Screenshot Dumps & Photos/5055546_700b_v2.jpg"]];
	
	[testNodeIn update];
	NSLog(@"Test input dict: %@", testNodeIn.inputValues);
	
	
	OutputViewingNode* testNodeOut = [(OutputViewingNode*)[FilterNodeFactory generateNodeForNodeClassName:@"OutputViewingNode"] retain];
	
	// connect and pass through data
	[testNodeOut.inputValues setValue:testNodeIn forKey:kFilterInputKeyInputImageNode];
	[testNodeOut update];
	
	// Put graphics in right places
	[_graphScrollView.documentView addSubview:testNodeIn.graphView];
	[testNodeOut.graphView setFrameOrigin:NSMakePoint(200, 200)];
	[_graphScrollView.documentView addSubview:testNodeOut.graphView];
	
	// output panes..
	[_outputPaneScrollView.documentView addSubview:testNodeIn.imageOutputView];
	float xPos = testNodeIn.imageOutputView.frame.size.width + 20;
	[testNodeOut.imageOutputView setFrame:NSOffsetRect(testNodeOut.imageOutputView.frame, xPos, 0)];
	[_outputPaneScrollView.documentView addSubview:testNodeOut.imageOutputView];
	
}

/**
 * Append a string to GUI log. Can be class method as there's only one AppDelegate instance per app.
 */
+ (void) log:(NSString *)string
{
	AppDelegate* this = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	[this.messageLog setString:[NSString stringWithFormat:@"%@%@\n", this.messageLog.string, string]];
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
