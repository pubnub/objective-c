//
//  PubNubClient.m
//  PubNubClient
//
//  Created by Luke Alonso on 4/9/15.
//  Copyright (c) 2015 Twitter. All rights reserved.
//

#import "PubNubClient.h"
#import "PubNubChannel.h"

static NSString* kPubNubPresenceSuffix = @"-pnpres";

@implementation PubNubClient
{
    NSString* _clientUuid;
    PubNubChannel* _channel;
    PubNubChannel* _presenceChannel;
}

- (instancetype)initWithChannel:(NSString*)channel uuid:(NSString*)uuid authKey:(NSString*)authKey subscriberKey:(NSString*)subscriberKey publisherKey:(NSString*)publisherKey
{
    self = [super init];
    if (self) {
        _clientUuid = uuid;
        _channel = [[PubNubChannel alloc] initWithName:channel clientUuid:_clientUuid authKey:authKey subscriberKey:subscriberKey publisherKey:publisherKey heartbeat:YES];
        _channel.delegate = self;
        _presenceChannel = [[PubNubChannel alloc] initWithName:[channel stringByAppendingString:kPubNubPresenceSuffix] clientUuid:_clientUuid authKey:authKey subscriberKey:subscriberKey publisherKey:publisherKey heartbeat:NO];
        _presenceChannel.delegate = self;
    }
    return self;
}


- (void)connectWithCompletion:(void (^)())completion
{
    [_channel subscribeWithUserInfo:_userInfo completion:^{
        [_presenceChannel subscribeWithUserInfo:_userInfo completion:^{
            completion();
        }];
    }];
}

- (void)disconnectWithCompletion:(void (^)())completion
{
    [_channel unsubscribeWithCompletion:^{
        [_presenceChannel unsubscribeWithCompletion:^{
            completion();
        }];
    }];
}

- (void)pubNubChannel:(PubNubChannel *)channel messages:(NSArray *)messages receivedDate:(NSDate*)receivedDate
{
    if (self.delegate) {
        if (channel == _presenceChannel) {
            [self.delegate pubNubClient:self presenceEvents:messages];
        } else {
            [self.delegate pubNubClient:self messages:messages receivedDate:receivedDate];
        }
    }
}

- (void)pubNubChannel:(PubNubChannel *)channel state:(PubNubChannelState)state
{
    if (channel == _channel) {
        [self.delegate pubNubClient:self state:state];
    }
}

@end
