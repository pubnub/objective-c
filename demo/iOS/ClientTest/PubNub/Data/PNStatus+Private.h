/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNStatus.h"


#pragma mark Private interface declaration

@interface PNStatus ()


#pragma mark - Information

@property (nonatomic, assign, getter = isError) BOOL error;
@property (nonatomic, strong) id associatedObject;
@property (nonatomic, assign, getter = willAutomaticallyRetry) BOOL automaticallyRetry;

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
 @brief      Construct status object using result information.
 @discussion Status can be built for API processing errors as well as for client state changes.

 @param result Reference on request processing results which changed client state.

 @return Created and ready to use status instance.

 @since 4.0
 */
+ (instancetype)statusFromResult:(PNResult *)result;

/**
 @brief      Construct status object with pre-defined information about request and how well
             processing was.
 @discussion Status can be built for API processing errors as well as for client state changes.

 @param request  Reference on base request object which is used to identify API endpoint type and
                 set of parameters which should be sent to \b PubNub service along with it.
 @param response Reference on request processing response from service.
 @param error    Reference on request processing error. Sometime error can include server response.
 @param data     Reference on data which is bound to processing/client state.

 @return Created and ready to use status instance.

 @since 4.0
 */
+ (instancetype)statusForRequest:(PNRequest *)request withResponse:(NSHTTPURLResponse *)response
                           error:(NSError *)error andData:(id <NSObject, NSCopying>)data;

/**
 @brief      Initialize status object with pre-defined information about request and how well
             processing was.
 @discussion Status can be built for API processing errors as well as for client state changes.

 @param request  Reference on base request object which is used to identify API endpoint type and
                 set of parameters which should be sent to \b PubNub service along with it.
 @param response Reference on request processing response from service.
 @param error    Reference on request processing error. Sometime error can include server response.
 @param data     Reference on data which is bound to processing/client state.

 @return Initialized and ready to use status instance.

 @since 4.0
 */
- (instancetype)initForRequest:(PNRequest *)request withResponse:(NSHTTPURLResponse *)response
                         error:(NSError *)error andData:(id <NSObject, NSCopying>)data;

#pragma mark - 


@end
