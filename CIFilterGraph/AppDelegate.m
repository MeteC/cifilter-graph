//
//  AppDelegate.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "AppDelegate.h"
#import "FilterNodeFactory.h"
#import "NSScrollView+AutosizeContent.h"

#import "FilterNode.h"
#import "RawImageInputFilterNode.h"
#import "OutputViewingNode.h"
#import "FilterGraphView.h"


@interface AppDelegate ()
{
	FilterNode* currentSelectedNode;
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
	
	[_filterConfigTitle setStringValue:@""];
	[_filterConfigScrollView.documentView setFlipped:YES]; // make sure filter config layout goes top down
	
	// Testing factory
	RawImageInputFilterNode* testNodeIn = [(RawImageInputFilterNode*)[FilterNodeFactory generateNodeForNodeClassName:@"RawImageInputFilterNode"] retain];
	
	// add image file and update
	[testNodeIn setFileInputURL:[NSURL fileURLWithPath:@"/Users/mcakman/Desktop/Screenshot Dumps & Photos/5055546_700b_v2.jpg"]];
	
	NSLog(@"Test input dict: %@", testNodeIn.inputValues);
	
	// Filter Example
	FilterNode* invertNode = [FilterNodeFactory generateNodeForNodeClassName:@"BoxBlur"];
	
	// Output
	OutputViewingNode* testNodeOut = [(OutputViewingNode*)[FilterNodeFactory generateNodeForNodeClassName:@"OutputViewingNode"] retain];
	
	// connect and pass through data
	[invertNode attachInputImageNode:testNodeIn];
	[testNodeOut attachInputImageNode:invertNode];
	[testNodeOut update];
	
	// Put graphics in right places
	[_graphScrollView.documentView addSubview:testNodeIn.graphView];
	[invertNode.graphView setFrameOrigin:NSMakePoint(100, 100)];
	[_graphScrollView.documentView addSubview:invertNode.graphView];
	[testNodeOut.graphView setFrameOrigin:NSMakePoint(200, 200)];
	[_graphScrollView.documentView addSubview:testNodeOut.graphView];
	
	// output panes..
	[_outputPaneScrollView.documentView addSubview:testNodeIn.imageOutputView];
	float xPos = testNodeIn.imageOutputView.frame.size.width + 20;
	[testNodeOut.imageOutputView setFrame:NSOffsetRect(testNodeOut.imageOutputView.frame, xPos, 0)];
	[_outputPaneScrollView.documentView addSubview:testNodeOut.imageOutputView];
	
	[_outputPaneScrollView autoResizeContentView];
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

- (void) clickedFilterGraph:(FilterGraphView*) graphView
{
	NSLog(@"Clicked filter graph %@", graphView);
	
	// Set up the configuration panel for the graph node
	currentSelectedNode = graphView.parentNode;
	
	NSString* filterTitle = [NSString stringWithFormat:@"Selected Filter: %@", currentSelectedNode];
	[_filterConfigTitle setStringValue:filterTitle];
	
	// go through config options and set up edit panels
	[self setupFilterConfigPanelForCurrentSelection];
}

/**
 * Clears out old configuration panels, reconstructs based on currently selected node.
 */
- (void) setupFilterConfigPanelForCurrentSelection
{
	[[_filterConfigScrollView.documentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	const float margin = 10; // margin value
	float currentY = margin; // keep track of vertical layout.
	
	for(NSString* key in currentSelectedNode.configurationOptions.allKeys)
	{
		NSString* className = [currentSelectedNode.configurationOptions valueForKey:key];
		
		if([className isEqualToString:@"NSNumber"])
		{
			// add a number field, with title
			NSTextField* label = [self makeLabelWithText:key];
			[label setFrameOrigin:CGPointMake(margin, currentY)];
			[_filterConfigScrollView.documentView addSubview:label];
			
			// add text field with number formatter
			float currentX = margin + label.frame.size.width + margin;
			NSTextField* input = [[NSTextField alloc] initWithFrame:CGRectMake(currentX, currentY, 100, label.frame.size.height*1.2)];
			[_filterConfigScrollView.documentView addSubview:input];
			[input release];
			
			// TODO: all of this more generically
			
			currentY += 50;
		}
		
		else if([className isEqualToString:@"CIImage"]) {} // does nothing
		
		else {
			NSString* errorMessage = [NSString stringWithFormat:@"Config option class '%@' found - not yet implemented in setupFilterConfigPanel... (AppDelegate). So you won't see it in the filter config panel yet.", className];
			[AppDelegate log:errorMessage];
		}
	}
}

#pragma mark - Helpers

- (NSTextField*) makeLabelWithText:(NSString*) text
{
	NSTextField* label = [[[NSTextField alloc] init] autorelease];
	[label setBordered:NO];
	[label setEditable:NO];
	[label setBackgroundColor:[NSColor clearColor]];
	[label setStringValue:text];
	[label sizeToFit];
	
	return label;
}
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
		
		// TODO: A set command that sets, for the selected filter node, one of the input values
		// perhaps just start with nsnumbers.. 
		
		// clear and return
		fieldEditor.string = @"";
	}
	
	return YES;
}

@end
