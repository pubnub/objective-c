#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Shared resources lock.
///
/// GCD based lock to organise thread-safe access to shared resources.
@interface PNLock : NSObject


#pragma mark - Initialization and configuration

/// Initialize lock with name.
///
/// Lock allows protecting mutable resources, accessed from multiple thread on read and write. Lock
/// implemented as MRSW, which allows having multiple readers and single writer.
///
/// > Note: Implementation of this lock allows avoiding threads starvation issue by targeting single
/// concurrent subsystem queue (as target of named queue).
///
/// - Parameters:
///   - queueName: Name of shared resources isolation queue.
///   - queueIdentifier: Identifier of queue which used by subsystem.
/// - Returns: Shared resources lock.
+ (instancetype)lockWithIsolationQueueName:(NSString *)queueName
                  subsystemQueueIdentifier:(NSString *)queueIdentifier;


#pragma mark - Read / write locks

/// Safe _synchronous_ `read` access to resources.
///
/// > Note: This is shorthand method to ``syncReadAccessWithBlock:``.
///
/// > Warning: This method should be used only for `read` or it may cause a runtime exception. If data should
/// be modified while accessed, it is better to user ``syncWriteAccessWithBlock:`` or
/// ``asyncWriteAccessWithBlock:``.
///
/// - Parameter block: GCD block within which it is safe to read resources from other threads.
- (void)readAccessWithBlock:(dispatch_block_t)block;

/// Safe _synchronous_ `write` access to resources.
///
/// > Note: This is shorthand method to ``asyncWriteAccessWithBlock:``.
///
/// - Parameter block: GCD block within which it is safe to modify resources from other threads.
- (void)writeAccessWithBlock:(dispatch_block_t)block;


#pragma mark - Synchronous read / write locks

/// Safe _synchronous_ `read` access to resources.
///
/// > Warning: This method should be used only for `read` or it may cause a runtime exception. If data should
/// be modified while accessed, it is better to user ``syncWriteAccessWithBlock:`` or
/// ``asyncWriteAccessWithBlock:``.
///
/// - Parameter block: GCD block within which it is safe to read resources from other threads.
- (void)syncReadAccessWithBlock:(dispatch_block_t)block;

/// Safe _synchronous_ `write` access to resources.
///
/// - Parameter block: GCD block within which it is safe to modify resources from other threads.
- (void)syncWriteAccessWithBlock:(dispatch_block_t)block;


#pragma mark - Asynchronous read / write locks

/// Safe _asynchronous_ `read` access to resources.
///
/// > Warning: This method should be used only for `read` or it may cause a runtime exception. If data should
/// be modified while accessed, it is better to user ``syncWriteAccessWithBlock:`` or
/// ``asyncWriteAccessWithBlock:``.
///
/// - Parameter block: GCD block within which it is safe to read resources from other threads.
- (void)asyncReadAccessWithBlock:(dispatch_block_t)block;

/// Safe _asynchronous_ `write` access to resources.
///
/// - Parameter block: GCD block within which it is safe to modify resources from other threads.
- (void)asyncWriteAccessWithBlock:(dispatch_block_t)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
