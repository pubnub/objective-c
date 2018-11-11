#import "PNStatus.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief  Class which is used to provide access to additional data available to describe error status
         object.
         In most cases this object may represent information related to \b PAM error scope.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNErrorData : PNServiceData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  List of channels for which error has been triggered.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSArray<NSString *> *channels;

/**
 @brief  List of channel groups for which error has been triggered.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSArray<NSString *> *channelGroups;

/**
 @brief  Service-provided information about error.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSString *information;

/**
 @brief  Service-provided additional information about error.
 
 @since 4.0
 */
@property (nonatomic, nullable, readonly, strong) id data;

#pragma mark -


@end



/**
 @brief  Class which is used to provide information about why request processing did fail. Status can be 
         returned by server or on local error event.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNErrorStatus : PNStatus


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief      Stores reference on additional information related to error status object.
 @discussion If error status arrived from \b PubNub network in most cases it will be because of \b PAM errors.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNErrorData *errorData;

/**
 @brief  Reference on data object which hold additional information about error and why it happened.
 
 @since 4.0.2
 */
@property (nonatomic, nullable, readonly, strong) id associatedObject;

#pragma mark - 


@end

NS_ASSUME_NONNULL_END
