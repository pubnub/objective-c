/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNFetchUsersRequest.h"


#pragma mark Interface implementation

@implementation PNFetchUsersRequest


#pragma mark - Information

@dynamic includeFields;


- (PNOperationType)operation {
    return PNFetchUsersOperation;
}

#pragma mark -


@end
