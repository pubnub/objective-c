/**
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNAPNSNotificationTarget+Private.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNAPNSNotificationTarget ()


#pragma mark - Information

/**
 * @brief Notifications topic name (usually it is application's bundle identifier).
 *
 * @note Value will be used in APNs POST request as \a apns-topic header value.
 */
@property (nonatomic, copy) NSString *topic;

/**
 * @brief One of \b PNAPNSEnvironment fields which specify environment within which registered
 * devices to which notifications should be delivered
 */
@property (nonatomic, assign) PNAPNSEnvironment environment;

/**
 * @brief List of devices (their push tokens) to which this notification shouldn't be delivered.
 */
@property (nonatomic, nullable, strong) NSArray<NSData *> *excludedDevices;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize and configure notification target.
 *
 * @param topic Notifications topic name (usually it is application's bundle identifier).
 *     Value will be used in APNs POST request as \a apns-topic header value. 
 * @param environment One of \b PNAPNSEnvironment fields which specify environment within which
 *     registered devices to which notifications should be delivered
 * @param excludedDevices List of devices (their push tokens) to which this notification shouldn't
 *     be delivered.
 *
 * @return Initialized and ready to use notification target.
 */
- (instancetype)initForTopic:(nullable NSString *)topic
               inEnvironment:(PNAPNSEnvironment)environment
         withExcludedDevices:(nullable NSArray<NSData *> *)excludedDevices;


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNAPNSNotificationTarget


#pragma mark - Initialization & Configuration

+ (instancetype)defaultTarget {
    return [self targetForTopic:NSBundle.mainBundle.bundleIdentifier];
}

+ (instancetype)targetForTopic:(NSString *)topic {
    return [self targetForTopic:topic inEnvironment:PNAPNSDevelopment withExcludedDevices:nil];
}

+ (instancetype)targetForTopic:(NSString *)topic
                 inEnvironment:(PNAPNSEnvironment)environment
           withExcludedDevices:(NSArray<NSData *> *)excludedDevices {
    
    return [[self alloc] initForTopic:topic
                        inEnvironment:environment
                  withExcludedDevices:excludedDevices];
}

- (instancetype)initForTopic:(NSString *)topic
               inEnvironment:(PNAPNSEnvironment)environment
         withExcludedDevices:(NSArray<NSData *> *)excludedDevices {
    
    if ((self = [super init])) {
        _topic = [(topic ?: NSBundle.mainBundle.bundleIdentifier) copy];
        _environment = environment;
        _excludedDevices = excludedDevices;
    }
    
    return self;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    dictionary[@"environment"] = (self.environment == PNAPNSDevelopment ? @"development"
                                                                        : @"production");
    dictionary[@"topic"] = self.topic;
    
    if (self.excludedDevices.count) {
        NSMutableArray<NSString *> *excludedDevices = [NSMutableArray new];
        
        [self.excludedDevices enumerateObjectsUsingBlock:^(NSData *token,
                                                           __unused NSUInteger idx,
                                                           __unused BOOL *stop) {
            
            [excludedDevices addObject:[PNData HEXFromDevicePushToken:token]];
        }];
        
        dictionary[@"excluded_devices"] = excludedDevices;
    }
    
    return dictionary;
}

#pragma mark -


@end
