#import <PubNub/PNBaseObjectsRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Set UUID metadata` request.
@interface PNSetUUIDMetadataRequest : PNBaseObjectsRequest


#pragma mark - Properties

/// Additional / complex attributes which should be associated with `metadata`.
@property(strong, nullable, nonatomic) NSDictionary *custom;

/// Identifier from external service (database, auth service).
@property(copy, nullable, nonatomic) NSString *externalId;

/// URL at which profile available.
@property(copy, nullable, nonatomic) NSString *profileUrl;

/// Bitfield set to fields which should be returned with response.
///
/// > Note: Supported keys specified in **PNUUIDFields** enum.
/// > Note:  Default value (**PNUUIDCustomField** ) can be reset by setting `0`.
@property(assign, nonatomic) PNUUIDFields includeFields;

/// UUID's `metadata` object `status`.
@property(strong, nullable, nonatomic) NSString *status;

/// UUID's `metadata` object `type`.
@property(strong, nullable, nonatomic) NSString *type;

/// Email address.
@property(copy, nullable, nonatomic) NSString *email;

/// Name which should be stored in `metadata` associated with specified `identifier`.
@property(copy, nullable, nonatomic) NSString *name;


#pragma mark - Initialization and Configuration

/// Create `Set UUID metadata` request.
///
/// - Parameter uuid: Identifier with which `metadata` is linked. Will be set to current **PubNub** configuration 
/// `uuid` if `nil` is set.
/// - Resturns: Ready to use `set UUID metadata` request.
+ (instancetype)requestWithUUID:(nullable NSString *)uuid;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
