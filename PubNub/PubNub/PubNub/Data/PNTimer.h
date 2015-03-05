#import <Foundation/Foundation.h>


/**
 @brief      GCD based timer which allow to work with scheduled for timeout blocks.
 @discussion This timer allow to schedule many code blocks to fire after specific amount of time.

 @author Sergey Mamontov
 @since 3.7.9
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNTimer : NSObject


#pragma mark Class methods

/**
 @brief Construct timer instance with predefined tick interval.

 @param tick  Reference on tick interval which should be used by timer during active phase.
 @param queue Reference on GCD queue on which timer will work and execute timeout blocks.

 @return Constructed and ready to use timer.

 @since 3.7.9
 */
+ (instancetype)timerWithTick:(NSTimeInterval)tick onQueue:(dispatch_queue_t)queue;


#pragma mark - Instance methods

/**
 @brief      Launch GCD timer.
 @discussion Start 'ticking' and code block execution time calculation.

 @since 3.7.9
 */
- (void)start;

/**
 @brief      Pause GCD timer.
 @discussion Pause previously created GCD timer to temporary suspend 'tick' handling.
             This can be useful in case if client should suspend for some period of time.

 @since 3.7.9
 */
- (void)resume;

/**
 @brief      Resume GCD timer.
 @discussion Resume previously created and paused GCD timer to resume 'ticking' and block execution
             date calculation.

 @since 3.7.9
 */
- (void)pause;

/**
 @brief      Stop GCD timer.
 @discussion This will destroy GCD timer source and release all objects which has been passed by
             user.

 @since 3.7.9
 */
- (void)stop;

/**
 @brief Schedule block execution after specified amount of time.

 @param block           Reference on block which should be executed after \c timeOutInterval
                        seconds.
 @param identifier      Reference on unique identifier which can be used to unschedule block in
                        future.
 @param timeOutInterval Interval in seconds after which block will be executed. This interval should
                        be larger then timer's tick value.

 @since 3.7.9
 */
- (void)schedule:(dispatch_block_t)block withIdentifier:(NSString *)identifier
     toFireAfter:(NSTimeInterval)timeOutInterval;

/**
 @brief Try to unschedule previously placed block.

 @param identifier Reference on unique identifier which has been passed during desired block
                   scheduling process.

 @since 3.7.9
 */
- (void)unscheduleBlockWithIdentifier:(NSString *)identifier;

#pragma mark -


@end
