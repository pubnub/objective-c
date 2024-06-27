#import "PNChannelGroupFetchData.h"
#import <PubNub/PNCodable.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration


/// Response `payload` object.
@interface PNChannelGroupChannelsPayload : NSObject <PNCodable>


#pragma mark - Properties

/// Channel groups for subscription key.
///
/// > Note: Value will be `nil` if channel group channels has been requested.
@property(strong, nullable, nonatomic, readonly) NSArray<NSString *> *groups;

/// Registered channels within channel group.
///
/// > Note: In case if status object represent error, this property may contain list of channels to which client
/// doesn't have access.
/// > Note: Value will be `nil` if list of channel groups has been requested.
@property (strong, nonatomic, readonly) NSArray<NSString *> *channels;

/// Name of the channel group for which request has been made.
/// 
/// > Note: Value will be `nil` if list of channel groups has been requested.
@property(strong, nonatomic, readonly) NSString *channelGroup;

#pragma mark -


@end


@interface PNChannelGroupFetchData () <PNCodable>


#pragma mark - Properties

/// Payload with service-provided in response on request.
@property(strong, nonatomic, readonly) PNChannelGroupChannelsPayload *payload;

/// List channel group channels human-readable result.
@property(strong, nonatomic, readonly) NSString *message;

/// Name of the service which provided response.
@property(strong, nonatomic, readonly) NSString *service;

/// Request result status code.
@property(strong, nonatomic, readonly) NSNumber *status;

/// Whether response represent service error or not.
@property(assign, nonatomic, readonly) BOOL error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNChannelGroupChannelsPayload


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{
        @"channelGroup": @"group",
        @"channels": @"channels",
        @"groups": @"groups",
    };
}

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"channelGroup", @"channels", @"groups"];
}

#pragma mark -


@end


@implementation PNChannelGroupFetchData


#pragma mark - Properties

+ (NSArray<NSString *> *)optionalKeys {
    // 'channelGroup' and 'channels' excluded because they are getters to the payload object.
    return @[@"channelGroup", @"channels", @"payload", @"message", @"groups"];
}

- (NSArray<NSString *> *)channels {
    return self.payload.channels;
}

- (NSArray<NSString *> *)groups {
    return self.payload.groups;
}

- (NSString *)channelGroup {
    return self.payload.channelGroup;
}

#pragma mark -


@end
