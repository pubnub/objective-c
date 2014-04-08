//
//  NSObject+PNAddition.h
//  pubnub
//
//  Created by Sergey Mamontov on 3/29/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Category methods declaration

@interface NSObject (PNAddition)


#pragma mark - Class methods

/**
 Swap provided class methods implementation with each other.
 
 @param originalSelector
 Method for which implementation will be replaced.
 
 @param replacementSelector
 Method from which implementation will be taken.
 */
+ (void)swizzleMethod:(SEL)originalSelector with:(SEL)replacementSelector;

/**
 Swap provided class methods implementation with each other temporarily till block execution completion.
 
 @param originalSelector
 Method for which implementation will be replaced.
 
 @param replacementSelector
 Method from which implementation will be taken.
 
 @param codeBlock
 Block with user provided code after which methods should be swapped back.
 */
+ (void)temporarilySwizzleMethod:(SEL)originalSelector with:(SEL)replacementSelector duringBlockExecution:(void(^)(void))codeBlock;


#pragma mark - Instance methods

/**
 Swap provided instance methods implementation with each other.
 
 @param originalSelector
 Method for which implementation will be replaced.
 
 @param replacementSelector
 Method from which implementation will be taken.
 */
- (void)swizzleMethod:(SEL)originalSelector with:(SEL)replacementSelector;

/**
 Swap provided class methods implementation with each other temporarily till block execution completion.
 
 @param originalSelector
 Method for which implementation will be replaced.
 
 @param replacementSelector
 Method from which implementation will be taken.
 
 @param codeBlock
 Block with user provided code after which methods should be swapped back.
 */
- (void)temporarilySwizzleMethod:(SEL)originalSelector with:(SEL)replacementSelector duringBlockExecution:(void(^)(void))codeBlock;

#pragma mark -


@end
