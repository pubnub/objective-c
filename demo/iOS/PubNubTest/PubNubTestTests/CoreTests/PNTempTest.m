//
//  PNTempTest.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/21/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

typedef NSString *(^intToString)(NSUInteger parametr);

intToString inlineconventer = ^(NSUInteger parametr) {
    
    return [NSString stringWithFormat:@"%lu", parametr];
};

@interface PNTempTest : XCTestCase

@end

@implementation PNTempTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExampleBlock {
    
//    1
//    NSLog(@"!!!%@", [self intToStrng:5]);

//   2
//    NSString *(^intToString)(NSUInteger) = ^(NSUInteger parametr) {
//        
//        return [NSString stringWithFormat:@"%lu", parametr];
//    };
    
//    NSLog(@"!!!%@", intToString(15));
    
//   3
    
//    NSLog(@"!!!%@", [self convertIntToString:123 blockObject:intToString]);
    
//   4.2
//    NSLog(@"!!!%@", [self convertIntToString:1235 blockObject:inlineconventer]);
    
//
////   5
//    
     NSLog(@"!!!%@", [self convertIntToString:12356 blockObject:^NSString *(NSUInteger parametr) {
         
         return [NSString stringWithFormat:@"%lu", parametr];
     }]);
//
  }
//
////   4.1




//- (NSString *)intToStrng:(NSUInteger)parametr {
//    
//    return [NSString stringWithFormat:@"%lu",parametr];
//}

//   For 3,5
- (NSString *)convertIntToString:(NSUInteger)parametrInteger
                     blockObject:(intToString)parametrBlock {
    sleep(5);
    return parametrBlock(parametrInteger * 2);
}

//   For 4


@end
