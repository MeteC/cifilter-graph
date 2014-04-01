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
	RawImageInputFilterNode* testNodeIn = (RawImageInputFilterNode*)[self createNodeForNodeClassName:@"RawImageInputFilterNode"];
	
	// add image file and update
	[testNodeIn setFileInputURL:[NSURL fileURLWithPath:@"/Users/mcakman/Desktop/Screenshot Dumps & Photos/alien-app-icon-1024x1024.png"]];
	
	NSLog(@"Test input dict: %@", testNodeIn.inputValues);
	
	// Filter Example
	FilterNode* testModNode = [self createNodeForNodeClassName:@"BoxBlurNode"]; //[FilterNodeFactory generateNodeForNodeClassName:@"BoxBlurNode"];
	
	// Output
	OutputViewingNode* testNodeOut = (OutputViewingNode*)[self createNodeForNodeClassName:@"OutputViewingNode"];
	
	// connect and pass through data
	[testModNode attachInputImageNode:testNodeIn];
	[testNodeOut attachInputImageNode:testModNode];
	
	// Put graphics in right places
	[testNodeIn.graphView setFrameOrigin:NSMakePoint(0, 200)];
	[testModNode.graphView setFrameOrigin:NSMakePoint(200, 100)];
	[testNodeOut.graphView setFrameOrigin:NSMakePoint(400, 200)];
	
	// output panes..
	[_outputPaneScrollView.documentView addSubview:testNodeIn.imageOutputView];
	float xPos = testNodeIn.imageOutputView.frame.size.width + 20;
	[testNodeOut.imageOutputView setFrame:NSOffsetRect(testNodeOut.imageOutputView.frame, xPos, 0)];
	[_outputPaneScrollView.documentView addSubview:testNodeOut.imageOutputView];
	
	outputNode = testNodeOut; // keep reference to root. Since it's a pull-graph, that's the output
	
	[_outputPaneScrollView autoResizeContentView];
	
	
	// We've connected them, so reset the connect points
	[testNodeIn.graphView resetGraphConnectsOnSuperview:_graphScrollView.documentView];
	[testModNode.graphView resetGraphConnectsOnSuperview:_graphScrollView.documentView];
	[testNodeOut.graphView resetGraphConnectsOnSuperview:_graphScrollView.documentView];
	
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
	
	// Note I'm using defaults to set up controls. It's important that all FilterNodes have full inputValue
	// defaults set up on initialisation!
	[currentSelectedNode.inputValues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		
		if([obj isKindOfClass:[NSNumber class]])
		{
			// add a number field, with title
			NSTextField* label = [self makeLabelWithText:key];
			[label setFrameOrigin:CGPointMake(margin, currentY)];
			[_filterConfigScrollView.documentView addSubview:label];
			
			// add text field 
			// TODO: add number formatter?
			float currentX = margin + label.frame.size.width + margin;
			
			// !!!: Yucky magic numbers that don't move with the GUI!
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
			
			currentY += input.frame.size.height + margin;
		}
		
		// TODO: NSURL as string input but with button for opening File Selector
		else if([obj isKindOfClass:[NSURL class]])
		{
			// add a string field
			NSTextField* label = [self makeLabelWithText:key];
			[label setFrameOrigin:CGPointMake(margin, currentY)];
			[_filterConfigScrollView.documentView addSubview:label];
			currentY += label.frame.size.height;
			
			// add text field 
			// !!!: Yucky magic numbers that don't move with the GUI!
			NSTextField* input = [[NSTextField alloc] initWithFrame:CGRectMake(margin, currentY, 300, label.frame.size.height*1.2)];
			[_filterConfigScrollView.documentView addSubview:input];
			currentY += input.frame.size.height + margin;
			
			input.stringValue = [currentSelectedNode.inputValues valueForKey:key];
			// text field delegate is the node
			input.delegate = self;
			
			objc_setAssociatedObject(input, kUIControlElementAssociatedInputKey, key,
									 OBJC_ASSOCIATION_ASSIGN);
			
			// Add button for file browser opening
			NSButton* fileBrowserButton = [[NSButton alloc] initWithFrame:NSMakeRect(margin, currentY, 40, 40)];
			[fileBrowserButton setImage:[NSImage imageNamed:@"NSComputer"]];
			[_filterConfigScrollView.documentView addSubview:fileBrowserButton];
			
			[fileBrowserButton setTarget:self];
			[fileBrowserButton setAction:@selector(pressFileBrowseButton:)];
			
			objc_setAssociatedObject(fileBrowserButton, kUIControlElementAssociatedInputKey, key,
									 OBJC_ASSOCIATION_ASSIGN);
			
			
			// TODO: all of this more generically
			
			currentY += fileBrowserButton.frame.size.height + margin;
		}
		
		else if([obj isKindOfClass:[FilterNode class]]) {} // does nothing
		
		
		else {
			NSString* errorMessage = [NSString stringWithFormat:@"WARNING: Config option class '%@' found - not yet implemented in setupFilterConfigPanel... (AppDelegate). So you won't see it in the filter config panel yet.", [obj className]];
			[AppDelegate log:errorMessage];
		}
		
	}];
	
}

#pragma mark - Helpers

/**
 * Create a node from it's class name, put it in the scene unattached to anything.
 */
- (FilterNode*) createNodeForNodeClassName:(NSString*) nodeClassName
{
	FilterNode* newNode = [FilterNodeFactory generateNodeForNodeClassName:nodeClassName];
	
	if(newNode)
	{
		[currentFilterList addObject:newNode];
		
		// add to graph scroll view
		[_graphScrollView.documentView addSubview:newNode.graphView];
		
		// Set up the connect points the first time. (If this looks wrong for a FilterNode,
		// ensure you have ALL inputs and outputs with default values on generation)
		[newNode.graphView resetGraphConnectsOnSuperview:_graphScrollView.documentView];
		
	}
	
	return newNode;
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
			
			else if([obj isKindOfClass:[NSURL class]])
			{
				NSURL* url = [NSURL URLWithString:fieldEditor.string];
				[[currentSelectedNode inputValues] setValue:url forKey:inputKey];
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

#pragma mark - Button

- (void) pressFileBrowseButton:(NSButton*) button
{
	NSString* inputKey = objc_getAssociatedObject(button, kUIControlElementAssociatedInputKey);
	id obj = [currentSelectedNode.inputValues objectForKey:inputKey];
	
	//NSLog(@"associated obj = %@ (%@)", obj, [obj class]); // it's an NSURL
	
	// TODO: load up file browser and point it at the URL
	NSOpenPanel* fileBrowser = [NSOpenPanel openPanel];
	[fileBrowser setDirectoryURL:obj];
	NSInteger returnVal = [fileBrowser runModal];
	
	// since it was modal, it happened in sync, now we can get the result
	if(returnVal == NSFileHandlingPanelOKButton && [[fileBrowser URLs] count] > 0)
	{
		// we got a new file selected. Pass it back to the selected node and do a global update.
		[currentSelectedNode.inputValues setObject:[[fileBrowser URLs] firstObject] forKey:inputKey];
		
		[AppDelegate log:[NSString stringWithFormat:@"Opened new file in %@: '%@'", currentSelectedNode, [[[fileBrowser URLs] firstObject] lastPathComponent] ]];
		
		[self doGlobalNodeUpdate];
	}
}

@end
