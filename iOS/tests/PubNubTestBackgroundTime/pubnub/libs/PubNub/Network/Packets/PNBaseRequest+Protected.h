//
//  PNBaseRequest+Protected.h
//  pubnub
//
//  This header file used by library internal
//  components which require to access to some
//  methods and properties which shouldn't be
//  visible to other application components
//
//  Created by Sergey Mamontov.
//
//
#import "PNBaseRequest.h"


#pragma mark Class forward

@class PNConfiguration;


#pragma mark - Structures

/**
 This enumerator lists available HTTP methods which can be used for request sending
 */
typedef NS_OPTIONS(NSInteger , PNRequestHTTPMethod) {
    
    /**
     Request will be sent as plain GET request and all data will be sent via request URL
     */
    PNRequestGETMethod,
    
    /**
     Request will be sent as POST request which may split parameters which should be send between POST body and URL string
     */
    PNRequestPOSTMethod
};


@interface PNBaseRequest (Protected)


#pragma mark - Properties

// Stores reference on client identifier on the moment of request creation
@property (nonatomic, copy) NSString *clientIdentifier;

// Stores reference on whether connection should be closed before sending this message or not
@property (nonatomic, assign, getter = shouldCloseConnection) BOOL closeConnection;


#pragma mark - Instance methods

/**
 Finalize configuration using specified information.
 
 @param configuration
 Reference on configuration instance which currently used by \b PubNub client.
 
 @param clientIdentifier
 Reference on client identifier which should be used along with request and identify concrete \b PubNub client user.
 */
- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier;

/**
 Reset request state so it can be reused and scheduled again on connection channel.
 */
- (void)reset;

/**
 Reset request state (including or not retry count information) so it can be reused and scheduled again on connection channel.
 
 @param shouldResetRetryCountInformation
 Flag which specify on whether retry count information should be reset as well if set to \c YES.
 */
- (void)resetWithRetryCount:(BOOL)shouldResetRetryCountInformation;

/**
 Retrieve reference on debug resource path with obfuscated private information.

 @return formatted resource path for debug output.
 */
- (NSString *)debugResourcePath;


#pragma mark - Processing retry

/**
 * Retrieve how many times request can be rescheduled for processing
 */
- (NSUInteger)allowedRetryCount;

- (void)resetRetryCount;
- (void)increaseRetryCount;

/**
 * Check whether request can retry processing one more time or not
 */
- (BOOL)canRetry;

/**
 * Return reference on authorization request field (if was specified)
 */
- (NSString *)authorizationField;

/**
 Composed client SDK information.
 
 @return String which should be used along with requests.
 */
- (NSString *)clientInformationField;

/**
 * Retrieve reference on full resource path
 */
- (NSString *)requestPath;

/**
 Each subclass may have it's own rule for request sending method.
 
 @note By default if subclass won't owerride this method it will return \c PNRequestGETMethod.
 
 @return one of \b PNRequestHTTPMethod enumerator fields which is set by any particular request.
 */
- (PNRequestHTTPMethod)HTTPMethod;

/**
 In case if \c -HTTPMethod will return \c PNRequestPOSTMethod this value will be checked on whether POST body should be compressed or not.
 
 @return \c YES if HTTP POST body should be GZIPed before appending to HTTP packet.
 */
- (BOOL)shouldCompressPOSTBody;

/**
 Retrieve reference on POST body which should be appended to HTTP payload before sending to the \b PubNub service.
 
 @return serialized into \b NSData instance POST body.
 */
- (NSData *)POSTBody;

/**
 Require from request fully prepared HTTP payload which will be sent to the PubNub service.
 
 @return \b NSData instance with serialized HTTP payload.
 */
- (NSData *)HTTPPayload;

#pragma mark -


@end
