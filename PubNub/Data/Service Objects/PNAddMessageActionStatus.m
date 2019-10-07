/**
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNAddMessageActionStatus.h"
#import "PNMessageAction+Private.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interfaces declaration

@interface PNAddMessageActionStatus ()


#pragma mark - Information

@property (nonatomic, strong) PNAddMessageActionData *data;

#pragma mark -


@end


@interface PNAddMessageActionData ()


#pragma mark - Information

@property (nonatomic, strong) PNMessageAction *action;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interfaces implementation

@implementation PNAddMessageActionData


#pragma mark - Information

- (PNMessageAction *)action {
    if (!_action) {
        _action = [PNMessageAction actionFromDictionary:self.serviceData[@"action"]];
    }
    
    return _action;
}

#pragma mark -


@end


@implementation PNAddMessageActionStatus


#pragma mark - Information

- (BOOL)isError {
    return super.isError ?: ((NSNumber *)self.serviceData[@"isError"]).boolValue;
}

- (PNAddMessageActionData *)data {
    if (!_data) {
        _data = [PNAddMessageActionData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end
