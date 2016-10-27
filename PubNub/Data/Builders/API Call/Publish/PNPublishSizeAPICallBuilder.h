#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Publish message size calculation API call builder.
 @discussion Class describe interface which provide ability to calculate resulting size of message which 
             can be published.
 
 @author Sergey Mamontov
 @since <#version#>
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNPublishSizeAPICallBuilder : PNAPICallBuilder


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 @brief      Specify name of channel.
 @discussion On block call return block which consume (\b required) name of \c channel to which \c message 
             size should be calculated.
 
 @since <#version#>
 */
@property (nonatomic, readonly, strong) PNPublishSizeAPICallBuilder *(^channel)(NSString *channel);

/**
 @brief      Specify message.
 @discussion On block call return block which consume Foundation object (\a NSString, \a NSNumber, \a NSArray,
             \a NSDictionary) which will be published.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 @note       Objects can be pushed only to regular channels.
 
 @since <#version#>
 */
@property (nonatomic, readonly, strong) PNPublishSizeAPICallBuilder *(^message)(id message); 

/**
 @brief      Specify message metadata.
 @discussion On block call return block which consume \b NSDictionary with values which should be used by 
             \b PubNub service to filter messages.
 
 @since <#version#>
 */
@property (nonatomic, readonly, strong) PNPublishSizeAPICallBuilder *(^metadata)(NSDictionary *metadata);

/**
 @brief      Specify whether published \c message should be stored or not.
 @discussion On block call return block which consume \a BOOL and specify wheter published \c message should 
             be stored in history / storage or not.
 
 @since <#version#>
 */
@property (nonatomic, readonly, strong) PNPublishSizeAPICallBuilder *(^shouldStore)(BOOL shouldStore);

/**
 @brief      Specify whether published \c message should be compressed or not.
 @discussion On block call return block which consume \a BOOL and specify wheter published \c message should 
             be compressed and sent with \c POST request or not.
 
 @since <#version#>
 */
@property (nonatomic, readonly, strong) PNPublishSizeAPICallBuilder *(^compress)(BOOL compress);

/**
 @brief  Specify whether published \c message should be replicated across the PubNub Real-Time Network and 
         sent simultaneously to all subscribed clients on a channel.
 
 @since <#version#>
 */
@property (nonatomic, readonly, strong) PNPublishSizeAPICallBuilder *(^replicate)(BOOL replicate); 


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 @brief      Perform composed API call.
 @discussion Execute API call and report processing results through passed comnpletion block.
 @discussion On block call return block which consume (\b required) block which should be sent, when message 
             size calculation will be completed.
 
 @since <#version#>
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNMessageSizeCalculationCompletionBlock block);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
