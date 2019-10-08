#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PubNub;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface declaration

/**
 * @brief Published messages sequence tracking manager.
 *
 * @discussion \b PubNub client allow to assign for each published messages it's sequence number.
 * Manager allow to keep track on published sequence number even after application restart.
 *
 * @author Sergey Mamontov
 * @version 4.10.2
 * @since 4.5.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNPublishSequence : NSObject


#pragma mark - Information

/**
 * @brief Sequence number which has been used for recent message publish API usage.
 */
@property (nonatomic, readonly, assign) NSUInteger sequenceNumber;

/**
 * @brief Sequence number for next message and update current value if requested.
 *
 * @param shouldUpdateCurrent Whether current value should be set to the one which is returned by
 * this method.
 *
 * @return Next published message sequence number.
 */
- (NSUInteger)nextSequenceNumber:(BOOL)shouldUpdateCurrent;


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure published messages sequence manager.
 *
 * @note If instance for same publish key already created it will be reused.
 *
 * @param client Client for which published messages sequence manager should be created.
 *
 * @return Configured and ready to use client published messages sequence manager.
 */
+ (instancetype)sequenceForClient:(PubNub *)client;

/**
 * @brief Reset all information which is related to publish message sequence.
 *
 * @discussion All data will be reset and removed from \b Keychain.
 */
- (void)reset;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
