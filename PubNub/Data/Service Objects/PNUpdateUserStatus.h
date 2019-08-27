#import "PNAcknowledgmentStatus.h"
#import "PNServiceData.h"
#import "PNUser.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Objects API response for \c update \c user request.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNUpdateUserData : PNServiceData


#pragma mark - Information

/**
 * @brief Updated user object.
 */
@property (nonatomic, nullable, readonly, strong) PNUser *user;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to processed \c update \c user request results.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNUpdateUserStatus : PNAcknowledgmentStatus


#pragma mark - Information

/**
 * @brief \c Update \c user request processed information.
 */
@property (nonatomic, readonly, strong) PNUpdateUserData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
