//
//  XCTestCase+PNClientState.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 5/5/16.
//
//

#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

@interface XCTestCase (PNClientState)

- (PNSetStateCompletionBlock)PN_successfulSetClientState:(NSDictionary *)state;

@end
