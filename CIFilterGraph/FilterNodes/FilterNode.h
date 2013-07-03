//
//  FilterNode.h
//  CIFilterGraph
//
//  Created by Mete Cakman on 3/07/13.
//  Copyright (c) 2013 Mete Cakman. All rights reserved.
//

//	The superclass of all filter nodes.

#import <Foundation/Foundation.h>

@interface FilterNode : NSObject
{
	
}

/**
 * Each node has an output image that can be read by any of it's children
 */
- (CIImage*) outputImage;


@end
