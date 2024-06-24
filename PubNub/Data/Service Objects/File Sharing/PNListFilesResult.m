#import "PNListFilesResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interfaces implementation

@implementation PNListFilesResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNFileListFetchData class];
}

- (PNFileListFetchData *)data {
    return self.responseData;
}

#pragma mark -


@end
