//
//  AppDelegate.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "AppDelegate.h"


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
}



#pragma mark - Delegate Methods

#pragma mark - Text Field

//- (BOOL)textView:(NSTextView *)aTextView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
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
