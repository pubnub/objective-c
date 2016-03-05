/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNConfiguration.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNConfiguration (Protected)


#pragma mark - Configuration

/**
 @brief Stores reference on unique device identifier based on bundle identifier used by software vendor.

 @since 4.0
 */
@property (nonatomic, readonly, copy) NSString *deviceID;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
