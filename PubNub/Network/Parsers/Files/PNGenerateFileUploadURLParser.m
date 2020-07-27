/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNGenerateFileUploadURLParser.h"


#pragma mark Interface implementation

@implementation PNGenerateFileUploadURLParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    return @[@(PNGenerateFileUploadURLOperation)];
}

+ (BOOL)requireAdditionalData {
    return NO;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response {
    NSDictionary<NSString *, id> *processedResponse = nil;
    
    if (((NSNumber *)response[@"status"]).integerValue != 200 ||
        ![response isKindOfClass:[NSDictionary class]]) {
        
        return processedResponse;
    }
    
    NSMutableDictionary *uploadMetadata = [NSMutableDictionary new];
    
    if ([response valueForKeyPath:@"data.id"]) {
        uploadMetadata[@"file"] = @{
            @"identifier": response[@"data"][@"id"],
            @"name": response[@"data"][@"name"]
        };
    }
    
    if ([response valueForKeyPath:@"file_upload_request.url"]) {
        NSDictionary *requestMetadata = response[@"file_upload_request"];
        uploadMetadata[@"request"] = [NSMutableDictionary new];
        
        uploadMetadata[@"request"][@"url"] = requestMetadata[@"url"];
        uploadMetadata[@"request"][@"method"] = requestMetadata[@"method"];
        uploadMetadata[@"request"][@"formFields"] = requestMetadata[@"form_fields"];
    }
    
    if (uploadMetadata.count == 2) {
        processedResponse = [uploadMetadata copy];
    }
    
    return processedResponse;
}

#pragma mark -

@end
