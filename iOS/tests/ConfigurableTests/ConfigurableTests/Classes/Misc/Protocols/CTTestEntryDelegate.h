//
//  CTTestEntryDelegate.h
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class CTTest;


#pragma mark Delegate delcaration

@protocol CTTestEntryDelegate <NSObject>

@required

/**
 Called on delegate when user launch test.
 
 @param test
 \b CTTest which should be launched.
 */
- (void)didRunTest:(CTTest *)test;

#pragma mark -


@end
