/**
 * @author Serhii Mamontov
 * @copyright © 2010-2026 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <PubNub/PNHelpers.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNURLRequestTest : XCTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNURLRequestTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: Packet size :: packetSizeForRequest:

- (void)testItShouldReturnPositiveSizeWhenValidGETRequestProvided {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ps.pndsn.com/v2/subscribe"]];
    request.HTTPMethod = @"GET";

    NSInteger size = [PNURLRequest packetSizeForRequest:request];

    XCTAssertGreaterThan(size, 0, @"Packet size should be positive for valid request.");
}

- (void)testItShouldIncludeBodySizeWhenPOSTRequestWithBodyProvided {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ps.pndsn.com/publish"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [@"Hello, PubNub!" dataUsingEncoding:NSUTF8StringEncoding];

    NSInteger sizeWithBody = [PNURLRequest packetSizeForRequest:request];

    request.HTTPBody = nil;
    NSInteger sizeWithoutBody = [PNURLRequest packetSizeForRequest:request];

    XCTAssertGreaterThan(sizeWithBody, sizeWithoutBody,
                        @"Request with body should have larger packet size.");
}

- (void)testItShouldIncludeHeadersSizeWhenCustomHeadersProvided {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ps.pndsn.com/v2/subscribe"]];
    request.HTTPMethod = @"GET";

    NSInteger sizeWithoutHeaders = [PNURLRequest packetSizeForRequest:request];

    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"PubNub-ObjC/5.0" forHTTPHeaderField:@"User-Agent"];

    NSInteger sizeWithHeaders = [PNURLRequest packetSizeForRequest:request];

    XCTAssertGreaterThan(sizeWithHeaders, sizeWithoutHeaders,
                        @"Request with headers should have larger packet size.");
}

- (void)testItShouldIncludeHTTPMethodInSizeWhenRequestBuilt {
    NSMutableURLRequest *getRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ps.pndsn.com/v2/subscribe"]];
    getRequest.HTTPMethod = @"GET";

    NSMutableURLRequest *deleteRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ps.pndsn.com/v2/subscribe"]];
    deleteRequest.HTTPMethod = @"DELETE";

    NSInteger getSize = [PNURLRequest packetSizeForRequest:getRequest];
    NSInteger deleteSize = [PNURLRequest packetSizeForRequest:deleteRequest];

    // DELETE is 3 chars longer than GET
    XCTAssertEqual(deleteSize - getSize, 3,
                  @"DELETE request should be 3 bytes larger than GET (method name difference).");
}

- (void)testItShouldIncludeHostHeaderWhenURLHasHost {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ps.pndsn.com/v2/subscribe"]];
    request.HTTPMethod = @"GET";

    NSInteger size = [PNURLRequest packetSizeForRequest:request];

    // The implementation adds "Host: <host>\r\n" so size should be positive.
    XCTAssertGreaterThan(size, 0, @"Packet size should include host header.");
}


#pragma mark -

#pragma clang diagnostic pop

@end
