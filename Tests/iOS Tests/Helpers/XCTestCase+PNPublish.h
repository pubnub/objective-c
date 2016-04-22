//
//  XCTestCase+PNPublish.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import <XCTest/XCTest.h>

@class PNPublishStatus;

@interface XCTestCase (PNPublish)

- (void)PN_assertOnPublishStatus:(PNPublishStatus *)status withSuccess:(BOOL)isSuccessful;

//- (PNPublishCompletionBlock)PN_assertWithSuccess:(BOOL)isSuccessful withExpectedTimetoken:(NSNumber *)timeToken;
- (PNPublishCompletionBlock)PN_successfulPublishCompletionWithExpectedTimeToken:(NSNumber *)timeToken;
- (PNPublishCompletionBlock)PN_failedPublishCompletion;

@end
