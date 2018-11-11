#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      API call builder pattern support class.
 * @discussion Class basing on required API protocol collect user-provided arguments and pass them on \c send to
 *             corresponding API end-point.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNAPICallBuilder : NSObject


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent encoded query parameters which should be sent along with
 *     original API call.
 *
 * @return API call configuration builder.
 *
 * @since 4.8.2
 */
@property (nonatomic, readonly, strong) id (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
