//
//  PNDataManager.h
// 
//
//  Created by moonlight on 1/20/13.
//
//


#import "PNDataManager.h"


#pragma mark Structures

typedef NS_OPTIONS(NSUInteger , PNPortalDataComponentIndices) {
    
    PNPortalSubscribeKeyIndex,
    PNPortalPublishKeyIndex,
    PNPortalSecretKeyIndex
};


#pragma mark - Static

// Stores reference on shared data manager instance
static PNDataManager *_sharedInstance = nil;


#pragma mark - Private interface methods

@interface PNDataManager ()


#pragma mark - Properties

// Stores reference on list of channels on which client is subscribed
@property (nonatomic, strong) NSArray *subscribedChannelsList;

// Stores reference on dictionary which stores messages for each of channels
@property (nonatomic, strong) NSMutableDictionary *messages;


@end


#pragma mark - Public interface methods

@implementation PNDataManager


#pragma mark - Class methods

+ (PNDataManager *)sharedInstance {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [PNDataManager new];
    });


    return _sharedInstance;
}


#pragma mark - Instance methods

- (id)init {

    // Check whether initialization successful or not
    if((self = [super init])) {

        self.events = [NSMutableDictionary dictionary];
        self.messages = [NSMutableDictionary dictionary];
        self.configuration = [PNConfiguration defaultConfiguration];
        self.subscribedChannelsList = [NSMutableArray array];

        __pn_desired_weak __typeof__(self) weakSelf = self;
        [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:weakSelf
                                                                     withCallbackBlock:^(PNSubscriptionProcessState state,
                                                                                         NSArray *channels,
                                                                                         PNError *subscriptionError) {

                    if (state == PNSubscriptionProcessSubscribedState || state == PNSubscriptionProcessRestoredState) {

                        NSArray *unsortedList = [PubNub subscribedObjectsList];
                        NSSortDescriptor *nameSorting = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
                        weakSelf.subscribedChannelsList = [unsortedList sortedArrayUsingDescriptors:@[nameSorting]];
                    }
                }];

        [[PNObservationCenter defaultCenter] addClientChannelUnsubscriptionObserver:weakSelf
                                                                  withCallbackBlock:^(NSArray *channels,
                                                                                      PNError *error) {
                                                                      
                  [channels enumerateObjectsUsingBlock:^(id<PNChannelProtocol> object, NSUInteger objectIdx,
                                                         BOOL *objectEnumeratorStop) {
                      if ([object isEqual:weakSelf.currentChannel]) {
                          
                          self.currentChannelChat = @"";
                          self.currentChannel = nil;
                      }
                      [weakSelf.messages removeObjectForKey:object.name];
                  }];
                  NSArray *unsortedList = [PubNub subscribedObjectsList];
                  NSSortDescriptor *nameSorting = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
                  weakSelf.subscribedChannelsList = [unsortedList sortedArrayUsingDescriptors:@[nameSorting]];
              }];
        
        void(^removeChannelGroupObject)(id, BOOL) = ^(id objectInformation, BOOL matchOnlyNamespace) {
            
            NSMutableArray *objectsForRemoval = [NSMutableArray array];
            [[weakSelf.subscribedChannelsList copy] enumerateObjectsUsingBlock:^(id<PNChannelProtocol> object,
                                                                                 NSUInteger objectIdx, BOOL *objectEnumeratorStop) {
                
                if (object.isChannelGroup) {
                    
                    BOOL isEqualToTargetObject = NO;
                    if (matchOnlyNamespace) {
                        
                        isEqualToTargetObject = [((PNChannelGroup *)object).nspace isEqualToString:objectInformation];
                    }
                    else {
                        
                        isEqualToTargetObject = [object isEqual:objectInformation];
                    }
                    
                    if (isEqualToTargetObject) {
                        
                        if([weakSelf.currentChannel isEqual:object]) {
                            
                            weakSelf.currentChannelChat = @"";
                            weakSelf.currentChannel = nil;
                        }
                        [weakSelf.messages removeObjectForKey:object.name];
                        [objectsForRemoval addObject:object];
                    }
                }
            }];
            
            NSPredicate *objectPredicate = [NSPredicate predicateWithFormat:@"NOT (self IN %@)", objectsForRemoval];
            weakSelf.subscribedChannelsList = [weakSelf.subscribedChannelsList filteredArrayUsingPredicate:objectPredicate];
            [PubNub unsubscribeFrom:objectsForRemoval];
        };
        
        [[PNObservationCenter defaultCenter] addChannelGroupNamespaceRemovalObserver:weakSelf
                                                                   withCallbackBlock:^(NSString *namespace, PNError *error) {
                                                                       
            if (!error) {
               
                removeChannelGroupObject(namespace, YES);
            }
        }];
        
        [[PNObservationCenter defaultCenter] addChannelGroupRemovalObserver:self
                                                          withCallbackBlock:^(PNChannelGroup *channelGroup, PNError *error) {
              
            if (!error) {
                  
                removeChannelGroupObject(channelGroup, NO);
            }
        }];

        [[PNObservationCenter defaultCenter] addMessageReceiveObserver:weakSelf
                                                             withBlock:^(PNMessage *message) {

                 NSDateFormatter *dateFormatter = [NSDateFormatter new];
                 dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

                 id <PNChannelProtocol> object = message.channel;
                 if (message.channelGroup) {
                     
                     object = message.channelGroup;
                 }
                 NSString *messages = [weakSelf.messages valueForKey:object.name];
                 if (messages == nil) {

                     messages = @"";
                 }
                 messages = [messages stringByAppendingFormat:@"<%@>%@ %@\n", [dateFormatter stringFromDate:message.receiveDate.date],
                             (![object isEqual:message.channel] ? [NSString stringWithFormat:@"<%@>", message.channel.name] : @""),
                             message.message];
                 [weakSelf.messages setValue:messages forKey:object.name];


                 weakSelf.currentChannelChat = [weakSelf.messages valueForKey:weakSelf.currentChannel.name];


                 if (![object isEqual:weakSelf.currentChannel]) {

                     NSNumber *numberOfEvents = [weakSelf.events valueForKey:object.name];
                     [weakSelf.events setValue:@([numberOfEvents intValue]+1) forKey:object.name];
                 }
             }];

        [[PNObservationCenter defaultCenter] addPresenceEventObserver:weakSelf
                                                            withBlock:^(PNPresenceEvent *event) {

                NSDateFormatter *dateFormatter = [NSDateFormatter new];
                dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                NSString *eventType = @"joined";
                if (event.type == PNPresenceEventStateChanged) {

                    eventType = @"state changed";
                }
                else if (event.type == PNPresenceEventLeave) {
                    
                    eventType = @"leaved";
                }
                else if (event.type == PNPresenceEventTimeout) {
                    
                    eventType = @"timeout";
                }
                id <PNChannelProtocol> object = event.channel;
                if (event.channelGroup) {

                    object = event.channelGroup;
                }
                NSString *eventMessage = [weakSelf.messages valueForKey:object.name];
                if (eventMessage == nil) {

                    eventMessage = @"";
                }
                eventMessage = [eventMessage stringByAppendingFormat:@"<%@>%@ \"%@\" %@\n",
                                 [dateFormatter stringFromDate:event.date.date],
                                 (![object isEqual:event.channel] ? [NSString stringWithFormat:@"<%@>", event.channel.name] : @""),
                                 event.client.identifier,
                                 eventType];
                [weakSelf.messages setValue:eventMessage forKey:object.name];


                weakSelf.currentChannelChat = [weakSelf.messages valueForKey:weakSelf.currentChannel.name];


                if (![object isEqual:weakSelf.currentChannel]) {

                    NSNumber *numberOfEvents = [weakSelf.events valueForKey:object.name];
                    [weakSelf.events setValue:@([numberOfEvents intValue]+1) forKey:object.name];
                }
            }];

        [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:weakSelf
                                                            withCallbackBlock:^(NSString *origin,
                                                                                BOOL connected,
                                                                                PNError *error) {

                                                                // Check whether client disconnected and there is no
                                                                // error (which means that user disconnected client)
                                                                if (!connected && !error) {

                                                                    weakSelf.currentChannel = nil;
                                                                    weakSelf.subscribedChannelsList = [NSMutableArray array];
                                                                    weakSelf.messages = [NSMutableDictionary dictionary];
                                                                    weakSelf.currentChannelChat = @"";
                                                                }
                                                            }];
}


    return self;
}

- (BOOL)handleOpenWithURL:(NSURL *)url {
    
    NSArray *supportedSchemes = [[[[NSBundle mainBundle] infoDictionary] valueForKeyPath:@"CFBundleURLTypes.CFBundleURLSchemes"] lastObject];
    BOOL isSupported = [supportedSchemes containsObject:[url scheme]];
    if (isSupported) {
        
        NSArray *portalData = [[[[url absoluteString] componentsSeparatedByString:@"//"] lastObject] componentsSeparatedByString:@"/"];
        NSString *subscribeKey = [portalData objectAtIndex:PNPortalSubscribeKeyIndex];
        NSString *publishKey = [portalData objectAtIndex:PNPortalPublishKeyIndex];
        NSString *secretKey = [portalData objectAtIndex:PNPortalSecretKeyIndex];
        
        isSupported = ([[subscribeKey stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] length] &&
                       [[publishKey stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] length] &&
                       [[secretKey stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] length]);
        
        if (isSupported) {
            
            self.configuration = [self.configuration updatedConfigurationWithOrigin:self.configuration.origin
                                                                         publishKey:publishKey subscribeKey:subscribeKey
                                                                          secretKey:secretKey cipherKey:self.configuration.cipherKey
                                                                   authorizationKey:self.configuration.authorizationKey];
        }
    }
    
    
    return isSupported;
}

- (void)updateSSLOption:(BOOL)shouldEnableSSL {

    self.configuration.useSecureConnection = shouldEnableSSL;
}

- (NSUInteger)numberOfEventsForChannel:(PNChannel *)channel {

    NSNumber *numberOfEvents = [self.events valueForKey:channel.name];
    
    
    return numberOfEvents ? [numberOfEvents unsignedIntValue] : 0;
}

- (void)clearChatHistory {

    if (self.currentChannel != nil) {

        [self.messages removeObjectForKey:self.currentChannel.name];
    }
    self.currentChannelChat = nil;
}

- (void)clearChannels {
    
    self.subscribedChannelsList = @[];
    self.currentChannel = nil;
    [self.messages removeAllObjects];
}

- (void)setCurrentChannel:(PNChannel *)currentChannel {

    if (currentChannel != nil) {

        // Resetting events count on selected channel
        [self.events removeObjectForKey:currentChannel.name];
    }

    [self willChangeValueForKey:@"currentChannel"];
    _currentChannel = currentChannel;
    [self didChangeValueForKey:@"currentChannel"];

    if (_currentChannel == nil) {

        self.currentChannelChat = nil;
    }
    else {

        self.currentChannelChat = [self.messages valueForKey:self.currentChannel.name];
    }
}

#pragma mark -


@end
