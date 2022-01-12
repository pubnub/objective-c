/**
 * @author Serhii Mamontov
 * @copyright © 2010-2022 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import <XCTest/XCTest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNConfigurationTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNConfigurationTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: UUID requirement

- (void)testItShouldNotThrowWhenUUIDIsSet {
    XCTAssertNoThrow([PNConfiguration configurationWithPublishKey:@"demo" subscribeKey:@"demo" uuid:@"uuid"],
                     @"Should not throw when UUID is set.");
}

- (void)testItShouldNotThrowWhenSetToNonEmptyUUID {
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" subscribeKey:@"demo" uuid:@"uuid"];
    XCTAssertNoThrow(configuration.uuid = @"uuid2", @"Should not throw when UUID changed.");
}

- (void)testItShouldThrowWhenUUIDIsEmpty {
    XCTAssertThrows([PNConfiguration configurationWithPublishKey:@"demo" subscribeKey:@"demo" uuid:@""],
                    @"Should throw on empty UUID.");
}

- (void)testItShouldThrowWhenUUIDWhichContainsOnlySpaces {
    XCTAssertThrows([PNConfiguration configurationWithPublishKey:@"demo" subscribeKey:@"demo" uuid:@"   "],
                    @"Should throw on empty UUID.");
}

- (void)testItShouldThrowWhenSetEmptyUUID {
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" subscribeKey:@"demo" uuid:@"uuid"];
    XCTAssertThrows(configuration.uuid = @"", @"Should throw when UUID changed to empty.");
}

- (void)testItShouldThrowWhenSetUUIDWhichContainsOnlySpaces {
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" subscribeKey:@"demo" uuid:@"uuid"];
    XCTAssertThrows(configuration.uuid = @"    ", @"Should throw when UUID changed to empty.");
}

#pragma mark -

#pragma clang diagnostic pop

@end
