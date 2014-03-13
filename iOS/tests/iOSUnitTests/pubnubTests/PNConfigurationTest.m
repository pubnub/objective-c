//
//  PNConfigurationTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/4/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNConfiguration+Protected.h"
#import "PNConfiguration.h"
#import "PNDefaultConfiguration.h"
#import "PNConstants.h"

@interface PNConfiguration (test)

@property (nonatomic, copy) NSString *realOrigin;
- (id)copyWithZone:(NSZone *)zone;
@property (nonatomic, assign, getter = shouldUseSecureConnection) BOOL useSecureConnection;
@property (nonatomic, assign, getter = shouldResubscribeOnConnectionRestore) BOOL resubscribeOnConnectionRestore;
@property (nonatomic, assign, getter = shouldRestoreSubscriptionFromLastTimeToken) BOOL restoreSubscriptionFromLastTimeToken;
@property (nonatomic, assign, getter = canIgnoreSecureConnectionRequirement) BOOL ignoreSecureConnectionRequirement;
@property (nonatomic, assign, getter = shouldReduceSecurityLevelOnError) BOOL reduceSecurityLevelOnError;
@property (nonatomic, assign, getter = shouldAutoReconnectClient) BOOL autoReconnectClient;
@property (nonatomic, assign, getter = shouldAcceptCompressedResponse) BOOL acceptCompressedResponse;

@end


@interface PNConfigurationTest : SenTestCase

@end

@implementation PNConfigurationTest

-(void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:0.1];
}

-(void)testDefaultConfiguration {
	PNConfiguration *conf = [PNConfiguration defaultConfiguration];
	STAssertTrue( [conf.origin isEqualToString: kPNOriginHost] == YES, @"");
	STAssertTrue( [conf.publishKey isEqualToString: kPNPublishKey] == YES, @"");
	STAssertTrue( [conf.subscriptionKey isEqualToString: kPNSubscriptionKey] == YES, @"");
	if( kPNSecretKey == nil )
		STAssertTrue( [conf.secretKey isEqualToString: @"0"] == YES, @"");
	else
		STAssertTrue( [conf.secretKey isEqualToString: kPNSecretKey] == YES, @"");
	if( kPNCipherKey == nil )
		STAssertTrue( [conf.cipherKey isEqualToString: @""] == YES, @"");
	else
		STAssertTrue( [conf.cipherKey isEqualToString: kPNCipherKey] == YES, @"");
}

-(void)testConfigurationWithPublishKeySubSecret {
	PNConfiguration *conf = [PNConfiguration configurationWithPublishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret"];
	STAssertTrue( [conf.origin isEqualToString: kPNDefaultOriginHost] == YES, @"");
	STAssertTrue( [conf.publishKey isEqualToString: @"publish"] == YES, @"");
	STAssertTrue( [conf.subscriptionKey isEqualToString: @"subscr"] == YES, @"");
	STAssertTrue( [conf.secretKey isEqualToString: @"secret"] == YES, @"");
	STAssertTrue( [conf.cipherKey isEqualToString: @""] == YES, @"");
	STAssertTrue( [conf.authorizationKey isEqualToString: @""] == YES, @"");
}

-(void)testConfigurationWithPublishKeySubSecretAuth {
	PNConfiguration *conf = [PNConfiguration configurationWithPublishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" authorizationKey: @"auth"];
	STAssertTrue( [conf.origin isEqualToString: kPNDefaultOriginHost] == YES, @"");
	STAssertTrue( [conf.publishKey isEqualToString: @"publish"] == YES, @"");
	STAssertTrue( [conf.subscriptionKey isEqualToString: @"subscr"] == YES, @"");
	STAssertTrue( [conf.secretKey isEqualToString: @"secret"] == YES, @"");
	STAssertTrue( [conf.cipherKey isEqualToString: @""] == YES, @"");
	STAssertTrue( [conf.authorizationKey isEqualToString: @"auth"] == YES, @"");
}

-(void)testConfigurationForOriginPubSubSec {
	PNConfiguration *conf = [PNConfiguration configurationForOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret"];
	STAssertTrue( [conf.origin isEqualToString: @"origin"] == YES, @"");
	STAssertTrue( [conf.publishKey isEqualToString: @"publish"] == YES, @"");
	STAssertTrue( [conf.subscriptionKey isEqualToString: @"subscr"] == YES, @"");
	STAssertTrue( [conf.secretKey isEqualToString: @"secret"] == YES, @"");
	STAssertTrue( [conf.cipherKey isEqualToString: @""] == YES, @"");
	STAssertTrue( [conf.authorizationKey isEqualToString: @""] == YES, @"");
}

-(void)testConfigurationForOriginPubSubSecAuth {
	PNConfiguration *conf = [PNConfiguration configurationForOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" authorizationKey: @"auth"];
	STAssertTrue( [conf.origin isEqualToString: @"origin"] == YES, @"");
	STAssertTrue( [conf.publishKey isEqualToString: @"publish"] == YES, @"");
	STAssertTrue( [conf.subscriptionKey isEqualToString: @"subscr"] == YES, @"");
	STAssertTrue( [conf.secretKey isEqualToString: @"secret"] == YES, @"");
	STAssertTrue( [conf.cipherKey isEqualToString: @""] == YES, @"");
	STAssertTrue( [conf.authorizationKey isEqualToString: @"auth"] == YES, @"");
}

-(void)testConfigurationForOriginPubSubSecChip {
	PNConfiguration *conf = [PNConfiguration configurationForOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper"];
	STAssertTrue( [conf.origin isEqualToString: @"origin"] == YES, @"");
	STAssertTrue( [conf.publishKey isEqualToString: @"publish"] == YES, @"");
	STAssertTrue( [conf.subscriptionKey isEqualToString: @"subscr"] == YES, @"");
	STAssertTrue( [conf.secretKey isEqualToString: @"secret"] == YES, @"");
	STAssertTrue( [conf.cipherKey isEqualToString: @"chiper"] == YES, @"");
	STAssertTrue( [conf.authorizationKey isEqualToString: @""] == YES, @"");
}

-(void)testConfigurationForOriginPubSubSecChipAuth {
	PNConfiguration *conf = [PNConfiguration configurationForOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	STAssertTrue( [conf.origin isEqualToString: @"origin"] == YES, @"");
	STAssertTrue( [conf.publishKey isEqualToString: @"publish"] == YES, @"");
	STAssertTrue( [conf.subscriptionKey isEqualToString: @"subscr"] == YES, @"");
	STAssertTrue( [conf.secretKey isEqualToString: @"secret"] == YES, @"");
	STAssertTrue( [conf.cipherKey isEqualToString: @"chiper"] == YES, @"");
	STAssertTrue( [conf.authorizationKey isEqualToString: @"auth"] == YES, @"");
}

-(void)testInitWithOrigin {
	PNConfiguration *conf = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	STAssertTrue( [conf.origin isEqualToString: @"origin"] == YES, @"");
	STAssertTrue( [conf.realOrigin isEqualToString: @"origin"] == YES, @"");
	STAssertTrue( [conf.publishKey isEqualToString: @"publish"] == YES, @"");
	STAssertTrue( [conf.subscriptionKey isEqualToString: @"subscr"] == YES, @"");
	STAssertTrue( [conf.secretKey isEqualToString: @"secret"] == YES, @"");
	STAssertTrue( [conf.cipherKey isEqualToString: @"chiper"] == YES, @"");
	STAssertTrue( [conf.authorizationKey isEqualToString: @"auth"] == YES, @"");

	STAssertTrue( conf.useSecureConnection == kPNSecureConnectionRequired, @"");
	STAssertTrue( conf.autoReconnectClient == kPNShouldAutoReconnectClient, @"");
	STAssertTrue( conf.reduceSecurityLevelOnError == kPNShouldReduceSecurityLevelOnError, @"");
	STAssertTrue( conf.ignoreSecureConnectionRequirement == kPNCanIgnoreSecureConnectionRequirement, @"");
	STAssertTrue( conf.resubscribeOnConnectionRestore == kPNShouldResubscribeOnConnectionRestore, @"");
	STAssertTrue( conf.restoreSubscriptionFromLastTimeToken == kPNShouldRestoreSubscriptionFromLastTimeToken, @"");
	STAssertTrue( conf.acceptCompressedResponse == kPNShouldAcceptCompressedResponse, @"");
	STAssertTrue( conf.nonSubscriptionRequestTimeout == kPNNonSubscriptionRequestTimeout, @"");
	STAssertTrue( conf.subscriptionRequestTimeout == kPNSubscriptionRequestTimeout, @"");


	conf = [conf copyWithZone: nil];
	STAssertTrue( [conf.origin isEqualToString: @"origin"] == YES, @"");
	STAssertTrue( [conf.realOrigin isEqualToString: @"origin"] == YES, @"");
	STAssertTrue( [conf.publishKey isEqualToString: @"publish"] == YES, @"");
	STAssertTrue( [conf.subscriptionKey isEqualToString: @"subscr"] == YES, @"");
	STAssertTrue( [conf.secretKey isEqualToString: @"secret"] == YES, @"");
	STAssertTrue( [conf.cipherKey isEqualToString: @"chiper"] == YES, @"");
	STAssertTrue( [conf.authorizationKey isEqualToString: @"auth"] == YES, @"");

	STAssertTrue( conf.useSecureConnection == kPNSecureConnectionRequired, @"");
	STAssertTrue( conf.autoReconnectClient == kPNShouldAutoReconnectClient, @"");
	STAssertTrue( conf.reduceSecurityLevelOnError == kPNShouldReduceSecurityLevelOnError, @"");
	STAssertTrue( conf.ignoreSecureConnectionRequirement == kPNCanIgnoreSecureConnectionRequirement, @"");
	STAssertTrue( conf.resubscribeOnConnectionRestore == kPNShouldResubscribeOnConnectionRestore, @"");
	STAssertTrue( conf.restoreSubscriptionFromLastTimeToken == kPNShouldRestoreSubscriptionFromLastTimeToken, @"");
	STAssertTrue( conf.acceptCompressedResponse == kPNShouldAcceptCompressedResponse, @"");
	STAssertTrue( conf.nonSubscriptionRequestTimeout == kPNNonSubscriptionRequestTimeout, @"");
	STAssertTrue( conf.subscriptionRequestTimeout == kPNSubscriptionRequestTimeout, @"");
}

-(void)testRequiresConnectionResetWithConfiguration {
	PNConfiguration *conf1 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	STAssertTrue( [conf1 requiresConnectionResetWithConfiguration: nil] == NO, @"");

	PNConfiguration *conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	conf2.useSecureConnection = !conf1.useSecureConnection;
	STAssertTrue( [conf1 requiresConnectionResetWithConfiguration: conf2] == YES, @"");

	STAssertTrue( [conf1 requiresConnectionResetWithConfiguration: conf2] == YES, @"");

	conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin1" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	STAssertTrue( [conf1 requiresConnectionResetWithConfiguration: conf2] == YES, @"");

	conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth1"];
	STAssertTrue( [conf1 requiresConnectionResetWithConfiguration: conf2] == YES, @"");
}

-(void)testIsEqual {
	PNConfiguration *conf1 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	PNConfiguration *conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	STAssertTrue( [conf1 isEqual: conf2] == YES, @"");

	conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin2" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	STAssertTrue( [conf1 isEqual: conf2] == NO, @"");

	conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish2" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	STAssertTrue( [conf1 isEqual: conf2] == NO, @"");

	conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr2" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	STAssertTrue( [conf1 isEqual: conf2] == NO, @"");

	conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret2" cipherKey: @"chiper" authorizationKey: @"auth"];
	STAssertTrue( [conf1 isEqual: conf2] == NO, @"");

	conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper2" authorizationKey: @"auth"];
	STAssertTrue( [conf1 isEqual: conf2] == NO, @"");

	conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth2"];
	STAssertTrue( [conf1 isEqual: conf2] == NO, @"");

	conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	conf2.nonSubscriptionRequestTimeout = 123;
	STAssertTrue( [conf1 isEqual: conf2] == NO, @"");

	conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	conf2.subscriptionRequestTimeout = 123;
	STAssertTrue( [conf1 isEqual: conf2] == NO, @"");

	conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	conf2.resubscribeOnConnectionRestore = !conf1.resubscribeOnConnectionRestore;
	STAssertTrue( [conf1 isEqual: conf2] == NO, @"");

	conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	conf2.restoreSubscriptionFromLastTimeToken = !conf1.restoreSubscriptionFromLastTimeToken;
	STAssertTrue( [conf1 isEqual: conf2] == NO, @"");

	conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	conf2.ignoreSecureConnectionRequirement = !conf1.ignoreSecureConnectionRequirement;
	STAssertTrue( [conf1 isEqual: conf2] == NO, @"");

	conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	conf2.reduceSecurityLevelOnError = !conf1.reduceSecurityLevelOnError;
	STAssertTrue( [conf1 isEqual: conf2] == NO, @"");

	conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	conf2.useSecureConnection = !conf1.useSecureConnection;
	STAssertTrue( [conf1 isEqual: conf2] == NO, @"");

	conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	conf2.autoReconnectClient = !conf1.autoReconnectClient;
	STAssertTrue( [conf1 isEqual: conf2] == NO, @"");

	conf2 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	conf2.acceptCompressedResponse = !conf1.acceptCompressedResponse;
	STAssertTrue( [conf1 isEqual: conf2] == NO, @"");
}

-(void)testShouldKillDNSCache {
	PNConfiguration *conf1 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	conf1.realOrigin = @"origin";
	STAssertTrue( [conf1 shouldKillDNSCache] == NO, @"");

	conf1.realOrigin = @"origin2";
	STAssertTrue( [conf1 shouldKillDNSCache] == YES, @"");
}

-(void)testShouldKillDNSCacheParam {
	PNConfiguration *conf1 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	conf1.realOrigin = @"realOrigin";
	[conf1 shouldKillDNSCache: NO];
	STAssertTrue( [conf1.origin isEqualToString: conf1.realOrigin] == YES, @"");

	conf1 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	conf1.realOrigin = @"realOrigin";
	[conf1 shouldKillDNSCache: YES];
	STAssertTrue( [conf1.origin isEqualToString: @"origin"] == NO, @"");
	STAssertTrue( conf1.origin != nil && [conf1.origin isKindOfClass: [NSString class]] == YES && conf1.origin.length > 0, @"");
}

-(void)testIsValid {
	PNConfiguration *conf1 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"publish" subscribeKey: @"" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	STAssertTrue( [conf1 isValid] == YES, @"");

	conf1 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"" subscribeKey: @"subscr" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	STAssertTrue( [conf1 isValid] == YES, @"");

	conf1 = [[PNConfiguration alloc] initWithOrigin: @"origin" publishKey: @"" subscribeKey: @"" secretKey: @"secret" cipherKey: @"chiper" authorizationKey: @"auth"];
	STAssertTrue( [conf1 isValid] == NO, @"");
}

@end
