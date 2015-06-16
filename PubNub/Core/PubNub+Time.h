#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


#pragma mark - API group protocols

/**
 @brief      Protocol which describe time data object structure.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNTimeData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Current time on \b PubNub network servers.
 
 @return Number with unsigned long long as timestamp.
 
 @since 4.0
 */
- (NSNumber *)timetoken;

@end


/**
 @brief  Protocol which describe operation processing resulting object with typed with \c data field
         with corresponding data type.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNTimeResult <PNResult>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Reference on service response data casted to required type.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSObject<PNTimeData> *data;

@end


#pragma mark - Types

/**
 @brief  Time request completion block.
 
 @param result Reference on result object which describe service response on time request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNTimeCompletionBlock)(PNResult<PNTimeResult> *result,
                                     PNStatus<PNStatus> *status);


#pragma mark - API group interface

/**
 @brief \b PubNub client core class extension to provide access to 'time' API group.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PubNub (Time)


///------------------------------------------------
/// @name Time token request
///------------------------------------------------

/**
 @brief Request current time from \b PubNub service servers.
 
 @code
 @endcode
 \b Example:
 
 @code
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [client timeWithHandlingBlock:^(PNResult<PNTimeResult> *result, PNStatus<PNStatus> *status) {
     
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Handle downloaded server time token using: result.data.timetoken
     }
     // Request processing failed.
     else {
     
         // Handle tmie token download error. Check 'category' property to find out possible
         // issue because of which request did fail.
         //
         // Request can be resend using: [status retry];
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
