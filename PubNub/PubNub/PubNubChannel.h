//
//  PubNubChannel.h
//  PubNubClient
//
//  Created by Luke Alonso on 4/9/15.
//  Copyright (c) 2015 Twitter. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PubNubChannel;

typedef NS_ENUM(NSUInteger, PubNubChannelState) {
    PubNubChannelStateConnected,
    PubNubChannelStateTransientFailure,
    PubNubChannelStateDisconnected
};

@protocol PubNubChannelDelegate <NSObject>

- (void)pubNubChannel:(PubNubChannel*)channel messages:(NSArray*)messages receivedDate:(NSDate*)receivedDate;
- (void)pubNubChannel:(PubNubChannel*)channel state:(PubNubChannelState)state;

@end

@interface PubNubChannel : NSObject <NSURLSessionDelegate>

- (instancetype)initWithName:(NSString*)name clientUuid:(NSString*)clientUUid authKey:(NSString*)authKey subscriberKey:(NSString*)subscriberKey publisherKey:(NSString*)publisherKey heartbeat:(BOOL)heartbeat;

- (void)subscribeWithUserInfo:(NSDictionary*)userInfo completion:(void (^)())completion;
- (void)unsubscribeWithCompletion:(void (^)())completion;
- (void)publishMessage:(NSDictionary*)message;
- (void)hereNowWithCompletion:(void (^)(NSArray* users))completion;
- (void)historyWithStartTime:(long long)startTime endTime:(long long)endTime limit:(NSInteger)limit completion:(void (^)(long long start, long long end, NSArray* messages))completion;

@property (nonatomic, readonly) BOOL connected;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) PubNubChannelState state;
@property (nonatomic, weak) id<PubNubChannelDelegate> delegate;

@end
