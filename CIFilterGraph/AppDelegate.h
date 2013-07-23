//
//  AppDelegate.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSScrollView *graphScrollView;
@property (assign) IBOutlet NSTextView *messageLog;

/**
 * Log a string to GUI. Can be class method as there's only one AppDelegate instance per app.
 */
+ (void) log:(NSString*) string;

@end
