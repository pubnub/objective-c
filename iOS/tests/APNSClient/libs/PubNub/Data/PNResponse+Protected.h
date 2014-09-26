/**
 Extending \b PNResponse class with properties which can be used internally by \b PubNub client.

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.
 */


#import "PNResponse.h"
#import "PNServiceResponseCallbacks.h"


#pragma mark Static

// Stores index of callback method name in array which was created by splitting callback method from JSONP by '_' sign
static NSUInteger const kPNResponseCallbackMethodNameIndex = 0;

// Stores index of request identifier in array which was created by splitting callback method from JSONP by '_' sign
static NSUInteger const kPNResponseRequestIdentifierIndex = 1;

/**
 Stores value for status code which should mean that request processed w/o errors.
 */
static NSUInteger const kPNHTTPStatusCodeOK = 200;


#pragma mark Structures

struct PNServiceResponseServiceDataKeysStruct {

    /**
     Stores name of the service which provided response.
     */
    __unsafe_unretained NSString *name;

    /**
     Status code of request processing.
     */
    __unsafe_unretained NSString *statusCode;

    /**
     Allow to identify whether this response should be treated as error explanation or not.
     */
    __unsafe_unretained NSString *errorState;

    /**
     Allow to identify whether this response should be treated as warning explanation or not.
     */
    __unsafe_unretained NSString *warningState;

    /**
     Service populated messages as for request processing results (description of statusCode field).
     */
    __unsafe_unretained NSString *message;

    /**
     Request populated response data (additional fields maybe added right into root of JSON,
     but will be moved inside corresponding dictionary).
     */
    __unsafe_unretained NSString *response;

    /**
     Stores special marker for PubNub internal usage response. This value will store regular expression which will
     allow to test "key" and in case if it is required, extract name of the service which added additional data.
     */
    __unsafe_unretained NSString *privateData;
};


#pragma mark Private interface declaration

@interface PNResponse ()


#pragma mark - Properties

@property (nonatomic, strong) NSData *content;
@property (nonatomic, strong) id additionalData;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, copy) NSString *serviceName;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign, getter = isErrorResponse) BOOL errorResponse;
@property (nonatomic, strong) PNError *error;
@property (nonatomic, copy) NSString *requestIdentifier;
@property (nonatomic, copy) NSString *callbackMethod;
@property (nonatomic, assign, getter = isLastResponseOnConnection) BOOL lastResponseOnConnection;
@property (nonatomic, strong) id response;
@property (nonatomic, strong) NSMutableDictionary *privateData;
@property (nonatomic, strong) NSMutableDictionary *unknownData;

#pragma mark -


@end
