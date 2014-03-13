//
//  CTAction.h
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface CTAction : NSObject


#pragma mark - Instance methods

/**
 Basing on action name corresponding \b PubNub client method will be called.
 
 @param executionStatusBlock
 Reference on block which will pass only one parameter, to inform about result of 'execute' method call (can be used
 to show in user interface). Second parameter is used to tell whether request completed or not. Third parameter is used to 
 identify whether request failed or not.
 */
- (void)executeWithStatusBlock:(void(^)(NSString *executionStatus, BOOL completed, BOOL failed))executionStatusBlock;

#pragma mark -


@end
