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
    
    NSArray *excludeTags = @[
        @"feature=push",
        @"contract=grantAllPermissions",
        @"contract=grantWithoutAuthorizedUUID",
        @"contract=grantWithAuthorizedUUID",
        @"contract=grantWithoutAnyPermissionsError",
        @"contract=grantWithRegExpSyntaxError",
        @"contract=grantWithRegExpNonCapturingError",
        @"missingOpenApi",
        @"skip"
    ];
    
    NSBundle * bundle = [NSBundle bundleForClass:[PNContractTestCase class]];
    [Cucumberish executeFeaturesInDirectory:@"Features"
                                 fromBundle:bundle
                                includeTags:nil
                                excludeTags:excludeTags];
}
