/**
 @author Sergey Mamontov
 @since 4.5.15
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNLockSupport.h"


/**
 @brief      Check whether os_unfair_lock functions family visible or not.
 @discussion Depending from environment functions may be not declared in linked SDK libraries. Function allow
             to examine loaded mach-o files and search for required symbols. Result will be cached because of
             performance considerations.
 
 @return \c YES in case if os_unfair_lock family functions visible and can be used.
 
 @since 4.5.15
 */
BOOL _pn_os_unfair_lock_functions_visible() {
#if PN_OS_UNFAIR_LOCK_AVAILABILE
    static BOOL visible;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void (*lock_func)(void *) = dlsym(dlopen(NULL, RTLD_NOW | RTLD_GLOBAL), "os_unfair_lock_lock");
        visible = lock_func != NULL;
    });
    
    return visible;
#else
    return NO;
#endif
}

void _pn_lock_lock(os_unfair_lock *lock) {
    #if PN_OS_VERSION_10_SDK_API_IS_SAFE
        os_unfair_lock_lock(lock);
    #else
        #if PN_OS_UNFAIR_LOCK_AVAILABILE
            if (_pn_os_unfair_lock_functions_visible()) { os_unfair_lock_lock(lock); }
            else { OSSpinLockLock((void *)lock); }
        #else
            OSSpinLockLock((void *)lock);
        #endif
    #endif
}

BOOL _pn_lock_trylock(os_unfair_lock *lock) {
    bool locked = false;
    #if PN_OS_VERSION_10_SDK_API_IS_SAFE
        locked = os_unfair_lock_trylock(lock);
    #else
        #if PN_OS_UNFAIR_LOCK_AVAILABILE
            if (_pn_os_unfair_lock_functions_visible()) { locked = os_unfair_lock_trylock(lock); }
            else { locked = OSSpinLockTry((void *)lock); }
        #else
            locked = OSSpinLockTry((void *)lock);
        #endif
    #endif
    
    return locked;
}

void _pn_lock_unlock(os_unfair_lock *lock) {
    #if PN_OS_VERSION_10_SDK_API_IS_SAFE
        os_unfair_lock_unlock(lock);
    #else
        #if PN_OS_UNFAIR_LOCK_AVAILABILE
            if (_pn_os_unfair_lock_functions_visible()) { os_unfair_lock_unlock(lock); }
            else { OSSpinLockUnlock((void *)lock); }
        #else
            OSSpinLockUnlock((void *)lock);
        #endif
    #endif
}

/**
 @brief      Try acquire lock to exec piece of code passed in \c block.
 @discussion Depending on whether it is possible or not lock will be acquired and if acquired will be released
             after \c block execution.
 
 @param shouldTry Whether should try acquire lock or call lock w/o any conditions.
 @param lock      Reference on structure which is used with lock API (OSSpinLock can work with 
                  \a os_unfair_lock structure).
 @param block     GCD block which enclose piece of code which should be protected with access locks.
 
 @since 4.5.15
 */
void _pn_lock(bool shouldTry, os_unfair_lock * lock, dispatch_block_t block) {
    
    bool locked = !shouldTry;
    if (shouldTry) { locked = _pn_lock_trylock(lock); }
    else { _pn_lock_lock(lock); }
    block();
    if (locked) { _pn_lock_unlock(lock); }
}

/**
 @brief      Try acquire lock to exec async piece of code passed in \c block.
 @discussion Depending on whether it is possible or not lock will be acquired and if acquired will be released
             after async \c block execution.
 
 @param shouldTry Whether should try acquire lock or call lock w/o any conditions.
 @param lock      Reference on structure which is used with lock API (OSSpinLock can work with 
                  \a os_unfair_lock structure).
 @param block     GCD block which enclose async piece of code which should be protected with access locks. 
                  Block pass only one argument - reference on block which should be called at the end of async
                  operation performed by code to release lock.
 
 @since 4.5.15
 */
void _pn_lock_async(bool shouldTry, os_unfair_lock * lock, PNLockAsyncAction block) {
    
    dispatch_semaphore_t semaphore = nil;
    bool locked = !shouldTry;
    if (shouldTry) { locked = _pn_lock_trylock(lock); }
    else { _pn_lock_lock(lock); }
    if (locked) { semaphore = dispatch_semaphore_create(0); }
    block(^{ if (locked) { dispatch_semaphore_signal(semaphore); } });
    if (locked) {
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
        dispatch_semaphore_wait(semaphore, popTime);
        _pn_lock_unlock(lock);
    }
}

void pn_lock(os_unfair_lock * lock, dispatch_block_t block) {
    
    _pn_lock(NO, lock, block);
}

void pn_trylock(os_unfair_lock * lock, dispatch_block_t block) {
    
    _pn_lock(YES, lock, block);
}

void pn_lock_async(os_unfair_lock * lock, PNLockAsyncAction block) {
    
    _pn_lock_async(NO, lock, block);
}

void pn_trylock_async(os_unfair_lock * lock, PNLockAsyncAction block) {
    
    _pn_lock_async(YES, lock, block);
}
