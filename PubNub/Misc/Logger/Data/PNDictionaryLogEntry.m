#import "PNDictionaryLogEntry.h"
#import "PNLogEntry+Private.h"


#pragma mark Interface implementation

@implementation PNDictionaryLogEntry


#pragma mark - Initialization and Configuration

+ (instancetype)entryWithMessage:(NSDictionary *)message details:(NSString *)details {
    PNDictionaryLogEntry *entry = [[self alloc] initWithMessageType:PNObjectLogMessageType message:message];
    entry.details = details;
    
    return entry;
}

#pragma mark -


@end
