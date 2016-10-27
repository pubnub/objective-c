/**
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNConfiguration.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNConfiguration (Private)


#pragma mark - Properties

/**
 @brief      Stores reference on unique instance identifier.
 @discussion Identifier used by presence service to track multiple clients which is configured for same 
             \c uuid and trigger events like \c leave only if all client instances not subscribed for
             particular channel. \c timeout event can be triggered only if all clients went \c offline 
             (w/o unsubscription)

 @since 4.5.4
 */
@property (nonatomic, readonly, copy) NSString *instanceID;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
