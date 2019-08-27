/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNFetchSpacesRequest.h"


#pragma mark Interface implementation

@implementation PNFetchSpacesRequest


#pragma mark - Information

@dynamic includeFields;


- (PNOperationType)operation {
    return PNFetchSpacesOperation;
}

#pragma mark -


@end
