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
#import "UXFilterGraphView.h"

#import <objc/runtime.h> // using "associated objects"


// UI elements have associated input key NSStrings, so that FilterNodes can respond directly
// to UI delegation methods (e.g. NSTextFieldDelegate). This is the key to look up the association
const char* const kUIControlElementAssociatedInputKey = "kUIControlElementAssociatedInputKey";


@interface AppDelegate ()
{
	FilterNode* outputNode; // TODO: what about multiple outputs?
	FilterNode* currentSelectedNode;
	
	NSMutableArray* currentFilterList;
}
@end

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{	
	// Insert code here to initialize your application
	[_messageLog setEditable:NO];
	
	currentFilterList = [NSMutableArray array];
	
	[_filterConfigTitle setStringValue:@""];
	[_filterConfigScrollView.documentView setFlipped:YES]; // make sure filter config layout goes top down
	
	
	
	
	
	// Testing factory
	RawImageInputFilterNode* testNodeIn = (RawImageInputFilterNode*)[FilterNodeFactory generateNodeForNodeClassName:@"RawImageInputFilterNode"];
	
	// add image file and update
	[testNodeIn setFileInputURL:[NSURL fileURLWithPath:@"/Users/mcakman/Desktop/Screenshot Dumps & Photos/alien-app-icon-1024x1024.png"]];
	
	NSLog(@"Test input dict: %@", testNodeIn.inputValues);
	
	// Filter Example
	FilterNode* testModNode = [FilterNodeFactory generateNodeForNodeClassName:@"BoxBlurNode"];
	
	// Output
	OutputViewingNode* testNodeOut = (OutputViewingNode*)[FilterNodeFactory generateNodeForNodeClassName:@"OutputViewingNode"];
	
	// connect and pass through data
	[testModNode attachInputImageNode:testNodeIn];
	[testNodeOut attachInputImageNode:testModNode];
	
	// Put graphics in right places
	[_graphScrollView.documentView addSubview:testNodeIn.graphView];
	[testModNode.graphView setFrameOrigin:NSMakePoint(200, 100)];
	[_graphScrollView.documentView addSubview:testModNode.graphView];
	[testNodeOut.graphView setFrameOrigin:NSMakePoint(400, 200)];
	[_graphScrollView.documentView addSubview:testNodeOut.graphView];
	
	// output panes..
	[_outputPaneScrollView.documentView addSubview:testNodeIn.imageOutputView];
	float xPos = testNodeIn.imageOutputView.frame.size.width + 20;
	[testNodeOut.imageOutputView setFrame:NSOffsetRect(testNodeOut.imageOutputView.frame, xPos, 0)];
	[_outputPaneScrollView.documentView addSubview:testNodeOut.imageOutputView];
	
	outputNode = testNodeOut; // keep reference to root. Since it's a pull-graph, that's the output
	
	[_outputPaneScrollView autoResizeContentView];
	
	// changed node connections so we need to update the graphs manually
	[testNodeIn.graphView resetGraphConnects];
	[testModNode.graphView resetGraphConnects];
	[testNodeOut.graphView resetGraphConnects];
	
	[self doGlobalNodeUpdate];
}

/**
 * Append a string to GUI log. Can be class method as there's only one AppDelegate instance per app.
 */
+ (void) log:(NSString *)string
{
	AppDelegate* this = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	[this.messageLog setString:[NSString stringWithFormat:@"%@%@\n", this.messageLog.string, string]];
	printf("GUI-LOG: %s\n", string.UTF8String);
}



#pragma mark - Delegate Methods

- (void) clickedFilterGraph:(UXFilterGraphView*) graphView
{
//	NSLog(@"Clicked filter graph %@", graphView);
	
	// Set up the configuration panel for the graph node
	currentSelectedNode = graphView.parentNode;
	
	NSString* filterTitle = [NSString stringWithFormat:@"Selected Filter: %@", currentSelectedNode];
	[_filterConfigTitle setStringValue:filterTitle];
	
	// go through config options and set up edit panels
	[self setupFilterConfigPanelForCurrentSelection];
	
	/*
	// memory test
	double delayInSeconds = 0.0001;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self clickedFilterGraph:graphView];
	});*/
}

/**
 * Clears out old configuration panels, reconstructs based on currently selected node.
 */
- (void) setupFilterConfigPanelForCurrentSelection
{
	[[_filterConfigScrollView.documentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	const float margin = 10; // margin value
	__block float currentY = margin; // keep track of vertical layout.
	
	// TODO: Add controlView method to FilterNode that constructs this? Rather than doing it here?
	[currentSelectedNode.inputValues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		
		if([obj isKindOfClass:[NSNumber class]])
		{
			// add a number field, with title
			NSTextField* label = [self makeLabelWithText:key];
			[label setFrameOrigin:CGPointMake(margin, currentY)];
			[_filterConfigScrollView.documentView addSubview:label];
			
			// add text field with number formatter
			float currentX = margin + label.frame.size.width + margin;
			NSTextField* input = [[NSTextField alloc] initWithFrame:CGRectMake(currentX, currentY, 100, label.frame.size.height*1.2)];
			[_filterConfigScrollView.documentView addSubview:input];
			
			input.stringValue = [currentSelectedNode.inputValues valueForKey:key];
			// text field delegate is the node
			input.delegate = self;
			
			// associate the input key value with the input, so the FilterNode can look it up
			// Note: using weak references to avoid any memory loops. If there are strange crashes, try
			// OBJC_ASSOCIATION_RETAIN.. Or use a mutable association dictionary somewhere..
			objc_setAssociatedObject(input, kUIControlElementAssociatedInputKey, key,
									 OBJC_ASSOCIATION_ASSIGN);
			
			// TODO: all of this more generically
			
			currentY += 50;
		}
		
		else if([obj isKindOfClass:[FilterNode class]]) {} // does nothing
		
		else {
			NSString* errorMessage = [NSString stringWithFormat:@"Config option class '%@' found - not yet implemented in setupFilterConfigPanel... (AppDelegate). So you won't see it in the filter config panel yet.", [obj className]];
			[AppDelegate log:errorMessage];
		}
		
	}];
	
}

#pragma mark - Helpers

/**
 * Create a node from it's class name, put it in the scene unattached to anything.
 */
- (void) createNodeForNodeClassName:(NSString*) nodeClassName
{
	FilterNode* newNode = [FilterNodeFactory generateNodeForNodeClassName:nodeClassName];
	
	if(newNode)
	{
		[currentFilterList addObject:newNode];
		
		[_graphScrollView.documentView addSubview:newNode.graphView];
		
		// TODO: find a smart place to put the new node
		[newNode.graphView setFrameOrigin:NSMakePoint(_graphScrollView.frame.size.width/2, _graphScrollView.frame.size.height/2)];
	}
}

/**
 * Code sugar to make a simple label, like a UILabel on iOS.
 */
- (NSTextField*) makeLabelWithText:(NSString*) text
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
 * Perform full update on node graph
 */
- (void) doGlobalNodeUpdate
{
	[AppDelegate log:@"Updating Filter Graph!"];
	[outputNode update];
}


#pragma mark - Text Field

/**
 * For my debug input field, process commands when ending editing. As I write this I have no commands,
 * but who knows when this might be a quickly useful test tool.
 *
 * For node inputs, (e.g. input radius value of box blur filter), we apply the control's updated value to
 * the 
 */
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	if(control == self.commandField)
	{
		// Catch returns, do debug stuff with whatever has been entered
		if([[fieldEditor string] length] != 0)
		{
			NSString* command = fieldEditor.string;
			NSLog(@"Entered command: '%@'", command);
			
			// Can do what I like with those commands now
			
			// 1. create a node using 'create NodeClassName'
			if([command hasPrefix:@"create "])
			{
				NSString* nodeClassName = [command substringFromIndex:@"create ".length];
				[self createNodeForNodeClassName:nodeClassName];
			}
			
			
			// clear and return
			fieldEditor.string = @"";
		}
	}
	
	else // it's a node input
	{
		NSString* inputKey = objc_getAssociatedObject(control, kUIControlElementAssociatedInputKey);
		id obj = [currentSelectedNode.inputValues objectForKey:inputKey];
		
		if(!inputKey) NSLog(@"ERROR: Control input has no associated input key!");
		else 
		{
			// pass on the input.. need to format it to the right class first!
			if([obj isKindOfClass:[NSNumber class]]) // is this the best way to do this?
			{
				NSNumber* num = [NSNumber numberWithDouble:fieldEditor.string.doubleValue];
				[[currentSelectedNode inputValues] setValue:num forKey:inputKey];
			}
			
			else // catchall - just pass the string
			{
				NSLog(@"--> Note to self: inputClass = %@, this isn't dealt with specifically yet in textShouldEndEditing", [obj className]);
				[[currentSelectedNode inputValues] setValue:fieldEditor.string forKey:inputKey];
			}
		}
		
		// now do an update!
		[self doGlobalNodeUpdate];
	}
	
	return YES;
}


@end
