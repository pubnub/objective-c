//
//  CTTestsSet.m
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "CTTestsSet.h"
#import "CTTest+Protected.h"


#pragma mark Private interface declaration

@interface CTTestsSet ()


#pragma mark - Properties

/**
 Property used to store all list of tests which has been loaded from JSON file.
 */
@property (nonatomic, strong) NSMutableArray *testsList;

#pragma mark -


@end


#pragma mark Public interface implementation

@implementation CTTestsSet


#pragma mark - Class methods

+ (CTTestsSet *)testsSetWithJSONFileContent:(NSString *)jsonFilePath {
    
    CTTestsSet *tests = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:jsonFilePath]) {
        
        tests = [[self alloc] initWithJSONFileContent:jsonFilePath];
    }
    
    return tests;
}


#pragma mark - Instance methods

- (id)initWithJSONFileContent:(NSString *)jsonFilePath {
    
    // Check whether intialization has been successful or not.
    if ((self = [super init])) {
        
        self.testsList = [NSMutableArray array];
        
        NSData *testsSetData = [NSData dataWithContentsOfFile:jsonFilePath];
        NSError *parsingError;
        NSArray *tests = [NSJSONSerialization JSONObjectWithData:testsSetData options:NSJSONReadingAllowFragments
                                                           error:&parsingError];
        if (!parsingError) {
            
            [tests enumerateObjectsUsingBlock:^(NSDictionary *testData, NSUInteger testDataIdx,
                                                BOOL *testDataEnumeratorStop) {
                CTTest *test = [CTTest testWithDictionary:testData andOrderNumber:testDataIdx];
                
                if (test) {
                    
                    [self.testsList addObject:test];
                }
            }];
        }
        else {
            
            @throw [NSException exceptionWithName:@"Can't load tests list." reason:@"Tests set JSON malformed." userInfo:nil];
        }
    }
    
    
    return self;
}

- (NSUInteger)count {
    
    return [self.testsList count];
}

- (NSArray *)tests {
    
    return self.testsList;
}


#pragma mark -


@end
