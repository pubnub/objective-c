#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PubNub;


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Published messages sequence tracking manager.
 @discussion \b PubNub client allow to assign for each published messages it's sequence number. Manager allow 
             to keep track on published sequence number even after application restart.
 
 @author Sergey Mamontov
 @since 4.5.2
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNPublishSequence : NSObject


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on sequence number which has been used for recent message publish API usage.
 
 @since 4.5.2
 */
@property (nonatomic, readonly, assign) NSUInteger sequenceNumber;

/**
 @brief  Retrieve sequence number for next message and update current value if requested.
 
 @param shouldUpdateCurrent Whether current value should be set to the one which is returned by this method.
 
 @return Next published message sequence number.
 
 @since 4.5.2
 */
- (NSUInteger)nextSequenceNumber:(BOOL)shouldUpdateCurrent;


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief      Create and configure published messages sequence manager.
 @discussion If instance for same publish key already created it will be reused.
 
 @param client Reference on client for which published messages sequence manager should be created.
 
 @return Configured and ready to use client published messages sequence manager.
 
 @since 4.5.2
 */
+ (instancetype)sequenceForClient:(PubNub *)client;

/**
 @brief      Reset all information which is related to publish message sequence.
 @discussion All data will be reset and removed from \b Keychain.
 */
- (void)reset;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
