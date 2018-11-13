#import "PNResult.h"
#import "PNStructures.h"



NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Class which is used to describe error response from server or any non-request related client
             state changes.
 @discussion In case of error this instance may contain service response in \c data. Also this object hold 
             additional information about current client state.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNStatus : PNResult


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  One of \b PNStatusCategory fields which provide information about for which status this instance has 
         been created.
 
 @return Processing status category.

 @since 4.0
 */
@property (nonatomic, readonly, assign) PNStatusCategory category;

/**
 @brief  Whether status object represent error or not.
 
 @return \c YES in case if status represent request processing error.
 
 @since 4.0
 */
@property (nonatomic, readonly, assign, getter = isError) BOOL error;

/**
 @brief      Auto-retry configuration information.
 @discussion In most cases client will keep retry request sending till it won't be successful or canceled with
             \c -cancelAutomaticRetry method.
 
 @return \c YES in case if request which represented with this failed status will be resent
         automatically or not.

 @since 4.0
 */
@property (nonatomic, readonly, assign, getter = willAutomaticallyRetry) BOOL automaticallyRetry;

/**
 @brief  Stringified \c category value.
 
 @return Stringified representation for \c category property which store value from \b PNStatusCategory.
 */
- (NSString *)stringifiedCategory;


///------------------------------------------------
/// @name Recovery
///------------------------------------------------

/**
 @brief      Try to resent request associated with processing status object.
 @discussion Some operations which perform automatic retry attempts will ignore method call.

 @since 4.0
 */
- (void)retry;

/**
 @brief  For some requests client try to resent them to \b PubNub for processing.
 @discussion This method can be performed only on operations which respond with \c YES on
             \c willAutomaticallyRetry property. Other operation types will ignore method call.

 @since 4.0
 */
- (void)cancelAutomaticRetry;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
