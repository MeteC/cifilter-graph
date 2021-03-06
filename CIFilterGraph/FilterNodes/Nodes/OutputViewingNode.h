//
//  OutputViewingNode.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

//	This node does nothing but allow viewing of an image it picks up from a single input node. It conforms to
//	the FilterNodeSeenInOutputPane protocol, which tags it for being shown in the output pane of the GUI.

#import "GenericIONode.h"


@interface OutputViewingNode : GenericIONode
{
	
}

@end
