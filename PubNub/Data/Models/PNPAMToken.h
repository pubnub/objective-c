#import <Foundation/Foundation.h>


#pragma mark Types & Structures

/**
 * @brief Specific resource permissions mask.
 */
typedef NS_OPTIONS(NSUInteger, PNPAMPermission) {
    PNPAMPermissionNone,
    PNPAMPermissionRead = 1 << 0,
    PNPAMPermissionWrite = 1 << 1,
    PNPAMPermissionManage = 1 << 2,
    PNPAMPermissionDelete = 1 << 3,
    PNPAMPermissionGet = 1 << 5,
    PNPAMPermissionUpdate = 1 << 6,
    PNPAMPermissionJoin = 1 << 7,
    
    PNPAMPermissionCRUD = PNPAMPermissionRead | PNPAMPermissionWrite | PNPAMPermissionUpdate | PNPAMPermissionDelete,
    PNPAMPermissionAll = PNPAMPermissionGet | PNPAMPermissionJoin | PNPAMPermissionCRUD | PNPAMPermissionManage,
};


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interfaces declaration

/**
 * @brief \b PubNub Access Manager resource permission.
 *
 * @discussion Object represent single resource permission information.
 *
 * @author Serhii Mamontov
 * @version 4.17.0
 * @since 4.17.0
 * @copyright © 2010-2021 PubNub, Inc.
 */
@interface PNPAMResourcePermission : NSObject


#pragma mark - Information

/**
  * @brief Value with which instance has been initialized.
 */
@property (nonatomic, readonly, assign) PNPAMPermission value;


#pragma mark -


@end


/**
 * @brief \b PubNub Access Manager resource permissions.
 *
 * @discussion Object represent resource permissions stored in PAM token.
 *
 * @author Serhii Mamontov
 * @version 4.17.0
 * @since 4.17.0
 * @copyright © 2010-2021 PubNub, Inc.
 */
@interface PNPAMTokenResource : NSObject


#pragma mark - Information

/**
 * @brief Permissions granted to specific / regexp matching channels.
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, PNPAMResourcePermission *> *channels;

/**
 * @brief Permissions granted to specific / regexp matching channel groups.
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, PNPAMResourcePermission *> *groups;

/**
 * @brief Permissions granted to specific / regexp matching uuids.
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, PNPAMResourcePermission *> *uuids;

#pragma mark -


@end


/**
 * @brief \b PubNub Access Manager Token.
 *
 * @discussion Object represent decoded token content.
 *
 * @author Serhii Mamontov
 * @version 4.17.0
 * @since 4.17.0
 * @copyright © 2010-2021 PubNub, Inc.
 */
@interface PNPAMToken : NSObject


#pragma mark - Information

/**
 * @brief Token version.
 */
@property (nonatomic, readonly, assign) NSUInteger version;

/**
 * @brief Token generation date time.
 */
@property (nonatomic, readonly, assign) NSUInteger timestamp;

/**
 * @brief Maximum duration (in minutes) during which token will be valid.
 */
@property (nonatomic, readonly, assign) NSUInteger ttl;

/**
 * @brief The uuid that is exclusively authorized to use this token to make API requests.
 */
@property (nonatomic, nullable, readonly, strong) NSString *authorizedUUID;

/**
 * @brief Permissions granted to specific resources.
 */
@property (nonatomic, readonly, strong) PNPAMTokenResource *resources;

/**
 * @brief Permissions granted to resources which match specified regular expression.
 */
@property (nonatomic, readonly, strong) PNPAMTokenResource *patterns;

/**
 * @brief Additional information which has been added to the token.
 */
@property (nonatomic, readonly, strong) NSDictionary *meta;

/**
 * @brief PAM token content signature.
 */
@property (nonatomic, readonly, strong) NSData *signature;

/**
 * @brief Contains error with information about what went wrong in case if token not \c valid.
 */
@property (nonatomic, nullable, readonly, strong) NSError *error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
