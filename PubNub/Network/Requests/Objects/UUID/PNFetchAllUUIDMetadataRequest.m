/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNFetchAllUUIDMetadataRequest.h"


#pragma mark Interface implementation

@implementation PNFetchAllUUIDMetadataRequest


#pragma mark - Information

@dynamic includeFields;


- (PNOperationType)operation {
    return PNFetchAllUUIDMetadataOperation;
}

- (BOOL)isIdentifierRequired {
    return NO;
}

#pragma mark -


@end
