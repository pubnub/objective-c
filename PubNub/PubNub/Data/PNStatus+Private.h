/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNStatus.h"
#import "PNRequest.h"


#pragma mark Private interface declaration

@interface PNStatus ()


#pragma mark - Information

@property (nonatomic, assign) PNStatusCategory category;


/**
 @brief  One of \b PNStatusCategory fields which provide a bit detailed information about issue.

 @since 4.0
*/
@property (nonatomic, readonly, assign) PNStatusCategory subCategory;

@property (nonatomic, assign, getter = isTLSEnabled) BOOL TLSEnabled;
@property (nonatomic, copy) NSArray *channels;
@property (nonatomic, copy) NSArray *channelGroups;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *authKey;
@property (nonatomic, copy) NSDictionary *state;
@property (nonatomic, assign, getter = isError) BOOL error;
@property (nonatomic, strong) NSNumber *currentTimetoken;
@property (nonatomic, strong) NSNumber *previousTimetoken;
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
 @brief  Construct minimal object to describe state using operation type and status category 
         information.
 
 @param operation Type of operation for which this status report.
 @param category  Operation processing status category.
 
 @return Constructed and ready to use status object.
 
 @since 4.0
 */
+ (instancetype)statusForOperation:(PNOperationType)operation category:(PNStatusCategory)category;

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
 @param error    Reference on request processing error. Sometime error can include server response.

 @return Created and ready to use status instance.

 @since 4.0
 */
+ (instancetype)statusForRequest:(PNRequest *)request withError:(NSError *)error;

/**
 @brief      Initialize status object with pre-defined information about request and how well
             processing was.
 @discussion Status can be built for API processing errors as well as for client state changes.

 @param request  Reference on base request object which is used to identify API endpoint type and
                 set of parameters which should be sent to \b PubNub service along with it.
 @param error    Reference on request processing error. Sometime error can include server response.

 @return Initialized and ready to use status instance.

 @since 4.0
 */
- (instancetype)initForRequest:(PNRequest *)request withError:(NSError *)error;

/**
 @brief      Sometimes category changed to be used in upper layers of the client, but before 
             delivering
 @discussion Before delivering status to the user, this method allow to return original category
             which has been passed during initalization.
 */
- (void)revertToOriginalCategory;

#pragma mark -


@end
