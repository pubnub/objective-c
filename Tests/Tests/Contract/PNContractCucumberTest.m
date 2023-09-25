//
//  ContractCucumberTest.m
//  [iOS] Contract Tests
//
//  Created by Sergey Mamontov on 10/2/21.
//  Copyright © 2021 Serhii Mamontov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNContractTestCase.h"

__attribute__((constructor))
void CucumberishInit(void) {
    [[Cucumberish instance] setPrettyNamesAllowed:YES];
    // Setup common steps
    [[PNContractTestCase new] setup];
    [Cucumberish instance].fixMissingLastScenario = NO;
    
    NSMutableArray *excludeTags = [@[
        @"contract=grantAllPermissions",
        @"contract=grantWithoutAuthorizedUUID",
        @"contract=grantWithAuthorizedUUID",
        @"contract=grantWithoutAnyPermissionsError",
        @"contract=grantWithRegExpSyntaxError",
        @"contract=grantWithRegExpNonCapturingError",
        @"missingOpenApi",
        @"na=objc",
        @"beta",
        @"skip"
    ] mutableCopy];
    
    
    NSString *xcTestBundlePath = NSProcessInfo.processInfo.environment[@"XCTestBundlePath"];
    NSBundle *contractTestsBundle = [NSBundle bundleForClass:[PNContractTestCase class]];
    Cucumberish.instance.resultsDirectory = contractTestsBundle.infoDictionary[@"CUCUMBER_REPORTS_PATH"];
    
    if ([xcTestBundlePath rangeOfString:@"Contract Tests Beta"].location != NSNotFound) {
        [excludeTags removeObject:@"beta"];
    }

    NSArray *includeTags = @[@"featureSet=cryptoModule"];
    excludeTags = nil;
    
    NSBundle * bundle = [NSBundle bundleForClass:[PNContractTestCase class]];
    [Cucumberish executeFeaturesInDirectory:@"Features"
                                 fromBundle:bundle
                                includeTags:includeTags
                                excludeTags:excludeTags];
}
