//
//  PNDeserializeResponseTest.m
//  UnitTests
//
//  Created by Vadim Osovets on 12/15/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface PNDeserializeResponseTest : XCTestCase

@end

@implementation PNDeserializeResponseTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParsingSeveralResponses {
    // This is an example of a performance test case.
    
//    NSMutableData *data = [NSMutableData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"response-1418134298673.541" ofType:@"dmp"]];
//    id deserializer = [NSClassFromString(@"PNResponseDeserialize") new];
//    [deserializer performSelector:@selector(parseResponseData:withBlock:)
//                       withObject:data
//                       withObject:^(NSArray *responses){
//                           
//                           NSLog(@"RESPONSE: %d", [responses count]);
//                       }];
    
    // prepare test data
    
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSError * error;
    resourcePath = [resourcePath stringByAppendingPathComponent:@"dump files.bundle"];
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:&error];
    
    NSMutableArray *storedResponses = [NSMutableArray new];
    
    for (NSString *dmpFileName in directoryContents) {
        NSString *dmpFilePath = [resourcePath stringByAppendingPathComponent:dmpFileName];
        
        NSMutableData *data = [NSMutableData dataWithContentsOfFile:dmpFilePath];
        
        [storedResponses addObject:data];
    }
    
    GCDGroup *group = [GCDGroup group];
    
    [group enterTimes:[storedResponses count]];
    
    // check that we have only one response in all batches
    for (NSData *data in storedResponses) {
        
        // get deserializer
        id deserializer = [NSClassFromString(@"PNResponseDeserialize") new];
        [deserializer performSelector:@selector(parseBufferContent:withBlock:)
                           withObject:dispatch_data_create(data.bytes, data.length, NULL, DISPATCH_DATA_DESTRUCTOR_DEFAULT)
                           withObject:^(NSArray *responses, NSUInteger fullBufferLength,
                                        NSUInteger processedBufferLength,
                                        void(^readBufferPostProcessing)(void)) {
                               
                               NSLog(@"RESPONSE: %@", @([responses count]));
                               readBufferPostProcessing();
                               
                               XCTAssert([responses count] == 1, @"More than one response in batch");
                               
                               [group leave];
                           }];
    }

    if ([GCDWrapper isGCDGroup:group timeoutFiredValue:30]) {
        XCTFail(@"Timout fired.");
        group = nil;
        
        return;
    }
    
    // complex requests
    
    resourcePath = [[NSBundle mainBundle] resourcePath];
    
    resourcePath = [resourcePath stringByAppendingPathComponent:@"dump files complex.bundle"];
    directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:&error];
    
    storedResponses = [NSMutableArray new];
    
    for (NSString *dmpFileName in directoryContents) {
        NSString *dmpFilePath = [resourcePath stringByAppendingPathComponent:dmpFileName];
        
        NSMutableData *data = [NSMutableData dataWithContentsOfFile:dmpFilePath];
        
        [storedResponses addObject:data];
    }
    
    group = [GCDGroup group];
    
    [group enterTimes:[storedResponses count]];
    
    // check that we have only one response in all batches
    for (NSData *data in storedResponses) {
        
        // get deserializer
        id deserializer = [NSClassFromString(@"PNResponseDeserialize") new];
        [deserializer performSelector:@selector(parseBufferContent:withBlock:)
                           withObject:dispatch_data_create(data.bytes, data.length, NULL, DISPATCH_DATA_DESTRUCTOR_DEFAULT)
                           withObject:^(NSArray *responses, NSUInteger fullBufferLength,
                                        NSUInteger processedBufferLength,
                                        void(^readBufferPostProcessing)(void)) {
                               
                               NSLog(@"RESPONSE: %@", @([responses count]));
                               
                               // TODO: now we have example with only 2 response in the case chunk,
                               // in future we need to improve it
                               XCTAssert([responses count] == 2, @"Cannot handle 2 response in one HTTP session.");
                               
                               [group leave];
                           }];
    }
    
    if ([GCDWrapper isGCDGroup:group timeoutFiredValue:30]) {
        XCTFail(@"Timout fired.");
    }

    group = nil;
}

@end
