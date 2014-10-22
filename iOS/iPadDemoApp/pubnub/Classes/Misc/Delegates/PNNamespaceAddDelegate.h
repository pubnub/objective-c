//
//  PNNamespaceAddDelegate.h
//  pubnub
//
//  Created by Sergey Mamontov on 10/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNNamespaceAddView, PNChannelGroupNamespace;


#pragma mark - Protocol declaration

@protocol PNNamespaceAddDelegate <NSObject>


@required

- (void)namespaceView:(PNNamespaceAddView *)view didEndNamespaceInput:(PNChannelGroupNamespace *)nspace;

#pragma mark -


@end
