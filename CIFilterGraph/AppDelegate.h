//
//  AppDelegate.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CustomisedScrollView.h"
#import "FilterGraphViewDelegate.h"

// UI elements have associated input key NSStrings, so that FilterNodes can respond directly
// to UI delegation methods (e.g. NSTextFieldDelegate). This is the key to look up the association
//extern const char* const kUIControlElementAssociatedInputKey;


@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate, FilterGraphViewDelegate>

@property (weak) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSScrollView *graphScrollView;
@property (weak) IBOutlet NSScrollView *outputPaneScrollView;

@property (weak) IBOutlet NSTextField* commandField;

@property (unsafe_unretained) IBOutlet NSTextView *messageLog;

@property (weak) IBOutlet NSTextField *filterConfigTitle;
@property (weak) IBOutlet NSScrollView *filterConfigScrollView;


/**
 * Append a string to GUI log. Can be class method as there's only one AppDelegate instance per app.
 */
+ (void) log:(NSString*) string;

@end
