/**
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
*/
#import "PNAPNSNotificationPayload+Private.h"
#import "PNBaseNotificationPayload+Private.h"
#import "PNNotificationsPayload.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNNotificationsPayload ()


#pragma mark - Information

/**
 * @brief Access to APNS specific notification builder.
 *
 * @discussion Allows to set specific general keys and provides access to mutable payload which
 * allow to make advanced configuration.
 */
@property (nonatomic, strong) PNAPNSNotificationPayload *apns;

/**
 * @brief Access to MPNS specific notification builder.
 *
 * @discussion Allows to set specific general keys and provides access to mutable payload which
 * allow to make advanced configuration.
 */
@property (nonatomic, strong) PNMPNSNotificationPayload *mpns;

/**
 * @brief Access to FCM specific notification builder.
 *
 * @discussion Allows to set specific general keys and provides access to mutable payload which
 * allow to make advanced configuration.
 */
@property (nonatomic, strong) PNFCMNotificationPayload *fcm;

/**
 * @brief Mutable dictionary which allow to access raw content (w/o helper builders usage) to make
 * direct modifications (if required).
 *
 * @note Platform specific payloads stored under: \c apns, \c fcm and \c mpns keys. Values for those
 * keys also mutable dictionaries which allow to make direct changes to payload before it will be
 * used.
 */
@property (nonatomic, strong) NSMutableDictionary *payload;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize and configure notifications payload builder.
 *
 * @param title Short text which should be shown at the top of notification instead of application
 *     name.
 * @param body Message which should be shown in notification body (under title line).
 *
 * @return Initialized and ready to use notifications payload builder.
 */
- (instancetype)initWithNotificationTitle:(nullable NSString *)title body:(NSString *)body;

@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNNotificationsPayload


#pragma mark - Information

- (void)setSubtitle:(NSString *)subtitle {
    self.apns.subtitle = subtitle;
    self.mpns.subtitle = subtitle;
    self.fcm.subtitle = subtitle;
}

- (void)setBadge:(NSNumber *)badge {
    self.apns.badge = badge;
    self.mpns.badge = badge;
    self.fcm.badge = badge;
}

- (void)setSound:(NSString *)sound {
    self.apns.sound = sound;
    self.mpns.sound = sound;
    self.fcm.sound = sound;
}


#pragma mark - Initialization & Configuration

+ (instancetype)payloadsWithNotificationTitle:(NSString *)title body:(NSString *)body {
    return [[self alloc] initWithNotificationTitle:title body:body];
}

- (instancetype)initWithNotificationTitle:(NSString *)title body:(NSString *)body {
    if ((self = [super init])) {
        _payload = [@{
            @"apns": [NSMutableDictionary new],
            @"fcm": [NSMutableDictionary new],
            @"mpns": [NSMutableDictionary new]
        } mutableCopy];
        
        _apns = [PNAPNSNotificationPayload payloadWithStorage:_payload[@"apns"]
                                            notificationTitle:title
                                                         body:body];
        
        _mpns = [PNMPNSNotificationPayload payloadWithStorage:_payload[@"mpns"]
                                            notificationTitle:title
                                                         body:body];
        
        _fcm = [PNFCMNotificationPayload payloadWithStorage:_payload[@"fcm"]
                                          notificationTitle:title
                                                       body:body];
    }
    
    return self;
}

- (instancetype)init {
    NSDictionary *errorInformation = @{
        NSLocalizedRecoverySuggestionErrorKey: @"Use provided builder constructor"
    };

    @throw [NSException exceptionWithName:@"PNInterfaceNotAvailable"
                                   reason:@"+new or -init methods unavailable."
                                 userInfo:errorInformation];
    
    return nil;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentationFor:(PNPushType)pushTypes {
    NSMutableDictionary *payload = [NSMutableDictionary new];
    
    if ((pushTypes & PNAPNSPush) == PNAPNSPush || (pushTypes & PNAPNS2Push) == PNAPNS2Push) {
        self.apns.apnsPushType = (pushTypes & PNAPNSPush) == PNAPNSPush ? PNAPNSPush : PNAPNS2Push;
        NSDictionary *apnsPayload = [self.apns dictionaryRepresentation];
        
        if (apnsPayload.count) {
            payload[@"pn_apns"] = apnsPayload;
        }
    }
    
    if ((pushTypes & PNMPNSPush) == PNMPNSPush) {
        NSDictionary *mpnsPayload = [self.mpns dictionaryRepresentation];
        
        if (mpnsPayload.count) {
            payload[@"pn_mpns"] = mpnsPayload;
        }
    }
    
    if ((pushTypes & PNFCMPush) == PNFCMPush) {
        NSDictionary *fcmPayload = [self.fcm dictionaryRepresentation];
        
        if (fcmPayload.count) {
            payload[@"pn_gcm"] = fcmPayload;
        }
    }
    
    if (payload.count && self.debugging) {
        payload[@"pn_debug"] = @YES;
    }
    
    return payload;
}

#pragma mark -


@end
