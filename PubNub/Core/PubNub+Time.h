#import <Foundation/Foundation.h>
#import "PNTimeAPICallBuilder.h"
#import "PubNub+Core.h"


#pragma mark Class forward

@class PNErrorStatus, PNTimeResult;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - API group interface

/**
 @brief \b PubNub client core class extension to provide access to 'time' API group.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PubNub (Time)


///------------------------------------------------
/// @name API Builder support
///------------------------------------------------

/**
 @brief      Stores reference on time API access \c builder construction block.
 @discussion On block call return builder which allow to configure parameters for time API access.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNTimeAPICallBuilder *(^time)(void);


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
[self.client timeWithCompletion:^(PNTimeResult *result, PNErrorStatus *status) {
     
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
- (void)timeWithCompletion:(PNTimeCompletionBlock)block NS_SWIFT_NAME(timeWithCompletion(_:));

#pragma mark -


@end

NS_ASSUME_NONNULL_END
