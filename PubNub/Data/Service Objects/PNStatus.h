#import <PubNub/PNOperationResult.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// General operation (request or client generated) status object.
///
/// This is a general object which is used to represent basic information about processing result. Additional
/// information about error or remote origin response on resource access or data push may be provided by its subclasses.
@interface PNStatus : PNOperationResult


#pragma mark - Properties

/// Stringify request processing status.
///
/// Stringify processing `category` field (one of the `PNStatusCategory` enum).
@property(strong, nonatomic, readonly) NSString *stringifiedCategory;

/// Whether service returned error response or not.
@property(assign, nonatomic, readonly, getter = isError) BOOL error;

/// Represent request processing status object using `PNStatusCategory` enum fields.
@property(assign, nonatomic, readonly) PNStatusCategory category;


#pragma mark - Properties (deprecated)

/// Request auto-retry configuration information.
///
/// > Important: This property always will return `NO` because it is possible to set request retries configuration when
/// setup **PubNub** client instance.
@property (nonatomic, readonly, assign, getter = willAutomaticallyRetry) BOOL automaticallyRetry
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. Please call "
                             "endpoint with already created request instance or setup retry configuration during PubNub"
                             " instance configuration.");


#pragma mark - Recovery (deprecated)

/// Try to resent request associated with processing status object.
///
/// > Important: This method **won't resend the failed request**. Error status will be created only when all retry
/// attempts configured when **PubNub** client has been set up will be exhausted. Next retry can be done manually by
/// sending the same request object which has been used for the initial call.
- (void)retry 
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with the next major update. Please call "
                             "endpoint with already created request instance or setup retry configuration during PubNub"
                             " instance configuration.");

/// For some requests client try to resent them to **PubNub** for processing.
///
/// > Important: This method **won't interrupt configured automatic retry**. Retry will stop when all configured retry
/// attempts will be exhausted.
- (void)cancelAutomaticRetry
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with the next major update. Retry will stop "
                             "when all configured retry attempts will be exhausted.");

#pragma mark -


@end

NS_ASSUME_NONNULL_END
