#import "PNTimeResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNTimeResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNTimeData class];
}

- (PNTimeData *)data {
    return self.responseData;
}

#pragma mark -


@end
