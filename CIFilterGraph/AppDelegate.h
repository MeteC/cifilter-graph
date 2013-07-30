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

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate, FilterGraphViewDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSScrollView *graphScrollView;
@property (assign) IBOutlet NSScrollView *outputPaneScrollView;

@property (assign) IBOutlet NSTextView *messageLog;

@property (assign) IBOutlet NSTextField *filterConfigTitle;
@property (assign) IBOutlet NSScrollView *filterConfigScrollView;


/**
 * Append a string to GUI log. Can be class method as there's only one AppDelegate instance per app.
 */
+ (void) log:(NSString*) string;

@end
