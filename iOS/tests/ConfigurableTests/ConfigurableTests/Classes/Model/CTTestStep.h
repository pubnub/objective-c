//
//  CTTestStep.h
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface CTTestStep : NSObject


#pragma mark - Class methods

/**
 Construct test step instance using dictionary which store information about particular step action and expected events.
 
 
 @param dictionary
 \b NSDictionary instance which holds information which descrive what should be done and what is expected on test step completion.
 
 @return Constructed \b CTTestSetp instance which can be used by test app.
 */
+ (CTTestStep *)stepWithDictionary:(NSDictionary *)dictionary;

/**
 Launch test case step actions.
 
 @param handlerBlock
 Block which is called each time when test execution status updated and pass three parameters: state string,
 whether test case step actions completed and whether it has been successful or not.
 */
- (void)executeWithStatusBlock:(void(^)(NSString *currentStatus, BOOL completed, BOOL successful))handlerBlock;

#pragma mark -


@end
