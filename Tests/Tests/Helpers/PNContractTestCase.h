#import <Foundation/Foundation.h>
#import <Cucumberish/Cucumberish.h>
#import <PubNub/PubNub.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Base class for contract based tests.
 *
 * @author Serhii Mamontov
 * @copyright © 2010-2021 PubNub, Inc.
 */
@interface PNContractTestCase : NSObject


#pragma mark - Information

/**
 * @brief \b PubNub client configuration which should be used with current scenario.
 */
@property (nonatomic, nullable, readonly, copy) PNConfiguration *configuration;

/**
 * @brief Client configured for current test scenario.
 */
@property (nonatomic, nullable, readonly, strong) PubNub *client;

/**
 * @brief Type of request operation which correspond to tested feature.
 */
@property (nonatomic, assign) PNOperationType testedFeatureType;


#pragma mark - Initialization & Configuration

/**
 * @brief Start listening for Cucumber hook notifications.
 */
- (void)startCucumberHookEventsListening;

/**
 * @brief Setup contract testing environment once per test suite run.
 */
- (void)setup;


#pragma mark - Subscribe handling

/**
 * @brief Subscribe to specified objects and wait for subscribe operation completion.
 *
 * @param client \b PubNub client which should be used for subscribe operation (or default if \c nil).
 * @param channels List of channels to which specified \c client should subscribe.
 * @param groups List of channel groups to which specified \c client should subscribe.
 * @param withPresence Whether specified \c client should subscribe to presence
 *   counterparts of \c channels and \c groups or not.
 * @param timetoken Timetoken from which subscribe should catch up.
 */
- (void)subscribeClient:(nullable PubNub *)client
synchronouslyToChannels:(nullable NSArray *)channels
                 groups:(nullable NSArray *)groups
           withPresence:(BOOL)withPresence
              timetoken:(nullable NSNumber *)timetoken;

/**
 * @brief Unsubscribe from specified objects and wait for unsubscribe operation completion.
 *
 * @param client \b PubNub client which should be used for unsubscribe operation (or default if \c nil).
 * @param channels List of channels from which specified \c client should unsubscribe.
 * @param groups List of channel groups from which specified \c client should unsubscribe.
 * @param withPresence Whether specified \c client should unsubscribe from unsubscribe
 *   counterparts of \c channels and \c groups or not.
 */
- (void)unsubscribeClient:(nullable PubNub *)client
synchronouslyFromChannels:(nullable NSArray *)channels
                   groups:(nullable NSArray *)groups
             withPresence:(BOOL)withPresence;

/**
 * @brief Wait specified \b PubNub client to receive expected number of messages.
 *
 * @param client \b PubNub client which is expecting to receive specific number of messages.
 * @param messagesCount How many messages it is expected to receive.
 * @param channel Channel on which messages expected. All channels for \c client if \c nil.
 *
 * @return List of messages when expected count received.
 */
- (nullable NSArray<PNMessageResult *> *)waitClient:(nullable PubNub *)client
                                  toReceiveMessages:(NSUInteger)messagesCount
                                          onChannel:(nullable NSString *)channel;

/**
 * @brief Wait specified \b PubNub client to receive expected number of status events.
 *
 * @param client \b PubNub client which is expecting to receive specific number of messages.
 * @param statusesCount How many status events it is expected to receive.
 *
 * @return List of statuses when expected count received.
 */
- (nullable NSArray<PNStatus *> *)waitClient:(nullable PubNub *)client
                           toReceiveStatuses:(NSUInteger)statusesCount;


#pragma mark - Result & Status handling

/**
 * @brief Store \c result receiver as result of PubNub REST API call.
 *
 * @param result Result which should be stored for further usage in test verification.
 */
- (void)storeRequestResult:(nullable PNOperationResult *)result;

/**
 * @brief Retrieve recently received PubNub REST API call result.
 *
 * @return Result instance in case if last REST API call was successful.
 */
- (nullable PNOperationResult *)lastResult;

/**
 * @brief Store PubNub REST API call error status object.
 *
 * @param status PubNub REST API call error status object.
 */
- (void)storeRequestStatus:(nullable PNStatus *)status;

/**
 * @brief Retrieve recently received PubNub REST API call error status.
 *
 * @return Status instance in case if last REST API call failed.
 */
- (nullable PNStatus *)lastStatus;


#pragma mark - Hooks handler

/**
 * @brief Called before each scenario run.
 */
- (void)handleBeforeHook;

/**
 * @brief Called after each scenario run.
 */
- (void)handleAfterHook;


#pragma mark - Helpers

/**
 * @brief Check whether running tests for specified feature or not.
 *
 * @param userInfo Dictionary with information about current feature.
 * @param featureName Name of feature which should be check running now.
 *
 * @return \c YES in case if currently running tests for specified feature.
 */
- (BOOL)checkInUserInfo:(NSDictionary *)userInfo testingFeature:(NSString *)featureName;

/**
 * @brief Perform code in provided \c block synchronously.
 *
 * @param block GCD block inside of which code for synchronous execution should be added.
 */
- (void)callCodeSynchronously:(void(^)(dispatch_block_t completion))block;

/**
 * @brief Pause main queue on which tests execution performed on specified amount of time.
 *
 * @param delay For how long main queue should be paused.
 */
- (void)pauseMainQueueFor:(NSTimeInterval)delay;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
