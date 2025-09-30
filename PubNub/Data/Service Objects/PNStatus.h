#import <PubNub/PNOperationResult.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// General operation (request or client generated) status object.
///
/// This is a general object which is used to represent basic information about processing result. Additional
/// information about error or remote origin response on resource access or data push may be provided by its subclasses.
@interface PNStatus : PNOperationResult


#pragma mark - Properties

/// Stringify request processing status.
///
/// Stringify processing `category` field (one of the `PNStatusCategory` enum).
@property(strong, nonatomic, readonly) NSString *stringifiedCategory;

/// Whether service returned error response or not.
@property(assign, nonatomic, readonly, getter = isError) BOOL error;

/// Represent request processing status object using `PNStatusCategory` enum fields.
@property(assign, nonatomic, readonly) PNStatusCategory category;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
