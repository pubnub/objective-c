/**
 @author Sergey Mamontov
 @since 4.5.15
 @copyright © 2009-2017 PubNub, Inc.
 */
#import <Foundation/Foundation.h>
#import "PNDefines.h"

#ifndef PNLockSupport_h
#define PNLockSupport_h

    #define PN_SPINLOCK_AVAILABLE 1
    // Check whether iOS/tvOS 10.0, watchOS 3.0 and macOS 10.12 SDK API can't be used safely and fallback 
    // required.
    #if !PN_OS_VERSION_10_SDK_API_IS_SAFE
        // Check whether OSSpinLock still available and can be imported or not.
        #if __has_include(<libkern/OSAtomic.h>)
            #import <libkern/OSAtomic.h>
        #else
            #undef PN_SPINLOCK_AVAILABLE
            #define PN_SPINLOCK_AVAILABLE 0
        #endif
    #endif

    #if PN_OS_UNFAIR_LOCK_AVAILABILE
        #import <os/lock.h>
        #if !PN_OS_VERSION_10_SDK_API_IS_SAFE
            #import <dlfcn.h>
        #endif
    #else
        // Declare os_unfair_lock structure because it is missing in linked SDK version.
        typedef struct os_unfair_lock_s {
            uint32_t _os_unfair_lock_opaque;
        } os_unfair_lock, *os_unfair_lock_t;

        // Declare os_unfair_lock initialization macro because it is missing in linked SDK version.
        #define OS_UNFAIR_LOCK_INIT ((os_unfair_lock){0})
    #endif

#endif // PNLockSupport_h

/**
 @brief  Block which is used during async operation locking process.
 @discussion Block passed to function and allow to call \c compleion at the end of async operation to release
             lock.
 
 @param complete Reference on block which should be called at the end of async operation performed by code to
                 release lock. 
 
 @since 4.5.15
 */
typedef void(^PNLockAsyncAction)(dispatch_block_t complete);


/**
 @brief      Acquire lock to exec piece of code passed in \c block.
 @discussion Lock object will be used to acquire lock before \c block call and release if possible after 
             \c block execution.
 
 @param lock  Reference on structure which is used with lock API (OSSpinLock can work with \a os_unfair_lock 
              structure).
 @param block GCD block which enclose piece of code which should be protected with access locks.
 
 @since 4.5.15
 */
extern void pn_lock(os_unfair_lock * lock, dispatch_block_t block);

/**
 @brief      Try acquire lock to exec piece of code passed in \c block.
 @discussion Depending on whether it is possible or not lock will be acquired and if acquired will be released
             after \c block execution.
 
 @param lock  Reference on structure which is used with lock API (OSSpinLock can work with \a os_unfair_lock 
              structure).
 @param block GCD block which enclose piece of code which should be protected with access locks.
 
 @since 4.5.15
 */
extern void pn_trylock(os_unfair_lock * lock, dispatch_block_t block);

/**
 @brief      Acquire lock to exec async piece of code passed in \c block.
 @discussion Lock object will be used to acquire lock before \c block call and release if possible after 
             async \c block execution.
 
 @param lock  Reference on structure which is used with lock API (OSSpinLock can work with \a os_unfair_lock 
              structure).
 @param block GCD block which enclose async piece of code which should be protected with access locks. Block
              pass only one argument - reference on block which should be called at the end of async operation
              performed by code to release lock.
 
 @since 4.5.15
 */
extern void pn_lock_async(os_unfair_lock * lock, PNLockAsyncAction block);

/**
 @brief      Try acquire lock to exec async piece of code passed in \c block.
 @discussion Depending on whether it is possible or not lock will be acquired and if acquired will be released
             after async \c block execution.
 
 @param lock  Reference on structure which is used with lock API (OSSpinLock can work with \a os_unfair_lock 
              structure).
 @param block GCD block which enclose async piece of code which should be protected with access locks. Block
              pass only one argument - reference on block which should be called at the end of async operation
              performed by code to release lock.
 
 @since 4.5.15
 */
extern void pn_trylock_async(os_unfair_lock * lock, PNLockAsyncAction block);
