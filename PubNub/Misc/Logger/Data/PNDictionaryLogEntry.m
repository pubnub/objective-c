#import "PNDictionaryLogEntry+Private.h"
#import "PNLogEntry+Private.h"


#pragma mark Interface implementation

@implementation PNDictionaryLogEntry


#pragma mark - Initialization and Configuration

+ (instancetype)entryWithMessage:(NSDictionary *)message details:(NSString *)details {
    return [self entryWithMessage:message details:details operation:PNUnknownLogMessageOperation];
}

+ (instancetype)entryWithMessage:(NSDictionary *)message
                         details:(NSString *)details
                       operation:(PNLogMessageOperation)operation {
    PNDictionaryLogEntry *entry = [[self alloc] initWithMessageType:PNObjectLogMessageType message:message];
    entry.operation = operation;
    entry.details = details;
    
    return entry;
}

#pragma mark -


@end
