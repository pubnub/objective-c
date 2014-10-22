#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNError;


/**
 Base class used to store \b PubNub service response along with identifiers which will allow to identify API endpoint
 which provided this response.

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PNResponse : NSObject


#pragma mark Properties

/**
 Stores RAW response from \b PubNub services.
 */
@property (nonatomic, readonly, strong) NSData *content;

/**
 Stores HTTP status code which was returned on sent request.
 */
@property (nonatomic, readonly, assign) NSInteger statusCode;

/**
 Stores response size (including HTTP header fields).
 */
@property (nonatomic, readonly, assign) NSUInteger size;

/**
 Stores reference on the name of the service which issued response.
 */
@property (nonatomic, readonly, copy) NSString *serviceName;

/**
 Stores reference on message which describe status code of request execution.
 */
@property (nonatomic, readonly, copy) NSString *message;

/**
 Stores reference on data which allow to provide additional information about source of response.
 */
@property (nonatomic, readonly, strong) id additionalData;

/**
 This property allow to check whether this is response which describe error of request processing or not.
 */
@property (nonatomic, readonly, assign, getter = isErrorResponse) BOOL errorResponse;

/**
 Stores reference on error object which will hold any information about parsing error.
 */
@property (nonatomic, readonly, strong) PNError *error;

/**
 Stores reference on request small identifier hash which will be used to find request which sent this request.
 */
@property (nonatomic, readonly, copy) NSString *requestIdentifier;

/**
 Stores reference on callback function name which will be returned in JSONP response.
 */
@property (nonatomic, readonly, copy) NSString *callbackMethod;

/**
 Stores whether this is last response from server which will be sent during current connection session.
 */
@property (nonatomic, readonly, assign, getter = isLastResponseOnConnection) BOOL lastResponseOnConnection;

/**
 Stores reference on response body object (array in most of cases).
 */
@property (nonatomic, readonly, strong) id response;


#pragma mark - Class methods

/**
 Construct response which will contain message body.
 
 @param errorMessage
 Message which should be placed into \b PNResponse instance.
 
 @return Created instance.
 */
+ (PNResponse *)errorResponseWithMessage:(NSString *)errorMessage;

/**
 Create and configure response instance with raw data which will be translated into correct form.

 @param content
 RAW \b NSData content from server which should be pre-parsed.

 @param responseSize
 Content response size from headers.

 @param statusCode
 Status code pulled out from headers.

 @param isLastResponseOnConnection
 This parameter tell \b PubNub client network sub-system on whether after this response may close connection or not
 (in case if \c keep-alive not supported) and it shouldn't treat it as error.

 @return Ready to use \b PNResponse instance.
 */
+ (PNResponse *)responseWithContent:(NSData *)content size:(NSUInteger)responseSize code:(NSInteger)statusCode
           lastResponseOnConnection:(BOOL)isLastResponseOnConnection;


#pragma mark - Instance methods

/**
 Initialize response instance with raw data which will be translated into correct form.

 @param content
 RAW \b NSData content from server which should be pre-parsed.

 @param responseSize
 Content response size from headers.

 @param statusCode
 Status code pulled out from headers.

 @param isLastResponseOnConnection
 This parameter tell \b PubNub client network sub-system on whether after this response may close connection or not
 (in case if \c keep-alive not supported) and it shouldn't treat it as error.

 @return Initialized \b PNResponse instance.
 */
- (id)    initWithContent:(NSData *)content size:(NSUInteger)responseSize code:(NSInteger)statusCode
 lastResponseOnConnection:(BOOL)isLastResponseOnConnection;

#pragma mark -


@end
