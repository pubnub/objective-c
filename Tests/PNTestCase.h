#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Types and structures

/**
 * @brief Type used to describe block for message handling.
 *
 * @param client \b PubNub client which used delegate callback.
 * @param message Object with information about received message.
 * @param shouldRemove Whether handling block should be removed after call or not.
 */
typedef void (^PNTClientDidReceiveMessageHandler)(PubNub *client, PNMessageResult *message, BOOL *shouldRemove);

/**
 * @brief Type used to describe block for signal handling.
 *
 * @param client \b PubNub client which used delegate callback.
 * @param signal Object with information about received signal.
 * @param shouldRemove Whether handling block should be removed after call or not.
 */
typedef void (^PNTClientDidReceiveSignalHandler)(PubNub *client, PNSignalResult *signal, BOOL *shouldRemove);

/**
 * @brief Type used to describe block for \c action handling.
 *
 * @param client \b PubNub client which used delegate callback.
 * @param action Object with information about received \c action.
 * @param shouldRemove Whether handling block should be removed after call or not.
 */
typedef void (^PNTClientDidReceiveMessageActionHandler)(PubNub *client, PNMessageActionResult *action, BOOL *shouldRemove);

/**
 * @brief Type used to describe block for presence event handling.
 *
 * @param client \b PubNub client which used delegate callback.
 * @param event Object with information about received presence event.
 * @param shouldRemove Whether handling block should be removed after call or not.
 */
typedef void (^PNTClientDidReceivePresenceEventHandler)(PubNub *client, PNPresenceEventResult *event, BOOL *shouldRemove);

/**
 * @brief Type used to describe block for \c user event handling.
 *
 * @param client \b PubNub client which used delegate callback.
 * @param event Object with information about received \c user event.
 * @param shouldRemove Whether handling block should be removed after call or not.
 */
typedef void (^PNTClientDidReceiveUserEventHandler)(PubNub *client, PNUserEventResult *event, BOOL *shouldRemove);

/**
 * @brief Type used to describe block for \c space event handling.
 *
 * @param client \b PubNub client which used delegate callback.
 * @param event Object with information about received \c space event.
 * @param shouldRemove Whether handling block should be removed after call or not.
 */
typedef void (^PNTClientDidReceiveSpaceEventHandler)(PubNub *client, PNSpaceEventResult *event, BOOL *shouldRemove);

/**
 * @brief Type used to describe block for \c membership event handling.
 *
 * @param client \b PubNub client which used delegate callback.
 * @param event Object with information about received \c membership event.
 * @param shouldRemove Whether handling block should be removed after call or not.
 */
typedef void (^PNTClientDidReceiveMembershipEventHandler)(PubNub *client, PNMembershipEventResult *event, BOOL *shouldRemove);

/**
 * @brief Type used to describe block for status change handling.
 *
 * @param client \b PubNub client which used delegate callback.
 * @param message Object with information about last client status change.
 * @param shouldRemove Whether handling block should be removed after call or not.
 */
typedef void (^PNTClientDidReceiveStatusHandler)(PubNub *client, PNSubscribeStatus *status, BOOL *shouldRemove);


/**
 * @brief Base class for all test cases which provide initial setup.
 *
 * @author Serhii Mamontov
 * @copyright © 2009-2019 PubNub, Inc.
 */
@interface PNTestCase : XCTestCase <PNObjectEventListener>


#pragma mark - Information

/**
 * @brief Number of seconds which should be waited before performing in-test verifications.
 */
@property (nonatomic, readonly, assign) NSTimeInterval delayedCheck;

/**
 * @brief Number of seconds which positive test should wait till async operation completion.
 */
@property (nonatomic, readonly, assign) NSTimeInterval testCompletionDelay;

/**
 * @brief Number of seconds which negative test should wait till async operation completion.
 */
@property (nonatomic, readonly, assign) NSTimeInterval falseTestCompletionDelay;

/**
 * @brief Loaded from \c 'Resources/keysset.plist' file PAM enabled PubNub subscribe key.
 *
 * @since 4.8.8
 */
@property (nonatomic, readonly, strong) NSString *pamSubscribeKey;

/**
 * @brief Loaded from \c 'Resources/keysset.plist' file PAM enabled PubNub publish key.
 *
 * @since 4.8.8
 */
@property (nonatomic, readonly, strong) NSString *pamPublishKey;

/**
 * @brief Loaded from \c 'Resources/keysset.plist' file PubNub subscribe key.
 *
 * @since 4.8.8
 */
@property (nonatomic, readonly, strong) NSString *subscribeKey;

/**
 * @brief Loaded from \c 'Resources/keysset.plist' file PubNub publish key.
 *
 * @since 4.8.8
 */
@property (nonatomic, readonly, strong) NSString *publishKey;

#pragma mark - Mocking

/**
 * @brief Check whether passed \c object has been mocked before or not.
 *
 * @param object Object which should be checked on whether it has been mocked or not.
 *
 * @return Whether mocked \c object passed or not.
 */
- (BOOL)isObjectMocked:(id)object;

/**
 * @brief Create mock object for class.
 *
 * @param object Object for which mock should be created (class or it's instance).
 *
 * @return Object mock.
 */
- (id)mockForObject:(id)object;


#pragma mark - Listeners

/**
 * @brief Add block which will be called for each client status change.
 *
 * @param client \b PubNub client for which state should be tracked.
 * @param handler Block which should be called each client's status change.
 */
- (void)addStatusHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveStatusHandler)handler;

/**
 * @brief Add block which will be called for each received message.
 *
 * @param client \b PubNub client for which messages should be tracked.
 * @param handler Block which should be called each received message.
 */
- (void)addMessageHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveMessageHandler)handler;

/**
 * @brief Add block which will be called for each received signal.
 *
 * @param client \b PubNub client for which signal should be tracked.
 * @param handler Block which should be called each received signal.
 */
- (void)addSignalHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveSignalHandler)handler;

/**
 * @brief Add block which will be called for each received presence change.
 *
 * @param client \b PubNub client for which presence change should be tracked.
 * @param handler Block which should be called each presence change.
 */
- (void)addPresenceHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceivePresenceEventHandler)handler;

/**
 * @brief Add block which will be called for each received \c user event.
 *
 * @param client \b PubNub client for which \c user events should be tracked.
 * @param handler Block which should be called each \c user event.
 */
- (void)addUserHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveUserEventHandler)handler;

/**
 * @brief Add block which will be called for each received \c space event.
 *
 * @param client \b PubNub client for which \c space events should be tracked.
 * @param handler Block which should be called each \c space event.
 */
- (void)addSpaceHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveSpaceEventHandler)handler;

/**
 * @brief Add block which will be called for each received \c membership event.
 *
 * @param client \b PubNub client for which \c membership events should be tracked.
 * @param handler Block which should be called each \c membership event.
 */
- (void)addMembershipHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveMembershipEventHandler)handler;

/**
 * @brief Add block which will be called for each received \c action event.
 *
 * @param client \b PubNub client for which \c action events should be tracked.
 * @param handler Block which should be called each \c action event.
 */
- (void)addActionHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveMessageActionHandler)handler;

/**
 * @brief Remove all handler for specified \c client.
 *
 * @param client \b PubNub client for which listeners should be removed.
 */
- (void)removeAllHandlersForClient:(PubNub *)client;


#pragma mark - Handlers

/**
 * @brief Wait for recorded (OCMExpect) stub to be called within specified interval. Default
 * interval for success test operation will be used.
 *
 * @param object Mock from object on which invocation call is expected.
 * @param invocation Invocation which is expected to be called.
 * @param initialBlock GCD block which contain initialization of code required to invoke tested
 * code.
 */
- (void)waitForObject:(id)object
    recordedInvocationCall:(id)invocation
                afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Wait for recorded (OCMExpect) stub to be called within specified interval.
 *
 * @param object Mock from object on which invocation call is expected.
 * @param invocation Invocation which is expected to be called.
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param initialBlock GCD block which contain initialization of code required to invoke tested
 * code.
 */
- (void)waitForObject:(id)object
    recordedInvocationCall:(id)invocation
            withinInterval:(NSTimeInterval)interval
                afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Wait for code from \c codeBlock to call completion handler in specified amount of time.
 *
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param codeBlock GCD block which contain tested async code. Block pass completion handler which
 *     should be called by tested code.
 */
- (void)waitToCompleteIn:(NSTimeInterval)interval
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock;

/**
 * @brief Wait for code from \c codeBlock to call completion handler in specified amount of time.
 *
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param label Label for executed code which will allow to identify it later in case of failure.
 * @param codeBlock GCD block which contain tested async code. Block pass completion handler which
 *     should be called by tested code.
 */
- (void)waitToCompleteIn:(NSTimeInterval)interval
           codeTaskLabel:(nullable NSString *)label
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock;

/**
 * @brief Wait for code from \c codeBlock to call completion handler in specified amount of time.
 *
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param codeBlock GCD block which contain tested async code. Block pass completion handler which
 *     should be called by tested code.
 * @param initialBlock GCD block which contain initialization of code which passed in \c codeBlock.
 */
- (void)waitToCompleteIn:(NSTimeInterval)interval
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock
              afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Wait for code from \c codeBlock to call completion handler in specified amount of time.
 *
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param label Label for executed code which will allow to identify it later in case of failure.
 * @param codeBlock GCD block which contain tested async code. Block pass completion handler which
 *     should be called by tested code.
 * @param initialBlock GCD block which contain initialization of code which passed in \c codeBlock.
 */
- (void)waitToCompleteIn:(NSTimeInterval)interval
           codeTaskLabel:(nullable NSString *)label
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock
              afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Expect recorded (OCMExpect) stub not to be called within specified interval. Default
 * interval for failed test operation will be used.
 *
 * @param object Mock from object on which invocation call is expected.
 * @param invocation Invocation which is expected to be called.
 * @param initialBlock GCD block which contain initialization of code required to invoke tested
 *     code.
 */
- (void)waitForObject:(id)object
    recordedInvocationNotCall:(id)invocation
                   afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Expect recorded (OCMExpect) stub not to be called within specified interval.
 *
 * @param object Mock from object on which invocation call is expected.
 * @param invocation Invocation which is expected to be called.
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param initialBlock GCD block which contain initialization of code required to invoke tested
 *     code.
 */
- (void)waitForObject:(id)object
    recordedInvocationNotCall:(id)invocation
               withinInterval:(NSTimeInterval)interval
                   afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Wait for code from \c codeBlock to not call completion handler in specified amount of
 * time.
 *
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param codeBlock GCD block which contain tested async code. Block pass completion handler which
 *     should be called by tested code.
 */
- (void)waitToNotCompleteIn:(NSTimeInterval)interval
                  codeBlock:(void(^)(dispatch_block_t handler))codeBlock;

/**
 * @brief Wait for code from \c codeBlock to not call completion handler in specified amount of time.
 *
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param codeBlock GCD block which contain tested async code. Block pass completion handler which
 *     should be called by tested code.
 * @param initialBlock GCD block which contain initialization of code which passed in \c codeBlock.
 */
- (void)waitToNotCompleteIn:(NSTimeInterval)interval
                  codeBlock:(void(^)(dispatch_block_t handler))codeBlock
                 afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Pause test execution to wait for asynchronous task to complete.
 *
 * @discussion Useful in case of asynchronous block execution and timer based events. This method
 * allow to pause test and wait for specified number of \c seconds.
 *
 * @param taskName Name of task for which we are waiting to complete.
 * @param seconds Number of seconds for which test execution will be postponed to give tested code
 *   time to perform asynchronous actions.
 *
 * @return Reference on expectation object which can be used for fulfillment.
 */
- (XCTestExpectation *)waitTask:(NSString *)taskName completionFor:(NSTimeInterval)seconds;


#pragma mark - Helpers

/**
 * @brief Retrieve object from invocation at specified index and store it till test case completion.
 *
 * @param invocation Invocation which passed by OCMock from which object should be retrieved.
 * @param index Index of parameter in method signature from which value should be retrieved (offset
 *     for self and selector applied internally).
 *
 * @return Object instance passed to method under specified index.
 */
- (id)objectForInvocation:(NSInvocation *)invocation argumentAtIndex:(NSUInteger)index;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
