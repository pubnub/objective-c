/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNSubscribeParser.h"
#import "PNEnvelopeInformation.h"
#import "PubNub+CorePrivate.h"
#import "PNConstants.h"
#import "PNLogMacro.h"
#import "PNLLogger.h"
#import "PNHelpers.h"
#import "PNAES.h"


#pragma mark Static

/**
 @brief  Stores reference on key under which request status is stored.
 */
static NSString * const kPNResponseStatusKey = @"s";

/**
 @brief  Stores reference on key under which service advisory information stored.
 */
static NSString * const kPNResponseAdvisoryKey = @"a";

/**
 @brief  Stores reference on key under which stored information about when event has been triggered by server 
         and from which region.
 */
static NSString * const kPNResponseEventTimeKey = @"t";

/**
 @brief  Stores reference on key under which list of events is stored.
 */
static NSString * const kPNResponseEventsListKey = @"m";


#pragma mark - Structures

/**
 @brief  Describe structure with keys under which sotred information about when event has been triggered and 
         in which region (to which region client subscribed at this moment).
 */
struct PNEventTimeTokenStructure {
    
    /**
     @brief  Stores reference on key under which stored high precision time token (on linuxtimestamp in case
             of presence events) on when event has been triggered.
     */
    __unsafe_unretained NSString *timeToken;
    
    /**
     @brief  Stores reference on key under which stored numeric region identier.
     */
    __unsafe_unretained NSString *region;
} PNEventTimeToken = { .timeToken = @"t", .region = @"r" };

/**
 @brief  Describes overall real-time event format.
 */
struct PNEventEnvelopeStructure {
    
    /**
     @brief  Describes structure to represent local time token (unixtimestamp casted to high precision).
     */
    struct {
        
        /**
         @brief  Stores reference on key under which sender time token information is stored.
         */
        __unsafe_unretained NSString *key;
        
        /**
         @brief  Describes time token information.
         */
        struct PNEventTimeTokenStructure token;
    } senderTimeToken;
    
    /**
     @brief  Describes structure to represent represent time when message has been received by \b PubNub 
             service and passed to subscribers.
     */
    struct {
        
        /**
         @brief  Stores reference on key under which publish time token information is stored.
         */
        __unsafe_unretained NSString *key;
        
        /**
         @brief  Describes time token information.
         */
        struct PNEventTimeTokenStructure token;
    } publishTimeToken;
    
    /**
     @brief  Stores reference on key under which actual channel name on which event has been triggered.
     */
    __unsafe_unretained NSString *channel;
    
    /**
     @brief  Stores reference on key under which stored name of the object on which client subscribed at this 
             moment (can be: \c channel, \c group or \c wildcard).
     */
    __unsafe_unretained NSString *subscriptionMatch;
    
    /**
     @brief  Stores reference on key under which stored event object data (can be user message for publish
             message or presence dictionary with information about event).
     */
    __unsafe_unretained NSString *payload;
    
    struct {
        
        /**
         @brief  Stores reference on key under which stored information about presence event type.
         */
        __unsafe_unretained NSString *action;
        
        /**
         @brief  Stores reference on key under which stores information about client state on channel which
                 triggered presence event.
         */
        __unsafe_unretained NSString *data;
        
        /**
         @brief  Stores reference on key under which stored information about occupancy in channel which
                 triggered event.
         */
        __unsafe_unretained NSString *occupancy;
        
        /**
         @brief  Stores reference on key under which stored event triggering time token (unixtimestamp).
         */
        __unsafe_unretained NSString *timestamp;
        
        /**
         @brief  Stores reference on unique client identifier which caused presence event triggering.
         */
        __unsafe_unretained NSString *uuid;
    } presence;
} PNEventEnvelope = {
    .senderTimeToken = { .key = @"o" },
    .publishTimeToken = { .key = @"p" },
    .channel = @"c",
    .subscriptionMatch = @"b",
    .payload = @"d",
    .presence = { .action = @"action", .data = @"data", .occupancy = @"occupancy",
        .timestamp = @"timestamp", .uuid = @"uuid" }
};


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface

@interface PNSubscribeParser ()


#pragma mark - Events processing

/**
 @brief  Parse real-time event received from data object live feed.
 
 @param data           Reference on service-provided data about event.
 @param additionalData Additional information provided by client to complete parsing.
 
 @return Pre-processed event information (depending on stored data).
 
 @since 4.3.0
 */
+ (NSMutableDictionary *)eventFromData:(NSDictionary<NSString *, id> *)data
              withAdditionalParserData:(nullable NSDictionary<NSString *, id> *)additionalData;

/**
 @brief  Parse provided data as new message event.
 
 @param data           Data which should be parsed to required 'message' object format.
 @param additionalData Additional information provided by client to complete parsing.
 
 @return Processed and parsed 'message' object.
 
 @since 4.0
 */
+ (NSMutableDictionary *)messageFromData:(id)data
                withAdditionalParserData:(nullable NSDictionary<NSString *, id> *)additionalData;

/**
 @brief  Parse provded data as presence event.
 
 @param data Data which should be parsed to required 'presence event' object format.
 
 @return Processed and parsed 'presence event' object.
 
 @since 4.0
 */
+ (NSMutableDictionary *)presenceFromData:(NSDictionary<NSString *, id> *)data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSubscribeParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    
    return @[@(PNSubscribeOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return YES;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response 
   withData:(NSDictionary<NSString *, id> *)additionalData {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Array will arrive in case of subscription event
    if ([response isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary<NSString *, NSString *> *timeTokenDictionary = response[kPNResponseEventTimeKey];
        NSNumber *timeToken = @(timeTokenDictionary[PNEventTimeToken.timeToken].longLongValue);
        NSNumber *region = @(timeTokenDictionary[PNEventTimeToken.region].longLongValue);
        
        // Checking whether at least one event arrived or not.
        NSArray<NSDictionary *> *feedEvents = response[kPNResponseEventsListKey];
        if (feedEvents.count) {
            
            NSMutableArray<NSDictionary *> *events = [[NSMutableArray alloc] initWithCapacity:feedEvents.count];
            for (NSUInteger eventIdx = 0; eventIdx < [feedEvents count]; eventIdx++) {
                
                // Fetching remote data object name on which event fired.
                NSMutableDictionary *event = [self eventFromData:feedEvents[eventIdx]
                                        withAdditionalParserData:additionalData];
                if (!event[@"timetoken"]) { event[@"timetoken"] = timeToken; }
                [events addObject:event];
            }
            feedEvents = [events copy];
        }
        processedResponse = @{@"events": feedEvents, @"timetoken": timeToken, @"region": region};
    }
    
    return processedResponse;
}


#pragma mark - Events processing

+ (NSMutableDictionary *)eventFromData:(NSDictionary<NSString *, id> *)data
              withAdditionalParserData:(NSDictionary<NSString *, id> *)additionalData {
    
    NSMutableDictionary *event = [NSMutableDictionary new];
    NSString *channel = data[PNEventEnvelope.channel];
    NSString *subscriptionMatch = data[PNEventEnvelope.subscriptionMatch];
    if ([channel isEqualToString:subscriptionMatch]) { subscriptionMatch = nil; }
    event[@"envelope"] = [PNEnvelopeInformation envelopeInformationWithPayload:data];
    event[@"subscription"] = (subscriptionMatch?: channel);
    event[@"channel"] = channel;

    id timeTokenData = (data[PNEventEnvelope.senderTimeToken.key]?:
                        data[PNEventEnvelope.publishTimeToken.key]);
    if ([timeTokenData isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary<NSString *, NSString *> *timeToken = timeTokenData;
        event[@"timetoken"] = @(timeToken[PNEventTimeToken.timeToken].longLongValue);
        event[@"region"] = @(timeToken[PNEventTimeToken.region].longLongValue);
    }
    
    if ([PNChannel isPresenceObject:event[@"subscription"]]) {
        
        [event addEntriesFromDictionary:[self presenceFromData:data[PNEventEnvelope.payload]]];
        event[@"subscription"] = [PNChannel channelForPresence:event[@"subscription"]];
        event[@"channel"] = [PNChannel channelForPresence:event[@"channel"]];
    }
    else {
        
        [event addEntriesFromDictionary:[self messageFromData:data[PNEventEnvelope.payload]
                                     withAdditionalParserData:additionalData]];
    }
    
    return event;
}

+ (NSMutableDictionary *)messageFromData:(id)data 
                withAdditionalParserData:(NSDictionary<NSString *, id> *)additionalData {
    
    BOOL shouldStripMobilePayload = ((NSNumber *)additionalData[@"stripMobilePayload"]).boolValue;
    NSMutableDictionary *message = nil;
    
    // Try decrypt message body if possible.
    if (((NSString *)additionalData[@"cipherKey"]).length){
        
        NSError *decryptionError;
        id decryptedEvent = nil;
        message = [NSMutableDictionary new];
        id dataForDecryption = ([data isKindOfClass:[NSDictionary class]] ? ((NSDictionary *)data)[@"pn_other"] : data);
        if ([dataForDecryption isKindOfClass:[NSString class]]) {
            
            NSData *eventData = [PNAES decrypt:dataForDecryption withKey:additionalData[@"cipherKey"]
                                      andError:&decryptionError];
            NSString *decryptedEventData = nil;
            if (eventData) {
                
                decryptedEventData = [[NSString alloc] initWithData:eventData encoding:NSUTF8StringEncoding];
            }
            
            // In case if after encryption another object has been received client should try to de-serialize
            // it again as JSON object.
            if (decryptedEventData && ![decryptedEventData isEqualToString:dataForDecryption]) {
                
                decryptedEvent = [PNJSON JSONObjectFrom:decryptedEventData withError:nil];
            }
        }
        
        if (decryptionError || !decryptedEvent) {
            
            PNLLogger *logger = [PNLLogger loggerWithIdentifier:kPNClientIdentifier];
            [logger enableLogLevel:PNAESErrorLogLevel];
            DDLogAESError(logger, @"<PubNub::AES> Message decryption error: %@", decryptionError);
            message[@"decryptError"] = @YES;
            message[@"message"] = dataForDecryption;
        }
        else {
            
            if (!shouldStripMobilePayload && [data isKindOfClass:[NSDictionary class]]) {
                
                NSMutableDictionary *mutableData = [data mutableCopy];
                [mutableData removeObjectForKey:@"pn_other"];
                if (![decryptedEvent isKindOfClass:[NSDictionary class]]) {
                    
                    mutableData[@"pn_other"] = decryptedEvent;
                } else { [mutableData addEntriesFromDictionary:decryptedEvent]; }
                decryptedEvent = [mutableData copy];
            }            
            
            message[@"message"] = decryptedEvent;
        }
    }
    else {
        
        if (shouldStripMobilePayload && [data isKindOfClass:[NSDictionary class]] && 
            (data[@"pn_apns"] || data[@"pn_gcm"] || data[@"pn_mpns"])) {
            
            id decomposedMessage = data;
            if (!data[@"pn_other"]) {
                
                NSMutableDictionary *dictionaryData = [data mutableCopy];
                [dictionaryData removeObjectsForKeys:@[@"pn_apns", @"pn_gcm", @"pn_mpns"]];
                decomposedMessage = dictionaryData;
            }
            else { decomposedMessage = data[@"pn_other"]; }
            message = [@{@"message": decomposedMessage} mutableCopy];
        }
        else { message = [@{@"message": data} mutableCopy]; } 
    }
    
    return message;
}

+ (NSMutableDictionary *)presenceFromData:(NSDictionary<NSString *, id> *)data {
    
    NSMutableDictionary *presence = [NSMutableDictionary new];
    
    // Processing common for all presence events data.
    presence[@"presenceEvent"] = (data[PNEventEnvelope.presence.action]?: @"interval");
    presence[@"presence"] = [NSMutableDictionary new];
    presence[@"presence"][@"timetoken"] = data[PNEventEnvelope.presence.timestamp];
    if (data[@"uuid"]) { presence[@"presence"][@"uuid"] = data[PNEventEnvelope.presence.uuid]; }
    
    // Check whether this is not state modification event.
    presence[@"presence"][@"occupancy"] = (data[PNEventEnvelope.presence.occupancy]?: @0);
    if (data[PNEventEnvelope.presence.data]) {
     
        presence[@"presence"][@"state"] = data[PNEventEnvelope.presence.data];
    }
    
    return presence;
}

#pragma mark -


@end
