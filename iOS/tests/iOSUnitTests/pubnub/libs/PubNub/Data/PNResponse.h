#import <Foundation/Foundation.h>


@interface PNResponse : NSObject


#pragma mark Properties

// Stores binary response from PubNub services
@property (nonatomic, readonly, strong) NSData *content;

// Stores HTTP status code which was returned on sent request
@property (nonatomic, readonly, assign) NSInteger statusCode;

// Stores response size (including HTTP header fields)
@property (nonatomic, readonly, assign) NSUInteger size;

// Stores reference on error object which will hold any information about parsing error
@property (nonatomic, readonly, strong) PNError *error;

// Stores reference on request small identifier hash which will be used to find request which sent this request
@property (nonatomic, readonly, copy) NSString *requestIdentifier;

// Stores reference on callback function name which will be returned in JSONP response
@property (nonatomic, readonly, copy) NSString *callbackMethod;

// Stores whether this is last response from server which will be sent during current connection session
@property (nonatomic, readonly, assign, getter = isLastResponseOnConnection) BOOL lastResponseOnConnection;

// Stores reference on response body object (array in most of cases)
@property (nonatomic, readonly, strong) id response;


#pragma mark - Class methods

/**
 * Retrieve instance which will hold information about
 * HTTP response body and size of whole response
 * (including HTTP headers)
 */
+ (PNResponse *)responseWithContent:(NSData *)content
                               size:(NSUInteger)responseSize
                               code:(NSInteger)statusCode
           lastResponseOnConnection:(BOOL)isLastResponseOnConnection;


#pragma mark - Instance methods

/**
 * Initialize response instance with response
 * body content data, response size and status
 * code (HTTP status code)
 */
- (id)initWithContent:(NSData *)content
                 size:(NSUInteger)responseSize
                 code:(NSInteger)statusCode
        lastResponseOnConnection:(BOOL)isLastResponseOnConnection;

#pragma mark -


@end