/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+CorePrivate.h"
#import "PNResult+Private.h"
#import "PNConstants.h"
#import "PNRequest.h"


#pragma mark Interface implementation

@implementation PubNub


#pragma mark - Configuration and initialization

+ (instancetype)clientWithPublishKey:(NSString *)publishKey
                     andSubscribeKey:(NSString *)subscribeKey {
    
    PubNub *client = [self new];
    client.publishKey = publishKey;
    client.subscribeKey = subscribeKey;
    
    
    return client;
}

- (instancetype)init {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {
        
        self.origin = kPNDefaultOrigin;
        self.publishKey = kPNDefaultPublishKey;
        self.subscribeKey = kPNDefaultSubscribeKey;
        self.uuid = [[NSUUID UUID] UUIDString];
        self.subscribeRequestTimeout = kPNDefaultSubscribeRequestTimeout;
        self.nonSubscribeRequestTimeout = kPNDefaultNonSubscribeRequestTimeout;
        self.secureConnection = kPNDefaultShouldUseSecureConnection;
        self.fallbackToInsecureConnection = kPNDefaultCanFallbackToInsecureConnection;
        self.restoreSubscription = kPNDefaultShouldRestoreSubscription;
        self.catchUpOnSubscriptionRestore = kPNDefaultShouldTryCatchUpOnSubscriptionRestore;
        self.callbackQueue = dispatch_get_main_queue();
        
        // Create queue which will be used to syncronize shared resources modification (client
        // configuration) and other queue which would like to use them.
        self.configurationAccessQueue = dispatch_queue_create("configuration.pubnub.com",
                                                              DISPATCH_QUEUE_CONCURRENT);
        
        // Create queue which will be used to issue calls from subscription API group.
        self.subscribeQueue = dispatch_queue_create("subscription.pubnub.com",
                                                    DISPATCH_QUEUE_SERIAL);
        
        // Synchronize blocks call on subscribe queue with configuration access queue to serialize
        // access to shared resources (client configuration).
        dispatch_set_target_queue(self.subscribeQueue, self.configurationAccessQueue);
        
        // Create queue which will be used to issue calls from non-subscription API group.
        self.serviceQueue = dispatch_queue_create("service.pubnub.com", DISPATCH_QUEUE_CONCURRENT);
        
        // Synchronize blocks call on service queue with configuration access queue to serialize
        // access to shared resources (client configuration).
        dispatch_set_target_queue(self.serviceQueue, self.configurationAccessQueue);
        
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        configuration.timeoutIntervalForRequest = self.subscribeRequestTimeout;
        configuration.timeoutIntervalForResource = 310.0f;
        configuration.HTTPShouldUsePipelining = YES;
        configuration.HTTPAdditionalHeaders = @{@"Accept":@"*/*",
                                                @"Accept-Encoding":@"gzip,deflate"};
        configuration.HTTPMaximumConnectionsPerHost = 1;
        NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"http%@://%@",
                                               (self.shouldUseSecureConnection ? @"s" :@""),
                                               self.origin]];
        self.subscriptionSession = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL
                                                            sessionConfiguration:configuration];
        self.subscriptionSession.completionQueue = self.subscribeQueue;
    }
    
    
    return self;
}

- (void)setOrigin:(NSString *)origin {
    
    // TODO: Check active subscription and re-subscribe if required.
    dispatch_barrier_async(self.configurationAccessQueue, ^{
        
        _origin = (origin?: kPNDefaultOrigin);
    });
}

- (void)setPublishKey:(NSString *)publishKey {
    
    // TODO: Check active subscription and re-subscribe if required.
    dispatch_barrier_async(self.configurationAccessQueue, ^{
        
        _publishKey = (publishKey?: kPNDefaultPublishKey);
    });
}

- (void)setSubscribeKey:(NSString *)subscribeKey {
    
    // TODO: Check active subscription and re-subscribe if required.
    dispatch_barrier_async(self.configurationAccessQueue, ^{
        
        _subscribeKey = (subscribeKey?: kPNDefaultSubscribeKey);
    });
}

- (void)setUUID:(NSString *)uuid {
    
    // TODO: Check active subscription and re-subscribe if required.
    dispatch_barrier_async(self.configurationAccessQueue, ^{
        
        _uuid = (uuid?: [[NSUUID UUID] UUIDString]);
    });
}

- (void)setCallbackQueue:(dispatch_queue_t)callbackQueue {
    
    dispatch_barrier_async(self.configurationAccessQueue, ^{
        
        _callbackQueue = (callbackQueue?: dispatch_get_main_queue());
    });
}

- (void)setMessageHandlingBlock:(PNEventHandlingBlock)messageHandlingBlock {
    
    dispatch_barrier_async(self.configurationAccessQueue, ^{
        
        _messageHandlingBlock = (messageHandlingBlock?: nil);
    });
}

- (void)setPresenceEventHandlingBlock:(PNEventHandlingBlock)presenceEventHandlingBlock {
    
    dispatch_barrier_async(self.configurationAccessQueue, ^{
        
        _presenceEventHandlingBlock = (presenceEventHandlingBlock?: nil);
    });
}


#pragma mark - Operation processing

- (void)processRequest:(PNRequest *)request {
    
    dispatch_block_t processingBlock = ^{
        
        // Add parameters required 
        NSMutableDictionary *query = [request.parameters mutableCopy];
        [query addEntriesFromDictionary:@{}];
        [self.serviceSession GET:request.resourcePath parameters:query
                         success:^(NSURLSessionDataTask *task, id responseObject) {
                             
                             // Call parse block which has been passed by calling API to pre-process
                             // received data before returning it to te user.
                             id preProcessedResponse = request.parseBlock(responseObject);
                             PNResult *result = [PNResult resultFor:request
                                                       withResponse:task.response
                                                            andData:preProcessedResponse];
                             request.completionBlock(result, nil);
                         }
                         failure:^(NSURLSessionDataTask *task, NSError *error) {
                             
                             if (request.operation == PNSubscribeOperation) {
                                 
                                 // TODO: Keep retrying request after 1s delay
                             }
                             else {
                                 
                                 // TODO: Report processing error
                             }
                         }];
    };
    
}

#pragma mark -


@end
