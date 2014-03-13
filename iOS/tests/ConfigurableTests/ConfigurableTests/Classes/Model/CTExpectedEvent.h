//
//  CTExpectedEvent.h
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface CTExpectedEvent : NSObject


#pragma mark - Class methods

/**
 Construct expected event instance from dictionary whith all information which should describe precise event which is
 expected from action specified in same test step.
 
 @param eventInformationArray
 \b NSArray instance which holds information which describe event which app is waiting in response for performed actions
 from test step.
 
 @return Constructed \b CTExpectedEvent instance which can be used by test app.
 */
+ (CTExpectedEvent *)eventWithArray:(NSArray *)eventInformationArray;

#pragma mark -


@end
