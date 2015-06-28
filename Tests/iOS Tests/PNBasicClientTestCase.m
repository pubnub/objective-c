//
//  PNBasicClientTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//
#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"

@implementation PNBasicClientTestCase

- (JSZVCRTestingStrictness)matchingFailStrictness {
    return JSZVCRTestingStrictnessNone;
}

- (void)setUp {
    [super setUp];
    PNConfiguration *config = [PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
    config.uuid = @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C";
    self.client = [PubNub clientWithConfiguration:config];
}

- (void)tearDown {
    self.client = nil;
    [super tearDown];
}

- (Class<JSZVCRMatching>)matcherClass {
    return [JSZVCRUnorderedQueryMatcher class];
}

@end
