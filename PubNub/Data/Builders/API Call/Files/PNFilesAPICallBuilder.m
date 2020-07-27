/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNFileDownloadURLAPICallBuilder.h"
#import "PNDownloadFileAPICallBuilder.h"
#import "PNDeleteFileAPICallBuilder.h"
#import "PNListFilesAPICallBuilder.h"
#import "PNSendFileAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"
#import "PNFilesAPICallBuilder.h"
#import <objc/runtime.h>


#pragma mark Interface implementation

@implementation PNFilesAPICallBuilder


#pragma mark - Initialization

+ (void)initialize {
    if (self == [PNFilesAPICallBuilder class]) {
        [self copyMethodsFromClasses:@[
            [PNSendFileAPICallBuilder class],
            [PNListFilesAPICallBuilder class],
            [PNFileDownloadURLAPICallBuilder class],
            [PNDownloadFileAPICallBuilder class],
            [PNDeleteFileAPICallBuilder class],
        ]];
    }
}


#pragma mark - Upload file

- (PNSendFileAPICallBuilder * (^)(NSString *channel, NSString *name))sendFile {
    return ^PNSendFileAPICallBuilder * (NSString *channel, NSString *name) {
        object_setClass(self, [PNSendFileAPICallBuilder class]);
        
        [self setValue:channel forParameter:@"channel"];
        [self setValue:name forParameter:@"name"];
        [self setFlag:NSStringFromSelector(_cmd)];
        
        return (PNSendFileAPICallBuilder *)self;
    };
}


#pragma mark - List files

- (PNListFilesAPICallBuilder * (^)(NSString *channel))listFiles {
    return ^PNListFilesAPICallBuilder * (NSString * channel) {
        object_setClass(self, [PNListFilesAPICallBuilder class]);
        
        [self setValue:channel forParameter:@"channel"];
        [self setFlag:NSStringFromSelector(_cmd)];
        
        return (PNListFilesAPICallBuilder *)self;
    };
}


#pragma mark - Download file

- (PNFileDownloadURLAPICallBuilder * (^)(NSString *channel, NSString *identifier, NSString *name))fileURL {
    return ^PNFileDownloadURLAPICallBuilder * (NSString *channel, NSString *identifier, NSString *name) {
        object_setClass(self, [PNFileDownloadURLAPICallBuilder class]);
        
        [self setValue:identifier forParameter:@"identifier"];
        [self setValue:channel forParameter:@"channel"];
        [self setValue:name forParameter:@"name"];
        [self setFlag:NSStringFromSelector(_cmd)];
        
        return (PNFileDownloadURLAPICallBuilder *)self;
    };
}

- (PNDownloadFileAPICallBuilder * (^)(NSString *channel, NSString *identifier, NSString *name))downloadFile {
    return ^PNDownloadFileAPICallBuilder * (NSString *channel, NSString *identifier, NSString *name) {
        object_setClass(self, [PNDownloadFileAPICallBuilder class]);
        
        [self setValue:identifier forParameter:@"identifier"];
        [self setValue:channel forParameter:@"channel"];
        [self setValue:name forParameter:@"name"];
        [self setFlag:NSStringFromSelector(_cmd)];
        
        return (PNDownloadFileAPICallBuilder *)self;
    };
}


#pragma mark - Delete file

- (PNDeleteFileAPICallBuilder * (^)(NSString *channel, NSString *identifier, NSString *name))deleteFile {
    return ^PNDeleteFileAPICallBuilder * (NSString *channel, NSString *identifier, NSString *name) {
        object_setClass(self, [PNDeleteFileAPICallBuilder class]);
        
        [self setValue:identifier forParameter:@"identifier"];
        [self setValue:channel forParameter:@"channel"];
        [self setValue:name forParameter:@"name"];
        [self setFlag:NSStringFromSelector(_cmd)];
        
        return (PNDeleteFileAPICallBuilder *)self;
    };
}

#pragma mark -


@end
