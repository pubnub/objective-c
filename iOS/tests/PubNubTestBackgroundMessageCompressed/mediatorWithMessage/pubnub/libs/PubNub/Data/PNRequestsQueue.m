//
//  PNRequestsQueue.m
//  pubnub
//
//  This class was created for iOS PubNub client support to handle request sending via single socket connection.
//  This is singleton class which will help to organize requests into single FIFO pipe.
//
//
//  Created by Sergey Mamontov on 12/13/12.
//
//

#import "PNRequestsQueue.h"
#import "NSObject+PNAdditions.h"
#import "PNBaseRequest.h"
#import "PNWriteBuffer.h"
#import "PNHelper.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub requests queue must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Static

static NSUInteger const kPNRequestQueueNextRequestIndex = 0;


#pragma mark - Private interface methods

@interface PNRequestsQueue ()


#pragma mark - Properties

// Stores list of scheduled queries
@property (nonatomic, strong) NSMutableArray *query;


#pragma mark - Instance methods

/**
 * Returns reference on request which is still not processed by connection with specified identifier
 */
- (PNBaseRequest *)dequeRequestWithIdentifier:(NSString *)requestIdentifier;

/**
 * Returns identifier for next request which probably will be sent for processing
 */
- (NSString *)nextRequestIdentifier;


@end


#pragma mark - Public interface methods

@implementation PNRequestsQueue


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization successful or not
    if((self = [super init])) {
        
        self.query = [NSMutableArray array];
        [self pn_setPrivateDispatchQueue:[self pn_serialQueueWithOwnerIdentifier:@"connection" andTargetQueue:nil]];
    }
    
    
    return self;
}

- (NSArray *)requestsQueue {

    return self.query;
}


#pragma mark - Queue management

- (BOOL)enqueueRequest:(PNBaseRequest *)request {

    return [self enqueueRequest:request outOfOrder:NO];
}

- (BOOL)enqueueRequest:(PNBaseRequest *)request outOfOrder:(BOOL)shouldEnqueueRequestOutOfOrder {

    __block BOOL requestScheduled = NO;

    [self pn_dispatchSynchronouslyBlock:^{

        // Searching for existing request entry
        NSPredicate *sameObjectsSearch = [NSPredicate predicateWithFormat:@"identifier = %@ && processing = %@",
                                          request.identifier, @NO];
        if ([[self.query filteredArrayUsingPredicate:sameObjectsSearch] count] == 0) {

            if (shouldEnqueueRequestOutOfOrder) {

                [self.query insertObject:request atIndex:0];
            }
            else {

                [self.query addObject:request];
            }
            requestScheduled = YES;
        }
    }];


    return requestScheduled;
}

- (PNBaseRequest *)dequeRequestWithIdentifier:(NSString *)requestIdentifier {

    __block PNBaseRequest *request = nil;
    if (requestIdentifier) {

        NSPredicate *nextRequestSearch = [NSPredicate predicateWithFormat:@"identifier = %@", requestIdentifier];
        [self pn_dispatchSynchronouslyBlock:^{

            // Searching for existing request entry by it's identifier which is not launched yet
            NSArray *filteredRequests = [self.query filteredArrayUsingPredicate:nextRequestSearch];

            request = ([filteredRequests count] > 0 ? [filteredRequests lastObject] : nil);
        }];
    }
    
    
    return request;
}

- (void)removeRequest:(PNBaseRequest *)request {

    [self pn_dispatchAsynchronouslyBlock:^{

        // Check whether request not in the processing at this moment and remove it if possible
        if (!request.processing) {

            [self.query removeObject:request];
        }
    }];
}

- (void)removeAllRequests {

    [self pn_dispatchAsynchronouslyBlock:^{

        // Remove all request which still not launched
        NSPredicate *activeRequestsSearch = [NSPredicate predicateWithFormat:@"processing = %@", @YES];
        [self.query filterUsingPredicate:activeRequestsSearch];
    }];
}

- (NSString *)nextRequestIdentifier {
    
    NSString *nextRequestIndex = nil;

    if ([self.query count] > 0) {
        
        PNBaseRequest *nextRequest = (PNBaseRequest *)[self.query objectAtIndex:kPNRequestQueueNextRequestIndex];
        nextRequestIndex = [nextRequest identifier];
    }
    
    
    return nextRequestIndex;
}


#pragma mark - Misc methods

#pragma mark - Connection data source methods

- (BOOL)hasDataForConnection:(PNConnection *)connection {

    __block BOOL hasDataForConnection = NO;
    [self pn_dispatchSynchronouslyBlock:^{

        hasDataForConnection = [self.query count] > 0;
    }];

    
    return hasDataForConnection;
}

- (NSString *)nextRequestIdentifierForConnection:(PNConnection *)connection {

    __block NSString *nextRequestIdentifier = nil;
    [self pn_dispatchSynchronouslyBlock:^{

        nextRequestIdentifier = [self nextRequestIdentifier];
    }];

    
    return nextRequestIdentifier;
}

- (PNBaseRequest *)nextRequestForConnection:(PNConnection *)connection {

    return [self dequeRequestWithIdentifier:[self nextRequestIdentifierForConnection:connection]];
}

- (PNWriteBuffer *)connection:(PNConnection *)connection requestDataForIdentifier:(NSString *)requestIdentifier {

    PNWriteBuffer *buffer = nil;

    // Retrieve reference on next request which will be processed
    PNBaseRequest *nextRequest = [self dequeRequestWithIdentifier:requestIdentifier];

    // Check whether request already processed or not (processed requests can be leaved in queue to lock it's further
    // execution till specific event or timeout)
    if (!nextRequest.processed) {

        buffer = [nextRequest buffer];
    }


    return buffer;
}

- (void)connection:(PNConnection *)connection processingRequestWithIdentifier:(NSString *)requestIdentifier {

    PNBaseRequest *currentRequest = [self dequeRequestWithIdentifier:requestIdentifier];
    if (currentRequest != nil) {

        /// Forward request processing start to the delegate
        [self.delegate requestsQueue:self willSendRequest:currentRequest];
    }
}

- (void)connection:(PNConnection *)connection didSendRequestWithIdentifier:(NSString *)requestIdentifier {

    PNBaseRequest *processedRequest = [self dequeRequestWithIdentifier:requestIdentifier];
    if (processedRequest != nil) {

        // Forward request processing completion to the delegate
        [self.delegate requestsQueue:self didSendRequest:processedRequest];


        // Check whether request issuer allow to remove completed request from queue or should leave it there and
        // lock queue with it
        [self.delegate shouldRequestsQueue:self removeCompletedRequest:processedRequest
                           checkCompletion:^(BOOL shouldRemove) {

                               if (shouldRemove) {

                                   // Find processed request by identifier to remove it from requests queue
                                   [self removeRequest:[self dequeRequestWithIdentifier:requestIdentifier]];
                               }
                           }];
    }
}

- (void)connection:(PNConnection *)connection didCancelRequestWithIdentifier:(NSString *)requestIdentifier {

    PNBaseRequest *currentRequest = [self dequeRequestWithIdentifier:requestIdentifier];
    if (currentRequest != nil) {

        // Forward request processing cancellation to the delegate
        [self.delegate requestsQueue:self didCancelRequest:currentRequest];
    }
}

/**
 * Handle request send failure event to reset request state. Maybe this error occurred because of network error, so we
 * should resend request right after connection is up again
 */
- (void)connection:(PNConnection *)connection didFailToProcessRequestWithIdentifier:(NSString *)requestIdentifier
         withError:(PNError *)error {

    PNBaseRequest *currentRequest = [self dequeRequestWithIdentifier:requestIdentifier];
    if (currentRequest != nil) {

        // Forward request processing failure to the delegate
        [self.delegate requestsQueue:self didFailRequestSend:currentRequest withError:error];
    }
}


#pragma mark - Memory management

- (void)dealloc {

    _delegate = nil;
}

#pragma mark -


@end
