//
//  PNAuthorizationKeyChangeDelegate.h
//  pubnub
//
//  Created by Sergey Mamontov on 11/26/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//


#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNAuthorizationKeyChangeView;


#pragma mark - Protocol declaration

@protocol PNAuthorizationKeyChangeDelegate <NSObject>


@required

/**
 Inform delegate that authorization key has beenchanged.
 
 @param view
 \b PNAuthorizationKeyChangeView instance of the view, which dispatched event.
 
 @param authorizationKey
 Updates authorization key.
 */
- (void)authorizationKeyChangeView:(PNAuthorizationKeyChangeView *)view didChangeKeyTo:(NSString *)authorizationKey;

#pragma mark -


@end
