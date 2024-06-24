#import "PNGenerateFileUploadURLStatus.h"
#import "PNOperationResult+Private.h"
#import "PNStatus+Private.h"


#pragma mark Interfaces implementation

@implementation PNGenerateFileUploadURLStatus


#pragma mark - Properties

+ (Class)statusDataClass {
    return [PNFileGenerateUploadURLData class];
}

- (PNFileGenerateUploadURLData *)data {
    return !self.isError ? self.responseData : nil;
}

#pragma mark -


@end
