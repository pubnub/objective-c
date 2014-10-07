//
//  PNDataManager.h
// 
//
//  Created by moonlight on 1/20/13.
//
//


#import "PNDataManager.h"
#import "PNPresenceEvent+Protected.h"
#import "PNMessage+Protected.h"
#import "PNChannel+Protected.h"
#import "PNClient.h"


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
                  NSArray *unsortedList = [PubNub subscribedObjectsList];
                  NSSortDescriptor *nameSorting = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
                  weakSelf.subscribedChannelsList = [unsortedList sortedArrayUsingDescriptors:@[nameSorting]];
              }];

        [[PNObservationCenter defaultCenter] addMessageReceiveObserver:weakSelf
                                                             withBlock:^(PNMessage *message) {

                 NSDateFormatter *dateFormatter = [NSDateFormatter new];
                 dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

                 PNChannel *channel = message.channel;
                 NSString *messages = [weakSelf.messages valueForKey:channel.name];
                 if (messages == nil) {

                     messages = @"";
                 }
                 messages = [messages stringByAppendingFormat:@"<%@> %@\n",
                                 [dateFormatter stringFromDate:message.receiveDate.date],
                                 message.message];
                 [weakSelf.messages setValue:messages forKey:channel.name];


                 weakSelf.currentChannelChat = [weakSelf.messages valueForKey:weakSelf.currentChannel.name];


                 if (![channel isEqual:weakSelf.currentChannel]) {

                     NSNumber *numberOfEvents = [weakSelf.events valueForKey:channel.name];
                     [weakSelf.events setValue:@([numberOfEvents intValue]+1) forKey:channel.name];
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
                PNChannel *channel = event.channel;
                NSString *eventMessage = [weakSelf.messages valueForKey:channel.name];
                if (eventMessage == nil) {

                    eventMessage = @"";
                }
                eventMessage = [eventMessage stringByAppendingFormat:@"<%@> \"%@\" %@\n",
                                                                     [dateFormatter stringFromDate:event.date.date],
                                                                     event.client.identifier,
                                                                     eventType];
                [weakSelf.messages setValue:eventMessage forKey:channel.name];


                weakSelf.currentChannelChat = [weakSelf.messages valueForKey:weakSelf.currentChannel.name];


                if (![channel isEqual:weakSelf.currentChannel]) {

                    NSNumber *numberOfEvents = [weakSelf.events valueForKey:channel.name];
                    [weakSelf.events setValue:@([numberOfEvents intValue]+1) forKey:channel.name];
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
