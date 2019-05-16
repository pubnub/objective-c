#import <XCTest/XCTest.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Base class for all test cases which provide initial setup.
 *
 * @author Serhii Mamontov
 * @copyright © 2009-2019 PubNub, Inc.
 */
@interface PNTestCase : XCTestCase


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
