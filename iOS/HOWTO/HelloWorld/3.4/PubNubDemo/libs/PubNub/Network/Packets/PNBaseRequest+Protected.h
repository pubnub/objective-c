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


@interface PNBaseRequest (Protected)


#pragma mark Properties

// Stores reference on whether connection should
// be closed before sending this message or not
@property (nonatomic, assign, getter = shouldCloseConnection) BOOL closeConnection;


#pragma mark - Instance methods

/**
 * Perform request state reset so it can be reused
 * and scheduled again on connection channel
 */
- (void)reset;


#pragma mark - Processing retry

/**
 * Retrieve how many times request can be
 * rescheduled for processing
 */
- (NSUInteger)allowedRetryCount;

- (void)resetRetryCount;
- (void)increaseRetryCount;

/**
 * Check whether request can retry processing
 * one more time or not
 */
- (BOOL)canRetry;

/**
 * Return reference on authorization request field
 * (if was specified)
 */
- (NSString *)authorizationField;

/**
 * Require from request fully prepared HTTP
 * payload which will be sent to the PubNub
 * service
 */
- (NSString *)HTTPPayload;

#pragma mark -


@end
