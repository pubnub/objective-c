/**
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNFetchMessageActionsResult.h"
#import "PNMessageAction+Private.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNFetchMessageActionsResult ()


#pragma mark - Information

@property (nonatomic, nonnull, strong) PNFetchMessageActionsData *data;

#pragma mark -


@end


@interface PNFetchMessageActionsData ()


#pragma mark - Information

@property (nonatomic, strong) NSArray<PNMessageAction *> *actions;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNFetchMessageActionsData


#pragma mark - Information

- (NSArray<PNMessageAction *> *)actions {
    if (!_actions) {
        NSMutableArray *actions = [NSMutableArray new];
        
        for (NSDictionary *action in self.serviceData[@"actions"]) {
            [actions addObject:[PNMessageAction actionFromDictionary:action]];
        }
        
        _actions = [actions copy];
    }
    
    return _actions;
}

- (NSNumber *)start {
    return self.serviceData[@"start"];
}

- (NSNumber *)end {
    return self.serviceData[@"end"];
}

#pragma mark -


@end


@implementation PNFetchMessageActionsResult


#pragma mark - Information

- (PNFetchMessageActionsData *)data {
    if (!_data) {
        _data = [PNFetchMessageActionsData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end
