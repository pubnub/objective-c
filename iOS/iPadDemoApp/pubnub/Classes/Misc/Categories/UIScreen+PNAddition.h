//
//  UIScreen+PNAddition.h
//  pubnub
//
//  Created by Sergey Mamontov on 2/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark Public interface declaration

@interface UIScreen (PNAddition)


#pragma mark - Instance methods

/**
 Method will return application frame basing on current interface orientation,
 
 @return Normalized application frame.
 */
- (CGRect)applicationFrameForCurrentOrientation;

/**
 Convert provided rect from portrait orientation into current orientation.
 
 @param frame
 \b CGRect which represent dimension information for portrait orientation.
 
 @return Normalized frame.
 */
- (CGRect)normalizedForCurrentOrientationFrame:(CGRect)frame;

#pragma mark -


@end
