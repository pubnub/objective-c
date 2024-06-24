#import "PNBaseObjectsMembershipRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General request for all `App Context Membership / Members` API endpoints private extension.
@interface PNBaseObjectsMembershipRequest (Private)


#pragma mark - Membership / members management

/**
 * @brief Set information about relation to objects.
 *
 * @discussion Method should be used to set linkage between \c UUID and \c channel.
 *
 * @param objectType Type of objects (known \b channel and \b uuid )
 * @param objects List of objects with additional information which should be used to create
 * relation.
 */
- (void)setRelationToObjects:(NSArray<NSDictionary *> *)objects ofType:(NSString *)objectType;

/**
 * @brief Remove information about relation to objects.
 *
 * @discussion Method should be used to remove linkage between \c UUID and \c channel.
 *
 * @param objectType Type of objects (known \b channel and \b uuid )
 * @param objects List of object identifiers which should be used to remove relation.
 */
- (void)removeRelationToObjects:(NSArray<NSString *> *)objects ofType:(NSString *)objectType;


#pragma mark - Serialization

/**
 * @brief Serialize input array of object dictionaries into structure required by API.
 *
 * @note This method check provided \c custom field value and create \b parametersError if it
 * contain not allowed data types. If \b parametersError is set, method won't process passed
 * \c objects.
 *
 * @param objectType Type of object for which information should be serialized (known \b channel
 *   and \b uuid )
 * @param objects List of \c object dictionaries which should be serialized.
 *
 * @return Objects which describe passed objects in required by Objects API structure.
 */
- (NSArray *)serializedObjectType:(NSString *)objectType
                        fromArray:(NSArray<NSDictionary *> *)objects;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
