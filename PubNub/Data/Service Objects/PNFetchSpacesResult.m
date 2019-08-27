/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNServiceData+Private.h"
#import "PNFetchSpacesResult.h"
#import "PNResult+Private.h"
#import "PNSpace+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNFetchSpaceResult ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNFetchSpaceData *data;

#pragma mark -


@end


@interface PNFetchSpacesResult ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNFetchSpacesData *data;

#pragma mark -


@end



@interface PNFetchSpaceData ()


#pragma mark - Information

@property (nonatomic, nullable, strong) PNSpace *space;

#pragma mark -


@end


@interface PNFetchSpacesData ()


#pragma mark - Information

@property (nonatomic, strong) NSArray<PNSpace *> *spaces;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNFetchSpaceData


#pragma mark - Information

- (PNSpace *)space {
    if (!_space) {
        _space = [PNSpace spaceFromDictionary:self.serviceData[@"space"]];
    }
    
    return _space;
}

#pragma mark -


@end


@implementation PNFetchSpacesData


#pragma mark - Information

- (NSUInteger)totalCount {
    return ((NSNumber *)self.serviceData[@"totalCount"]).unsignedIntegerValue;
}

- (NSArray<PNSpace *> *)spaces {
    if (!_spaces) {
        NSMutableArray *spaces = [NSMutableArray new];
        
        for (NSDictionary *space in self.serviceData[@"spaces"]) {
            [spaces addObject:[PNSpace spaceFromDictionary:space]];
        }
        
        _spaces = [spaces copy];
    }
    
    return _spaces;
}

- (NSString *)next {
    return self.serviceData[@"next"];
}

- (NSString *)prev {
    return self.serviceData[@"prev"];
}

#pragma mark -


@end


@implementation PNFetchSpaceResult


#pragma mark - Information

- (PNFetchSpaceData *)data {
    if (!_data) {
        _data = [PNFetchSpaceData dataWithServiceResponse:self.serviceData];
    }

    return _data;
}

#pragma mark -


@end


@implementation PNFetchSpacesResult


#pragma mark - Information

- (PNFetchSpacesData *)data {
    if (!_data) {
        _data = [PNFetchSpacesData dataWithServiceResponse:self.serviceData];
    }

    return _data;
}

#pragma mark -


@end
