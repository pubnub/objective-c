/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNGenerateFileUploadURLStatus.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNGenerateFileUploadURLStatus ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNGenerateFileUploadURLData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNGenerateFileUploadURLData


#pragma mark - Information

- (NSArray<NSDictionary *> *)formFields {
    return self.serviceData[@"request"][@"formFields"];
}

- (NSString *)fileIdentifier {
    return self.serviceData[@"file"][@"identifier"];
}

- (NSString *)httpMethod {
    return self.serviceData[@"request"][@"method"];
}

- (NSString *)filename {
    return self.serviceData[@"file"][@"name"];
}

- (NSURL *)requestURL {
    return [NSURL URLWithString:self.serviceData[@"request"][@"url"]];
}

#pragma mark -


@end

@implementation PNGenerateFileUploadURLStatus


#pragma mark - Information

- (PNGenerateFileUploadURLData *)data {
    if (!_data) {
        _data = [PNGenerateFileUploadURLData dataWithServiceResponse:self.serviceData];
    }

    return _data;
}

#pragma mark -


@end
