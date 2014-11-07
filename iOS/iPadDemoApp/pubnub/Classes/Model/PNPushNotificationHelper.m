//
//  PNPushNotificationHelper.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/5/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNPushNotificationHelper.h"
#import "PNDataManager.h"


#pragma mark Private interface declaration

@interface PNPushNotificationHelper ()


#pragma mark - Properties

@property (nonatomic, strong) NSMutableArray *userProvidedChannels;
@property (nonatomic, strong) NSMutableArray *existingChannels;
@property (nonatomic, strong) NSArray *pushNotificationEnabledChannels;
@property (nonatomic, strong) NSMutableArray *channelsForPushNotificationManipulation;


#pragma mark - Instance methods

/**
 Prepare all required set of cached data.
 */
- (void)prepareData;
- (void)updateData;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNPushNotificationHelper


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class
    [super awakeFromNib];
    
    [self prepareData];
}

- (void)setEnablingPushNotifications:(BOOL)enablingPushNotifications {
    
    BOOL isStateChanged = _enablingPushNotifications != enablingPushNotifications;
    _enablingPushNotifications = enablingPushNotifications;
    
    if (isStateChanged) {
        
        [self prepareData];
    }
}

- (void)prepareData {
    
    self.userProvidedChannels = [NSMutableArray array];
    self.channelsForPushNotificationManipulation = [NSMutableArray array];
}

- (void)updateData {
    
    self.existingChannels = [NSMutableArray array];
    if (self.isEnablingPushNotifications) {
        
        NSArray *subscribedChannels = [PubNub subscribedObjectsList];
        [subscribedChannels enumerateObjectsUsingBlock:^(id<PNChannelProtocol> object, NSUInteger objectIdx,
                                                         BOOL *objectEnumeratorStop) {

            if (!object.isChannelGroup && ![self.pushNotificationEnabledChannels containsObject:object]) {
                
                [self.existingChannels addObject:object];
            }
        }];
    }
    else {
        
        [self.existingChannels addObjectsFromArray:self.pushNotificationEnabledChannels];
    }
}

- (void)requestPushNotificationEnabledChannelsWithBlock:(void(^)(void))handlerBlock {
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    void(^auditionCompletionBlock)(NSArray *, PNError *) = ^(NSArray *channels, PNError *requestError) {
        
        if (!requestError) {
            
            weakSelf.pushNotificationEnabledChannels = channels;
            
            [weakSelf updateData];
        }
        if (handlerBlock) {
            
            handlerBlock();
        }
    };
    
    [PubNub requestPushNotificationEnabledChannelsForDevicePushToken:[PNDataManager sharedInstance].devicePushToken
                                         withCompletionHandlingBlock:auditionCompletionBlock];
}



- (void)addChannel:(PNChannel *)channel {
    
    if (![self willChangePushNotificationStateForChanne:channel]) {
        
        [self.channelsForPushNotificationManipulation addObject:channel];
    }
    
    if (![self.existingChannels containsObject:channel] && ![self.pushNotificationEnabledChannels containsObject:channel] &&
        self.isEnablingPushNotifications) {
        
        if (![self.userProvidedChannels containsObject:channel]) {
            
            [self.userProvidedChannels addObject:channel];
        }
        
        [self.existingChannels addObject:channel];
    }
}

- (void)removeChannel:(PNChannel *)channel {
    
    if ([self.userProvidedChannels containsObject:channel]) {
        
        [self.existingChannels removeObject:channel];
        [self.userProvidedChannels removeObject:channel];
    }
    [self.channelsForPushNotificationManipulation removeObject:channel];
}

- (BOOL)willChangePushNotificationStateForChanne:(PNChannel *)channel {
    
    return [self.channelsForPushNotificationManipulation containsObject:channel];
}

- (NSArray *)channels {
    
    return self.existingChannels;
}

- (BOOL)isAbleToChangePushNotificationState {
    
    return [self.channelsForPushNotificationManipulation count] > 0;
}

- (void)performRequestWithBlock:(void(^)(NSArray *, PNError *))handlerBlock {
    
    void(^completionBlock)(NSArray *, PNError *) = ^(NSArray *channels, PNError *requestError) {
        
        __block __pn_desired_weak __typeof(self) weakSelf = self;
        void(^auditionCompletionBlock)(NSArray *, PNError *) = ^(NSArray *auditedChannels, PNError *auditionError) {
            
            if (!requestError) {
                
                [weakSelf reset];
                
                weakSelf.pushNotificationEnabledChannels = auditedChannels;
                [weakSelf updateData];
            }
            if (handlerBlock) {
                
                handlerBlock(channels, requestError);
            }
        };
        
        [PubNub requestPushNotificationEnabledChannelsForDevicePushToken:[PNDataManager sharedInstance].devicePushToken
                                             withCompletionHandlingBlock:auditionCompletionBlock];
    };
    
    if (self.isEnablingPushNotifications) {
        
        [PubNub enablePushNotificationsOnChannels:self.channelsForPushNotificationManipulation
                              withDevicePushToken:[PNDataManager sharedInstance].devicePushToken
                       andCompletionHandlingBlock:completionBlock];
    }
    else {
        
        [PubNub disablePushNotificationsOnChannels:self.channelsForPushNotificationManipulation
                               withDevicePushToken:[PNDataManager sharedInstance].devicePushToken
                        andCompletionHandlingBlock:completionBlock];
    }
}

- (void)reset {
    
    [self prepareData];
}

#pragma mark -


@end
