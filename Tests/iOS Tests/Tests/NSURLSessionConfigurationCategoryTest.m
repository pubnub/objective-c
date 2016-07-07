#import <XCTest/XCTest.h>
#import "NSURLSessionConfiguration+PNConfigurationPrivate.h"


#pragma mark NSURLProtocol

@interface SessionConfigurationCategoryTestProtocol : NSURLProtocol

@end

@implementation SessionConfigurationCategoryTestProtocol

@end


/**
 @brief      NSURLSessionConfiguration testing.
 @discussion Verify NSURLSessionConfiguration category apply passed parameters to default \b PubNub session
             configuration.

 @author Sergey Mamontov
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface NSURLSessionConfigurationCategoryTest : XCTestCase


#pragma mark - Properties

/**
 @brief  Stores reference on shared session configuration which is used to configure \c NSURLSession which
         is used to call \b PubNub REST API.
 */
@property (nonatomic, weak) NSURLSessionConfiguration *configuration;

/**
 @brief  Storing reference on original set of protocol classes which may be used by mocking libraries.
 */
@property (nonatomic, strong) NSArray<Class> *originalProtocolClasses;


#pragma mark - Misc

/**
 @brief  Allow to construct set of headers which should be used for network requests.
 
 @return Dictionary with headers which should be added to each request.
 */
+ (NSDictionary *)pn_testHeaders;

#pragma mark -


@end



#pragma mark - Test case implementation 

@implementation NSURLSessionConfigurationCategoryTest


- (void)setUp {
    
    // Forward method call to the super class.
    [super setUp];
    
    self.configuration = [NSURLSessionConfiguration pn_ephemeralSessionConfiguration];
    self.originalProtocolClasses = [self.configuration.protocolClasses copy];
    
    // Reset shared session configuration instance.
    [NSURLSessionConfiguration pn_setHTTPAdditionalHeaders:nil];
    [NSURLSessionConfiguration pn_setNetworkServiceType:NSURLNetworkServiceTypeDefault];
    [NSURLSessionConfiguration pn_setAllowsCellularAccess:YES];
    [NSURLSessionConfiguration pn_setProtocolClasses:nil];
    [NSURLSessionConfiguration pn_setConnectionProxyDictionary:nil];
}

- (void)tearDown {
    
    // Forward method call to the super class.
    [super tearDown];
    
    // Restoring original set of protocol classes.
    self.configuration.protocolClasses = self.originalProtocolClasses;
}

- (void)testDefaultSessionConfiguration {
    
    XCTAssertEqual(self.configuration.requestCachePolicy, NSURLRequestReloadIgnoringLocalCacheData, 
                  @"Unexpected requests cache policy.");
    XCTAssertNil(self.configuration.URLCache, @"NSURLCache should be 'nil' for default NSURLSession "
                 "configuration.");
    XCTAssertEqualObjects([NSURLSessionConfiguration pn_HTTPAdditionalHeaders], nil, 
                          @"Custome HTTP headers should be 'nil'.");
    XCTAssertEqualObjects(self.configuration.HTTPAdditionalHeaders, [[self class] pn_testHeaders], 
                          @"Unexpected default set of additional HTTP headers.");
}

- (void)testSetAdditionalHeaders {
    
    // Set custom HTTP header.
    NSDictionary *customHeaders = @{@"X-Powered-By": @"PubNub"};
    [NSURLSessionConfiguration pn_setHTTPAdditionalHeaders:customHeaders];
    
    // Construct expected set of headers.
    NSMutableDictionary *expectedHeaders = [customHeaders mutableCopy];
    [expectedHeaders addEntriesFromDictionary:[[self class] pn_testHeaders]];
    
    XCTAssertEqualObjects([NSURLSessionConfiguration pn_HTTPAdditionalHeaders], customHeaders, 
                          @"Unexpected additional HTTP headers.");
    XCTAssertEqualObjects(self.configuration.HTTPAdditionalHeaders, expectedHeaders, 
                          @"Unexpected additional HTTP headers.");
}

- (void)testSetAdditionalHeadersWithCustomUserAgent {
    
    // Set custom HTTP header.
    NSDictionary *customHeaders = @{@"X-Powered-By": @"PubNub", @"User-Agent": @"PubNub-Test"};
    [NSURLSessionConfiguration pn_setHTTPAdditionalHeaders:customHeaders];
    
    // Construct expected set of headers.
    // Custom 'User-Agent' should be ignored.
    NSMutableDictionary *expectedHeaders = [customHeaders mutableCopy];
    [expectedHeaders addEntriesFromDictionary:[[self class] pn_testHeaders]];
    
    XCTAssertEqualObjects([NSURLSessionConfiguration pn_HTTPAdditionalHeaders], 
                          [customHeaders dictionaryWithValuesForKeys:@[@"X-Powered-By"]], 
                          @"Unexpected additional HTTP headers.");
    XCTAssertEqualObjects(self.configuration.HTTPAdditionalHeaders, expectedHeaders, 
                          @"Unexpected additional HTTP headers.");
}

- (void)testResetAdditionalHeadersToNil {
    
    // Set custom HTTP header.
    NSMutableDictionary *customHeaders = [@{@"X-Powered-By": @"PubNub", 
                                            @"User-Agent": @"PubNub-Test"} mutableCopy];
    [NSURLSessionConfiguration pn_setHTTPAdditionalHeaders:customHeaders];
    [NSURLSessionConfiguration pn_setHTTPAdditionalHeaders:nil];
    
    // Construct expected set of headers.
    NSDictionary *expectedHeaders = [[self class] pn_testHeaders];
    
    XCTAssertEqualObjects([NSURLSessionConfiguration pn_HTTPAdditionalHeaders], nil, 
                          @"Custome HTTP headers should be 'nil'.");
    XCTAssertEqualObjects(self.configuration.HTTPAdditionalHeaders, expectedHeaders, 
                          @"Expected only default HTTP header fields.");
}

- (void)testSetNetworkServiceType {
    
    [NSURLSessionConfiguration pn_setNetworkServiceType:NSURLNetworkServiceTypeBackground];
    
    XCTAssertEqual([NSURLSessionConfiguration pn_networkServiceType], NSURLNetworkServiceTypeBackground, 
                   @"Unexpected network service type is set.");
    XCTAssertEqual(self.configuration.networkServiceType, NSURLNetworkServiceTypeBackground, 
                   @"Unexpected network service type is set.");
}

- (void)testSetAllowsCellularAccess {
    
    [NSURLSessionConfiguration pn_setAllowsCellularAccess:NO];
    
    XCTAssertEqual([NSURLSessionConfiguration pn_allowsCellularAccess], NO, 
                   @"Expected cellular access to be disabled.");
    XCTAssertEqual(self.configuration.allowsCellularAccess, NO, @"Expected cellular access to be disabled.");
}

- (void)testSetProtocolClasses {
    
    NSUInteger systemProvidedProtocolsCount = self.configuration.protocolClasses.count;
    Class testProtocolClass = [SessionConfigurationCategoryTestProtocol class];
    [NSURLSessionConfiguration pn_setProtocolClasses:@[testProtocolClass]];
    
    XCTAssertEqual([NSURLSessionConfiguration pn_protocolClasses].count, 1, 
                   @"Unexpected number of custom request handlign protocol classes.");
    XCTAssertEqual(self.configuration.protocolClasses.count, (systemProvidedProtocolsCount + 1), 
                   @"Unexpected number of custom request handlign protocol classes.");
    XCTAssertEqualObjects([NSURLSessionConfiguration pn_protocolClasses].firstObject, testProtocolClass, 
                          @"Expected test protocol class.");
    XCTAssertEqualObjects(self.configuration.protocolClasses.lastObject, testProtocolClass, 
                          @"Expected test protocol class.");
}


- (void)testSetConnectionProxy {
    
    // Prepare and apply connection proxy dictionary.
    NSDictionary *proxyDictionary = @{(NSString *)kCFStreamPropertySOCKSProxyHost : @"pubsub.pubnub.com",
                                      (NSString *)kCFStreamPropertySOCKSProxyPort : @(80) };
    [NSURLSessionConfiguration pn_setConnectionProxyDictionary:proxyDictionary];
    
    XCTAssertEqualObjects([NSURLSessionConfiguration pn_connectionProxyDictionary],  proxyDictionary, 
                          @"Unexpected connection proxy dictionary content.");
    XCTAssertEqualObjects(self.configuration.connectionProxyDictionary, proxyDictionary, 
                          @"Unexpected connection proxy dictionary content.");
}


#pragma mark - Misc

+ (NSDictionary *)pn_testHeaders {
    
    NSString *device = @"iPhone";
#if TARGET_OS_WATCH
    NSString *osVersion = [[WKInterfaceDevice currentDevice] systemVersion];
#elif __IPHONE_OS_VERSION_MIN_REQUIRED
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo]operatingSystemVersion];
    NSMutableString *osVersion = [NSMutableString stringWithFormat:@"%@.%@",
                                  @(version.majorVersion), @(version.minorVersion)];
    if (version.patchVersion > 0) {
        
        [osVersion appendFormat:@".%@", @(version.patchVersion)];
    }
#endif
    NSString *userAgent = [NSString stringWithFormat:@"iPhone; CPU %@ OS %@ Version",
                           device, osVersion];
    
    return @{@"Accept":@"*/*", @"Accept-Encoding":@"gzip,deflate", @"User-Agent":userAgent,
             @"Connection":@"keep-alive"};
}

#pragma mark -


@end
