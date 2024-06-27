#import "PNPublishRequest.h"
#import "PNBasePublishRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


#pragma mark Interface implementation

@implementation PNPublishRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNPublishOperation;
}

- (BOOL)shouldCompressBody {
    return self.shouldCompress;
}

- (NSString *)path {
    return PNStringFormat(@"/publish/%@/%@/0/%@/0/%@",
                          self.publishKey,
                          self.subscribeKey,
                          [PNString percentEscapedString:self.channel],
                          self.httpMethod == TransportPOSTMethod ? @"" : [PNString percentEscapedString:self.preparedMessage]);
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithChannel:(NSString *)channel {
    return [[self alloc] initWithChannel:channel];
}

#pragma mark -


@end
