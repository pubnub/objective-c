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


#pragma mark - Properties (deprecated)

/// Request auto-retry configuration information.
///
/// > Important: This property always will return `NO` because it is possible to set request retries configuration when
/// setup **PubNub** client instance.
@property(assign, nonatomic, getter = willAutomaticallyRetry) BOOL automaticallyRetry
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. Please call "
                             "endpoint with already created request instance or setup retry configuration during PubNub"
                             " instance configuration.");

/// Block which can be used to cancel automatic retry on requests.
///
/// > Important: This property won't be used by the client code anymore.
@property(copy, nullable, nonatomic) dispatch_block_t retryCancelBlock
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. Please call "
                             "endpoint with already created request instance or setup retry configuration during PubNub"
                             " instance configuration.");

/// Block which can be used to retry request processing.
///
/// > Important: This property won't be used by the client code anymore.
@property(copy, nullable, nonatomic) dispatch_block_t retryBlock
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. Please call "
                             "endpoint with already created request instance or setup retry configuration during PubNub"
                             " instance configuration.");


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
