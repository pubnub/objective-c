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
#import "PNConnection.h"


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

/**
 @brief Filter stored queue and find list of requests which is not processing(ed) yet.
 
 @return Filtered list of requests which still can be processed.
 
 @since 3.7.3
 */
- (NSArray *)unprocessedQueue;


@end


#pragma mark - Public interface methods

@implementation PNRequestsQueue


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization successful or not
    if((self = [super init])) {
        
        self.query = [NSMutableArray array];
        [self pn_setupPrivateSerialQueueWithIdentifier:@"request-queue" andPriority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
    }
    
    
    return self;
}

- (NSArray *)requestsQueue {

    return self.query;
}


#pragma mark - Queue management

- (void)enqueueRequest:(PNBaseRequest *)request outOfOrder:(BOOL)shouldEnqueueRequestOutOfOrder
             withBlock:(void (^)(BOOL scheduled))enqueueCompletionBlock {

    [self pn_dispatchBlock:^{

        BOOL requestScheduled = NO;

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

        enqueueCompletionBlock(requestScheduled);
    }];
}

- (PNBaseRequest *)dequeRequestWithIdentifier:(NSString *)requestIdentifier {

    // This method should be launched only from within it's private queue
    [self pn_scheduleOnPrivateQueueAssert];

    PNBaseRequest *request = nil;
    if (requestIdentifier) {

        NSPredicate *nextRequestSearch = [NSPredicate predicateWithFormat:@"identifier = %@", requestIdentifier];

        // Searching for existing request entry by it's identifier which is not launched yet
        NSArray *filteredRequests = [self.query filteredArrayUsingPredicate:nextRequestSearch];
        request = ([filteredRequests count] > 0 ? [filteredRequests lastObject] : nil);
    }
    
    
    return request;
}

- (void)removeRequest:(PNBaseRequest *)request {

    [self pn_dispatchBlock:^{

        // Check whether request not in the processing at this moment and remove it if possible
        if (!request.processing) {

            [self.query removeObject:request];
        }
    }];
}

- (void)removeAllRequests {

    [self pn_dispatchBlock:^{

        // Remove all request which still not launched
        NSPredicate *activeRequestsSearch = [NSPredicate predicateWithFormat:@"processing = %@", @YES];
        [self.query filterUsingPredicate:activeRequestsSearch];
    }];
}

- (NSString *)nextRequestIdentifier {

    // This method should be launched only from within it's private queue
    [self pn_scheduleOnPrivateQueueAssert];

    NSString *nextRequestIndex = nil;
    NSArray *query = [self unprocessedQueue];
    if ([query count] > 0) {
        
        PNBaseRequest *nextRequest = (PNBaseRequest *)[query objectAtIndex:kPNRequestQueueNextRequestIndex];
        nextRequestIndex = [nextRequest identifier];
    }
    
    
    return nextRequestIndex;
}

- (NSArray *)unprocessedQueue {
    
    static NSPredicate *inactiveRequestsSearch;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        inactiveRequestsSearch = [NSPredicate predicateWithFormat:@"processing = %@ && processed = %@", @NO, @NO];
    });
    
    
    return [self.query filteredArrayUsingPredicate:inactiveRequestsSearch];
}


#pragma mark - Misc methods

#pragma mark - Connection data source methods

- (void)checkHasDataForConnection:(PNConnection *)connection withBlock:(void (^)(BOOL hasData))checkCompletionBlock {

    [self pn_dispatchBlock:^{

        if (checkCompletionBlock) {

            checkCompletionBlock([[self unprocessedQueue] count] > 0);
        }
    }];
}

- (void)nextRequestIdentifierForConnection:(PNConnection *)connection
                                 withBlock:(void (^)(NSString *identifier))fetchCompletionBlock {

    [self pn_dispatchBlock:^{

        if (fetchCompletionBlock) {

            fetchCompletionBlock([self nextRequestIdentifier]);
        }
    }];
}

- (void)connection:(PNConnection *)connection requestDataForIdentifier:(NSString *)requestIdentifier
         withBlock:(void (^)(PNWriteBuffer *buffer))fetchCompletionBlock {

    [self pn_dispatchBlock:^{

        PNWriteBuffer *buffer = nil;

        // Retrieve reference on next request which will be processed
        PNBaseRequest *nextRequest = [self dequeRequestWithIdentifier:requestIdentifier];

        // Check whether request already processed or not (processed requests can be leaved in queue to lock it's further
        // execution till specific event or timeout)
        if (!nextRequest.processed) {

            buffer = [nextRequest buffer];
        }

        if (fetchCompletionBlock) {

            fetchCompletionBlock(buffer);
        }
    }];
}

- (void)connection:(PNConnection *)connection processingRequestWithIdentifier:(NSString *)requestIdentifier
         withBlock:(dispatch_block_t)notifyCompletionBlock {

    [self pn_dispatchBlock:^{

        PNBaseRequest *currentRequest = [self dequeRequestWithIdentifier:requestIdentifier];
        if (currentRequest != nil) {

            /// Forward request processing start to the delegate
            [self.delegate requestsQueue:self willSendRequest:currentRequest withBlock:notifyCompletionBlock];
        }
        else {

            if (notifyCompletionBlock) {

                notifyCompletionBlock();
            }
        }
    }];
}

- (void)connection:(PNConnection *)connection didSendRequestWithIdentifier:(NSString *)requestIdentifier
         withBlock:(dispatch_block_t)notifyCompletionBlock {

    [self pn_dispatchBlock:^{

        PNBaseRequest *processedRequest = [self dequeRequestWithIdentifier:requestIdentifier];
        if (processedRequest != nil) {

            // Forward request processing completion to the delegate
            [self.delegate requestsQueue:self didSendRequest:processedRequest withBlock:^{

                // Check whether request issuer allow to remove completed request from queue or should leave it there and
                // lock queue with it
                [self.delegate shouldRequestsQueue:self removeCompletedRequest:processedRequest
                                   checkCompletion:^(BOOL shouldRemove) {

                    if (shouldRemove) {

                        [self pn_dispatchBlock:^{

                            // Find processed request by identifier to remove it from requests queue
                            [self removeRequest:[self dequeRequestWithIdentifier:requestIdentifier]];

                            if (notifyCompletionBlock) {

                                notifyCompletionBlock();
                            }
                        }];
                    }
                    else {

                        if (notifyCompletionBlock) {

                            notifyCompletionBlock();
                        }
                    }
                }];
            }];
        }
        else {

            if (notifyCompletionBlock) {

                notifyCompletionBlock();
            }
        }
    }];
}

- (void)connection:(PNConnection *)connection didCancelRequestWithIdentifier:(NSString *)requestIdentifier
         withBlock:(dispatch_block_t)notifyCompletionBlock {

    [self pn_dispatchBlock:^{

        PNBaseRequest *currentRequest = [self dequeRequestWithIdentifier:requestIdentifier];
        if (currentRequest != nil) {

            // Forward request processing cancellation to the delegate
            [self.delegate requestsQueue:self didCancelRequest:currentRequest withBlock:notifyCompletionBlock];
        }
        else {

            if (notifyCompletionBlock) {

                notifyCompletionBlock();
            }
        }
    }];
}

/**
 * Handle request send failure event to reset request state. Maybe this error occurred because of network error, so we
 * should resend request right after connection is up again
 */
- (void)connection:(PNConnection *)connection didFailToProcessRequestWithIdentifier:(NSString *)requestIdentifier
             error:(PNError *)error withBlock:(dispatch_block_t)notifyCompletionBlock {

    [self pn_dispatchBlock:^{

        PNBaseRequest *currentRequest = [self dequeRequestWithIdentifier:requestIdentifier];
        if (currentRequest != nil) {

            // Forward request processing failure to the delegate
            [self.delegate requestsQueue:self didFailRequestSend:currentRequest error:error
                               withBlock:notifyCompletionBlock];
        }
        else {

            if (notifyCompletionBlock) {

                notifyCompletionBlock();
            }
        }
    }];
}


#pragma mark - Memory management

- (void)dealloc {
    
    [self pn_destroyPrivateDispatchQueue];
    
    _delegate = nil;
}

#pragma mark -


@end
