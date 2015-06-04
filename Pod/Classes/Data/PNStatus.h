#import "PNResult.h"
#import "PNStructures.h"


/**
 @brief      Class which is used to describe error response from server or any non-request related
             client state changes.
 @discussion In case of error this instance may contain service response in \c data. Also this 
             object hold additional information about current client state.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNStatus : PNResult


///------------------------------------------------
/// @name Recovery
///------------------------------------------------

/**
 @brief      Try to resend request associated with processing status object.
 @discussion Some operations which perform automatic retry attempts will ignore method call.

 @since 4.0
 */
- (void)retry;

/**
 @brief  For some requests client try to resend them to \b PubNub for processing.
 @discussion This method can be performed only on operations which respond with \c YES on
             \c willAutomaticallyRetry property. Other operation types will ignore method call.

 @since 4.0
 */
- (void)cancelAutomaticRetry;

#pragma mark -


@end
