/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNResponse.h"


#pragma mark Private interface declaration

@interface PNResponse (Private)


///------------------------------------------------
/// @name Initialization and configuration
///------------------------------------------------

/**
 @brief  Construct response holder instance with predefined configuration (the only way to pass data
         into this class).

 @param response Reference on HTTP response from \b PubNub service for \c request sent by client.
 @param request  Reference on request which has been used to communicate with \b PubNub service.
 @param data     Reference on pre-processed data received from service.
 @param error    Reference on \a NSError instance in case if any issues appeared while request was
                 on processing.

 @return Configured and ready to use response instance.

 @since 4.0
 */
+ (instancetype)responseWith:(NSHTTPURLResponse *)response forRequest:(NSURLRequest *)request
                    withData:(id)data andError:(NSError *)error;

/**
 @brief  Initialize response holder instance with predefined configuration (the only way to pass
         data into this class).

 @param response Reference on HTTP response from \b PubNub service for \c request sent by client.
 @param request  Reference on request which has been used to communicate with \b PubNub service.
 @param data     Reference on pre-processed data received from service.
 @param error    Reference on \a NSError instance in case if any issues appeared while request was
                 on processing.

 @return Initialized and ready to use response instance.

 @since 4.0
 */
- (instancetype)initWith:(NSHTTPURLResponse *)response forRequest:(NSURLRequest *)request
                withData:(id)data andError:(NSError *)error;

#pragma mark -


@end
