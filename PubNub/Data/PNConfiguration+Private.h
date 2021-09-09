/**
 * @author Sergey Mamontov
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PNConfiguration.h"


#pragma mark Private interface declaration

NS_ASSUME_NONNULL_BEGIN

@interface PNConfiguration (Private)


#pragma mark - Information

/**
 * @brief Token which is used along with every request to \b PubNub service to identify client user.
 *
 * @discussion \b PubNub service provide \b PAM (PubNub Access Manager) functionality which allow to
 * specify access rights to access \b PubNub services with provided \c publishKey and
 * \c subscribeKey keys.
 * Access can be limited to concrete users. \b PAM system use this key to check whether client user
 * has rights to access to required service or not.
 *
 * @warning If \c authToken is set if till be used instead of \c authKey.
 *
 * @default By default this value set to \b nil.
 */
@property (nonatomic, nullable, copy) NSString *authToken;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
