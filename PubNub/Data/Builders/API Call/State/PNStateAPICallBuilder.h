#import "PNAPICallBuilder.h"
#import "PNStructures.h"


#pragma mark Class forward

@class PNStateModificationAPICallBuilder, PNStateAuditAPICallBuilder;


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      State API call builder.
 @discussion Class describe interface which provide access to various state manipulation and audition 
             endpoints.
 
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNStateAPICallBuilder : PNAPICallBuilder


///------------------------------------------------
/// @name Presence state manipulation
///------------------------------------------------

/**
 @brief      Stores reference on construction block which return \c builder which is responsible for access to presence state modification.
 @discussion On block call return builder which provide interface for user presence state modification.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStateModificationAPICallBuilder *(^set)(void);


///------------------------------------------------
/// @name Presence state audition
///------------------------------------------------

/**
 @brief      Stores reference on construction block which return \c builder which is responsible for access, to presence state audit.
 @discussion On block call return builder which provide interface for user's presence state audit (retrieve 
             state information which has been set for user on \c channel and / or channel \c group).
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStateAuditAPICallBuilder *(^audit)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
