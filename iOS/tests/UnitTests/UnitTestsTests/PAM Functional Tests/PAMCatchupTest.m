//
//  PAMcatchupTest.m
//  UnitTests
//
//  Created by Sergey Kazanskiy on 4/1/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface PAMCatchupTest : XCTestCase <PNDelegate>

@end

@implementation PAMCatchupTest  {
    
    GCDGroup *_resGroup;
    PubNub *_testClient;
}

- (void)setUp {
    
    [super setUp];
    [PubNub disconnect];
    
    _testClient = [PubNub clientWithConfiguration:[PNConfiguration accessManagerTestConfiguration] andDelegate:self];
}

- (void)tearDown {
    
    [PubNub disconnect];
    [super tearDown];
}

- (void)testChangeAndAuditWithoutDelay {
    
    [PubNub setDelegate:self];
    
    [_testClient connect];
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    

    // First change access rights to "Read"
    [_testClient changeApplicationAccessRightsTo:PNReadAccessRight onPeriod:10 andCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection1, PNError *error) {
        
        if (error) {
            
            XCTFail(@"Client did fail to change access rights");
        } else {
            
            XCTAssertTrue([accessRightsCollection1 accessRightsInformationForApplication].rights == PNReadAccessRight);
            
            // Audit access rights ("Read")
            [_testClient auditAccessRightsForApplicationWithCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection2, PNError *error) {
                
                if (error) {
                    
                    XCTFail(@"Client did fail to audit access rights");
                } else {
                    
                    XCTAssertTrue([accessRightsCollection2 accessRightsInformationForApplication].rights == PNReadAccessRight);
                }
            }];
            

            // Second change access rights to "Write"
            [_testClient changeApplicationAccessRightsTo:PNWriteAccessRight onPeriod:10 andCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection3, PNError *error) {
                
                if (error) {
                    
                    XCTFail(@"Client did fail to change access rights");
                } else {
                    
                    XCTAssertTrue([accessRightsCollection3 accessRightsInformationForApplication].rights == PNWriteAccessRight);
                    
#warning Test failed without delay here.
                    // Uncomment only for test with delay.
//                    [GCDWrapper sleepForSeconds:3];
                    
                    // Audit access rights ("Write")
                    [_testClient auditAccessRightsForApplicationWithCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection4, PNError *error) {
                        
                        if (error) {
                            
                            XCTFail(@"Client did fail to audit access rights");
                        } else {
                            
                            XCTAssertTrue([accessRightsCollection4 accessRightsInformationForApplication].rights == PNWriteAccessRight);
                            [_resGroup leave];
                        }
                    }];
                }
            }];
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTFail(@"Timeout fired during change or audit access right.");
    }
}

@end
