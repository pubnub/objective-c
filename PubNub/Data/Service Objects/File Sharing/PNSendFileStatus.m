#import "PNSendFileStatus.h"
#import "PNOperationResult+Private.h"
#import "PNStatus+Private.h"


#pragma mark Interfaces implementation

@implementation PNSendFileStatus


#pragma mark - Properties

+ (Class)statusDataClass {
    return [PNFileSendData class];
}

- (PNFileSendData *)data {
    return !self.isError ? self.responseData : nil;
}

#pragma mark -


@end
