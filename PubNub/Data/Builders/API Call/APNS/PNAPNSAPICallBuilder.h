#import "PNAPICallBuilder.h"
#import "PNStructures.h"


#pragma mark Class forward

@class PNAPNSModificationAPICallBuilder, PNAPNSAuditAPICallBuilder;


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      APNS API call builder.
 @discussion Class describe interface which provide access to various APNS manipulation and audition 
             endpoints.
 
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNAPNSAPICallBuilder : PNAPICallBuilder


///------------------------------------------------
/// @name APNS state manipulation
///------------------------------------------------

/**
 @brief      Stores reference on construction block which return \c builder which is responsible for push 
             notifications state manipulation.
 @discussion On block call return builder which provide interface for push notification enabling on list of 
             channel(s).
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder *(^enable)(void);

/**
 @brief      Stores reference on construction block which return \c builder which is responsible for push 
             notifications state manipulation.
 @discussion On block call return builder which provide interface for push notification disabling on list of 
             channel(s).
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder *(^disable)(void);


///------------------------------------------------
/// @name APNS state audition
///------------------------------------------------

/**
 @brief      Stores reference on construction block which return \c builder which is responsible for push 
             notifications state audition.
 @discussion On block call return builder which provide interface for push notification state audit (retrieve 
             list of channels for which push notifications has been enabled).
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNAPNSAuditAPICallBuilder *(^audit)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
