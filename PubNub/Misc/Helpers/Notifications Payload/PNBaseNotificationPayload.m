/**
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
*/
#import "PNBaseNotificationPayload+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNBaseNotificationPayload ()


#pragma mark - Information

/**
 * @brief Platform specific notification payload.
 */
@property (nonatomic, strong) NSMutableDictionary *payload;

/**
 * @brief Additional information which may explain reason why this notification has been delivered.
 */
@property (nonatomic, nullable, copy) NSString *subtitle;

/**
 * @brief Number which should be shown in space designated by platform (for example atop of
 * application icon).
 */
@property (nonatomic, nullable, strong) NSNumber *badge;

/**
 * @brief Path to file with sound or name of system sound which should be played upon notification
 * receive.
 */
@property (nonatomic, nullable, copy) NSString *sound;

/**
 * @brief Short text which should be shown at the top of notification instead of application name.
 */
@property (nonatomic, nullable, copy) NSString *title;

/**
 * @brief Message which should be shown in notification body (under title line).
 */
@property (nonatomic, nullable, copy) NSString *body;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize and configure platform specific notification payload builder.
 *
 * @param payloadStorage Mutable dictionary which can be used to store user-provided information.
 * @param title Short text which should be shown at the top of notification instead of application
 *     name.
 * @param body Message which should be shown in notification body (under title line).
 *
 * @return Initialized and ready to use platform specific notification payload builder.
 */
- (instancetype)initWithStorage:(NSMutableDictionary *)payloadStorage
              notificationTitle:(nullable NSString *)title
                           body:(nullable NSString *)body;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNBaseNotificationPayload


#pragma mark - Initialization & Configuration

+ (instancetype)payloadWithStorage:(NSMutableDictionary *)payloadStorage
                 notificationTitle:(NSString *)title
                              body:(NSString *)body {
    
    return [[self alloc] initWithStorage:payloadStorage notificationTitle:title body:body];
}

- (instancetype)initWithStorage:(NSMutableDictionary *)payloadStorage
              notificationTitle:(NSString *)title
                           body:(NSString *)body {
    
    if ((self = [super init])) {
        _payload = payloadStorage;
        
        [self setDefaultPayloadStructure];
        self.title = title;
        self.body = body;
    }
    
    return self;
}

#pragma mark -


@end
