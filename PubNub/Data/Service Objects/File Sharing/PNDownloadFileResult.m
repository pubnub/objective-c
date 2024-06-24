#import "PNDownloadFileResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNDownloadFileResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNFileDownloadData class];
}

- (PNFileDownloadData *)data {
    return self.responseData;
}

#pragma mark -


@end
