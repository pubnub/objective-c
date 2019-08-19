#import "PNStructures.h"
#import "PNRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Base class for all Object API endpoints which has shared query options.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNBaseObjectsRequest : PNRequest


#pragma mark - Information

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Available values depends from object type for which request created. So far following
 *   helper \a types available: \b PNMembershipFields, \b PNMemberFields,
 *   \b PNSpaceFields, \b PNUserFields.
 * @note Omit this property if you don't want to retrieve additional attributes.
 */
@property (nonatomic, assign) NSUInteger includeFields;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
