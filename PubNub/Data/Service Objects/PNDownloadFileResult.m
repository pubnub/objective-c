/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNServiceData+Private.h"
#import "PNOperationResult+Private.h"
#import "PNDownloadFileResult.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNDownloadFileResult ()


#pragma mark - Information

@property (nonatomic, strong) PNDownloadFileData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNDownloadFileData


#pragma mark - Information

- (NSURL *)location {
    return [NSURL URLWithString:self.serviceData[@"location"]];
}

- (BOOL)isTemporary {
    return ((NSNumber *)self.serviceData[@"temporary"]).boolValue;
}

#pragma mark -


@end


@implementation PNDownloadFileResult


#pragma mark - Information

- (PNDownloadFileData *)data {
    if (!_data) {
        _data = [PNDownloadFileData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end
