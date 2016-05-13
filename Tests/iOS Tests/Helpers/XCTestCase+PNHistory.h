//
//  XCTestCase+PNHistory.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 5/13/16.
//
//

#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

@interface XCTestCase (PNHistory)

- (PNHistoryCompletionBlock)PN_historyCompletionBlock;

@end
