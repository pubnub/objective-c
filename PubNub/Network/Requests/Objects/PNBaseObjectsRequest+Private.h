#import "PNBaseObjectsRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General request for all `App Context` API endpoints private extension.
@interface PNBaseObjectsRequest (Private)


#pragma mark - Information

/// Whether entity identifier required to complete request or not.
@property(assign, nonatomic, readonly, getter = isIdentifierRequired) BOOL identifierRequired;

/// Unique `object` identifier.
@property(copy, nonatomic) NSString *identifier;

/// Bitfield set to fields which should be returned with response.
///
/// > Note: Available values depends from object type for which request created. So far following helper `types`
/// available: **PNMembershipFields**, **PNChannelMemberFields**, **PNChannelFields**, and **PNUUIDFields**.
@property(assign, nonatomic) NSUInteger includeFields;


#pragma mark - Initialization and Configuration

/// Initialize general `App Context` request for identifiable object.
///
/// - Parameters:
///   - objectType: Name of object type (so far known: `UUID` and `Channel`).
///   - identifier: Identifier of `object` for which request created.
/// - Returns: Initialized general `App Context` request.
- (instancetype)initWithObject:(NSString *)objectType identifier:(nullable NSString *)identifier;


#pragma mark - Misc

/// Add another data field to `include` query fields set.
///
/// - Parameters:
///   -  fields: List of names of data fields which should be added to `include` list.
///   -  query: Request's query object which is used to build actual network request.
- (void)addIncludedFields:(NSArray<NSString *> *)fields toQuery:(NSMutableDictionary *)query;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
