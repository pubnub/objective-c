<<<<<<< HEAD
/**

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNResponse+Protected.h"
=======
//
//  PNResponse.m
//  pubnub
//
//  This class instance designed to store
//  binary response from backend with some
//  additional information which will help
//  to understand some metrics.
//
//
//  Created by Sergey Mamontov on 12/20/12.
//
//

#import "PNResponse.h"
>>>>>>> fix-pt65153600
#import "PNJSONSerialization.h"
#import "PNRequestsImport.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub response must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


<<<<<<< HEAD
#pragma mark Structures

struct PNServiceResponseServiceDataKeysStruct PNServiceResponseServiceDataKeys = {

    .name = @"service",
    .statusCode = @"status",
    .errorState = @"error",
    .message = @"message",
    .response = @"payload",
    .privateData = @"^_(.*?)_(?=[^\\s])"
};

struct PNServiceResponseCallbacksStruct PNServiceResponseCallbacks = {

    .latencyMeasureMessageCallback = @"lm",
    .stateRetrieveCallback = @"mr",
    .stateUpdateCallback = @"mu",
=======
#pragma mark Static

// Stores index of callback method name in array which was created by splitting callback method from JSONP by '_' sign
static NSUInteger const kPNResponseCallbackMethodNameIndex = 0;

// Stores index of request identifier in array which was created by splitting callback method from JSONP by '_' sign
static NSUInteger const kPNResponseRequestIdentifierIndex = 1;


#pragma mark Structures

struct PNServiceResponseCallbacksStruct PNServiceResponseCallbacks = {
    
    .latencyMeasureMessageCallback = @"lm",
>>>>>>> fix-pt65153600
    .subscriptionCallback = @"s",
    .leaveChannelCallback = @"lv",
    .channelPushNotificationsEnableCallback = @"cpe",
    .channelPushNotificationsDisableCallback = @"cpd",
    .pushNotificationEnabledChannelsCallback = @"pec",
    .pushNotificationRemoveCallback = @"pnr",
    .sendMessageCallback = @"m",
    .timeTokenCallback = @"t",
    .messageHistoryCallback = @"h",
    .channelParticipantsCallback = @"p",
<<<<<<< HEAD
    .participantChannelsCallback = @"pc",
=======
>>>>>>> fix-pt65153600
    .channelAccessRightsChangeCallback = @"arc",
    .channelAccessRightsAuditCallback = @"arr"
};


#pragma mark - Private interface methods

<<<<<<< HEAD
@interface PNResponse (Private)
=======
@interface PNResponse ()


#pragma mark - Properties

@property (nonatomic, strong) NSData *content;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, strong) PNError *error;
@property (nonatomic, copy) NSString *requestIdentifier;
@property (nonatomic, copy) NSString *callbackMethod;
@property (nonatomic, assign, getter = isLastResponseOnConnection) BOOL lastResponseOnConnection;
@property (nonatomic, strong) id response;
>>>>>>> fix-pt65153600


#pragma mark - Instance methods

#pragma mark - Handler methods

/**
<<<<<<< HEAD
 Handle JSON encoding error and try perform additional tasks to silently fallback this error.

 @param errorCode
 JSON Parsing error.
=======
 * Handle JSON encoding error and try perform additional tasks to silently fallback this error
>>>>>>> fix-pt65153600
 */
- (void)handleJSONDecodeErrorWithCode:(NSUInteger)errorCode;


#pragma mark - Misc methods

/**
<<<<<<< HEAD
 If user is using cypher key to send request than it will be used to decode server response.

 @return Current implementation just provide cleaned data.
=======
 * If user is using cypher key to send request than it will be used to decode server response
>>>>>>> fix-pt65153600
 */
- (NSString *)decodedResponse;

/**
<<<<<<< HEAD
 Extract service parameters from response (server send additional data which help to identify service which privded
 response and state of request processing.
 */
- (void)extractServiceData;

/**
 In case of JSON parsing error, this method will allow to pull out information about request and callback function
 from partial response.

 @param callback
 Reference on \b NSString variable inside of which \a callback name will be stored.

 @param identifier
 Reference on \b NSString variable inside of which request identifier will be stored.

 @param responseData
 RAW data from which response should be extracted (basically JSON(P) will be parsed).
 */
- (void)getCallbackFunction:(NSString **)callback requestIdentifier:(NSString **)identifier fromData:(NSData *)responseData;

#pragma mark -
=======
 * In case of JSON parsing error, this method will allow to pull out information about request and callback
 * function from partial response
 */
- (void)getCallbackFunction:(NSString **)callback
          requestIdentifier:(NSString **)identifier
                   fromData:(NSData *)responseData;
>>>>>>> fix-pt65153600


@end


#pragma mark - Public interface methods

@implementation PNResponse


#pragma mark Class methods

<<<<<<< HEAD
+ (PNResponse *)responseWithContent:(NSData *)content size:(NSUInteger)responseSize code:(NSInteger)statusCode
           lastResponseOnConnection:(BOOL)isLastResponseOnConnection {
    
    return [[[self class] alloc] initWithContent:content size:responseSize code:statusCode
=======
/**
 * Retrieve instance which will hold information about HTTP response body and size of whole response
 * (including HTTP headers)
 */
+ (PNResponse *)responseWithContent:(NSData *)content
                               size:(NSUInteger)responseSize
                               code:(NSInteger)statusCode
           lastResponseOnConnection:(BOOL)isLastResponseOnConnection {
    
    return [[[self class] alloc] initWithContent:content
                                            size:responseSize
                                            code:statusCode
>>>>>>> fix-pt65153600
                        lastResponseOnConnection:isLastResponseOnConnection];
}


#pragma mark - Instance methods

<<<<<<< HEAD
- (id)    initWithContent:(NSData *)content size:(NSUInteger)responseSize code:(NSInteger)statusCode
 lastResponseOnConnection:(BOOL)isLastResponseOnConnection {
=======
/**
 * Initialize response instance with response body content data, response size and status code (HTTP status code)
 */
- (id)initWithContent:(NSData *)content
                 size:(NSUInteger)responseSize
                 code:(NSInteger)statusCode
        lastResponseOnConnection:(BOOL)isLastResponseOnConnection {
>>>>>>> fix-pt65153600
    
    // Check whether initialization was successful or not
    if((self = [super init])) {

        self.content = content;
        self.size = responseSize;
        self.statusCode = statusCode;
<<<<<<< HEAD
        self.privateData = [NSMutableDictionary dictionary];
=======
>>>>>>> fix-pt65153600
        self.lastResponseOnConnection = isLastResponseOnConnection;

        
        NSString *decodedResponse = [self decodedResponse];
        if (decodedResponse) {
            
            __pn_desired_weak __typeof__(self) weakSelf = self;
            [PNJSONSerialization JSONObjectWithString:decodedResponse
                                      completionBlock:^(id result, BOOL isJSONP, NSString *callbackMethodName){

                                          if (isJSONP) {

                                              NSArray *callbackMethodElements = [callbackMethodName componentsSeparatedByString:@"_"];

                                              if ([callbackMethodElements count] > 1) {

                                                  weakSelf.callbackMethod = [callbackMethodElements objectAtIndex:kPNResponseCallbackMethodNameIndex];
                                                  weakSelf.requestIdentifier = [callbackMethodElements objectAtIndex:kPNResponseRequestIdentifierIndex];
                                              }
                                              else {

                                                  weakSelf.callbackMethod = callbackMethodName;
                                              }

                                              weakSelf.response = result;
                                          }
                                          else {

                                              self.response = result;
                                          }
<<<<<<< HEAD

                                          [weakSelf extractServiceData];
=======
>>>>>>> fix-pt65153600
                                      }
                                           errorBlock:^(NSError *error) {

                                               PNLog(PNLogGeneralLevel, weakSelf, @"JSON DECODE ERROR: %@", error);
                                               [weakSelf handleJSONDecodeErrorWithCode:kPNResponseMalformedJSONError];
                                           }];
        }
<<<<<<< HEAD
        // Looks like message can't be decoded event from RAW response looks like malformed data arrived with
        // characters which can't be encoded.
=======
        // Looks like message can't be decoded event from RAW response
        // looks like malformed data arrived with characters which can't
        // be encoded
>>>>>>> fix-pt65153600
        else {

            PNLog(PNLogGeneralLevel, self, @"FAILED TO DECODE DATA");
            [self handleJSONDecodeErrorWithCode:kPNResponseEncodingError];
        }
    }
    
    
    return self;
}

#pragma mark - Handler methods

- (void)handleJSONDecodeErrorWithCode:(NSUInteger)errorCode {

    // Mark that request is failed to be processed correctly
    self.size = 0;

    self.error = [PNError errorWithCode:errorCode];

    NSString *callbackMethod;
    NSString *requestIdentifier;
    [self getCallbackFunction:&callbackMethod requestIdentifier:&requestIdentifier fromData:self.content];
    self.callbackMethod = callbackMethod;
    self.requestIdentifier = requestIdentifier;
}


#pragma mark - Misc methods

- (NSString *)decodedResponse {

    NSString *encodedString = [[NSString alloc] initWithData:self.content encoding:NSUTF8StringEncoding];
    return [encodedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

<<<<<<< HEAD
- (void)extractServiceData {

    // Checking on whether we got dictionary or not
    if ([self.response respondsToSelector:@selector(allKeys)]) {

        NSMutableDictionary *processedData = [self.response mutableCopy];

        // Check whether response contains information about service which provided response or not.
        if ([processedData objectForKey:PNServiceResponseServiceDataKeys.name]) {

            self.serviceName = [processedData valueForKey:PNServiceResponseServiceDataKeys.name];
            [processedData removeObjectForKey:PNServiceResponseServiceDataKeys.name];
        }

        // Check whether response contains service specific request processing status code or not
        if ([processedData objectForKey:PNServiceResponseServiceDataKeys.statusCode]) {

            self.statusCode = [[processedData objectForKey:PNServiceResponseServiceDataKeys.statusCode] integerValue];
            [processedData removeObjectForKey:PNServiceResponseServiceDataKeys.statusCode];
        }

        // Check whether response contains information about whether this is error clarification or not.
        if ([processedData objectForKey:PNServiceResponseServiceDataKeys.errorState]) {

            self.errorResponse = [[processedData objectForKey:PNServiceResponseServiceDataKeys.errorState] boolValue];
            [processedData removeObjectForKey:PNServiceResponseServiceDataKeys.errorState];
        }

        // Check whether response contains service populated message or not.
        if ([processedData objectForKey:PNServiceResponseServiceDataKeys.message]) {

            self.message = [processedData objectForKey:PNServiceResponseServiceDataKeys.message];
            [processedData removeObjectForKey:PNServiceResponseServiceDataKeys.message];
        }

        // Check whether server messed up and there is actual error or not.
        if (!self.isErrorResponse && self.statusCode != kPNHTTPStatusCodeOK && !self.error && self.message) {

            self.error = [PNError errorWithResponseErrorMessage:self.message];
            self.errorResponse = YES;
        }

        // Check whether response contains key under which service response is stored or not.
        BOOL isPayloadFound = [processedData objectForKey:PNServiceResponseServiceDataKeys.response] != nil;
        if (isPayloadFound) {

            self.response = [processedData objectForKey:PNServiceResponseServiceDataKeys.response];
            [processedData removeObjectForKey:PNServiceResponseServiceDataKeys.response];
        }

        NSArray *unprocessedDataKeys = [processedData allKeys];
        [unprocessedDataKeys enumerateObjectsUsingBlock:^(NSString *dataKey, NSUInteger dataKeyIdx,
                                                             BOOL *dataKeyEnumeratorStop) {

            // Checking on whether key conforms to PubNub service "private" data template or not.
            if ([dataKey rangeOfString:PNServiceResponseServiceDataKeys.privateData
                               options:NSRegularExpressionSearch].location != NSNotFound) {

                [self.privateData setValue:[processedData valueForKey:dataKey] forKey:dataKey];
                [processedData removeObjectForKey:dataKey];
            }
        }];

        unprocessedDataKeys = [processedData allKeys];
        if ([unprocessedDataKeys count]) {

            if (isPayloadFound) {

                NSMutableDictionary *responseForModification = [self.response mutableCopy];
                [unprocessedDataKeys enumerateObjectsUsingBlock:^(NSString *dataKey, NSUInteger dataKeyIdx,
                                                                  BOOL *dataKeyEnumeratorStop) {

                    [responseForModification setValue:[processedData valueForKey:dataKey] forKey:dataKey];
                    [processedData removeObjectForKey:dataKey];
                }];
                self.response = [NSDictionary dictionaryWithDictionary:responseForModification];
            }
            else {

                self.response = [NSDictionary dictionaryWithDictionary:processedData];
            }
        }
    }
}

- (void)getCallbackFunction:(NSString **)callback requestIdentifier:(NSString **)identifier fromData:(NSData *)responseData {
=======
- (void)getCallbackFunction:(NSString **)callback
          requestIdentifier:(NSString **)identifier
                   fromData:(NSData *)responseData {
>>>>>>> fix-pt65153600


    // Trying to extract callback method and request identifier
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    if (responseString) {

        NSRange openingBracketRange = [responseString rangeOfString:@"("];
        if (openingBracketRange.location != NSNotFound) {

            NSString *callbackMethod = [responseString substringToIndex:openingBracketRange.location];
            NSArray *callbackMethodElements = [callbackMethod componentsSeparatedByString:@"_"];

            if ([callbackMethodElements count] > 1) {

                if (callback != NULL) {

                    *callback = [callbackMethodElements objectAtIndex:kPNResponseCallbackMethodNameIndex];
                }

                if (identifier != NULL) {

                    *identifier = [callbackMethodElements objectAtIndex:kPNResponseRequestIdentifierIndex];
                }
            }
            else {

                if (callback != NULL) {

                    *callback = callbackMethod;
                }
            }
        }
    }
    else {

        if (callback != NULL) {

            // Assign 'subscription' callback method
            *callback = PNServiceResponseCallbacks.subscriptionCallback;
        }
    }
}

- (NSString *)description {
    
<<<<<<< HEAD
    return [NSString stringWithFormat:@"\nHTTP STATUS CODE: %ld\nSTATUS MESSAGE: %@\nIS ERROR RESPONSE? %@"
                                       "\nCONNECTION WILL BE CLOSE? %@\nRESPONSE SIZE: %ld\nRESPONSE CONTENT SIZE: %ld"
                                       "\nIS JSONP: %@\nCALLBACK METHOD: %@\nSERVICE NAME: %@\nREQUEST IDENTIFIER: %@"
                                       "\nRESPONSE: %@\nADDITIONAL DATA: %@\n",
                                      (long)self.statusCode, self.message, self.isErrorResponse ? @"YES" : @"NO",
                                      self.isLastResponseOnConnection ? @"YES" : @"NO", (unsigned long)[self.content length],
                                      (unsigned long)self.size, self.callbackMethod ? @"YES" : @"NO", self.callbackMethod,
                                      self.serviceName, self.requestIdentifier, self.response, self.additionalData];
=======
    return [NSString stringWithFormat:@"\nHTTP STATUS CODE: %ld\nCONNECTION WILL BE CLOSE? %@\nRESPONSE SIZE: %ld\nRESPONSE CONTENT SIZE: %ld\nIS JSONP: %@\nCALLBACK METHOD: %@\nREQUEST IDENTIFIER: %@\nRESPONSE: %@\n",
                                      (long)self.statusCode,
                                      self.isLastResponseOnConnection ? @"YES" : @"NO",
                                      (unsigned long)[self.content length],
                                      (unsigned long)self.size,
                                      self.callbackMethod ? @"YES" : @"NO",
                                      self.callbackMethod,
                                      self.requestIdentifier,
                                      self.response];
>>>>>>> fix-pt65153600
}

#pragma mark -


@end
