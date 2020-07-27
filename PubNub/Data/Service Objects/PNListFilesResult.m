/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNServiceData+Private.h"
#import "PNListFilesResult.h"
#import "PNResult+Private.h"
#import "PNFile+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNListFilesResult ()


#pragma mark - Information

@property (nonatomic, strong) PNListFilesData *data;

#pragma mark -


@end


@interface PNListFilesData ()


#pragma mark - Information

@property (nonatomic, strong) NSArray<PNFile *> *files;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNListFilesData


#pragma mark - Information

- (NSArray<PNFile *> *)files {
    if (!_files) {
        NSMutableArray *files = [NSMutableArray new];
        
        for (NSDictionary *file in self.serviceData[@"files"]) {
            [files addObject:[PNFile fileFromDictionary:file]];
        }
        
        _files = [files copy];
    }
    
    return _files;
}

- (NSUInteger)count {
    return ((NSNumber *)self.serviceData[@"count"]).unsignedIntegerValue;
}

- (NSString *)next {
    return self.serviceData[@"next"];
}

#pragma mark -


@end


@implementation PNListFilesResult


#pragma mark - Information

- (PNListFilesData *)data {
    if (!_data) {
        _data = [PNListFilesData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end
