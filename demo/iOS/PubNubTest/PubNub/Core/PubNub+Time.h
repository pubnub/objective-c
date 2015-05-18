#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


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
 PubNub *client = [PubNub new];
 [client timeWithHandlingBlock:^(PNResult *result, PNStatus *status){
     
     if (result) {
         
         NSLog(@"Time token: %@", result.data);
     }
     else {
         
         NSLog(@"Request failed: %@", status);
     }
 }];
 @endcode
 
 @param block Time request process results handling block which pass two arguments: \c result - in 
              case of successful request processing \c data field will contain server-provided time 
              token; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)timeWithCompletion:(PNCompletionBlock)block;

#pragma mark -


@end
