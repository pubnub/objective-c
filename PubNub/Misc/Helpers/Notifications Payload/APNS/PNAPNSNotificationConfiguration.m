/**
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNAPNSNotificationConfiguration+Private.h"
#import "PNAPNSNotificationTarget+Private.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNAPNSNotificationConfiguration ()


#pragma mark - Information

/**
 * @brief List of topics which should receive this notification.
 */
@property (nonatomic, nullable, strong) NSArray<PNAPNSNotificationTarget *> *targets;

/**
 * @brief Notification group / collapse identifier.
 * 
 * @note Value will be used in APNs POST request as \a apns-collapse-id header value.
 */
@property (nonatomic, nullable, copy) NSString *collapseId;

/**
 * @brief Date till which APNS will try to deliver notification to target device.
 *
 * @note Value will be used in APNs POST request as \a apns-expiration header value.
 */
@property (nonatomic, nullable, strong) NSDate *date;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure APNS over HTTP/2 notification configuration.
 *
 * @param collapseId Notification group / collapse identifier.
 *     Value will be used in APNs POST request as \a apns-collapse-id header value. 
 * @param date Date till which APNS will try to deliver notification to target device.
 *     Value will be used in APNs POST request as \a apns-expiration header value. 
 * @param targets List of topics which should receive this notification.
 *
 * @return Configured and ready to use APNS over HTTP/2 notification configuration.
 */
- (instancetype)initWithCollapseID:(nullable NSString *)collapseId
                    expirationDate:(nullable NSDate *)date
                           targets:(NSArray<PNAPNSNotificationTarget *> *)targets;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNAPNSNotificationConfiguration


#pragma mark - Initialization & Configuration

+ (instancetype)defaultConfiguration {
    return [self configurationWithTargets:@[[PNAPNSNotificationTarget defaultTarget]]];
}

+ (instancetype)configurationWithTargets:(NSArray<PNAPNSNotificationTarget *> *)targets {
    return [self configurationWithCollapseID:nil expirationDate:nil targets:targets];
}

+ (instancetype)configurationWithCollapseID:(NSString *)collapseId
                             expirationDate:(NSDate *)date
                                    targets:(NSArray<PNAPNSNotificationTarget *> *)targets {
    
    return [[self alloc] initWithCollapseID:collapseId expirationDate:date targets:targets];
}

- (instancetype)initWithCollapseID:(NSString *)collapseId
                    expirationDate:(NSDate *)date
                           targets:(NSArray<PNAPNSNotificationTarget *> *)targets {
    
    if ((self = [super init])) {
        _targets = targets.count ? targets : @[[PNAPNSNotificationTarget defaultTarget]];
        _collapseId = [collapseId copy];
        _date = date;
    }
    
    return self;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSArray<PNAPNSNotificationTarget *> *configurationTargets = self.targets;
    NSMutableArray *targets = [NSMutableArray new];
    NSMutableDictionary *dictionary = [@{
        @"auth_method": @"token",
        @"targets": targets,
        @"version": @"v2"
    } mutableCopy];
    
    if (self.collapseId.length) {
        dictionary[@"collapse_id"] = self.collapseId;
    }
    
    if (self.date) {
        dictionary[@"expiration"] = [PNDate RFC3339StringFromDate:self.date];
    }
    
    [configurationTargets enumerateObjectsUsingBlock:^(PNAPNSNotificationTarget *target,
                                                       __unused NSUInteger idx,
                                                       __unused BOOL *stop) {
        
        [targets addObject:[target dictionaryRepresentation]];
    }];
    
    return dictionary;
}

#pragma mark -


@end
