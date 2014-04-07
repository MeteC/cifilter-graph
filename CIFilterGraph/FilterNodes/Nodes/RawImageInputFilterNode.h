//
//  RawImageInputFilterNode.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

//	This badboy takes as input 1 image from the filesystem, and feeds it directly to it's output.
//	It's node view shows a thumbnail of that image. RII Filter Node conforms to the empty 
//	FilterNodeSeenInOutputPane protocol, which tags it for being shown in the output pane of the GUI.

#import "FilterNode.h"
#import "FilterNodeSeenInOutputPane.h"

@interface RawImageInputFilterNode : FilterNode <FilterNodeSeenInOutputPane>
{
	
}
@property (nonatomic, strong) NSImageView *imageOutputView;

// convenience methods

/**
 * Set the input file URL key in the inputValues dictionary easily.
 */
- (void) setFileInputURL:(NSURL*) inputFileURL;


@end
