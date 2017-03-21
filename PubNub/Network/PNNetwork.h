#import <Foundation/Foundation.h>
#import "PNStructures.h"


#pragma mark Class forward

@class PNRequestParameters, PubNub;


/**
 @brief      Class which translate \b PubNub operations to request for \b PubNub network.
 @discussion Intermediate layer between \b PubNub client operations and networking which is used to send 
             network request to \b PubNub service.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNNetwork : NSObject


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Construct \b PubNub network manager with predefined options.
 
 @param client             Reference on client for which this network manager is creating.
 @param timeout            Maximum time which manager should wait for response on request.
 @param maximumConnections Maximum simultaneously connections (requests) which can be opened.
 @param longPollEnabled    Whether \b PubNub network manager should be configured for long-poll requests or 
                           not. This option affect the way how network manager handle reset.
 
 @return 4.0
 
 @since Constructed and ready to use \b PubNub network manager.
 */
+ (instancetype)networkForClient:(PubNub *)client requestTimeout:(NSTimeInterval)timeout
              maximumConnections:(NSInteger)maximumConnections longPoll:(BOOL)longPollEnabled;


///------------------------------------------------
/// @name Request processing
///------------------------------------------------

/**
 @brief      Process passed operation using set of parameters.
 @discussion Translate client operation to actual request to \b PubNub network.
 
 @param operationType One of \b PNOperationType enumerator fields which describe what kind of operation should
                      be executed by client.
 @param parameters    Request parameters representation object.
 @param data          Reference on binary data which should be pushed to \b PubNub network along with request.
 @param block         Depending on operation type it can be \b PNResultBlock, \b PNStatusBlock or
                      \b PNCompletionBlock blocks.`
 
 @since 4.0
 */
- (void)processOperation:(PNOperationType)operationType
          withParameters:(PNRequestParameters *)parameters data:(NSData *)data
         completionBlock:(id)block;

/**
 @brief  Fetch list of active requests and cancel their processing.
 
 @since 4.0
 */
- (void)cancelAllRequests;

/**
 @brief  Invalidate network communication layer.
 
 @since 4.1.1
 */
- (void)invalidate;


///------------------------------------------------
/// @name Handlers
///------------------------------------------------

#if TARGET_OS_IOS

/**
 @brief      Handle \b PubNub client transition to inactive satate.
 @discussion Depending from network manager configuration it may request from system more time to complete 
             already scheduled data tasks.
 
 @since 4.5.0
 */
- (void)handleClientWillResignActive;

/**
 @brief      Handle \b PubNub client transition to active satate.
 @discussion If network manager requested from system more time to complete tasks processing it will cancel 
             this request.
 
 @since 4.5.0
 */
- (void)handleClientDidBecomeActive;

#endif // TARGET_OS_IOS


///------------------------------------------------
/// @name Operation information
///------------------------------------------------

/**
 @brief  Calculate actual size of packet for passed \c operationType which will be sent to \b PubNub network.
 
 @param operationType One of \b PNOperationType enum fields which specify for what kind of operation packet 
                      size should be calculated.
 @param parameters    List of passed parameters which should be passed to URL builder.
 @param data          Data which can be pushed along with request to \b PubNub network if required.
 
 @return Size of the packet which include request string, host, headers and HTTP post body.
 
 @since 4.0
 */
- (NSInteger)packetSizeForOperation:(PNOperationType)operationType
                     withParameters:(PNRequestParameters *)parameters data:(NSData *)data;

#pragma mark -


@end
