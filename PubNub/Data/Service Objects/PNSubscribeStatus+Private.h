/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNSubscribeStatus.h"
#import "PNEnvelopeInformation.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNSubscriberData ()


#pragma mark - Properties

/**
 @brief Stores reference on \b PubNub server region identifier (which generated \c timetoken value).
 
 @since 4.3.0
 */
@property (nonatomic, readonly) NSNumber *region;

/**
 @brief  Stores reference on delivered message enevelop object (data which appended by \b PubNub service 
         mostly because of debug purposes).
 
 @since 4.5.6
 */
@property (nonatomic, nullable, readonly) PNEnvelopeInformation *envelope;

#pragma mark -


@end


#pragma mark Private interface declaration

@interface PNSubscribeStatus ()

@property (nonatomic, strong) PNSubscriberData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
