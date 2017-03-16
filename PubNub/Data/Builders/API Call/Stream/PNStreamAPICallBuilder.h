#import "PNAPICallBuilder.h"
#import "PNStructures.h"


#pragma mark Class forward

@class PNStreamModificationAPICallBuilder, PNStreamAuditAPICallBuilder;


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Stream API call builder.
 @discussion Class describe interface which provide access to various stream manipulation and audition 
             endpoints.
 
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNStreamAPICallBuilder : PNAPICallBuilder


///------------------------------------------------
/// @name Stream state manipulation
///------------------------------------------------

/**
 @brief      Stores reference on construction block which return \c builder for stream state modification API.
 @discussion On block call return builder which provide interface for channel(s) \b addition to channel 
             \c group.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStreamModificationAPICallBuilder *(^add)(void);

/**
 @brief      Stores reference on construction block which return \c builder for stream state modification API.
 @discussion On block call return builder which provide interface for channel(s) \b removal from channel 
             \c group.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStreamModificationAPICallBuilder *(^remove)(void);


///------------------------------------------------
/// @name Stream state audit
///------------------------------------------------

/**
 @brief      Stores reference on construction block which return \c builder for stream state audit API.
 @discussion On block call return builder which provide interface for stream state audit (retrieve list of 
             channels which belong to provided channel \c group).
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStreamAuditAPICallBuilder *(^audit)(void);

#pragma mark - 


@end

NS_ASSUME_NONNULL_END
