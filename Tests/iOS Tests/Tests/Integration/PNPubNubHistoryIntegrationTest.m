/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <PubNub/PubNub.h>
#import "PNTestCase.h"


#pragma mark Test interface declaration

@interface PNPubNubHistoryIntegrationTest : PNTestCase


#pragma mark - Information

@property (nonatomic, strong) PubNub *client;


#pragma mark - Misc

/**
 * @brief Publish messages with random time tokens to specified channels.
 *
 * @param messagesCount Number of messages which should be published.
 * @param channels List of channel names to which messages should be published.
 *
 * @return Dictinoary where each key represent name of channel and values are timetokens of
 * published messages.
 */
- (NSDictionary<NSString *, NSArray<NSNumber *> *> *)publishMessages:(NSUInteger)messagesCount
                                                          toChannels:(NSArray<NSString *> *)channels;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNPubNubHistoryIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    
    dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:self.publishKey
                                                                     subscribeKey:self.subscribeKey];
    configuration.stripMobilePayload = NO;
    
    self.client = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
}


#pragma mark - Tests :: messageCounts

- (void)testMessageCounts_ShouldFetchCount_WhenSingleChannelAndTimetokenPassed {
    
    NSArray<NSString *> *channels = @[[NSUUID UUID].UUIDString];
    NSDictionary<NSString *, NSArray<NSNumber *> *> *timetokensData = nil;
    timetokensData = [self publishMessages:3 toChannels:channels];
    NSArray<NSNumber *> *channelTimetokens = timetokensData[channels.firstObject];
    NSNumber *timetoken = channelTimetokens[channelTimetokens.count - 2];
    NSDictionary *expected = @{ channels.firstObject: @(1) };
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.messageCounts().channels(channels).timetokens(@[timetoken])
            .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) {
                XCTAssertNil(status);
                XCTAssertEqualObjects(result.data.channels, expected);
                handler();
            });
    }];
}

- (void)testMessageCounts_ShouldFetchCount_WhenSingleTimetokenAndMultipleChannelsPassed {
    
    NSArray<NSString *> *channels = @[[NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString];
    NSDictionary<NSString *, NSArray<NSNumber *> *> *timetokensData = nil;
    timetokensData = [self publishMessages:3 toChannels:channels];
    NSArray<NSNumber *> *channelTimetokens = timetokensData[channels.firstObject];
    NSNumber *timetoken = channelTimetokens[channelTimetokens.count - 2];
    NSDictionary *expected = @{ channels.firstObject: @(1), channels.lastObject: @(3) };
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.messageCounts().channels(channels).timetokens(@[timetoken])
            .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) {
                XCTAssertNil(status);
                XCTAssertEqualObjects(result.data.channels, expected);
                handler();
            });
    }];
}

- (void)testMessageCounts_ShouldFetchCount_WhenPerChannelTimetokenPassed {
    
    NSArray<NSString *> *channels = @[[NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString];
    NSDictionary<NSString *, NSArray<NSNumber *> *> *timetokensData = nil;
    timetokensData = [self publishMessages:3 toChannels:channels];
    NSArray<NSNumber *> *channelTimetokens1 = timetokensData[channels.firstObject];
    NSArray<NSNumber *> *channelTimetokens2 = timetokensData[channels.lastObject];
    NSNumber *timetoken1 = channelTimetokens1[channelTimetokens1.count - 2];
    NSNumber *timetoken2 = channelTimetokens2[channelTimetokens2.count - 2];
    NSArray<NSNumber *> *timetokens = @[timetoken1, timetoken2];
    NSDictionary *expected = @{ channels.firstObject: @(1), channels.lastObject: @(1) };
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.messageCounts().channels(channels).timetokens(timetokens)
            .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) {
                XCTAssertNil(status);
                XCTAssertEqualObjects(result.data.channels, expected);
                handler();
            });
    }];
}

- (void)testMessageCounts_ShouldFail_WhenTimetokenNotPassed {
    
    NSArray<NSString *> *channels = @[[NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.messageCounts().channels(channels)
            .performWithCompletion(^(PNMessageCountResult *result, PNErrorStatus *status) {
                XCTAssertNil(result);
                XCTAssertTrue(status.isError);
                handler();
            });
    }];
}


#pragma mark - Misc

- (NSDictionary<NSString *, NSArray<NSNumber *> *> *)publishMessages:(NSUInteger)messagesCount
                                                          toChannels:(NSArray<NSString *> *)channels {
    
    NSMutableDictionary *channelsMessageTimetokens = [NSMutableDictionary new];
    
    for (NSString *channel in channels) {
        NSMutableArray *messageTimetokens = [NSMutableArray new];
        
        for (NSUInteger msgIdx = 0; msgIdx < messagesCount; msgIdx++) {
            [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
                self.client.publish().channel(channel)
                    .message(@{ @"msg": @([NSDate date].timeIntervalSince1970) })
                    .performWithCompletion(^(PNPublishStatus * status) {
                        if (!status.isError) {
                            [messageTimetokens addObject:status.data.timetoken];
                        }
                        handler();
                    });
            }];
        }
        
        channelsMessageTimetokens[channel] = messageTimetokens;
    }
    
    [self waitTask:@"waitHistoryABit" completionFor:self.delayedCheck];
    
    return channelsMessageTimetokens;
}

#pragma mark -


@end
