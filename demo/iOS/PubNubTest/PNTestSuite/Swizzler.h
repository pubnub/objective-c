
#import <Foundation/Foundation.h>

@class SwizzleReceipt;

@interface Swizzler : NSObject

/**
 Swizzles instance method; returns a receipt that you can use to later
 undo the swizzling.
 */
+ (SwizzleReceipt *)swizzleSelector:(SEL)sel
                forInstancesOfClass:(Class)cls
                          withBlock:(id)block;
+ (SwizzleReceipt *)swizzleSelector:(SEL)sel1
                           forClass:(Class)cls
						 withSelector:(SEL)sel2;

+ (SwizzleReceipt *)swizzleSelector:(SEL)sel1
                           forClass:(Class)cls1
                       withSelector:(SEL)sel2
                          fromClass:(Class)cls2;
/**
 Swizzles class method; returns a receipt for unswizzling.
 */
+ (SwizzleReceipt *)swizzleSelector:(SEL)sel
                           forClass:(Class)cls
                          withBlock:(id)block;

/**
 Undoes an earlier swizzling.
 */
+ (void)unswizzleFromReceipt:(SwizzleReceipt *)receipt;

/**
 A convenient wrapper that will swizzle a method, run a block, then undo
 the swizzling before returning.
 */
+ (void)whileSwizzlingSelector:(SEL)sel
           forInstancesOfClass:(Class)cls
                     withBlock:(id)block
                      runBlock:(void (^)(void))runBlock;

+ (void)whileSwizzlingSelector:(SEL)sel
                      forClass:(Class)cls
                     withBlock:(id)block
                      runBlock:(void (^)(void))runBlock;

@end
