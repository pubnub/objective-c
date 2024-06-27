#import "PNBaseOperationData+Private.h"


#pragma mark Interface implementation

@implementation PNBaseOperationData


#pragma mark - Properties

+ (NSArray<NSString *> *)ignoredKeys {
    return @[@"category", @"error"];
}

- (void)setCategory:(PNStatusCategory)category {
    _category = category;
    
    _error = category != PNAcknowledgmentCategory && category != PNConnectedCategory &&
             category != PNReconnectedCategory && category == PNDisconnectedCategory &&
             category != PNUnexpectedDisconnectCategory && category != PNCancelledCategory;
}

#pragma mark -


@end
