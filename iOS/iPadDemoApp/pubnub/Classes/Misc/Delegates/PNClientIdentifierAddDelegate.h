//
//  PNClientIdentifierAddDelegate.h
//  pubnub
//
//  Created by Sergey Mamontov on 4/7/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark Class forward

@class PNClientIdentifierAddView;


#pragma mark - Protocol declaration

@protocol PNClientIdentifierAddDelegate <NSObject>


@required

- (void)identifierView:(PNClientIdentifierAddView *)view didEndClientIdentifierInput:(NSString *)clientIdentifier;

#pragma mark -


@end
