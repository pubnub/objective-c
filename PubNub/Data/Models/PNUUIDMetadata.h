#import <PubNub/PNBaseAppContextObject.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `UUID Metadata` object.
@interface PNUUIDMetadata : PNBaseAppContextObject


#pragma mark - Properties

/// Identifier from external service (database, auth service).
@property(copy, nullable, nonatomic, readonly) NSString *externalId;

/// URL at which profile available.
@property(copy, nullable, nonatomic, readonly) NSString *profileUrl;

/// Email address.
@property(copy, nullable, nonatomic, readonly) NSString *email;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-property-synthesis"
/// `User`'s object status.
@property(copy, nullable, nonatomic, readonly) NSString *status;
#pragma clang diagnostic pop

/// Name which should be stored in `metadata` associated with specified `uuid`.
@property(copy, nullable, nonatomic, readonly) NSString *name;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-property-synthesis"
/// `User`'s object type information.
@property(copy, nullable, nonatomic, readonly) NSString *type;
#pragma clang diagnostic pop

/// `UUID` with which `metadata` has been associated.
@property(copy, nonatomic, readonly) NSString *uuid;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
