/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNSendFileStatus+Private.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNSendFileData ()


#pragma mark - Information

@property (nonatomic, assign) BOOL fileUploaded;

#pragma mark -


@end

@interface PNSendFileStatus ()


#pragma mark - Information

@property (nonatomic, strong) PNSendFileData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNSendFileData


#pragma mark - Information

- (NSString *)fileIdentifier {
    return self.serviceData[@"id"];
}

- (NSNumber *)timetoken {
    return self.serviceData[@"timetoken"];
}

- (NSString *)fileName {
    return self.serviceData[@"name"];
}

#pragma mark -


@end


@implementation PNSendFileStatus


#pragma mark - Information

- (PNSendFileData *)data {
    if (!_data) {
        _data = [PNSendFileData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end
