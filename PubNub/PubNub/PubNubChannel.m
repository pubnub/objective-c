//
//  PubNubChannel.m
//  PubNubClient
//
//  Created by Luke Alonso on 4/9/15.
//  Copyright (c) 2015 Twitter. All rights reserved.
//

#import "PubNubChannel.h"
#import <AFNetworkReachabilityManager.h>

static NSString* kPubNubProtocol = @"https";
static NSString* kPubNubHost = @"pubsub.pubnub.com";
static NSString* kPubNubSdkId = @"Periscope";
static const NSTimeInterval kPubNubPollTimeoutSeconds = 20.0;
static const NSTimeInterval kPubNubTimeoutSeconds = 5.0;
static const NSTimeInterval kPubNubPollFailureBackoffSeconds = 1.0;
static const NSInteger kPubNubHeartbeatFailureThreshold = 2;
static const NSTimeInterval kPubNubHeartbeatInterval = 5.0;
static const NSTimeInterval kPubNubHeartbeatIntervalFail = 1.0;

@implementation PubNubChannel
{
    NSString* _channelId;
    NSString* _authKey;
    NSString* _subscriberKey;
    NSString* _publisherKey;
    NSString* _clientUuid;
    NSURLSession* _session;
    NSURLSession* _pollingSession;
    AFNetworkReachabilityManager* _reachability;
    dispatch_queue_t _immediateQueue;
    dispatch_queue_t _pollingQueue;
    dispatch_queue_t _connectQueue;
    dispatch_queue_t _heartbeatQueue;
    int64_t _sinceTime;
    NSInteger _heartbeatFailureCount;
    NSString* _encodedUserInfo;
    NSInteger _connectCount;
    AFNetworkReachabilityStatus _prevReachabilityStatus;
    BOOL _connected;
    BOOL _heartbeat;
}

- (instancetype)initWithName:(NSString*)name clientUuid:(NSString*)clientUuid authKey:(NSString*)authKey subscriberKey:(NSString*)subscriberKey publisherKey:(NSString*)publisherKey heartbeat:(BOOL)heartbeat
{
    self = [super init];
    if (self) {
        _state = PubNubChannelStateDisconnected;
        _name = name;
        _channelId = [[self class] _urlEncode:name];
        _authKey = [[self class] _urlEncode:authKey];
        _subscriberKey = [[self class] _urlEncode:subscriberKey];
        _publisherKey = [[self class] _urlEncode:publisherKey];
        _clientUuid = clientUuid;
        _heartbeat = heartbeat;
        _connectQueue = dispatch_queue_create("PubNubChannelConnectQueue", DISPATCH_QUEUE_CONCURRENT);
        _pollingQueue = dispatch_queue_create("PubNubChannelPollingQueue", DISPATCH_QUEUE_SERIAL);
        _immediateQueue = dispatch_queue_create("PubNubChannelImmediateQueue", DISPATCH_QUEUE_SERIAL);
        _heartbeatQueue = dispatch_queue_create("PubNubChannelHeartbeatQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)subscribeWithUserInfo:(NSDictionary *)userInfo completion:(void (^)())completion
{
    dispatch_barrier_async(_connectQueue, ^{
        if (!_connected) {
            _connected = YES;
            _encodedUserInfo = [[self class] _encodeJsonData:@{ _channelId: userInfo }];
            _sinceTime = 0;
            _heartbeatFailureCount = 0;
            _connectCount++;

            _session = [[self class] _createSession];
            _pollingSession = [[self class] _createPollingSession];

            [self _dispatchSubscribePoll];

            if (_heartbeat) {
                [self _dispatchHeartbeat];
            }

            if (_heartbeat) {
                _prevReachabilityStatus = AFNetworkReachabilityStatusUnknown;
                _reachability = [AFNetworkReachabilityManager managerForDomain:kPubNubHost];
                [_reachability startMonitoring];
                __weak typeof(self) weakSelf = self;
                [_reachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                    __strong typeof(self) strongSelf = weakSelf;
                    [strongSelf _reachabilityStatusChanged:status];
                }];
            }

            [self _dispatchChangeState:PubNubChannelStateConnected];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)unsubscribeWithCompletion:(void (^)())completion
{
    dispatch_barrier_async(_connectQueue, ^{
        if (_connected) {
            _connected = NO;
            [_session invalidateAndCancel];
            _session = nil;
            [_pollingSession invalidateAndCancel];
            _pollingSession = nil;
            [_reachability stopMonitoring];
            [_reachability setReachabilityStatusChangeBlock:nil];
            _reachability = nil;
            [self _dispatchChangeState:PubNubChannelStateDisconnected];
            [self _leaveWithCompletion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }];
        }
    });
}

- (void)publishMessage:(NSDictionary*)message
{
    dispatch_async(_immediateQueue, ^{
        NSString* encodedMsg = [[self class] _encodeJsonData:message];
        if (encodedMsg) {
            [self _issueRequestWithUrl:[self _requestForPublishWithEncodedMessage:encodedMsg] polling:NO arrayCompletion:^(NSArray* array, NSError* error) {
            }];
        }
    });
}

- (void)hereNowWithCompletion:(void (^)(NSArray* users))completion
{
    dispatch_async(_immediateQueue, ^{
        dispatch_suspend(_immediateQueue);
        [self _issueRequestWithUrl:[self _requestForHereNow] polling:NO dictionaryCompletion:^(NSDictionary* dict, NSError* error) {
            dispatch_resume(_immediateQueue);
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([dict[@"uuids"] isKindOfClass:[NSArray class]]) {
                    completion((NSArray*)dict[@"uuids"]);
                } else {
                    completion(nil);
                }
            });
        }];
    });
}

- (void)historyWithStartTime:(long long)startTime endTime:(long long)endTime limit:(NSInteger)limit completion:(void (^)(long long start, long long end, NSArray* messages))completion
{
    dispatch_async(_immediateQueue, ^{
        dispatch_suspend(_immediateQueue);
        [self _issueRequestWithUrl:[self _requestForHistoryWithStartTime:startTime endTime:endTime limit:limit] polling:NO arrayCompletion:^(NSArray* array, NSError* error) {
            dispatch_resume(_immediateQueue);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray* messages = nil;
                if ([array[0] isKindOfClass:[NSArray class]]) {
                    messages = array[0];
                }
                long long resultStart = 0;
                if ([array[1] isKindOfClass:[NSNumber class]] || [array[1] isKindOfClass:[NSString class]]) {
                    resultStart = [array[1] longLongValue];
                }
                long long resultEnd = 0;
                if ([array[2] isKindOfClass:[NSNumber class]] || [array[2] isKindOfClass:[NSString class]]) {
                    resultEnd = [array[2] longLongValue];
                }
                completion(resultStart, resultEnd, messages);
            });
        }];
    });
}

- (void)_leaveWithCompletion:(void (^)())completion
{
    // Leave uses the polling queue and the global url session, because it must happen after any subscribes and the session may
    // already be destroyed.
    dispatch_async(_pollingQueue, ^{
        dispatch_suspend(_pollingQueue);
        if (self) {
            [[self class] _issueRequestWithSession:[NSURLSession sharedSession] url:[self _requestForLeaveChannel] completion:^(NSObject *jsonObject, NSError *error) {
                dispatch_resume(_pollingQueue);
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }];
        }
    });
}

- (void)_dispatchChangeState:(PubNubChannelState)newState
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Disallow transition to/from disconnected <-> transientfailure.
        if (newState == _state || (newState == PubNubChannelStateTransientFailure && _state == PubNubChannelStateDisconnected) || (newState == PubNubChannelStateDisconnected && _state == PubNubChannelStateTransientFailure)) {
            return;
        }
        _state = newState;
        [self.delegate pubNubChannel:self state:_state];
    });
}

- (void)_processSubscribePollResponseWithArray:(NSArray*)array error:(NSError*)error
{
    if (!error) {
        // Deliver the messages.
        NSDate* receivedDate = [NSDate date];
        if ([array[1] isKindOfClass:[NSNumber class]] || [array[1] isKindOfClass:[NSString class]]) {
            _sinceTime = [array[1] longLongValue];
            receivedDate = [NSDate dateWithTimeIntervalSince1970:(double)(_sinceTime / 10000) / 1000.0];
        }
        if ([array[0] isKindOfClass:[NSArray class]]) {
            NSArray* messages = array[0];
            [self _deliverMessages:messages receivedDate:receivedDate];
        }
    }

    NSTimeInterval pollSeconds = error ? kPubNubPollFailureBackoffSeconds : 0.0;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(pollSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf _dispatchIfConnectedSync:^{
            [strongSelf _dispatchSubscribePoll];
        }];
    });
}

- (void)_deliverMessages:(NSArray*)messages receivedDate:(NSDate*)receivedData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate) {
            [self _dispatchIfConnectedSync:^{
                [self.delegate pubNubChannel:self messages:messages receivedDate:receivedData];
            }];
        }
    });
}

- (void)_dispatchSubscribePoll
{
    NSInteger connectCountOnDispatch = _connectCount;
    dispatch_queue_t queue = _pollingQueue;
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue, ^{
        dispatch_suspend(queue);
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf _issueRequestWithUrl:[strongSelf _requestForSubscribe] polling:YES arrayCompletion:^(NSArray* array, NSError* error) {
            __strong typeof(self) innerStrongSelf = weakSelf;
            if (innerStrongSelf && connectCountOnDispatch == innerStrongSelf->_connectCount) {
                [innerStrongSelf _processSubscribePollResponseWithArray:array error:error];
            }
            dispatch_resume(queue);
        }];
    });
}

- (void)_processHeartbeatResponse:(NSObject*)object error:(NSError*)error
{
    if (error) {
        _heartbeatFailureCount++;
        if (_heartbeatFailureCount >= kPubNubHeartbeatFailureThreshold) {
            _sinceTime = 0;
            [self _resetPollingSession];
            // Too many consecutive failures, notify delegate and reset since for future requests.
            [self _dispatchChangeState:PubNubChannelStateTransientFailure];
        }
    } else {
        if (_heartbeatFailureCount >= kPubNubHeartbeatFailureThreshold) {
            // We were failing, now we're not, so reset the polling session in case it's still stuck in a long timeout.
            [self _resetPollingSession];
        }
        _heartbeatFailureCount = 0;
        [self _dispatchChangeState:PubNubChannelStateConnected];
    }
    __weak typeof(self) weakSelf = self;
    NSTimeInterval pollSeconds = error ? kPubNubHeartbeatIntervalFail : kPubNubHeartbeatInterval;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(pollSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf _dispatchHeartbeat];
    });
}

- (void)_dispatchHeartbeat
{
     NSInteger connectCountOnDispatch = _connectCount;
    __weak typeof(self) weakSelf = self;
    dispatch_async(_heartbeatQueue, ^{
        dispatch_suspend(_heartbeatQueue);
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf _issueRequestWithUrl:[strongSelf _requestForHeartbeat] polling:NO completion:^(NSObject* object, NSError* error) {
            __strong typeof(self) innerStrongSelf = weakSelf;
            if (innerStrongSelf && connectCountOnDispatch == innerStrongSelf->_connectCount) {
                [innerStrongSelf _processHeartbeatResponse:object error:error];
            }
            dispatch_resume(_heartbeatQueue);
        }];
    });
}

- (void)_dispatchIfConnectedSync:(void (^)())completion
{
    __block BOOL connected = NO;
    dispatch_sync(_connectQueue, ^{
        connected = _connected;
    });
    if (connected) {
        completion();
    }
}

- (NSString*)_pubNubPath
{
    return [NSString stringWithFormat:@"%@://%@", kPubNubProtocol, kPubNubHost];
}

- (NSString*)_standardQueryParams
{
    return [NSString stringWithFormat:@"?uuid=%@&auth=%@&pnsdk=%@", _clientUuid, _authKey, kPubNubSdkId];
}

- (NSURL*)_requestForPublishWithEncodedMessage:(NSString*)encodedMessage
{
    NSString* path = [NSString stringWithFormat:@"%@/publish/%@/%@/0/%@/0/%@%@", [self _pubNubPath], _publisherKey, _subscriberKey, _channelId, encodedMessage, [self _standardQueryParams]];
    return [NSURL URLWithString:path];
}

- (NSURL*)_requestForHistoryWithStartTime:(long long)startTime endTime:(long long)endTime limit:(NSInteger)limit
{
    NSString* path = [NSString stringWithFormat:@"%@/v2/history/sub-key/%@/channel/%@%@&stringtoken=true&include_token=true&reverse=false&count=%lli&start=%lli&end=%lli", [self _pubNubPath], _subscriberKey, _channelId, [self _standardQueryParams], (long long)limit, startTime, endTime];
    return [NSURL URLWithString:path];
}

// TODO Unprotected access to _encodedUserInfo
- (NSURL*)_requestForSubscribe
{
    NSString* userInfoQuery = @"";
    if (_encodedUserInfo) {
        userInfoQuery = [@"&state=" stringByAppendingString:_encodedUserInfo];
    }
    NSString* path = [NSString stringWithFormat:@"%@/subscribe/%@/%@/0/%llu%@%@", [self _pubNubPath], _subscriberKey, _channelId, _sinceTime, [self _standardQueryParams], userInfoQuery];
    return [NSURL URLWithString:path];
}

- (NSURL*)_requestForHereNow
{
    NSString* path = [NSString stringWithFormat:@"%@/v2/presence/sub_key/%@/channel/%@%@&state=1", [self _pubNubPath], _subscriberKey, _channelId, [self _standardQueryParams]];
    return [NSURL URLWithString:path];
}

- (NSURL*)_requestForLeaveChannel
{
    NSString* path = [NSString stringWithFormat:@"%@/v2/presence/sub-key/%@/channel/%@/leave%@", [self _pubNubPath], _subscriberKey, _channelId, [self _standardQueryParams]];
    return [NSURL URLWithString:path];
}

- (NSURL*)_requestForHeartbeat
{
    NSString* path = [NSString stringWithFormat:@"%@/subscribe/%@/%@/0/0%@", [self _pubNubPath], _subscriberKey, _channelId, [self _standardQueryParams]];
    return [NSURL URLWithString:path];
}

- (void)_issueRequestWithUrl:(NSURL*)url polling:(BOOL)polling completion:(void (^)(NSObject* jsonObject, NSError* error))completion
{
    __block NSURLSession* session = nil;
    [self _dispatchIfConnectedSync:^{
        session = polling ? _pollingSession : _session;
    }];
    if (session != nil) {
        [[self class] _issueRequestWithSession:session url:url completion:completion];
    } else {
        completion(nil, nil);
    }
}

- (void)_issueRequestWithUrl:(NSURL*)url polling:(BOOL)polling arrayCompletion:(void (^)(NSArray* jsonObject, NSError* error))arrayCompletion
{
    [self _issueRequestWithUrl:url polling:polling completion:^(NSObject *jsonObject, NSError *error) {
        if (error) {
            arrayCompletion(nil, error);
            return;
        }
        if ([jsonObject isKindOfClass:[NSArray class]]){
            NSArray* array = (NSArray*)jsonObject;
            arrayCompletion(array, nil);
            return;
        }
        arrayCompletion(nil, [[self class] _errorWithMessage:@"json response not an array"]);
    }];
}

- (void)_issueRequestWithUrl:(NSURL*)url polling:(BOOL)polling dictionaryCompletion:(void (^)(NSDictionary* jsonObject, NSError* error))dictionaryCompletion
{
    [self _issueRequestWithUrl:url polling:polling completion:^(NSObject *jsonObject, NSError *error) {
        if (error) {
            dictionaryCompletion(nil, error);
            return;
        }
        if ([jsonObject isKindOfClass:[NSDictionary class]]){
            NSDictionary* dict = (NSDictionary*)jsonObject;
            dictionaryCompletion(dict, nil);
            return;
        }
        dictionaryCompletion(nil, [[self class] _errorWithMessage:@"json response not a dictionary"]);
    }];
}

- (void)_resetPollingSession
{
    dispatch_barrier_async(_connectQueue, ^{
        if (_connected) {
            [_pollingSession invalidateAndCancel];
            _pollingSession = [[self class] _createPollingSession];
        }
    });
}

- (void)_reachabilityStatusChanged:(AFNetworkReachabilityStatus)status
{
    if (_prevReachabilityStatus != AFNetworkReachabilityStatusUnknown) {
        [self _resetPollingSession];
    }
    _prevReachabilityStatus = status;
}

+ (NSURLSession*)_createSession
{
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    config.HTTPShouldUsePipelining = YES;
    config.HTTPMaximumConnectionsPerHost = 3;
    config.timeoutIntervalForRequest = kPubNubTimeoutSeconds;
    config.timeoutIntervalForResource = kPubNubTimeoutSeconds;
    return [NSURLSession sessionWithConfiguration:config];
}

+ (NSURLSession*)_createPollingSession
{
    NSURLSessionConfiguration* pollingConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    pollingConfig.HTTPShouldUsePipelining = YES;
    pollingConfig.timeoutIntervalForResource = kPubNubPollTimeoutSeconds;
    pollingConfig.timeoutIntervalForRequest = kPubNubPollTimeoutSeconds;
    return [NSURLSession sessionWithConfiguration:pollingConfig];
}

+ (NSString*)_encodeJsonData:(NSObject*)object
{
    NSError* error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    if (error) {
        NSLog(@"error encoding json %@", error);
        return nil;
    }
    NSString* encodedStr = [[self class] _urlEncode:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    return encodedStr;
}

+ (void)_parseJsonData:(NSData*)json completion:(void (^)(NSObject* jsonObject, NSError* error))completion
{
    if (!json) {
        completion(nil, [[self class] _errorWithMessage:@"missing json data"]);
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError* error = nil;
        NSObject* object = [NSJSONSerialization JSONObjectWithData:json options:0 error:&error];
        if (error) {
            completion(nil, error);
            return;
        }
        completion(object, nil);
    });
}

+ (void)_issueRequestWithSession:(NSURLSession*)session url:(NSURL*)url completion:(void (^)(NSObject* jsonObject, NSError* error))completion;
{
    NSURLSessionDataTask* task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        [[self class] _parseJsonData:data completion:^(NSObject *jsonObject, NSError *error) {
            if (error) {
                completion(nil, error);
                return;
            }
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            if (httpResponse.statusCode == 200) {
                completion(jsonObject, nil);
            } else {
                completion(jsonObject, [[self class] _errorWithMessage:@"bad http response"]);
            }
        }];

    }];
    [task resume];
}

+ (NSString*)_urlEncode:(NSString*)str
{
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)str, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

+ (NSError*)_errorWithMessage:(NSString*)message
{
    return [NSError errorWithDomain:@"PubNubClient" code:0 userInfo:@{ @"message": message }];
}

@end
