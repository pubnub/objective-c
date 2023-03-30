/**
 * @author Serhii Mamontov
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PNPublishContractTestSteps.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNPublishContractTestSteps ()


#pragma mark - Helpers

- (PNPublishAPICallBuilder *)publishBuilderForMessage:(id)message toChannel:(NSString *)channel;
- (id)message:(id)message castedToType:(NSString *)type;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNPublishContractTestSteps


#pragma mark - Initialization & Configuration

- (void)setup {
    [self startCucumberHookEventsListening];
    
    When(@"^I publish a message$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNPublishOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.publish()
                .message(@"hello")
                .channel(@"test")
                .performWithCompletion(^(PNPublishStatus *status) {
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });
    
    When(@"^I publish ('(.*)' (string|number|array|dictionary) as|too long) message to '(.*)' channel( with compression| as POST body)?$",
         ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNPublishOperation;
        XCTAssertGreaterThanOrEqual(args.count, 2);
        id message;
        id channel;
        
        if ([args[0] isEqualToString:@"too long"]) {
            NSMutableString *string = [NSMutableString new];
            for (NSUInteger count = 0; count < 2500; count += 6) [string appendString:@"hello-"];
            message = string;
            channel = args[1];
        } else {
            args = [args subarrayWithRange:NSMakeRange(1, args.count - 1)];
            message = [self message:args[0] castedToType:args[1]];
            channel = args[2];
        }
        
        PNPublishAPICallBuilder *publish = [self publishBuilderForMessage:message toChannel:channel];
        if (args.count == 4 && [args[3] isEqualToString:@" with compression"]) publish.compress(YES);
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            publish.performWithCompletion(^(PNPublishStatus *status) {
                [self storeRequestStatus:status];
                completion();
            });
        }];
    });
    
    When(@"^I publish '(.*)' (string|number|array|dictionary) as message to '(.*)' channel with '(.*)' set to '(.*)'$",
         ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNPublishOperation;
        XCTAssertEqual(args.count, 5);
        
        id message = [self message:args[0] castedToType:args[1]];
        id channel = args[2];
        
        PNPublishAPICallBuilder *publish = [self publishBuilderForMessage:message toChannel:channel];
        if (args.count == 5 && [args[3] isEqualToString:@"meta"]) {
            NSString *metaType = [args[4] characterAtIndex:0] == '{' ? @"dictionary" : @"string";
            publish.metadata([self message:args[4] castedToType:metaType]);
        } else if (args.count == 5 && [args[3] isEqualToString:@"store"]) {
            publish.shouldStore([args[4] isEqualToString:@"1"]);
        } else if (args.count == 5 && [args[3] isEqualToString:@"ttl"]) {
            publish.ttl(args[4].integerValue);
        }
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            publish.performWithCompletion(^(PNPublishStatus *status) {
                [self storeRequestStatus:status];
                completion();
            });
        }];
    });

    When(@"^I publish a message with (.*) metadata$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNPublishOperation;

        [self callCodeSynchronously:^(dispatch_block_t completion) {
            id meta = [args.lastObject isEqualToString:@"JSON"] ? @{@"test-user": @"bob"} : @"test-user=bob";
            self.client.publish()
                .message(@"hello")
                .channel(@"test")
                .metadata(meta)
                .performWithCompletion(^(PNPublishStatus *status) {
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });

    When(@"^I publish message with '(.*)' space id and '(.*)' type$",
         ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNPublishOperation;

        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.publish()
                .message(@"hello")
                .channel(@"test")
                .type(args.lastObject)
                .spaceId([PNSpaceId spaceIdFromString:args.firstObject])
                .performWithCompletion(^(PNPublishStatus *status) {
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });
    
    When(@"^I send a signal$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNSignalOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.signal()
                .message(@"hello")
                .channel(@"test")
                .performWithCompletion(^(PNSignalStatus *status) {
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });

    When(@"^I send a signal with '(.*)' space id and '(.*)' type$",
         ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNSignalOperation;

        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.signal()
                .message(@"hello")
                .channel(@"test")
                .type(args.lastObject)
                .spaceId([PNSpaceId spaceIdFromString:args.firstObject])
                .performWithCompletion(^(PNSignalStatus *status) {
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });
}


#pragma mark - Helpers

- (PNPublishAPICallBuilder *)publishBuilderForMessage:(id)message toChannel:(NSString *)channel {
    return self.client.publish().channel(channel).message(message);
}

- (id)message:(id)message castedToType:(NSString *)type {
    if ([type isEqualToString:@"number"]) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        message = [formatter numberFromString:message];
    } else if (![type isEqualToString:@"string"]) {
        NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
        message = [NSJSONSerialization JSONObjectWithData:messageData options:0 error:nil];
    }
    
    return message;
}

#pragma mark -


@end
