//
//  CTTestsSet.h
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface CTTestsSet : NSObject


#pragma mark - Class methods

/**
 Allow to fetch test cases which should be performed by client during test from JSON file.
 
 @param jsonFilePath
 Full path to the file which stores array of tests and steps.
 
 @return reference on \b CTTestsSet which will provide all required information during test (step across tests and 
 provide test case information).
 */
+ (CTTestsSet *)testsSetWithJSONFileContent:(NSString *)jsonFilePath;


#pragma mark - Instance methods

/**
 Construct instance with content of JSON file.
 
 @param jsonFilePath
 Full path to the file which stores array of tests and steps.
 
 @return Ready to use \b CTTestsSet instance.
 */
- (id)initWithJSONFileContent:(NSString *)jsonFilePath;

/**
 Number of tests, which is available for app in current configuration.
 
 @return Available tests count.
 */
- (NSUInteger)count;

/**
 Return list of tests which is available from loaded JSON.
 
 @return \b NSArray of \b CTTest instances.
 */
- (NSArray *)tests;

#pragma mark -


@end
