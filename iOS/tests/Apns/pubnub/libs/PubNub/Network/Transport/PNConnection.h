//
//  PNConnection.h
//  pubnub
//
//  This is core class for communication over the network with PubNub services.
//  It allow to establish socket connection and organize write packet requests into FIFO queue.
//  
//
//  Created by Sergey Mamontov on 12/10/12.
//
//

#import <Foundation/Foundation.h>
#import "PNConnectionDelegate.h"
#import "PNMacro.h"


#pragma mark Class forward

@class PNConfiguration;


#pragma mark - Public interface declaration

@interface PNConnection : NSObject


#pragma mark Properties

// Reference on object which will provide requests pool for connection
@property (nonatomic, pn_desired_weak) id<PNConnectionDataSource> dataSource;

// Stores reference on connection delegate which also will be packet provider for connection
@property (nonatomic, pn_desired_weak) id<PNConnectionDelegate> delegate;


#pragma mark - Class methods

/**
 Depending on platform will be able to return few connections when on Mac OS and will reuse same connection on iOS
 */
+ (PNConnection *)connectionWithConfiguration:(PNConfiguration *)configuration andIdentifier:(NSString *)identifier;


#pragma mark - Instance methods

#pragma mark - Requests queue execution management

/**
 Inform connection to schedule requests queue processing.
 */
- (void)scheduleNextRequestExecution;

/**
 Inform connection to stop requests queue processing (last active request will be sent)
 */
- (void)unscheduleRequestsExecution;


#pragma mark - Connection management

- (void)connectWithResult:(void (^)(BOOL connecting))resultBlock;
- (void)checkConnected:(void (^)(BOOL connected))checkCompletionBlock;

- (void)disconnect;
- (void)checkDisconnected:(void (^)(BOOL disconnected))checkCompletionBlock;

/**
 * Reconnect sockets and streams by user request
 */
- (void)reconnectWithBlock:(dispatch_block_t)processReportBlock;

/**
 * Suspend sockets (basically they will be closed w/o PNConnection instance destroy)
 */
- (void)suspend;
- (void)checkSuspended:(void (^)(BOOL suspended))checkCompletionBlock;

/**
 * Restore default sockets functions (sockets connection will be up again)
 */
- (void)resume;
- (void)checkResuming:(void (^)(BOOL resuming))checkCompletionBlock;

#pragma mark -


@end
