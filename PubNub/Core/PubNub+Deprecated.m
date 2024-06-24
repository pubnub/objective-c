#import "PubNub+Deprecated.h"
#import "PNOperationResult+Private.h"
#import "PNConfiguration+Private.h"
#import "PubNub+CorePrivate.h"
#import "PNHelpers.h"


#pragma mark Interface implementation

@implementation PubNub (Deprecated)


#pragma mark - Result and Status

- (void)updateResult:(PNOperationResult *)result
         withRequest:(PNTransportRequest *)transportRequest
            response:(id<PNTransportResponse>)response {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    result.TLSEnabled = self.configuration.isTLSEnabled;
    result.userID = self.configuration.userID;
    result.authKey = self.configuration.authToken ?: self.configuration.authKey;
    result.statusCode = response.statusCode;
    result.origin = transportRequest.origin;

    if (!transportRequest) return;
    
    NSDictionary *query = transportRequest.query;
    NSString *path = transportRequest.path;

    if (query.count > 0) {
        NSMutableArray *keyValuePairs = [NSMutableArray arrayWithCapacity:query.count];
        [query enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, __unused BOOL *stop) {
            value = [value isKindOfClass:[NSString class]] ? [PNString percentEscapedString:value] : value;
            [keyValuePairs addObject:PNStringFormat(@"%@=%@", key, value)];
        }];

        path = PNStringFormat(@"%@?%@", path, [keyValuePairs componentsJoinedByString:@"&"]);
    }

    NSURL *url = [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:transportRequest.origin]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = transportRequest.stringifiedMethod;
    request.timeoutInterval = transportRequest.timeout;

    if (transportRequest.method == TransportPOSTMethod || transportRequest.method == TransportPATCHMethod) {
        if (transportRequest.bodyStreamAvailable) request.HTTPBodyStream = transportRequest.bodyStream;
        else request.HTTPBody = transportRequest.body;
    }

    request.allHTTPHeaderFields = transportRequest.headers;
    result.clientRequest = request;
#pragma clang diagnostic pop
}

#pragma mark -


@end
