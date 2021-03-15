/**
 * @author Serhii Mamontov
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PNLockSupport.h"


void _pn_lock_lock(pthread_mutex_t *lock) {
    pthread_mutex_lock(lock);
}

BOOL _pn_lock_trylock(pthread_mutex_t *lock) {
    return pthread_mutex_trylock(lock) == 0;
}

void _pn_lock_unlock(pthread_mutex_t *lock) {
    pthread_mutex_unlock(lock);
}

/**
 * @brief Try acquire lock to exec piece of code passed in \c block.
 *
 * @discussion Depending on whether it is possible or not lock will be acquired and if acquired will be released
 * after \c block execution.
 *
 * @param shouldTry Whether should try acquire lock or call lock w/o any conditions.
 * @param lock      Reference on structure which is used with lock API (OSSpinLock can work with
 *                 \a os_unfair_lock structure).
 * @param block     GCD block which enclose piece of code which should be protected with access locks.
 */
void _pn_lock(bool shouldTry, pthread_mutex_t * lock, dispatch_block_t block) {
    bool locked = !shouldTry;

    if (shouldTry) {
        locked = _pn_lock_trylock(lock);
    } else {
        _pn_lock_lock(lock);
    }

    block();

    if (locked) {
        _pn_lock_unlock(lock);
    }
}

/**
 * @brief Try acquire lock to exec async piece of code passed in \c block.
 *
 * @discussion Depending on whether it is possible or not lock will be acquired and if acquired will be released
 * after async \c block execution.
 *
 * @param shouldTry Whether should try acquire lock or call lock w/o any conditions.
 * @param lock Reference on pthread mutex which should be used with lock.
 * @param block GCD block which enclose async piece of code which should be protected with access locks.
 *     Block pass only one argument - reference on block which should be called at the end of async
 *     operation performed by code to release lock.
 */
void _pn_lock_async(bool shouldTry, pthread_mutex_t * lock, PNLockAsyncAction block) {
    dispatch_semaphore_t semaphore = nil;
    bool locked = !shouldTry;

    if (shouldTry) {
        locked = _pn_lock_trylock(lock);
    } else {
        _pn_lock_lock(lock);
    }

    if (locked) {
        semaphore = dispatch_semaphore_create(0);
    }

    block(^{
        if (locked) {
            dispatch_semaphore_signal(semaphore);
        }
    });

    if (locked) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
        dispatch_semaphore_wait(semaphore, popTime);
        _pn_lock_unlock(lock);
    }
}

void pn_lock(pthread_mutex_t * lock, dispatch_block_t block) {
    _pn_lock(NO, lock, block);
}

void pn_trylock(pthread_mutex_t * lock, dispatch_block_t block) {
    _pn_lock(YES, lock, block);
}

void pn_lock_async(pthread_mutex_t * lock, PNLockAsyncAction block) {
    _pn_lock_async(NO, lock, block);
}

void pn_trylock_async(pthread_mutex_t * lock, PNLockAsyncAction block) {
    _pn_lock_async(YES, lock, block);
}
