/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNStatus.h"


#pragma mark Private interface declaration

@interface PNStatus ()


#pragma mark - Information

@property (nonatomic, assign) PNStatusCategory category;
@property (nonatomic, assign, getter = isError) BOOL error;
@property (nonatomic, assign, getter = willAutomaticallyRetry) BOOL automaticallyRetry;
@property (nonatomic, strong) NSNumber *currentTimetoken;
@property (nonatomic, strong) NSNumber *lastTimetoken;
@property (nonatomic, copy) NSArray *subscribedChannels;
@property (nonatomic, copy) NSArray *subscribedChannelGroups;

/**
 @brief      Stores reference on block which can be used to retry request processing.
 @discussion This blocks provided only for requests which won't be auto-restarted by client.

 @since 4.0
 */
@property (nonatomic, copy) dispatch_block_t retryBlock;

/**
 @brief      Stores reference on block which can be used to cancel automatic retry on requests.
 @discussion Usually requests resent by client \b 1 second late after failure and this is time when
             request can be canceled by user using \c -cancelAutomaticRetry method.

 @since 4.0
 */
@property (nonatomic, copy) dispatch_block_t retryCancelBlock;


#pragma mark - Initialization and configuration

/**
 @brief  Construct minimal object to describe state using operation type and status category 
         information.
 
 @param operation Type of operation for which this status report.
 @param category  Operation processing status category.
 
 @return Constructed and ready to use status object.
 
 @since 4.0
 */
+ (instancetype)statusForOperation:(PNOperationType)operation category:(PNStatusCategory)category;

/**
 @brief  Alter status category.
 
 @param category One of \b PNStatusCategory enum fields which should be applied on status object
                 \c category property.
 
 @since 4.0
 */
- (void)updateCategory:(PNStatusCategory)category;

#pragma mark -


@end
