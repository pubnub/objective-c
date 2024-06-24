#import "PNTransportRequest+Private.h"


#pragma mark Interface implementation

@implementation PNTransportRequest


#pragma mark - Initialization and Configuration

- (instancetype)init {
    if ((self = [super init])) {
        _identifier = [NSUUID UUID].UUIDString;
        _method = TransportGETMethod;
        _retriable = YES;
        _secure = YES;
    }
    return self;
}


#pragma mark - Properties

- (NSString *)stringifiedMethod {
    switch (self.method) {
        case TransportGETMethod:
            return @"GET";
            break;
        case TransportPOSTMethod:
            return @"POST";
            break;
        case TransportPATCHMethod:
            return @"PATCH";
            break;
        case TransportDELETEMethod:
            return @"DELET";
            break;
        case TransportLOCALMethod:
            return @"LOCAL";
            break;
        default:
            return nil;
            break;
    }
}

#pragma mark -


@end
