//
//  RawImageInputFilterNode.m
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

#import "RawImageInputFilterNode.h"

@implementation RawImageInputFilterNode

- (void)dealloc
{
    self.imageOutputView = nil;
    [super dealloc];
}

/**
 * RII Filter Node update takes the input file URL, loads a valid CIImage representation of it, and
 * stores that in the output dictionary.
 */
- (void) update
{
	[super update];
	
	NSURL* fileURL = [[self inputValues] valueForKey:kFilterInputKeyFileURL];
	if(fileURL)
	{
		// load the image to a CIImage
		CIImage* theImage = [CIImage imageWithContentsOfURL:fileURL];
		
		// store it
		if(theImage)
		{
			[[self outputValues] setValue:theImage forKey:kFilterOutputKeyImage];
			
			// update output view. Use CIImage representation.
			NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:theImage];
			NSImage *nsImage = [[NSImage alloc] initWithSize:rep.size];
			[nsImage addRepresentation:rep];
			
			[self.imageOutputView setImage:nsImage];
			[nsImage release];
		}
		else if(self.verboseUpdate)
		{
			NSLog(@"%@ update FAIL: no image loaded for url %@!", self.class, fileURL);
		}
	}
	
	else if(self.verboseUpdate)
	{
		NSLog(@"%@ update FAIL: no fileURL set for inputValues at kFilterInputKeyFileURL!", self.class);
	}
}


- (void) setFileInputURL:(NSURL*) inputFileURL
{
	[[self inputValues] setValue:inputFileURL forKey:kFilterInputKeyFileURL];
}

@end
