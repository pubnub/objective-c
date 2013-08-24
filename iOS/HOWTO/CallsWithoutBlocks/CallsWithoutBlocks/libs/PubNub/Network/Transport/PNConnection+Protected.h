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


#pragma mark - Class methods

+ (void)resetConnectionsPool;


#pragma mark - Instance methods

/**
 * Open connection from name of the user (if flag is set to 'YES')
 */
- (BOOL)connectByUserRequest:(BOOL)byUserRequest;
- (BOOL)isConnecting;
- (BOOL)isReconnecting;
- (BOOL)shouldReconnect;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (BOOL)isSuspending;
- (BOOL)isResuming;
#endif

/**
 * Disconnect from name of the user (if flag is set to 'YES')
 */
- (void)disconnectByUserRequest:(BOOL)byUserRequest;
- (BOOL)isDisconnecting;

/**
 * This is final point where connection can release all resources which may not allow it to destroy it from outside
 */
- (void)prepareForTermination;

#pragma mark -


@end