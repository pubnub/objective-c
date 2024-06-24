//
//  PNSendFileData.m
//  PubNub Framework
//
//  Created by Sergey Mamontov on 19.06.2024.
//  Copyright © 2024 PubNub. All rights reserved.
//

#import "PNFileSendData+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `File Upload` request response private extension.
@interface PNFileSendData ()


#pragma mark - Properties

/// Time token when the message with file information has been published.
@property(strong, nullable, nonatomic) NSNumber *timetoken;

/// Whether file uploaded or not.
///
/// > Note: This property should be used during error handling to identify whether send file request should be resend or
/// only file message publish.
@property(assign, nonatomic) BOOL fileUploaded;


#pragma mark - Initialization and Configuration

/// Initialize send file response data.
///
/// - Parameters:
///   - fileId: Unique identifier which has been assigned to file during upload.
///   - fileName: Name under which uploaded data has been stored.
/// - Returns: Initialized send file response data.
- (instancetype)initWithId:(NSString *)fileId name:(NSString *)fileName;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNFileSendData


#pragma mark - Initialization and Configuration

+ (instancetype)fileDataWithId:(NSString *)fileId name:(NSString *)fileName {
    return [[self alloc] initWithId:fileId name:fileName];
}

- (instancetype)initWithId:(NSString *)fileId name:(NSString *)fileName {
    if ((self = [super init])) {
        _fileIdentifier = [fileId copy];
        _fileName = [fileName copy];
    }

    return self;
}

#pragma mark -


@end

