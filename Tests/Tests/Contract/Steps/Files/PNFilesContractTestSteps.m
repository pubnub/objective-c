/**
 * @author Serhii Mamontov
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PNFilesContractTestSteps.h"


#pragma mark Interface implementation

@implementation PNFilesContractTestSteps


#pragma mark - Initialization & Configuration

- (void)setup {
    [self startCucumberHookEventsListening];
    
    When(@"I list files", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNListFilesOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.files()
                .listFiles(@"test")
                .performWithCompletion(^(PNListFilesResult *result, PNErrorStatus *status) {
                    [self storeRequestResult:result];
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });
    
    When(@"I publish file message", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNPublishFileMessageOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.publishFileMessage()
                .fileIdentifier(@"identifier")
                .fileName(@"name")
                .channel(@"test")
                .message(@"test-file").performWithCompletion(^(PNPublishStatus *status) {
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });
    
    When(@"I delete file", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNDeleteFileOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.files()
                .deleteFile(@"test", @"identifier", @"name.txt")
                .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });
    
    When(@"I download file", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNDownloadFileOperation;
        
        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.files()
                .downloadFile(@"channel", @"identifier", @"name.txt")
                .performWithCompletion(^(PNDownloadFileResult *result, PNErrorStatus *status) {
                    [self storeRequestResult:result];
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });

    When(@"^I send file$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.testedFeatureType = PNSendFileOperation;

        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.files()
                .sendFile(@"test", @"name.txt")
                .data([@"test file data" dataUsingEncoding:NSUTF8StringEncoding])
                .performWithCompletion(^(PNSendFileStatus *status) {
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });

    When(@"^I send a file with '(.+)' space id and '(.+)' type$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        XCTAssertEqual(args.count, 2);
        NSString *messageType = args.lastObject;
        NSString *spaceId = args.firstObject;

        self.testedFeatureType = PNSendFileOperation;

        [self callCodeSynchronously:^(dispatch_block_t completion) {
            self.client.files()
                .sendFile(@"test", @"name.txt")
                .data([@"test file data" dataUsingEncoding:NSUTF8StringEncoding])
                .type(messageType)
                .spaceId([PNSpaceId spaceIdFromString:spaceId])
                .performWithCompletion(^(PNSendFileStatus *status) {
                    [self storeRequestStatus:status];
                    completion();
                });
        }];
    });
}

#pragma mark -


@end
