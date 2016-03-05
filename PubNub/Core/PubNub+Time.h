#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


#pragma mark Class forward

@class PNErrorStatus, PNTimeResult;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Types

/**
 @brief  Time request completion block.
 
 @param result Reference on result object which describe service response on time request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNTimeCompletionBlock)(PNTimeResult * _Nullable result, PNErrorStatus * _Nullable status);


#pragma mark - API group interface

/**
 @brief \b PubNub client core class extension to provide access to 'time' API group.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PubNub (Time)


///------------------------------------------------
/// @name Time token request
///------------------------------------------------

/**
 @brief      Request current time from \b PubNub service servers.
 @discussion \b Example:
 
 @code
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client timeWithCompletion:^(PNTimeResult * _Nullable result, PNErrorStatus * _Nullable status) {
     
    // Check whether request successfully completed or not.
    if (!status.isError) {
        
        // Handle downloaded server time token using: result.data.timetoken
    }
    // Request processing failed.
    else {
    
        // Handle tmie token download error. Check 'category' property to find out possible
        // issue because of which request did fail.
        //
        // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param block Time request process results handling block which pass two arguments: \c result - in 
              case of successful request processing \c data field will contain server-provided time 
              token; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)timeWithCompletion:(PNTimeCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
