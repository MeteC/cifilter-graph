//
//  AppDelegate.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "AppDelegate.h"
#import "NSScrollView+AutosizeContent.h"

#import "FilterNodeFactory.h"
#import "UXFilterControlsFactory.h"

#import "FilterNodeContext.h"
#import "FilterNode.h"
#import "RawImageInputFilterNode.h"
#import "OutputViewingNode.h"

#import "UXFilterGraphView.h"
#import "UXFilterInputPointView.h"
#import "UXFilterOutputPointView.h"
#import "UXFilterConnectionView.h"
#import "UXHighlightingImageView.h"

#import "ListedNodeManager.h"

// Generic nodes (listed nodes)
#import "GenericCIEffectNode.h"
#import "GenericIONode.h"


#import <objc/runtime.h> // using "associated objects"


// Set this to 0 for no test menu
#define TESTING_MENU_ACCESSIBLE 1
#define TESTING_INPUT_IMAGE_URL @"/Users/mete/Desktop/screenshot.png"


// UI elements have associated input key NSStrings, so that FilterNodes can respond directly
// to UI delegation methods (e.g. NSTextFieldDelegate). This is the key to look up the association
const char* const kUIControlElementAssociatedInputKey = "kUIControlElementAssociatedInputKey";


@interface AppDelegate ()
{
	FilterNodeContext* sharedContext;	// the filter update context. owner of nodes.
	FilterNode* currentSelectedNode;	// currently selected node pointer
}
@property NSMutableArray* mListedNodeManagers; // all the "listed node" managers

@end

@implementation AppDelegate


#pragma mark - Startup


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{	
	UXLog(@"Hi there");
	
	// Insert code here to initialize your application
	[_messageLog setEditable:NO];
	
	[_filterConfigTitle setStringValue:@""];
	[_filterConfigScrollView.documentView setFlipped:YES]; // make sure filter config layout goes top down
	
	// Grab the filter update context
	sharedContext = [FilterNodeContext sharedInstance];
	
	// set up listed node managers here!
	_mListedNodeManagers = [NSMutableArray array];
	
	[_mListedNodeManagers addObject:[[ListedNodeManager alloc] initWithPlist:@"ListedCIEffectNodes.plist" ownedDelegate:[GenericCIEffectNode new]]];
	
	[_mListedNodeManagers addObject:[[ListedNodeManager alloc] initWithPlist:@"ListedIONodes.plist" ownedDelegate:[GenericIONode new]]];
	
	
	// Construct node menu
	[self setupNodeMenus];
	
	// And testing menu
	[self setupTestMenus];
	
	
	/*
	// testing still...
	[self createTestForFilter:@"CIDiscBlur"];
	[self doGlobalNodeUpdate];
	*/
	// done!
}

/**
 * Set up the node menu based on listings
 */
- (void) setupNodeMenus
{
	[_mListedNodeManagers enumerateObjectsUsingBlock:^(ListedNodeManager* mgr, NSUInteger idx, BOOL *stop) {
		
		// Create the submenu
		NSMenuItem* listMenu = [self createMenuItemForListMgr:mgr 
											   withItemAction:@selector(selectNodeMenuItem:)];
		[_nodeMenuItem.submenu addItem:listMenu];
	}];
}

/**
 * Set up the test menu, or kill it, depending on TESTING_MENU_ACCESSIBLE
 */
- (void) setupTestMenus
{
#if (TESTING_MENU_ACCESSIBLE == 0) // kill the test menu
	[_testMenuItem.menu removeItem:_testMenuItem];
#else // set up the test menu
	
	// Menu for testing GenericCIEffectNodes; the test cases will set up a 3 part node chain,
	// with the test filter in the middle of an input and output
	ListedNodeManager* genericCIList = [[ListedNodeManager alloc] initWithPlist:@"ListedCIEffectNodes.plist" ownedDelegate:[GenericCIEffectNode new]];
	
	NSMenuItem* genericTestsItem = [self createMenuItemForListMgr:genericCIList withItemAction:@selector(selectTestMenuItem:)];
	[_testMenuItem.submenu addItem:genericTestsItem];
	
#endif
}

/**
 * Factoring out the code for creating menus from listings, so I can use it in different places.
 */
- (NSMenuItem*) createMenuItemForListMgr:(ListedNodeManager*) mgr withItemAction:(SEL) selector
{
	// Create the submenu
	NSMenuItem* listMenu = [[NSMenuItem alloc] initWithTitle:mgr.plistDisplayName action:nil keyEquivalent:@""];
	[listMenu setSubmenu:[[NSMenu alloc] initWithTitle:mgr.plistDisplayName]];
	
	// Grab the list structure
	NSDictionary* menuStruct = [mgr availableFilterNames];
	[menuStruct enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSArray* list, BOOL *stop) 
	 {
		 // subcategory, or "root" if no subcategory
		 if([key isEqualToString:@"root"])
		 {
			 // directly in the root menu, create the list
			 [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) 
			  {
				  [listMenu.submenu addItemWithTitle:obj 
											  action:selector 
									   keyEquivalent:@""];
			  }];
			 
		 }
		 else
		 {
			 // got a subcategory - make another submenu for it
			 NSMenuItem* subcategory = [[NSMenuItem alloc] initWithTitle:key 
																  action:nil 
														   keyEquivalent:@""];
			 [listMenu.submenu addItem:subcategory];
			 [subcategory setSubmenu:[[NSMenu alloc] initWithTitle:key]];
			 
			 // done, create the list
			 [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) 
			  {
				  [subcategory.submenu addItemWithTitle:obj 
												 action:selector
										  keyEquivalent:@""];
			  }];
		 }
	 }];
	
	return listMenu;
}

/**
 * A test setup, using 1 input, 1 output, and a filter.
 */
- (void) createTestForFilter:(NSString*) filterName
{
	// Testing factory
	RawImageInputFilterNode* testNodeIn = (RawImageInputFilterNode*)[self createNodeForNodeName:@"File Input"];
	
	// add image file and update
	[testNodeIn setFileInputURL:[NSURL fileURLWithPath:TESTING_INPUT_IMAGE_URL]];
	[testNodeIn.graphView setFrameOrigin:NSMakePoint(0, 200)];
	
	// Output
	OutputViewingNode* testNodeOut = (OutputViewingNode*)[self createNodeForNodeName:@"Image Output"];
	[testNodeOut.graphView setFrameOrigin:NSMakePoint(400, 200)];
	
	
	
	if(filterName)
	{
		// Filter Example
		FilterNode* testModNode = [self createNodeForNodeName:filterName];
		
		// connect and pass through data
		[testModNode attachInputImageNode:testNodeIn];
		[testNodeOut attachInputImageNode:testModNode];
		
		// Put graphics in right places
		[testModNode.graphView setFrameOrigin:NSMakePoint(200, 100)];
		
		
		// We've connected them, so reset the connect points
		[testNodeIn.graphView resetGraphConnectsOnSuperview:_graphScrollView.documentView];
		[testModNode.graphView resetGraphConnectsOnSuperview:_graphScrollView.documentView];
		[testNodeOut.graphView resetGraphConnectsOnSuperview:_graphScrollView.documentView];
		
	}
	else
	{
		// Just a passthrough please
		[testNodeOut attachInputImageNode:testNodeIn];
		
		[testNodeIn.graphView resetGraphConnectsOnSuperview:_graphScrollView.documentView];
		[testNodeOut.graphView resetGraphConnectsOnSuperview:_graphScrollView.documentView];
	}
	
	[sharedContext smartUpdate];
}

#pragma mark - Class Methods

/**
 * Append a string to GUI log. Can be class method as there's only one AppDelegate instance per app.
 */
+ (void) log:(NSString *)string
{
	AppDelegate* this = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	[this.messageLog setString:[NSString stringWithFormat:@"%@%@\n", this.messageLog.string, string]];
	printf("GUI-LOG: %s\n", string.UTF8String);
}

/**
 * Make the array of PlistNodeManagers accessible globally & direct from the AppDelegate class. 
 * There's only one after all.
 * Any node directories set up with plists will be accessible here.
 */
+ (NSArray*) listedNodeManagers
{
	AppDelegate* this = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	return this.mListedNodeManagers;
}


#pragma mark - Delegate Methods

- (void) clickedFilterGraph:(UXFilterGraphView*) graphView wasLeftClick:(BOOL)wasLeftClick
{	
	// Set up the configuration panel for the graph node
	currentSelectedNode = graphView.parentNode;
	
	NSString* filterTitle = [NSString stringWithFormat:@"Selected Filter: %@", currentSelectedNode];
	[_filterConfigTitle setStringValue:filterTitle];
	
	// go through config options and set up edit panels
	[self setupFilterConfigPanelForCurrentSelection];
	
	// read ID to log so you can delete with command line
	UXLog(@"Selected %@ node ID %p", graphView.parentNode, graphView.parentNode);
	
	if(!wasLeftClick) // right click
	{
		NSLog(@"right clicked %@", graphView.parentNode);
		
		// pop-up menu for the graph appears
		NSMenu* popup = [self popupMenuForGraphView:graphView];
		[popup popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:nil];
	}
	
	
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
	
	[UXFilterControlsFactory createControlPanelFor:currentSelectedNode 
									addToSuperview:_filterConfigScrollView.documentView 
								  controlsDelegate:self];
}

#pragma mark - Menu Items


- (void) selectNodeMenuItem:(NSMenuItem*) item
{
	NSLog(@"Node Menu Item Selected: %@", item);
	
	[self createNodeForNodeName:item.title];
}

- (void) selectTestMenuItem:(NSMenuItem*) item
{
	NSLog(@"Test Menu Item Selected: %@", item);
	
	[self createTestForFilter:item.title];
}


- (void) selectPopupMenuItem:(NSMenuItem*) item
{
	NSLog(@"Popup menu item selected: %@", item);
	
	if([item.title isEqualTo:@"Remove"])
	{
		// remove the selected node
		[self removeNodeFromScene:currentSelectedNode];
	}
}

#pragma mark - Helpers


static const float scrollerPaneMargin = 20; // margin between image views


/**
 * Remove a node, along with all it's graphical stuff
 */
- (void) removeNodeFromScene:(FilterNode*) node
{
	// First remove associated graphics - image output, connect points, connections, graph view..
	UXFilterGraphView* graph = [node graphView];
	
	// removing output image from scroller
	if([node conformsToProtocol:@protocol(FilterNodeSeenInOutputPane)])
	{
		// remove the image from the output pane and reshuffle the output scroller..
		NSImageView* imgView = [(id<FilterNodeSeenInOutputPane>)node imageOutputView];
		float xPos = imgView.frame.origin.x;
		
		// move all images to the right of this back by the width+margin
		float offset = imgView.frame.size.width + scrollerPaneMargin;
		
		[[_outputPaneScrollView.documentView subviews] enumerateObjectsUsingBlock:^(NSView* obj, NSUInteger idx, BOOL *stop) {
			
			if(obj.frame.origin.x > xPos)
			{
				obj.frame = NSOffsetRect(obj.frame, -offset, 0);
			}
			
		}];
		
		[imgView removeFromSuperview];
	}
	
	// removing connect points and connections
	[graph.outputConnectPoints enumerateKeysAndObjectsUsingBlock:^(id key, UXFilterOutputPointView* obj, BOOL *stop) 
	{
		// remove connections attached to the output connect point - nullifying the other end too
		[obj.connectionViews enumerateObjectsUsingBlock:^(UXFilterConnectionView* connection, BOOL *stop) {
			connection.inputPointProvider.connectionView = nil;
			[connection removeFromSuperview];
		}];
		
		// remove the output connect point
		[obj removeFromSuperview];
	}];
	
	[graph.inputConnectPoints enumerateKeysAndObjectsUsingBlock:^(id key, UXFilterInputPointView* obj, BOOL *stop) {
		
		// nullify the other side too!
		obj.connectionView.outputPointProvider = nil;
		[obj.connectionView removeFromSuperview];
		
		[obj removeFromSuperview];
	}];
	
	[node.graphView removeFromSuperview];
	
	
	// Finally get context to remove the FilterNode
	[sharedContext removeNodeFromScene:node];
	
	// and update!
	[sharedContext smartUpdate];
}

/**
 * Create a node from it's listing display name or class, put it in the scene unattached to anything.
 */
- (FilterNode*) createNodeForNodeName:(NSString*) nodeClassName
{
	FilterNode* newNode = [FilterNodeFactory generateNodeForNodeClassName:nodeClassName];
	
	if(newNode)
	{
		// allow context to pull smartly. It may not be an output node but smart update will still
		// do dependencies correctly. Note the context is now the owner of the node.
		[sharedContext registerOutputNode:newNode]; 
		
		// add to graph scroll view
		[_graphScrollView.documentView addSubview:newNode.graphView];
		
		// Set up the connect points the first time. (If this looks wrong for a FilterNode,
		// ensure you have ALL inputs and outputs with default values on generation)
		[newNode.graphView resetGraphConnectsOnSuperview:_graphScrollView.documentView];
		
		if([newNode conformsToProtocol:@protocol(FilterNodeSeenInOutputPane)])
		{	
			// it needs an output image pane!
			NSUInteger currentPaneCount = [_outputPaneScrollView.documentView subviews].count;
			
			UXHighlightingImageView* outputPane = [(id<FilterNodeSeenInOutputPane>)newNode imageOutputView];
			[_outputPaneScrollView.documentView addSubview:outputPane];
			
			float xPos = (outputPane.frame.size.width + scrollerPaneMargin) * currentPaneCount;
			[outputPane setFrame:NSOffsetRect(outputPane.frame, xPos, 0)];
			
			[_outputPaneScrollView autoResizeContentView];
		}
	}
	
	return newNode;
}

/**
 * Create standard right-click pop-up menu for a graph view
 */
- (NSMenu*) popupMenuForGraphView:(UXFilterGraphView*) graphView
{
	NSMenu *theMenu = [[NSMenu alloc] initWithTitle:graphView.parentNode.description];
	
    [theMenu insertItemWithTitle:theMenu.title action:nil keyEquivalent:@"" atIndex:0];
    [theMenu insertItem:[NSMenuItem separatorItem] atIndex:1];
	
    [theMenu insertItemWithTitle:@"Remove" action:@selector(selectPopupMenuItem:) keyEquivalent:@"" atIndex:2];
    
	return theMenu;
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
			UXLog(@"Entered command: '%@'", command);
			
			// Can do what I like with those commands now
			
			// 1. create a node using 'create NodeClassName'
			if([command hasPrefix:@"create "])
			{
				NSString* nodeClassName = [command substringFromIndex:@"create ".length];
				[self createNodeForNodeName:nodeClassName];
			}
			
			// 2. update nodes
			else if([command isEqualToString:@"update"])
			{
				[sharedContext smartUpdate];
			}
			
			// 3. remove a node by pointer address
			else if([command hasPrefix:@"remove "])
			{
				NSString* nodeAddress = [command substringFromIndex:@"remove ".length];
				
				// find that node
				__block BOOL gotIt = NO;
				[sharedContext.registeredNodes enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
					NSString* objAddress = [NSString stringWithFormat:@"%p", obj];
					
					if([objAddress isEqualToString:nodeAddress])
					{
						[self removeNodeFromScene:obj];
						gotIt = YES;
						*stop = YES;
					}
				}];
				
				if(gotIt)	UXLog(@"Removed node '%@'",nodeAddress);
				else		UXLog(@"Could not remove node '%@'..",nodeAddress);
				
			}
			
			
			else
			{
				UXLog(@"Command '%@' does nothing..",command);
			}
			// clear and return
			fieldEditor.string = @"";
		}
	}
	
	else // the text editor is a node's control
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
		[sharedContext smartUpdate];
	}
	
	return YES;
}

#pragma mark - Button Responses

- (void) pressFileBrowseButton:(NSButton*) button
{
	NSString* inputKey = objc_getAssociatedObject(button, kUIControlElementAssociatedInputKey);
	id obj = [currentSelectedNode.inputValues objectForKey:inputKey];
	
	//NSLog(@"associated obj = %@ (%@)", obj, [obj class]); // it's an NSURL
	
	// Load up file browser and point it at the URL
	NSOpenPanel* fileBrowser = [NSOpenPanel openPanel];
	[fileBrowser setDirectoryURL:obj];
	NSInteger returnVal = [fileBrowser runModal];
	
	// since it was modal, it happened in sync, now we can get the result
	if(returnVal == NSFileHandlingPanelOKButton && [[fileBrowser URLs] count] > 0)
	{
		// we got a new file selected. Pass it back to the selected node and do a global update.
		[currentSelectedNode.inputValues setObject:[[fileBrowser URLs] firstObject] forKey:inputKey];
		
		UXLog(@"Opening new file in %@: '%@'", currentSelectedNode, [[[fileBrowser URLs] firstObject] lastPathComponent]);
		
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            // update the on-screen input and output after a tick so user isn't looking
            // at frozen file browser dialog.
            [self setupFilterConfigPanelForCurrentSelection];
            [sharedContext smartUpdate];
            
        });
		
	}
}

@end
