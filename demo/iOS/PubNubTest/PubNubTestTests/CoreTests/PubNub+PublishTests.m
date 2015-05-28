//
//  PubNub+PublishTests.m
//  PubNubTest
//
//  Created by Vadim Osovets on 5/27/15.
//  Copyright (c) 2015 PubNub Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>
#import "TestConfigurator.h"
#import "Swizzler.h"

@interface PubNub_PublishTests : XCTestCase

@end

@implementation PubNub_PublishTests {
    
    PubNub *_pubNub;
}

- (void)setUp {
    
    [super setUp];
    _pubNub = [PubNub clientWithPublishKey:[[TestConfigurator shared] mainPubKey]
                           andSubscribeKey:[[TestConfigurator shared] mainSubKey]];
}

- (void)tearDown {
    
    _pubNub = nil;
    [super tearDown];
}

#pragma mark - Tests Messages (compressed:NO)

- (void)testPublishNilMessage {
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send nil message"];
    
    [_pubNub publish:nil
           toChannel:[TestConfigurator uniqueString]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
          if (!status.isError) {
              
              XCTFail(@"Should return an error");
          } else {
              
              NSString *errorInfomation = [status.data objectForKey:@"information"];
#warning Server returns incorrect information about error
              XCTAssertTrue([errorInfomation isEqualToString:@"Channel not specified."]);  // !!! may be @"Message isn't specified"
          }
          [_publishExpectation fulfill];
      }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
        }
    }];
}

- (void)testPublishEmptyMessage {
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send empty message"];
    
    [_pubNub publish:@""
           toChannel:[TestConfigurator uniqueString]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
          if (status.isError) {
              
              XCTFail(@"Error occurs during publishing %@", status.data);
          }
          [_publishExpectation fulfill];
      }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
        }
    }];
}

- (void)testPublishHugeMessage {
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send huge message"];
    
    [_pubNub publish:[self randomStringWithLength:40000]
           toChannel:[TestConfigurator uniqueString]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
          if (!status.isError) {
              
              XCTFail(@"Should return an error");
          } else {
              
              NSString *errorInfomation = [status.data objectForKey:@"information"];
              
#warning Server returns incorrect information about error
              XCTAssertTrue([errorInfomation isEqualToString:@"JSON text did not start with array or object and option to allow fragments not set."]);
          }
          [_publishExpectation fulfill];
      }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
        }
    }];
}

- (void)testPublishWeirdMessage {
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send weird message"];
    
    [_pubNub publish:@"WeirdMessage: /?#[]@!$&’()*+,;="
           toChannel:[TestConfigurator uniqueString]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
          if (status.isError) {
              
              XCTFail(@"Error occurs during publishing %@", status.data);
          }
          [_publishExpectation fulfill];
      }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
        }
    }];
}


#pragma mark - Tests Messages (compressed:YES)

- (void)testPublishCompressedNilMessage {
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send compressed nil message"];
    
    [_pubNub publish:nil
           toChannel:[TestConfigurator uniqueString]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:YES
      withCompletion:^(PNStatus *status) {
          
          if (!status.isError) {
              
              XCTFail(@"Should return an error");
          } else {
              
              NSString *errorInfomation = [status.data objectForKey:@"information"];
#warning Server returns incorrect information about error
              XCTAssertTrue([errorInfomation isEqualToString:@"Channel not specified."]);  // May be @"Empty message."
          }
          [_publishExpectation fulfill];
      }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
        }
    }];
}

- (void)testPublishCompressedEmptyMessage {
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send compressed empty message"];
    
    [_pubNub publish:@""
           toChannel:[TestConfigurator uniqueString]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:YES
      withCompletion:^(PNStatus *status) {
          
          if (status.isError) {
              
              XCTFail(@"Error occurs during publishing %@", status.data);
          }
          [_publishExpectation fulfill];
      }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
        }
    }];
}

- (void)testPublishCompressedHugeMessage {
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send compressed huge message"];
    
    [_pubNub publish:[self randomStringWithLength:40000]
           toChannel:[TestConfigurator uniqueString]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:YES
      withCompletion:^(PNStatus *status) {
          
          if (!status.isError) {
              
              XCTFail(@"Should return an error");
          } else {
              
              NSString *errorInfomation = [status.data objectForKey:@"information"];
              XCTAssertTrue([errorInfomation isEqualToString:@"Invalid JSON"]); // is it right?
          }
          [_publishExpectation fulfill];
      }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
        }
    }];
}

- (void)testPublishCompressedWeirdMessage {
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send compressed weird message"];
    
    [_pubNub publish:@"WeirdMessage: /?#[]@!$&’()*+,;="
           toChannel:[TestConfigurator uniqueString]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:YES
      withCompletion:^(PNStatus *status) {
          
          if (status.isError) {
              
              XCTFail(@"Error occurs during publishing %@", status.data);
          }
          [_publishExpectation fulfill];
      }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
        }
    }];
}


#pragma mark - Tests Channels

- (void)testPublishMessageToNilChannel {
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message to channel without name"];
    
    [_pubNub publish:[TestConfigurator uniqueString]
           toChannel:nil
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
          if (!status.isError) {
              
              XCTFail(@"Should return an error");
          } else {
              
              NSString *errorInfomation = [status.data objectForKey:@"information"];
#warning Server returns incorrect information about error
              XCTAssertTrue([errorInfomation isEqualToString:@"Empty message."]); // May be "Channel not specified."
          }
          [_publishExpectation fulfill];
      }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
        }
    }];
}

#warning crach
- (void)t1estPublishMessageToNotStringChannels {
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message to channel with not string name"];
    NSNumber *number = @5;
    
    [_pubNub publish:[TestConfigurator uniqueString]
           toChannel:(NSString *)number
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
          if (status.isError) {
              
              XCTFail(@"Error occurs during publishing %@", status.data);
          }
          [_publishExpectation fulfill];
      }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
        }
    }];
}

- (void)testPublishMessageToNotValidChannel {
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message to channel with not valid name"];
    
    [_pubNub publish:[TestConfigurator uniqueString]
           toChannel:@""
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
          if (!status.isError) {
              
              XCTFail(@"Should return an error");
          } else {
              
              NSString *errorInfomation = [status.data objectForKey:@"information"];
#warning Server returns incorrect information about error
              XCTAssertTrue([errorInfomation isEqualToString:@"Empty message."]); // May be "Channel not specified."
          }
          [_publishExpectation fulfill];
      }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
        }
    }];
}

#warning The channels name shoudn't be so big, test mustn't passes
- (void)testPublishMessageToChannelWithLongName {
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message to channel with to long name"];
    
    [_pubNub publish:[TestConfigurator uniqueString]
           toChannel:[self randomStringWithLength:10000]
   mobilePushPayload:nil
      storeInHistory:YES
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
          if (status.isError) {
              
              XCTFail(@"Error occurs during publishing %@", status.data);
          }
          [_publishExpectation fulfill];
      }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
        }
    }];
}

- (void)testPublishMessageToChannelGroup {
    
    [self createGroup:@"testGroup" withChannel:@"testChannel"];
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message to channelgroup"];
    
    [_pubNub publish:[TestConfigurator uniqueString]
           toChannel:@"testGroup"
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
          if (status.isError) {
              
              XCTFail(@"Error occurs during publishing %@", status.data);
          }
          [_publishExpectation fulfill];
      }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
        }
    }];
}


#pragma mark - Store message in history

- (void)testPublishWithStoryInHistory {
    
    NSString *testChannel = [TestConfigurator uniqueString];
    NSString *testMessage = [self randomStringWithLength:10];
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message"];
    
    [_pubNub publish:testMessage
           toChannel:testChannel
   mobilePushPayload:nil
      storeInHistory:YES
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
          if (status.isError) {
              
              XCTFail(@"Error occurs during publishing %@", status.data);
          }
          [_publishExpectation fulfill];
      }];
    
#warning it doesn't work without delay
    sleep(5); // delay
    NSString *savedMessage = [[self historyForChannel:testChannel] lastObject];
    XCTAssertEqualObjects(testMessage, savedMessage, @"Error, test-message: %@, saved-message: %@", testMessage, savedMessage);
}

- (void)testPublishWithoutStoryInHistory {
    
    NSString *testChannel = [TestConfigurator uniqueString];
    NSString *testMessage = [TestConfigurator uniqueString];
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message"];
    
    [_pubNub publish:testMessage
           toChannel:testChannel
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
          if (status.isError) {
              
              XCTFail(@"Error occurs during publishing %@", status.data);
          }
          [_publishExpectation fulfill];
      }];
    
    NSString *savedMessage = [[self historyForChannel:testChannel] lastObject];
    XCTAssertFalse([testMessage isEqual:savedMessage], @"Error, test-message: %@, saved-message: %@", testMessage, savedMessage);
}


#pragma mark - Private methods

-(NSString *)randomStringWithLength:(int)length {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i = 0; i < length; i++) {
        
        [randomString appendFormat: @"%C",[letters characterAtIndex:(NSUInteger)arc4random_uniform((u_int32_t)[letters length])]];
    }
    return randomString;
}

- (void)createGroup:(NSString *)groupName withChannel:(NSString *)channelName {
    
    XCTestExpectation *addChannelsExpectation = [self expectationWithDescription:@"Adding channels"];
    
    [_pubNub addChannels:@[channelName] toGroup:groupName withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during adding channels %@", status.data);
        }
        [addChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
        }
    }];
}

- (NSArray *)historyForChannel:(NSString *)channelName {
    
    XCTestExpectation *_getHistoryExpectation = [self expectationWithDescription:@"Getting history"];
    __block NSMutableArray *messages = nil;
    
    [_pubNub historyForChannel:channelName withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting history %@", status.data);
        } else {
            
            NSArray *dictionariesWithMessage = (NSArray *)[result.data objectForKey:@"messages"];
            messages = [NSMutableArray new];
            
            for (NSDictionary *dic in dictionariesWithMessage) {
                
                [messages addObject:[dic objectForKey:@"message"]];
            }
        }
        [_getHistoryExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            XCTFail(@"Timeout is fired");
        }
    }];
    
    return messages;
}

#pragma mark - in prosses
- (void)testPublishMessage {
    
//    SwizzleReceipt *receipt = [Swizzler swizzleSelector:@selector(processRequest:) forClass:[PubNub class] withSelector:@selector(processRequest) fromClass:[self class]];
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message to channel with to long name"];
    
    [_pubNub publish:[TestConfigurator uniqueString]
           toChannel:[self randomStringWithLength:10]
   mobilePushPayload:nil
      storeInHistory:YES
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
          if (status.isError) {
              
              XCTFail(@"Error occurs during publishing %@", status.data);
          }
          [_publishExpectation fulfill];
      }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
        }
    }];
}



@end
