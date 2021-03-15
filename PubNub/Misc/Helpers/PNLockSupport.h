/**
 * @author Serhii Mamontov
 *
 * @version 4.16.1
 * @since 4.16.1
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import <Foundation/Foundation.h>
#import <pthread/pthread.h>
#import "PNDefines.h"

/**
 * @brief Block which is used during async operation locking process.
 *
 * @discussion Block passed to function and allow to call \c completion at the end of async operation to release
 * lock.
 *
 * @param complete Reference on block which should be called at the end of async operation performed by code to
 * release lock.
 */
typedef void(^PNLockAsyncAction)(dispatch_block_t complete);

/**
 * @brief Acquire lock to exec piece of code passed in \c block.
 *
 * @discussion Lock object will be used to acquire lock before \c block call and release if possible after
 * \c block execution.
 *
 * @param lock Reference on pthread mutex which should be used with lock.
 * @param block GCD block which enclose piece of code which should be protected with access locks.
 */
extern void pn_lock(pthread_mutex_t * lock, dispatch_block_t block);

/**
 * @brief Try acquire lock to exec piece of code passed in \c block.
 *
 * @discussion Depending on whether it is possible or not lock will be acquired and if acquired will be released
 * after \c block execution.
 *
 * @param lock Reference on pthread mutex which should be used with lock.
 * @param block GCD block which enclose piece of code which should be protected with access locks.
 */
extern void pn_trylock(pthread_mutex_t * lock, dispatch_block_t block);

/**
 * @brief Acquire lock to exec async piece of code passed in \c block.
 *
 * @discussion Lock object will be used to acquire lock before \c block call and release if possible after
 * async \c block execution.
 *
 * @param lock Reference on pthread mutex which should be used with lock.
 * @param block GCD block which enclose async piece of code which should be protected with access locks. Block
 *     pass only one argument - reference on block which should be called at the end of async operation performed
 *     by code to release lock.
 */
extern void pn_lock_async(pthread_mutex_t * lock, PNLockAsyncAction block);

/**
 * @brief Try acquire lock to exec async piece of code passed in \c block.
 *
 * @discussion Depending on whether it is possible or not lock will be acquired and if acquired will be released
 * after async \c block execution.
 *
 * @param lock Reference on pthread mutex which should be used with lock.
 * @param block GCD block which enclose async piece of code which should be protected with access locks. Block
 *     pass only one argument - reference on block which should be called at the end of async operation performed
 *     by code to release lock.
 */
extern void pn_trylock_async(pthread_mutex_t * lock, PNLockAsyncAction block);
