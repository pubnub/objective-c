/**
 * @author Serhii Mamontov
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PNAccessContractTestSteps.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNAccessContractTestSteps ()

#pragma mark - Information

/**
 * @brief Access token which should be used with feature scenarios.
 */
@property (nonatomic, copy) NSString *authToken;

/**
 * @brief Access token parsed during one of steps.
 */
@property (nonatomic, nullable, strong) PNPAMToken *token;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNAccessContractTestSteps


#pragma mark - Initialization & Configuration

- (void)handleBeforeHook {
    self.token = nil;
    [super handleBeforeHook];
}

- (void)setup {
    [self startCucumberHookEventsListening];
    
    Given(@"I have a keyset with access manager enabled", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        // Do noting, because client doesn't support token grant.
    });
    
    Given(@"^I have a known token containing (.*)$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.authToken = @"qEF2AkF0GmEI03xDdHRsGDxDcmVzpURjaGFuoWljaGFubmVsLTEY70NncnChb2NoYW5uZWxfZ3JvdXAtMQVDdXNyoENzcGOgRHV1aWShZnV1aWQtMRhoQ3BhdKVEY2hhbqFtXmNoYW5uZWwtXFMqJBjvQ2dycKF0XjpjaGFubmVsX2dyb3VwLVxTKiQFQ3VzcqBDc3BjoER1dWlkoWpedXVpZC1cUyokGGhEbWV0YaBEdXVpZHR0ZXN0LWF1dGhvcml6ZWQtdXVpZENzaWdYIPpU-vCe9rkpYs87YUrFNWkyNq8CVvmKwEjVinnDrJJc";
    });
    
    When(@"I parse the token", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.token = [self.client parseAuthToken:self.authToken];
    });
    
    Then(@"^the parsed token output contains the authorized UUID \"(.*)\"$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        XCTAssertNotNil(self.token.authorizedUUID);
        XCTAssertEqualObjects(self.token.authorizedUUID, args.firstObject);
    });
    
    Then(@"^the token has '(.*)' UUID resource access permissions$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        XCTAssertGreaterThanOrEqual(self.token.resources.uuids.count, 1);
        XCTAssertNotNil(self.token.resources.uuids[args.firstObject]);
    });
    
    Match(@[@"*"], @"token resource permission GET", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        XCTAssertEqual(self.token.resources.uuids.allValues.lastObject.value & PNPAMPermissionGet, PNPAMPermissionGet);
    });
    
    Then(@"the token has '(.*)' UUID pattern access permissions", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        XCTAssertGreaterThanOrEqual(self.token.patterns.uuids.count, 1);
        XCTAssertNotNil(self.token.patterns.uuids[args.firstObject]);
    });
    
    Match(@[@"*"], @"token pattern permission GET", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        XCTAssertEqual(self.token.patterns.uuids.allValues.lastObject.value & PNPAMPermissionGet, PNPAMPermissionGet);
    });
}

#pragma mark -


@end
