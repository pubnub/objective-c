/**
 Extending \b PubNub class with properties and methods which can be used internally by \b PubNub client.

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.
 */

#import "PNPrivateImports.h"
#import "PNConfiguration.h"
#import "PNReachability.h"
#import "PNDelegate.h"
#import "PubNub.h"


@class PNCache;


#pragma mark Static

typedef enum _PNPubNubClientState {

    // Client instance was reset
    PNPubNubClientStateReset,
    
    // Client instance was just created
    PNPubNubClientStateCreated,
    
    // Client is trying to establish connection to remote PubNub services
    PNPubNubClientStateConnecting,
    
    // Client successfully connected to remote PubNub services
    PNPubNubClientStateConnected,
    
    // Client is disconnecting from remote services
    PNPubNubClientStateDisconnecting,
    
    // Client closing connection because configuration has been changed while client was connected
    PNPubNubClientStateDisconnectingOnConfigurationChange,
    
    // Client is disconnecting from remote services because of network failure
    PNPubNubClientStateDisconnectingOnNetworkError,
    
    // Client disconnected from remote PubNub services (by user request)
    PNPubNubClientStateDisconnected,

    PNPubNubClientStateSuspended,
    
    // Client disconnected from remote PubNub service because of network failure
    PNPubNubClientStateDisconnectedOnNetworkError
} PNPubNubClientState;


@interface PubNub (Protected)


#pragma mark - Properties

/**
 Stores reference on configuration which was used to perform initial PubNub client initialization.
 */
@property (nonatomic, strong) PNConfiguration *configuration;

@property (nonatomic, strong) PNCache *cache;

/**
 Stores reference on current client identifier.
 */
@property (nonatomic, strong) NSString *clientIdentifier;

/**
 Stores unique client initialization session identifier (created each time when PubNub stack is configured after
 application launch).
 */
@property (nonatomic, strong) NSString *launchSessionIdentifier;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
/**
 Stores whether application is able to work in background or not.
 */
@property (nonatomic, readonly, getter = canRunInBackground) BOOL runInBackground;
#endif


#pragma mark - Class methods

/**
 * Return reference on client identifier which is ready to be sent as part of GET HTTP request (encoded with %
 * which allow to use it to send in HTTP requests)
 */
+ (NSString *)escapedClientIdentifier;


#pragma mark - Instance methods

/**
 * Return reference on reachability instance which is used to track network state
 */
- (PNReachability *)reachability;

#pragma mark -


@end
