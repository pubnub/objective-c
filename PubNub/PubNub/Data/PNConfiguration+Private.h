/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNConfiguration.h"


#pragma mark Private interface declaration

@interface PNConfiguration (Protected)


#pragma mark - Configuration

/**
 @brief Stores reference on unique device identifier based on bundle identifier used by software
        vendor.

 @since 4.0
 */
@property (nonatomic, readonly, copy) NSString *deviceID;

#pragma mark -


@end
