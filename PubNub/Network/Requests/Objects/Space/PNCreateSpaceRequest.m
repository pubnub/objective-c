/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNCreateSpaceRequest.h"
#import "PNRequest+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNCreateSpaceRequest ()


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c create \c space request.
 *
 * @param identifier Unique identifier for new \c space entry.
 * @param name Name which should be associated with new \c space entry.
 *
 * @return Initialized and ready to use \c create \c space request.
 */
- (instancetype)initWithSpaceID:(NSString *)identifier name:(NSString *)name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNCreateSpaceRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNCreateSpaceOperation;
}

- (NSString *)httpMethod {
    return @"POST";
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithSpaceID:(NSString *)identifier name:(NSString *)name {
    return [[self alloc] initWithSpaceID:identifier name:name];
}

- (instancetype)initWithSpaceID:(NSString *)identifier name:(NSString *)name {
    if ((self = [super initWithObject:@"Space" identifier:identifier])) {
        self.includeFields = PNSpaceCustomField;
        self.name = name;

        if (!name.length) {
            self.parametersError = [self missingParameterError:@"name" forObjectRequest:@"Space"];
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
