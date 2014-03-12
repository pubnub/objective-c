//
//  CTAction+Protected.h
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "CTAction.h"

#pragma mark Structures

/**
 Enum represents action entry field values.
 */
typedef enum _CTActionData {
    
    /**
     Under this index name of the action which should be performed is stored.
     */
    CTActionName,
    
    /**
     Different actions require different set of options which is stored under this index.
     */
    CTActionParameters,
    
    /**
     Action execution delay.
     */
    CTActionExecutionDelay
} CTActionData;

/**
 Enum represent possible list of actions and their representation
 */
typedef enum _CTActionType {
    
    CTSubscribeAction,
    CTUnsubscribeAction,
    CTUnkonwnAction
} CTActionType;


#pragma mark - Private interface declaration

@interface CTAction ()


#pragma mark - Properties

/**
 Stores action type which will be used to call corresponding action on client.
 */
@property (nonatomic, assign) CTActionType action;
@property (nonatomic, copy) NSString *actionName;

/**
 Stores reference on parameters which should be passed to \b PubNub client.
 */
@property (nonatomic, strong) id parameters;

/**
 Stores how many miliseconds action should wait before execution.
 */
@property (nonatomic, assign) NSUInteger delay;


#pragma mark - Class methods

/**
 Construct \b CTAction instance using provided information from array.
 
 @param actionData
 \b NSArray instance which allow to complete action instance intialization with required data.
 
 @return Constructed \b CTAction instance which can be used further in test cases.
 */
+ (CTAction *)actionWithArray:(NSArray *)actionData;


#pragma mark - Instance methods

/**
 Initialize \b CTAction instance using provided information from array.
 
 @param actionData
 \b NSArray instance which allow to complete action instance intialization with required data.
 
 @return Initialized and ready to use \b CTAction instance which can be used further in test cases.
 */
- (id)initWithArray:(NSArray *)actionData;

/**
 Convert provided action name to action type.
 
 @param actionName
 \b NSString instance which should be converted to one of \b CTActionType field values.
 
 @return One of \b CTActionType fields.
 */
- (CTActionType)actionTypeFromName:(NSString *)actionName;

#pragma mark -


@end
