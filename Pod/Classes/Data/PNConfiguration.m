/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import <UIKit/UIKit.h>
#import "PNConfiguration+Private.h"
#import "PNConstants.h"


#pragma mark Protected interface declaration

@interface PNConfiguration () <NSCopying>


#pragma mark - Initialization and Configuration

@property (nonatomic, copy) NSString *deviceID;

/**
 @brief  Initialize configuration instance using minimal required data.
 
 @param publishKey   Key which allow client to use data push API.
 @param subscribeKey Key which allow client to subscribe on live feeds pushed from \b PubNub 
                     service.
 
 @return Configured and ready to se configuration instance.
 
 @since 4.0
 */
- (instancetype)initWithPublishKey:(NSString *)publishKey
                      subscribeKey:(NSString *)subscribeKey NS_DESIGNATED_INITIALIZER;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNConfiguration


#pragma mark - Initialization and Configuration

+ (instancetype)configurationWithPublishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey {
    
    NSParameterAssert(publishKey);
    NSParameterAssert(subscribeKey);
    
    return [[self alloc] initWithPublishKey:publishKey subscribeKey:subscribeKey];
}

- (instancetype)initWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey {
    
    // Check whether initialization successful or not.
    if ((self = [super init])) {
        
        _deviceID = [[[[UIDevice currentDevice] identifierForVendor] UUIDString] copy];
        _origin = [kPNDefaultOrigin copy];
        _publishKey = [publishKey copy];
        _subscribeKey = [subscribeKey copy];
        _uuid = [[[NSUUID UUID] UUIDString] copy];
        _subscribeMaximumIdleTime = kPNDefaultSubscribeMaximumIdleTime;
        _nonSubscribeRequestTimeout = kPNDefaultNonSubscribeRequestTimeout;
        _TLSEnabled = kPNDefaultIsTLSEnabled;
        _keepTimeTokenOnListChange = kPNDefaultShouldKeepTimeTokenOnListChange;
        _restoreSubscription = kPNDefaultShouldRestoreSubscription;
        _catchUpOnSubscriptionRestore = kPNDefaultShouldTryCatchUpOnSubscriptionRestore;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    
    PNConfiguration *configuration = [[[self class] allocWithZone:zone] init];
    configuration.deviceID = self.deviceID;
    configuration.origin = self.origin;
    configuration.publishKey = self.publishKey;
    configuration.subscribeKey = self.subscribeKey;
    configuration.uuid = self.uuid;
    configuration.subscribeMaximumIdleTime = self.subscribeMaximumIdleTime;
    configuration.nonSubscribeRequestTimeout = self.nonSubscribeRequestTimeout;
    configuration.TLSEnabled = self.isTLSEnabled;
    configuration.keepTimeTokenOnListChange = self.shouldKeepTimeTokenOnListChange;
    configuration.restoreSubscription = self.shouldRestoreSubscription;
    configuration.catchUpOnSubscriptionRestore = self.shouldTryCatchUpOnSubscriptionRestore;
    
    return configuration;
}

#pragma mark -


@end
