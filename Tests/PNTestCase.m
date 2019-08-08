/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "PNTestCase.h"
#import <PubNub/PubNub+CorePrivate.h>
#import "NSInvocation+PNTest.h"
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Types and structures

/**
 * @brief Type used to describe block for any PubNub callback.
 *
 * @param client \b PubNub client which used delegate callback.
 * @param data Data which has been passed with callback.
 * @param shouldRemove Whether handling block should be removed after call or not.
 */
typedef void (^PNTClientCallbackHandler)(PubNub *client, id data, BOOL *shouldRemove);


#pragma mark Protected interface declaration

@interface PNTestCase ()


#pragma mark - Information

/**
 * @brief Stores number of seconds which should be waited before performing in-test verifications.
 */
@property (nonatomic, assign) NSTimeInterval delayedCheck;

/**
 * @brief Stores number of seconds which positive test should wait till async operation completion.
 */
@property (nonatomic, assign) NSTimeInterval testCompletionDelay;

/**
 * @brief Stores number of seconds which negative test should wait till async operation completion.
 */
@property (nonatomic, assign) NSTimeInterval falseTestCompletionDelay;

/**
 * @brief Resource access serialization queue.
 */
@property (nonatomic, nullable, strong) dispatch_queue_t resourceAccessQueue;

/**
 * @brief PubNub handlers list.
 */
@property (nonatomic, nullable, strong) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSMutableArray<PNTClientCallbackHandler> *> *> *pubNubHandlers;

/**
 * @brief Stores reference on previously created mocking objects.
 */
@property (nonatomic, strong) NSMutableArray *classMocks;

/**
 * @brief Stores reference on previously created mocking objects.
 */
@property (nonatomic, strong) NSMutableArray *instanceMocks;

/**
 * @brief List of objects which has been pulled out from method invocation arguments.
 *
 * @return List of stored invocation objects.
 */
+ (NSMutableArray *)invocationObjects;

/**
 * @brief Content of \c 'Resources/keysset.plist' which is used with this test.
 *
 * @return \a NSDictionary with 'pam' and 'regula' set of 'publish'/'subscribe' keys.
 *
 * @since 4.8.8
 */
+ (NSDictionary *)testKeysSet;


#pragma mark - Listeners

/**
 * @brief Add block which will be called for callbacks from \c client.
 *
 * @param type One of known event listener callback types: \c status, \c message or \c presence.
 * @param client \b PubNub client for which block should be added.
 * @param handler Block which should be called for specified callback \c type.
 */
- (void)addHandlerOfType:(NSString *)type forClient:(PubNub *)client withBlock:(PNTClientCallbackHandler)handler;

/**
 * @brief Removed list of blocks for callbacks from \c client.
 *
 * @param handlers List of handler blocks which should be removed for specified callback \c type.
 * @param type One of known event listener callback types: \c status, \c message or \c presence.
 * @param client \b PubNub client for which blocks should be removed.
 */
- (void)removeHandlers:(NSArray<PNTClientCallbackHandler> *)handlers ofType:(NSString *)type forClient:(PubNub *)client;

/**
 * @brief Receive block which will be called for callbacks from \c client.
 *
 * @param type One of known event listener callback types: \c status, \c message or \c presence.
 * @param client \b PubNub client for which block should be retrieved for specified \c type.
 *
 * @return List of callback handler blocks which can be called.
 */
- (nullable NSArray<PNTClientCallbackHandler> *)handlersOfType:(NSString *)type forClient:(PubNub *)client;


#pragma mark - Handlers

/**
 * @brief Test recorded (OCMExpect) stub call within specified interval.
 *
 * @param object Mock from object on which invocation call is expected.
 * @param invocation Invocation which is expected to be called.
 * @param shouldCall Whether tested \c invocation call or reject.
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param initialBlock GCD block which contain initialization of code required to invoke tested
 *     code.
 */
- (void)waitForObject:(id)object
    recordedInvocation:(id)invocation
                  call:(BOOL)shouldCall
        withinInterval:(NSTimeInterval)interval
            afterBlock:(void(^)(void))initialBlock;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNTestCase


#pragma mark - Information

+ (NSMutableArray *)invocationObjects {
    
    static NSMutableArray *_invocationObjects;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _invocationObjects = [NSMutableArray new];
    });
    
    return _invocationObjects;
}

+ (NSDictionary *)testKeysSet {
  
  static NSDictionary *_testKeysSet;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    NSBundle *testBundle = [NSBundle bundleForClass:self];
    NSString *keysPath = [testBundle pathForResource:@"keysset" ofType:@"plist"];
    _testKeysSet = [NSDictionary dictionaryWithContentsOfFile:keysPath];
  });
  
  return _testKeysSet;
}

- (NSString *)pamSubscribeKey {
  
  return [[[self class] testKeysSet] valueForKeyPath:@"pam.subscribe"];
}

- (NSString *)pamPublishKey {
  
  return [[[self class] testKeysSet] valueForKeyPath:@"pam.publish"];
}

- (NSString *)subscribeKey {
  
  return [[[self class] testKeysSet] valueForKeyPath:@"regular.subscribe"];
}

- (NSString *)publishKey {
  
  return [[[self class] testKeysSet] valueForKeyPath:@"regular.publish"];
}


#pragma mark - Configuration

- (void)setUp {
    
    [super setUp];
    
    
    self.resourceAccessQueue = dispatch_queue_create("test-case", DISPATCH_QUEUE_SERIAL);
    self.pubNubHandlers = [NSMutableDictionary new];
    self.testCompletionDelay = 15.f;
    self.delayedCheck = 0.25f;
    self.falseTestCompletionDelay = 0.25f;
    self.instanceMocks = [NSMutableArray new];
    self.classMocks = [NSMutableArray new];
}

- (void)tearDown {

    NSLog(@"\nTest completed.\n");
    
    dispatch_sync(self.resourceAccessQueue, ^{
        [self.pubNubHandlers removeAllObjects];
    });
    
    if (self.instanceMocks.count || self.classMocks.count) {
        [self.instanceMocks makeObjectsPerformSelector:@selector(stopMocking)];
        [self.classMocks makeObjectsPerformSelector:@selector(stopMocking)];
    }
    
    [self.instanceMocks removeAllObjects];
    [self.classMocks removeAllObjects];
    
    [self waitTask:@"clientsDestroyCompletion" completionFor:0.3f];
    
    [super tearDown];
}


#pragma mark - Mocking

- (BOOL)isObjectMocked:(id)object {

    return [self.classMocks containsObject:object] || [self.instanceMocks containsObject:object];
}

- (id)mockForObject:(id)object {
    
    BOOL isClass = object_isClass(object);
    __unsafe_unretained id mock = isClass ? OCMClassMock(object) : OCMPartialMock(object);
    
    if (isClass) {
        [self.classMocks addObject:mock];
    } else {
        [self.instanceMocks addObject:mock];
    }
    
    return mock;
}


#pragma mark - Listeners


- (void)addHandlerOfType:(NSString *)type forClient:(PubNub *)client withBlock:(PNTClientCallbackHandler)handler {
    
    NSString *instanceID = client.instanceID;
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSMutableDictionary *handlersByType = self.pubNubHandlers[instanceID];
        
        if (!handlersByType) {
            handlersByType = [NSMutableDictionary new];
            self.pubNubHandlers[instanceID] = handlersByType;
        }
        
        NSMutableArray *handlers = handlersByType[type];
        
        if (!handlers) {
            handlers = [NSMutableArray new];
            handlersByType[type] = handlers;
        }
        
        [handlers addObject:handler];
    });
}

- (void)removeHandlers:(NSArray<PNTClientCallbackHandler> *)handlers ofType:(NSString *)type forClient:(PubNub *)client {
    
    NSString *instanceID = client.instanceID;
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSMutableDictionary *handlersByType = self.pubNubHandlers[instanceID];
        [handlersByType[type] removeObjectsInArray:handlers];
    });
}

- (NSArray<PNTClientCallbackHandler> *)handlersOfType:(NSString *)type forClient:(PubNub *)client {
    
    __block NSArray<PNTClientCallbackHandler> *handlers = nil;
    NSString *instanceID = client.instanceID;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        handlers = [self.pubNubHandlers[instanceID][type] copy];
    });
    
    return handlers;
}

- (void)addStatusHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveStatusHandler)handler {
    
    [self addHandlerOfType:@"status" forClient:client withBlock:handler];
}

- (void)addMessageHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveMessageHandler)handler {
    
    [self addHandlerOfType:@"message" forClient:client withBlock:handler];
}

- (void)addSignalHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveSignalHandler)handler {
    
    [self addHandlerOfType:@"signal" forClient:client withBlock:handler];
}

- (void)addPresenceHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveMessageHandler)handler {
    
    [self addHandlerOfType:@"presence" forClient:client withBlock:handler];
}

- (void)removeAllHandlersForClient:(PubNub *)client {
    
    NSString *instanceID = client.instanceID;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        [self.pubNubHandlers removeObjectForKey:instanceID];
    });
}


#pragma mark - Handlers

- (void)waitForObject:(id)object
    recordedInvocation:(id)invocation
                  call:(BOOL)shouldCall
        withinInterval:(NSTimeInterval)interval
            afterBlock:(void(^)(void))initialBlock {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    ((OCMStubRecorder *)invocation).andDo(^(NSInvocation *expectedInvocation) {
        handlerCalled = YES;
        dispatch_semaphore_signal(semaphore);
    });
    
    if (initialBlock) {
        initialBlock();
    }
    
    dispatch_semaphore_wait(semaphore,
                            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)));

    if (shouldCall) {
        XCTAssertTrue(handlerCalled);
    } else {
        XCTAssertFalse(handlerCalled);
    }

    OCMVerifyAll(object);
}

- (void)waitForObject:(id)object
    recordedInvocationCall:(id)invocation
                afterBlock:(void(^)(void))initialBlock {

    [self waitForObject:object
     recordedInvocationCall:invocation
             withinInterval:self.testCompletionDelay
                 afterBlock:initialBlock];
}

- (void)waitForObject:(id)object
    recordedInvocationCall:(id)invocation
            withinInterval:(NSTimeInterval)interval
                afterBlock:(void(^)(void))initialBlock {
    
    [self waitForObject:object
     recordedInvocation:invocation
                   call:YES
         withinInterval:interval
             afterBlock:initialBlock];
}

- (void)waitToCompleteIn:(NSTimeInterval)interval
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock {
    
    [self waitToCompleteIn:interval codeBlock:codeBlock afterBlock:nil];
}

- (void)waitToCompleteIn:(NSTimeInterval)interval
           codeTaskLabel:(NSString *)label
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock {
    
    [self waitToCompleteIn:interval codeTaskLabel:label codeBlock:codeBlock afterBlock:nil];
}

- (void)waitToCompleteIn:(NSTimeInterval)interval
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock
              afterBlock:(void(^)(void))initialBlock {
    
    [self waitToCompleteIn:interval codeTaskLabel:nil codeBlock:codeBlock afterBlock:initialBlock];
}

- (void)waitToCompleteIn:(NSTimeInterval)interval
           codeTaskLabel:(NSString *)label
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock
              afterBlock:(void(^)(void))initialBlock {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    codeBlock(^{
        handlerCalled = YES;
        dispatch_semaphore_signal(semaphore);
    });
    
    if (initialBlock) {
        initialBlock();
    }
    
    dispatch_semaphore_wait(semaphore,
                            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)));
    
    if (label) {
        XCTAssertTrue(handlerCalled, @"'%@' code block not completed in time", label);
    } else {
        XCTAssertTrue(handlerCalled);
    }
}

- (void)waitForObject:(id)object
    recordedInvocationNotCall:(id)invocation
                   afterBlock:(void(^)(void))initialBlock {

    [self waitForObject:object
     recordedInvocationNotCall:invocation
                withinInterval:self.falseTestCompletionDelay
                    afterBlock:initialBlock];
}

- (void)waitForObject:(id)object
    recordedInvocationNotCall:(id)invocation
               withinInterval:(NSTimeInterval)interval
                   afterBlock:(nullable void(^)(void))initialBlock {
    
    [self waitForObject:object recordedInvocation:invocation call:NO withinInterval:interval
             afterBlock:initialBlock];
}

- (void)waitToNotCompleteIn:(NSTimeInterval)delay
                  codeBlock:(void(^)(dispatch_block_t handler))codeBlock {
    
    [self waitToNotCompleteIn:delay codeBlock:codeBlock afterBlock:nil];
}

- (void)waitToNotCompleteIn:(NSTimeInterval)delay
                  codeBlock:(void(^)(dispatch_block_t handler))codeBlock
                 afterBlock:(void(^)(void))initialBlock {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    codeBlock(^{
        handlerCalled = YES;
        dispatch_semaphore_signal(semaphore);
    });
    
    if (initialBlock) {
        initialBlock();
    }
    
    dispatch_semaphore_wait(semaphore,
                            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)));
    XCTAssertFalse(handlerCalled);
}

- (XCTestExpectation *)waitTask:(NSString *)taskName completionFor:(NSTimeInterval)seconds {
    
    if (seconds <= 0.f) {
        return nil;
    }
    
    XCTestExpectation *waitExpectation = [self expectationWithDescription:taskName];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [waitExpectation fulfill];
    });

    [self waitForExpectations:@[waitExpectation] timeout:(seconds + 0.3f)];
    
    return waitExpectation;
}

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    
    NSMutableArray<PNTClientCallbackHandler> *handlersForRemoval = [NSMutableArray new];
    NSArray<PNTClientCallbackHandler> *handlers = [self handlersOfType:@"status" forClient:client];
    
    for (PNTClientCallbackHandler handler in handlers) {
        BOOL shouldRemoved = NO;
        
        handler(client, status, &shouldRemoved);
        
        if (shouldRemoved) {
            [handlersForRemoval addObject:handler];
        }
    }
    
    [self removeHandlers:handlersForRemoval ofType:@"status" forClient:client];
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    
    NSMutableArray<PNTClientCallbackHandler> *handlersForRemoval = [NSMutableArray new];
    NSArray<PNTClientCallbackHandler> *handlers = [self handlersOfType:@"message" forClient:client];
    
    for (PNTClientCallbackHandler handler in handlers) {
        BOOL shouldRemoved = NO;
        
        handler(client, message, &shouldRemoved);
        
        if (shouldRemoved) {
            [handlersForRemoval addObject:handler];
        }
    }
    
    [self removeHandlers:handlersForRemoval ofType:@"message" forClient:client];
}

- (void)client:(PubNub *)client didReceiveSignal:(PNSignalResult *)signal {
    NSMutableArray<PNTClientCallbackHandler> *handlersForRemoval = [NSMutableArray new];
    NSArray<PNTClientCallbackHandler> *handlers = [self handlersOfType:@"signal" forClient:client];
    
    for (PNTClientCallbackHandler handler in handlers) {
        BOOL shouldRemoved = NO;
        
        handler(client, signal, &shouldRemoved);
        
        if (shouldRemoved) {
            [handlersForRemoval addObject:handler];
        }
    }
    
    [self removeHandlers:handlersForRemoval ofType:@"signal" forClient:client];
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    
    NSMutableArray<PNTClientCallbackHandler> *handlersForRemoval = [NSMutableArray new];
    NSArray<PNTClientCallbackHandler> *handlers = [self handlersOfType:@"presence" forClient:client];
    
    for (PNTClientCallbackHandler handler in handlers) {
        BOOL shouldRemoved = NO;
        
        handler(client, event, &shouldRemoved);
        
        if (shouldRemoved) {
            [handlersForRemoval addObject:handler];
        }
    }
    
    [self removeHandlers:handlersForRemoval ofType:@"presence" forClient:client];
}


#pragma mark - Helpers

- (id)objectForInvocation:(NSInvocation *)invocation argumentAtIndex:(NSUInteger)index {
    
    __strong id object = [invocation objectForArgumentAtIndex:(index + 1)];
    
    [[PNTestCase invocationObjects] addObject:object];
    
    return object;
}

@end
