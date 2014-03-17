//
//  CTExpectedEvent.m
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "CTExpectedEvent+Protected.h"


#pragma mark Public interface implementation

@implementation CTExpectedEvent


#pragma mark - Class methods

+ (CTExpectedEvent *)eventWithArray:(NSArray *)eventInformationArray {
    
    return [[self alloc] initWithArray:eventInformationArray];
}


#pragma mark - Instance methods

- (id)initWithArray:(NSArray *)eventInformationArray {
    
    // Check whether initialization has been successful or not.
    if ((self = [super init])) {
        
        self.eventType = [eventInformationArray objectAtIndex:CTExpectedEventType];
        self.target = [eventInformationArray objectAtIndex:CTExpectedEventTarget];
        self.timeout = [[eventInformationArray objectAtIndex:CTExpectedEventTimeout] floatValue];
    }
    
    
    return self;
}

#pragma mark -


@end
