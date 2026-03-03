/**
 * @author Serhii Mamontov
 * @copyright © 2010-2026 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <PubNub/PNHelpers.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNChannelTest : XCTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNChannelTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: Lists encoding :: namesForRequest:

- (void)testItShouldReturnCommaSeparatedStringWhenMultipleNamesProvided {
    NSArray<NSString *> *names = @[@"channel1", @"channel2", @"channel3"];

    NSString *result = [PNChannel namesForRequest:names];

    XCTAssertNotNil(result, @"Result should not be nil.");
    XCTAssertTrue([result containsString:@"channel1"], @"Should contain first channel.");
    XCTAssertTrue([result containsString:@"channel2"], @"Should contain second channel.");
    XCTAssertTrue([result containsString:@"channel3"], @"Should contain third channel.");
    XCTAssertTrue([result containsString:@","], @"Should use comma as separator.");
}

- (void)testItShouldReturnSingleNameWhenOneNameProvided {
    NSArray<NSString *> *names = @[@"my-channel"];

    NSString *result = [PNChannel namesForRequest:names];

    XCTAssertNotNil(result, @"Result should not be nil.");
    XCTAssertEqualObjects(result, @"my-channel", @"Should return single channel name.");
}

- (void)testItShouldReturnNilWhenEmptyArrayProvided {
    NSArray<NSString *> *names = @[];

    NSString *result = [PNChannel namesForRequest:names];

    XCTAssertNil(result, @"Result should be nil for empty array.");
}

- (void)testItShouldPercentEncodeNamesWhenSpecialCharactersPresent {
    NSArray<NSString *> *names = @[@"channel with spaces"];

    NSString *result = [PNChannel namesForRequest:names];

    XCTAssertNotNil(result, @"Result should not be nil.");
    XCTAssertTrue([result rangeOfString:@" "].location == NSNotFound,
                  @"Spaces should be percent-encoded.");
}


#pragma mark - Tests :: Lists encoding :: namesForRequest:defaultString:

- (void)testItShouldReturnDefaultStringWhenEmptyArrayAndDefaultProvided {
    NSArray<NSString *> *names = @[];
    NSString *defaultString = @",";

    NSString *result = [PNChannel namesForRequest:names defaultString:defaultString];

    XCTAssertEqualObjects(result, defaultString,
                         @"Should return default string when names array is empty.");
}

- (void)testItShouldReturnNamesWhenNonEmptyArrayAndDefaultProvided {
    NSArray<NSString *> *names = @[@"channel1"];
    NSString *defaultString = @",";

    NSString *result = [PNChannel namesForRequest:names defaultString:defaultString];

    XCTAssertEqualObjects(result, @"channel1",
                         @"Should return encoded names instead of default when array is non-empty.");
}


#pragma mark - Tests :: Lists decoding :: namesFromRequest:

- (void)testItShouldSplitResponseStringWhenCommaSeparatedNamesProvided {
    NSString *response = @"channel1,channel2,channel3";

    NSArray<NSString *> *names = [PNChannel namesFromRequest:response];

    XCTAssertEqual(names.count, 3, @"Should split into 3 names.");
    XCTAssertEqualObjects(names[0], @"channel1", @"First name should match.");
    XCTAssertEqualObjects(names[1], @"channel2", @"Second name should match.");
    XCTAssertEqualObjects(names[2], @"channel3", @"Third name should match.");
}

- (void)testItShouldReturnSingleElementArrayWhenNoCommasPresent {
    NSString *response = @"channel1";

    NSArray<NSString *> *names = [PNChannel namesFromRequest:response];

    XCTAssertEqual(names.count, 1, @"Should return array with single element.");
    XCTAssertEqualObjects(names[0], @"channel1", @"Name should match.");
}


#pragma mark - Tests :: Subscriber helper :: isPresenceObject:

- (void)testItShouldReturnYESWhenChannelNameEndsWithPnpres {
    XCTAssertTrue([PNChannel isPresenceObject:@"my-channel-pnpres"],
                  @"Channel ending with -pnpres should be detected as presence.");
}

- (void)testItShouldReturnNOWhenChannelNameDoesNotEndWithPnpres {
    XCTAssertFalse([PNChannel isPresenceObject:@"my-channel"],
                   @"Regular channel should not be detected as presence.");
}

- (void)testItShouldReturnNOWhenChannelNameContainsPnpresInMiddle {
    XCTAssertFalse([PNChannel isPresenceObject:@"my-pnpres-channel"],
                   @"Channel with -pnpres in the middle should not be detected as presence.");
}

- (void)testItShouldReturnYESWhenChannelIsJustPnpresSuffix {
    XCTAssertTrue([PNChannel isPresenceObject:@"-pnpres"],
                  @"Channel that is just '-pnpres' should be detected as presence.");
}


#pragma mark - Tests :: Subscriber helper :: channelForPresence:

- (void)testItShouldRemovePnpresSuffixWhenPresenceChannelProvided {
    NSString *result = [PNChannel channelForPresence:@"my-channel-pnpres"];

    XCTAssertEqualObjects(result, @"my-channel",
                         @"Should strip -pnpres suffix to get the actual channel name.");
}

- (void)testItShouldReturnSameStringWhenNonPresenceChannelProvided {
    NSString *result = [PNChannel channelForPresence:@"my-channel"];

    XCTAssertEqualObjects(result, @"my-channel",
                         @"Should return unchanged string when -pnpres suffix is not present.");
}

- (void)testItShouldReturnEmptyStringWhenChannelIsJustPnpresSuffix {
    NSString *result = [PNChannel channelForPresence:@"-pnpres"];

    XCTAssertEqualObjects(result, @"",
                         @"Should return empty string when channel name is just '-pnpres'.");
}


#pragma mark - Tests :: Subscriber helper :: presenceChannelsFrom:

- (void)testItShouldAppendPnpresSuffixWhenRegularChannelsProvided {
    NSArray<NSString *> *names = @[@"channel1", @"channel2"];

    NSArray<NSString *> *presenceNames = [PNChannel presenceChannelsFrom:names];

    XCTAssertEqual(presenceNames.count, 2, @"Should return same number of channels.");
    for (NSString *name in presenceNames) {
        XCTAssertTrue([name hasSuffix:@"-pnpres"],
                      @"Each channel should have -pnpres suffix, got: %@", name);
    }
}

- (void)testItShouldNotDoubleSuffixWhenPresenceChannelsProvided {
    NSArray<NSString *> *names = @[@"channel1-pnpres"];

    NSArray<NSString *> *presenceNames = [PNChannel presenceChannelsFrom:names];

    XCTAssertEqual(presenceNames.count, 1, @"Should return one channel.");
    XCTAssertTrue([presenceNames containsObject:@"channel1-pnpres"],
                  @"Should not double -pnpres suffix.");
}

- (void)testItShouldNotAppendSuffixWhenWildcardChannelProvided {
    NSArray<NSString *> *names = @[@"channel.*"];

    NSArray<NSString *> *presenceNames = [PNChannel presenceChannelsFrom:names];

    XCTAssertEqual(presenceNames.count, 1, @"Should return one channel.");
    XCTAssertTrue([presenceNames containsObject:@"channel.*"],
                  @"Wildcard channels should not get -pnpres suffix.");
}

- (void)testItShouldReturnEmptyArrayWhenEmptyArrayProvided {
    NSArray<NSString *> *presenceNames = [PNChannel presenceChannelsFrom:@[]];

    XCTAssertEqual(presenceNames.count, 0, @"Should return empty array for empty input.");
}


#pragma mark - Tests :: Subscriber helper :: objectsWithOutPresenceFrom:

- (void)testItShouldRemovePresenceChannelsWhenMixedListProvided {
    NSArray<NSString *> *names = @[@"channel1", @"channel1-pnpres", @"channel2", @"channel2-pnpres"];

    NSArray<NSString *> *filtered = [PNChannel objectsWithOutPresenceFrom:names];

    XCTAssertEqual(filtered.count, 2, @"Should contain only non-presence channels.");
    XCTAssertTrue([filtered containsObject:@"channel1"], @"Should contain channel1.");
    XCTAssertTrue([filtered containsObject:@"channel2"], @"Should contain channel2.");
}

- (void)testItShouldReturnSameListWhenNoPresenceChannelsPresent {
    NSArray<NSString *> *names = @[@"channel1", @"channel2"];

    NSArray<NSString *> *filtered = [PNChannel objectsWithOutPresenceFrom:names];

    XCTAssertEqual(filtered.count, 2, @"Should contain all channels.");
    XCTAssertTrue([filtered containsObject:@"channel1"], @"Should contain channel1.");
    XCTAssertTrue([filtered containsObject:@"channel2"], @"Should contain channel2.");
}

- (void)testItShouldReturnEmptyListWhenAllChannelsArePresence {
    NSArray<NSString *> *names = @[@"channel1-pnpres", @"channel2-pnpres"];

    NSArray<NSString *> *filtered = [PNChannel objectsWithOutPresenceFrom:names];

    XCTAssertEqual(filtered.count, 0, @"Should return empty list when all channels are presence.");
}

- (void)testItShouldReturnEmptyArrayWhenEmptyArrayProvidedForFiltering {
    NSArray<NSString *> *filtered = [PNChannel objectsWithOutPresenceFrom:@[]];

    XCTAssertEqual(filtered.count, 0, @"Should return empty array for empty input.");
}


#pragma mark -

#pragma clang diagnostic pop

@end
