/**
 @author Sergey Mamontov
 @since 3.7.9
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNTimer.h"
#import "NSObject+PNAdditions.h"
#import "PNHelper.h"
#import "PNMacro.h"


#pragma mark Types & Structures

/**
 @brief Structure describes dictionary which is stored as scheduled blocks.

 @since 3.7.9
 */
struct PNTimerScheduledDataStructure {

    /**
     @brief Reference on identifier which has been provided by user and can be used to unschedule
            particular block.

     @since 3.7.9
     */
    __unsafe_unretained NSString *identifier;

    /**
     @brief Reference on number which stores

     @since 3.7.9
     */
    __unsafe_unretained NSString *countDown;
    __unsafe_unretained NSString *block;
};

static struct PNTimerScheduledDataStructure PNTimerScheduledData = {

    .identifier = @"id",
    .countDown = @"countDown",
    .block = @"block"
};


#pragma mark - Private interface declaration

@interface PNTimer ()


#pragma mark - Properties

/**
 @brief Stores reference on tick passed during initialization so it can be reused if required.

 @since 3.7.9
 */
@property (nonatomic, assign) NSTimeInterval tick;

/**
 @brief Stores reference on GCD queue on which all actions should be serialized and executed.

 @since 3.7.9
 */
@property (nonatomic, pn_dispatch_property_ownership) dispatch_queue_t executionQueue;

/**
 @brief Reference on GCD timer used to generate tick events.

 @since 3.7.9
 */
@property (nonatomic, pn_dispatch_property_ownership) dispatch_source_t timeoutTimer;

/**
 @brief Reference on list of dictionaries which hold information about unique block identifier,
        countdown field and block copy itself.

 @since 3.7.9
 */
@property (nonatomic, strong) NSMutableArray *scheduledBlocks;

/**
 @brief Stores whether GCD timer currently suspended or not.

 @since 3.7.9
 */
@property (nonatomic, assign) BOOL suspended;


#pragma mark - Instance methods

/**
 @brief Initiate timer instance with predefined tick interval.

 @param tick  Reference on tick interval which should be used by timer during active phase.
 @param queue Reference on GCD queue on which timer will work and execute timeout blocks.

 @return Ready to use timer.

 @since 3.7.9
 */
- (instancetype)initWithTick:(NSTimeInterval)tick andQueue:(dispatch_queue_t)queue;

/**
 @brief Construct actual GCD timer using user provided configuration.

 @since 3.7.9
 */
- (void)createGCDTimer;


#pragma mark - Handler methods

/**
 @brief Handle another time out timer tick phase.

 @since 3.7.9
 */
- (void)handleTick;

#pragma mark -


@end


#pragma mark - Class interface implementation

@implementation PNTimer


#pragma mark Class methods

+ (instancetype)timerWithTick:(NSTimeInterval)tick onQueue:(dispatch_queue_t)queue {

    return [[self alloc] initWithTick:tick andQueue:queue];
}


#pragma mark - Instance methods

- (instancetype)initWithTick:(NSTimeInterval)tick andQueue:(dispatch_queue_t)queue {

    // Check whether initialization has been successful or not
    if ((self = [super init])) {

        self.tick = tick;
        self.executionQueue = queue;
        self.scheduledBlocks = [NSMutableArray array];
        [self createGCDTimer];
    }


    return self;
}

- (void)createGCDTimer {

    if (self.timeoutTimer == NULL || dispatch_source_testcancel(self.timeoutTimer) > 0) {

        dispatch_source_t timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,
                self.executionQueue);
        [PNDispatchHelper retain:timerSource];
        self.timeoutTimer = timerSource;

        __pn_desired_weak __typeof__(self) weakSelf = self;
        dispatch_source_set_event_handler(timerSource, ^{

            __strong __typeof__(self) strongSelf = weakSelf;
            [strongSelf handleTick];
        });
        dispatch_source_set_cancel_handler(timerSource, ^{

            [PNDispatchHelper release:timerSource];
        });

        dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.tick * NSEC_PER_SEC));
        dispatch_source_set_timer(timerSource, start, (uint64_t)(self.tick * NSEC_PER_SEC), NSEC_PER_SEC);
        self.suspended = YES;
    }
}

- (void)start {

    if (self.timeoutTimer == NULL || dispatch_source_testcancel(self.timeoutTimer) > 0) {

        [self createGCDTimer];
    }

    [self resume];
}

- (void)resume {

    if (self.timeoutTimer != NULL && dispatch_source_testcancel(self.timeoutTimer) == 0 &&
        self.suspended) {

        dispatch_resume(self.timeoutTimer);
        self.suspended = NO;
    }
}

- (void)pause {

    if (self.timeoutTimer != NULL && dispatch_source_testcancel(self.timeoutTimer) == 0 &&
        !self.suspended) {

        dispatch_suspend(self.timeoutTimer);
        self.suspended = YES;
    }
}

- (void)stop {

    if (self.timeoutTimer != NULL && dispatch_source_testcancel(self.timeoutTimer) == 0) {

        dispatch_source_cancel(self.timeoutTimer);
        self.timeoutTimer = NULL;
        self.suspended = YES;
    }

    [self.scheduledBlocks removeAllObjects];
}

- (void)schedule:(dispatch_block_t)block withIdentifier:(NSString *)identifier
     toFireAfter:(NSTimeInterval)timeOutInterval {

    NSArray *identifiers = [self.scheduledBlocks valueForKey:PNTimerScheduledData.identifier];
    if (![identifiers containsObject:identifier]) {

        NSMutableDictionary *scheduledBlockData = [@{PNTimerScheduledData.identifier: identifier,
                                                      PNTimerScheduledData.countDown: @(timeOutInterval),
                                                          PNTimerScheduledData.block: [block copy]} mutableCopy];
        [self.scheduledBlocks addObject:scheduledBlockData];
    }
}

- (void)unscheduleBlockWithIdentifier:(NSString *)identifier {
    
    [[self.scheduledBlocks copy] enumerateObjectsUsingBlock:^(NSMutableDictionary *scheduledBlockData,
                                                              NSUInteger scheduledBlockDataIdx,
                                                              BOOL *scheduledBlocksDataEnumeratorStop) {

        if ([[scheduledBlockData valueForKey:PNTimerScheduledData.identifier] isEqualToString:identifier]) {

            [self.scheduledBlocks removeObject:scheduledBlockData];
            *scheduledBlocksDataEnumeratorStop = YES;
        }
    }];
}


#pragma mark - Handler methods

- (void)handleTick {

    [[self.scheduledBlocks copy] enumerateObjectsUsingBlock:^(NSMutableDictionary *scheduledBlockData,
                                                              NSUInteger scheduledBlockDataIdx,
                                                              BOOL *scheduledBlocksDataEnumeratorStop) {

        NSTimeInterval countDown = [[scheduledBlockData valueForKey:PNTimerScheduledData.countDown] doubleValue];
        countDown -= self.tick;
        if (countDown > 0.0f) {

            [scheduledBlockData setValue:@(countDown) forKey:PNTimerScheduledData.countDown];
        }
        else {

            [self.scheduledBlocks removeObject:scheduledBlockData];
            dispatch_block_t block = [scheduledBlockData valueForKey:PNTimerScheduledData.block];
            dispatch_async(self.executionQueue, block);
        }
    }];
}

#pragma mark - Misc methods

- (void)dealloc {

    [self stop];
}

#pragma mark -


@end
