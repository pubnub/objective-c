/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNDownloadFileAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNDownloadFileAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNDownloadFileAPICallBuilder * (^)(NSString *key))cipherKey {
    return ^PNDownloadFileAPICallBuilder * (NSString *key) {
        if ([key isKindOfClass:[NSString class]]) {
            [self setValue:key forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNDownloadFileAPICallBuilder * (^)(NSURL *path))url {
    return ^PNDownloadFileAPICallBuilder * (NSURL *url) {
        if ([url isKindOfClass:[NSURL class]]) {
            [self setValue:url forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNDownloadFileCompletionBlock block))performWithCompletion {
    return ^(PNDownloadFileCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
