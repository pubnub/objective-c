#import <Foundation/Foundation.h>
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Object which is used to represent \c message \c action.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNMessageAction : NSObject


#pragma mark - Information

/**
 * @brief What feature this \c message \c action represents.
 */
@property (nonatomic, readonly, copy) NSString *type;

/**
 * @brief Timetoken (\b PubNub's high precision timestamp) of \c message for which \c action has
 * been added.
 */
@property (nonatomic, readonly, strong) NSNumber *messageTimetoken;

/**
 * @brief \c Message \c action addition timetoken (\b PubNub's high precision timestamp).
 */
@property (nonatomic, readonly, strong) NSNumber *actionTimetoken;

/**
 * @brief \c Identifier of user which added this \c message \c action.
 */
@property (nonatomic, readonly, copy) NSString *uuid;

/**
 * @brief Value which has been added with \c message \c action \b type.
 */
@property (nonatomic, readonly, copy) NSString *value;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
