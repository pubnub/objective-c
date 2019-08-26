/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNCreateUserRequest.h"
#import "PNRequest+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNCreateUserRequest ()


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c create \c user request.
 *
 * @param identifier Unique identifier for new \c user entry.
 * @param name Name which should be associated with new \c user entry.
 *
 * @return Initialized and ready to use \c create \c user request.
 */
- (instancetype)initWithUserID:(NSString *)identifier name:(NSString *)name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNCreateUserRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNCreateUserOperation;
}

- (NSString *)httpMethod {
    return @"POST";
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithUserID:(NSString *)identifier name:(NSString *)name {
    return [[self alloc] initWithUserID:identifier name:name];
}

- (instancetype)initWithUserID:(NSString *)identifier name:(NSString *)name {
    if ((self = [super initWithObject:@"User" identifier:identifier])) {
        self.includeFields = PNUserCustomField;
        self.name = name;

        if (!name.length) {
            self.parametersError = [self missingParameterError:@"name" forObjectRequest:@"User"];
        }
    }

    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}

#pragma mark -


@end
