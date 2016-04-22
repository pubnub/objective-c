//
//  PNPublishSizeOfMessageTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import "PNClientTestCase.h"

@interface PNPublishSizeOfMessageTestCase : PNClientTestCase

@end

@implementation PNPublishSizeOfMessageTestCase

- (BOOL)isRecording {
    return YES;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

@end
