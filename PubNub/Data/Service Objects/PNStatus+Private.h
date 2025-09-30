#import "PNStatus.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General operation (request or client generated) status object private extension.
@interface PNStatus () <NSCopying>


#pragma mark - Properties

/// Channel group names list on which client currently subscribed.
@property(copy, nonatomic) NSArray<NSString *> *subscribedChannelGroups;

/// Class which should be used to deserialize ``responseData``.
@property(class, strong, nonatomic, readonly) Class statusDataClass;

/// List of channels on which client currently subscribed.
@property(copy, nonatomic) NSArray<NSString *> *subscribedChannels;

/// Whether request require network availability check or not.
@property(assign, nonatomic) BOOL requireNetworkAvailabilityCheck;

/// **PubNub** server region identifier (which generated `currentTimetoken` value).
@property(strong, nonatomic) NSNumber *currentTimeTokenRegion;

/// Previous time token region which has been used in subscription cycle to receive `currentTimeTokenRegion` along with
/// other events.
@property(strong, nonatomic) NSNumber *lastTimeTokenRegion;

/// Whether service returned error response or not.
@property(assign, nonatomic, getter = isError) BOOL error;

/// Time token which has been used to establish current subscription cycle.
@property(strong, nonatomic) NSNumber *currentTimetoken;

/// Represent request processing status object using `PNStatusCategory` enum fields.
@property(assign, nonatomic) PNStatusCategory category;

/// Previous time token which has been used in subscription cycle to receive `currentTimetoken` along with other events.
@property(strong, nonatomic) NSNumber *lastTimeToken;


#pragma mark - Initialization and Configuration

/// Create operation status object.
///
/// - Parameters:
///   - operation: Type of operation for which status object has been created.
///   - category: Operation processing status category.
///   - response: Processed operation outcome data object.
/// - Returns: Ready to use operation status object.
+ (instancetype)objectWithOperation:(PNOperationType)operation
                           category:(PNStatusCategory)category
                           response:(nullable id)response;

/// Change status category.
///
/// - Parameter category: One of **PNStatusCategory** enum fields which should be applied on status object `category`
/// property.
- (void)updateCategory:(PNStatusCategory)category;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
