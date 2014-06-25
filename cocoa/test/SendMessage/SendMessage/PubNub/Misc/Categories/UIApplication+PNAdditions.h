//
//  UIApplication+PNAdditions.h
//  pubnub
//
//  Created by Sergey Mamontov on 8/4/13.
//
//


#if __IPHONE_OS_VERSION_MIN_REQUIRED

#import <UIKit/UIKit.h>


#pragma mark Public interface declaration

@interface UIApplication (PNAdditions)


#pragma mark - Class methods

/**
 * Will check application Property List file to fetch whether application can run in background or not
 */
+ (BOOL)canRunInBackground;

#pragma mark -


@end
#endif
