#import "PNMessageCountResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNMessageCountResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNHistoryMessageCountData class];
}

- (PNHistoryMessageCountData *)data {
    return self.responseData;
}

#pragma mark -


@end
