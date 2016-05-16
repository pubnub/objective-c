#import <XCTest/XCTest.h>
#import <PubNub/PNNumber.h>


/**
 @brief      PNNumber testing.
 @discussion Verify PNNumber output compared to expected conversion results.

 @author Sergey Mamontov
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNNumberTests : XCTestCase


#pragma mark - Properties

/**
 @brief  Stores reference on number with predefined unix timestamp value.
 */
@property (nonatomic, strong) NSNumber *unixTimestamp;

/**
 @brief  Stores reference on number with predefined unix timestamp value which has been multiplied on 10^7.
 */
@property (nonatomic, strong) NSNumber *preMultipliedUnixTimestamp;

/**
 @brief  Stores reference on number with correctly transformed to PubNub timetoken value.
 */
@property (nonatomic, strong) NSNumber *pubNubTimetoken;

#pragma mark - 


@end


#pragma mark - Test case implementation 

@implementation PNNumberTests

- (void)setUp {
    
    // Forward method call to the super class.
    [super setUp];
    
    
    // Prepare 'fixtures'
    self.unixTimestamp = @(1463002708.147192);
    self.preMultipliedUnixTimestamp = @(1463002708.147192 * 10000000);
    self.pubNubTimetoken = @(14630027081471920);
}

- (void)testUnixTimestampToPubNubTimetoken {
    
    NSNumber *convertedPubNubTimetoken = [PNNumber timeTokenFromNumber:self.unixTimestamp];
    XCTAssertEqualObjects(convertedPubNubTimetoken, self.pubNubTimetoken, 
                          @"Unexpected PubNub timetoken value from Unix-timestamp.");
}

- (void)testPubNubTimetokenToPubNubTimetoken {
    
    NSNumber *convertedPubNubTimetoken = [PNNumber timeTokenFromNumber:self.pubNubTimetoken];
    XCTAssertEqualObjects(convertedPubNubTimetoken, self.pubNubTimetoken, 
                          @"Unexpected PubNub timetoken value from 17-digit precision PubNub time token.");
}

- (void)testNilValueToPubNubTimetoken {
    
    NSNumber *convertedPubNubTimetoken = [PNNumber timeTokenFromNumber:nil];
    XCTAssertNil(convertedPubNubTimetoken, @"'nil' should be returned if 'nil' passed to +timeTokenFromNumber:.");
}

/**
 @brief  When test launched on 32bit system allow to verify fix on infinity \c while statement while trying
         to convert pre-multiplied unix-timestamp (double).
 */
- (void)testPreMultipliedUnixTimestampToPubNubTimetoken {
    
    NSNumber *convertedPubNubTimetoken = [PNNumber timeTokenFromNumber:self.preMultipliedUnixTimestamp];
    XCTAssertEqualObjects(convertedPubNubTimetoken, self.pubNubTimetoken,
                          @"Unexpected PubNub timetoken value from pre-multiplied Unix-timestamp.");
}

#pragma mark -


@end
