//
//  PNConnection+Protected.h
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

#import "PNConnection.h"
#import "PNBaseRequest+Protected.h"


#pragma mark - Structures

// Structure describes list of available connection identifiers
struct PNConnectionIdentifiersStruct {
    
    // Used to identify connection which is used for: subscriptions and presence observing
    __unsafe_unretained NSString *messagingConnection;
    
    // Used for another set of calls to the PubNub service
    __unsafe_unretained NSString *serviceConnection;
};

extern struct PNConnectionIdentifiersStruct PNConnectionIdentifiers;


@interface PNConnection (Protected)


#pragma mark - Instance methods

/**
 * Open connection from name of the user (if flag is set to 'YES')
 */
- (void)connectByInternalRequest:(void (^)(BOOL connecting))resultBlock;
- (BOOL)isConnecting;
- (BOOL)isReconnecting;
- (BOOL)shouldReconnect;
- (BOOL)canRetryConnection;
- (void)retryConnection;

- (BOOL)isConnected;
- (BOOL)isSuspending;
- (BOOL)isSuspended;
- (BOOL)isResuming;

/**
 * Disconnect from name of the user (if flag is set to 'YES')
 */
- (void)disconnectByInternalRequest;
- (BOOL)isDisconnecting;

/**
 Silently close connection
 */
- (void)closeConnection;

/**
 * This is final point where connection can release all resources which may not allow it to destroy it from outside
 */
- (void)prepareForTermination;

#pragma mark -


@end
