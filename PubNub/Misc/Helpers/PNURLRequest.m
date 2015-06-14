/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNURLRequest.h"


#pragma mark Interface implementation

@implementation PNURLRequest

+ (NSInteger)packetSizeForRequest:(NSURLRequest *)request {
    
    NSMutableString *packet = [NSMutableString stringWithFormat:@"%@ %@ HTTP/1.1\r\n",
                               request.HTTPMethod, [request.URL absoluteString]];
    [packet appendFormat:@"Host: %@\r\n", request.URL.host];
    for (NSString *fieldName in request.allHTTPHeaderFields) {
        
        [packet appendFormat:@"%@: %@\r\n", fieldName, request.allHTTPHeaderFields[fieldName]];
    }
    [packet appendString:@"\r\n"];
    NSMutableData *packetData = [[packet dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    if ([request.HTTPBody length]) {
        
        [packetData appendData:request.HTTPBody];
        [packetData appendData:[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return ([packetData length] > 0 ? (NSInteger)[packetData length] : -1);
}

#pragma mark -


@end
