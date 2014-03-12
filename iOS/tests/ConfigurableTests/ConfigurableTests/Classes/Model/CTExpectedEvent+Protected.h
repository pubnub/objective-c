//
//  CTExpectedEvent_Protected.h
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "CTExpectedEvent.h"


#pragma mark Structures


/**
 Enum represent expected event entry field values
 */
typedef enum _CTExpectedEventData {
    
    /**
     Event type which is expected (currently 'join', 'leave', 'timeout').
     */
    CTExpectedEventType,
    
    /**
     Represent target on which this event is expected (channel name(s)).
     */
    CTExpectedEventTarget,
    
    /**
     Number of milliseconds during which this event is expected.
     */
    CTExpectedEventTimeout
} CTExpectedEventData;


#pragma mark - Private interface declaration

@interface CTExpectedEvent ()


#pragma mark - Properties

/**
 Name of event which is expected after some action in predefined amount of time (time frame).
 */
@property (nonatomic, copy) NSString *eventType;

/**
 Target on which event is expected (when event arrived, it will be compared with this field to check whether it should
 handle it or not).
 */
@property (nonatomic, strong) id target;

/**
 Stores timeout during which event is expected.
 */
@property (nonatomic, assign) NSTimeInterval timeout;


#pragma mark - Instance methods

/**
 Initialize expected event instance from dictionary whith all information which should describe precise event which is
 expected from action specified in same test step.
 
 @param eventInformationArray
 \b NSArray instance which holds information which describe event which app is waiting in response for performed actions
 from test step.
 
 @return Initialized and ready to use \b CTExpectedEvent instance which can be used by test app.
 */
- (id)initWithArray:(NSArray *)eventInformationArray;

#pragma mark -


@end
