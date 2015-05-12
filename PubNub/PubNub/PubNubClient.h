//
//  PubNubClient.h
//  PubNubClient
//
//  Created by Luke Alonso on 4/9/15.
//  Copyright (c) 2015 Twitter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubNubChannel.h"

@class PubNubClient;

@protocol PubNubClientDelegate <NSObject>

- (void)pubNubClient:(PubNubClient*)client messages:(NSArray*)messages receivedDate:(NSDate*)receivedDate;
- (void)pubNubClient:(PubNubClient*)client presenceEvents:(NSArray*)presenceEvents;
- (void)pubNubClient:(PubNubClient*)client state:(PubNubChannelState)state;

@end

@interface PubNubClient : NSObject <PubNubChannelDelegate>

- (instancetype)initWithChannel:(NSString*)channel uuid:(NSString*)uuid authKey:(NSString*)authKey subscriberKey:(NSString*)subscriberKey publisherKey:(NSString*)publisherKey;

- (void)connectWithCompletion:(void (^)())completion;
- (void)disconnectWithCompletion:(void (^)())completion;

@property (nonatomic, readonly) PubNubChannel* channel;
@property (nonatomic, weak) id<PubNubClientDelegate> delegate;
@property (nonatomic, copy) NSDictionary* userInfo;

@end
