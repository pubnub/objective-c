//
//  CTTestStep+Protected.h
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "CTTestStep.h"


#pragma mark Structures

struct CTTestStepsDataKeysStruct {
    
    /**
     Stores reference on key under which stored actions which should be performed by actor (event emitter).
     */
    __unsafe_unretained NSString *actorActionsKey;
    
    /**
     Stores reference on key which stores expected events which listener is waiting from actor.
     */
    __unsafe_unretained NSString *expectedEventsKey;
};

extern struct CTTestStepsDataKeysStruct CTTestStepsDataKeys;


#pragma mark - Private interface declaration

@interface CTTestStep ()


#pragma mark - Properties

@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic, strong) NSMutableArray *expectedEvents;

/**
 Stores reference on current test step action index (among whole test step actions).
 */
@property (nonatomic, assign) NSInteger currentActionIndex;


#pragma mark - Instance methods

/**
 Initialize test step instance using dictionary which store information about particular step action and expected events.
 
 
 @param dictionary
 \b NSDictionary instance which holds information which descrive what should be done and what is expected on test step completion.
 
 @return Initialized and ready to use \b CTTestSetp instance which can be used by test app.
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

/**
 Launch next test step action.
 
 @param handlerBlock
 Block which is called each time when test execution status updated and pass three parameters: state string,
 whether test completed and whether it has been successful or not.
 */
- (void)executeNextActionWithStatusBlock:(void(^)(NSString *status, BOOL completed, BOOL successful))handlerBlock;

#pragma mark -


@end
