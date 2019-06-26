/**
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNStatus.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNStatus () <NSCopying>


#pragma mark - Information

/**
 * @brief One of \b PNStatusCategory fields which provide information about for which status this
 * instance has been created.
 */
@property (nonatomic, assign) PNStatusCategory category;

/**
 * @brief Whether status object represent error or not.
 */
@property (nonatomic, assign, getter = isError) BOOL error;

/**
 * @brief Whether client will try to resent request associated with status or not.
 *
 * @discussion In most cases client will keep retry request sending till it won't be successful or
 * canceled with \c -cancelAutomaticRetry method.
 */
@property (nonatomic, assign, getter = willAutomaticallyRetry) BOOL automaticallyRetry;

/**
 * @brief Whether request require network availability check or not.
 *
 * @since 4.8.10
 */
@property (nonatomic, assign) BOOL requireNetworkAvailabilityCheck;

/**
 * @brief Time token which has been used to establish current subscription cycle.
 */
@property (nonatomic, strong) NSNumber *currentTimetoken;

/**
 * @brief Previous time token which has been used in subscription cycle to receive
 * \c currentTimetoken along with other events.
 */
@property (nonatomic, strong) NSNumber *lastTimeToken;

/**
 * @brief \b PubNub server region identifier (which generated \c currentTimetoken value).
 *
 * @since 4.3.0
 */
@property (nonatomic, strong) NSNumber *currentTimeTokenRegion;

/**
 * @brief Previous time token region which has been used in subscription cycle to receive
 * \c currentTimeTokenRegion along with other events.
 *
 * @since 4.3.0
 */
@property (nonatomic, strong) NSNumber *lastTimeTokenRegion;

/**
 * @brief List of channels on which client currently subscribed.
 */
@property (nonatomic, copy) NSArray<NSString *> *subscribedChannels;

/**
 * @brief Channel group names list on which client currently subscribed.
 */
@property (nonatomic, copy) NSArray<NSString *> *subscribedChannelGroups;

/**
 * @brief Block which can be used to retry request processing.
 *
 * @discussion This blocks provided only for requests which won't be auto-restarted by client.
 */
@property (nonatomic, nullable, copy) dispatch_block_t retryBlock;

/**
 * @brief Block which can be used to cancel automatic retry on requests.
 *
 * @discussion Usually requests resent by client \b 1 second late after failure and this is time
 * when request can be canceled by user using \c -cancelAutomaticRetry method.
 */
@property (nonatomic, nullable, copy) dispatch_block_t retryCancelBlock;


#pragma mark - Initialization and configuration

/**
 * @brief Construct minimal object to describe state using operation type and status category
 * information.
 *
 * @param operation Type of operation for which this status report.
 * @param category Operation processing status category.
 *
 * @return Constructed and ready to use status object.
 */
+ (instancetype)statusForOperation:(PNOperationType)operation
                          category:(PNStatusCategory)category
               withProcessingError:(nullable NSError *)error;

/**
 * @brief Alter status category.
 *
 * @param category One of \b PNStatusCategory enum fields which should be applied on status object
 * \c category property.
 */
- (void)updateCategory:(PNStatusCategory)category;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
