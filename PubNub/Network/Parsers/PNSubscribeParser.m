/**
 * @author Serhii Mamontov
 * @version 4.9.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNSubscribeParser.h"
#import "PNEnvelopeInformation.h"
#import "PubNub+CorePrivate.h"
#import "PNCryptoProvider.h"
#import "PNConstants.h"
#import "PNLogMacro.h"
#import "PNLLogger.h"
#import "PNHelpers.h"
#import "PNAES.h"


#pragma mark Static

/**
 * @brief Key under which request status is stored.
 */
static NSString * const kPNResponseStatusKey = @"s";

/**
 * @brief Key under which service advisory information stored.
 */
static NSString * const kPNResponseAdvisoryKey = @"a";

/**
 * @brief Key under which stored information about when event has been triggered by server and from
 * which region.
 */
static NSString * const kPNResponseEventTimeKey = @"t";

/**
 * @brief Key under which list of events is stored.
 */
static NSString * const kPNResponseEventsListKey = @"m";


#pragma mark - Structures

/**
 * @brief Structure with keys under which stored information about when event has been triggered and
 * in which region (to which region client subscribed at this moment).
 */
struct PNEventTimeTokenStructure {
    /**
     * @brief Key under which stored high precision time token (on linuxtimestamp in case of
     * presence events) on when event has been triggered.
     */
    __unsafe_unretained NSString *timeToken;
    
    /**
     * @brief Key under which stored numeric region identifier.
     */
    __unsafe_unretained NSString *region;
} PNEventTimeToken = {
    .timeToken = @"t",
    .region = @"r"
};

/**
 * @brief Structure with keys under which stored information about newly uploaded file.
 *
 * @since 4.15.0
 */
struct PNFileMessageDataStructure {
    /**
     * @brief Key under which stored unique file identifier
     */
    __unsafe_unretained NSString *identifier;
    
    /**
     * @brief Key under which stored name under which file has been stored remotely.
     */
    __unsafe_unretained NSString *filename;
} PNFileMessageData = {
    .identifier = @"id",
    .filename = @"name"
};

/**
 * @brief Overall real-time event format.
 */
struct PNEventEnvelopeStructure {
    /**
     * @brief Describes structure to represent local time token (unixtimestamp casted to high
     * precision).
     */
    struct {
        /**
         * @brief Key under which sender time token information is stored.
         */
        __unsafe_unretained NSString *key;
        
        /**
         * @brief Time token information.
         */
        struct PNEventTimeTokenStructure token;
    } senderTimeToken;
    
    /**
     * @brief Represent time when message has been received by \b PubNub  service and passed to
     * subscribers.
     */
    struct {
        /**
         * @brief Key under which publish time token information is stored.
         */
        __unsafe_unretained NSString *key;
        
        /**
         * @brief Time token information.
         */
        struct PNEventTimeTokenStructure token;
    } publishTimeToken;
    
    /**
     * @brief Key under which actual channel name on which event has been triggered.
     */
    __unsafe_unretained NSString *channel;
    
    /**
     * @brief Key under which stored name of the object on which client subscribed at this moment
     * (can be: \c channel, \c group or \c wildcard).
     */
    __unsafe_unretained NSString *subscriptionMatch;
    
    /**
     * @brief Key under which stored event object data (can be user message for publish message or
     * presence dictionary with information about event).
     */
    __unsafe_unretained NSString *payload;
    
    struct {
        /**
         * @brief Key under which stored information about presence event type.
         */
        __unsafe_unretained NSString *action;
        
        /**
         * @brief Key under which stores information about client state on channel which triggered
         * presence event.
         */
        __unsafe_unretained NSString *data;
        
        /**
         * @brief Key under which stored information about occupancy in channel which triggered
         * event.
         */
        __unsafe_unretained NSString *occupancy;
        
        /**
         * @brief Key under which stored event triggering time token (unixtimestamp).
         */
        __unsafe_unretained NSString *timestamp;
        
        /**
         * @brief Unique client identifier which caused presence event triggering.
         */
        __unsafe_unretained NSString *uuid;
        
        /**
         * @brief Key under which stored difference in active subscribers (UUIDs) since last
         * presence event has been triggered.
         *
         * @discussion Presence service after specified number of channel participants will send
         * presence events at configured intervals and provide list of subscribers which joined
         * since last interval or regular presence event has been sent.
         *
         * @since 4.5.16
         */
        __unsafe_unretained NSString *joined;
        
        /**
         * @brief Key under which stored difference in active subscribers (UUIDs) since last
         * presence event has been triggered.
         *
         * @discussion Presence service after specified number of channel participants will send
         * presence events at configured intervals and provide list of subscribers which leaved
         * since last interval or regular presence event has been sent.
         *
         * @since 4.5.16
         */
        __unsafe_unretained NSString *leaved;
        
        /**
         * @brief Key under which stored difference in active subscribers (UUIDs) since last
         * presence event has been triggered.
         *
         * @discussion Presence service after specified number of channel participants will send
         * presence events at configured intervals and provide list of subscribers which leaved by
         * timeout since last interval or regular presence event has been sent.
         *
         * @since 4.5.16
         */
        __unsafe_unretained NSString *timeouted;
    } presence;
    
    struct {
        /**
         * @brief Key under which stored object event (\c create / \c update / \c delete).
         */
        __unsafe_unretained NSString *event;
        /**
         * @brief Key under which stored event source name (service which triggered event).
         */
        __unsafe_unretained NSString *source;
        
        /**
         * @brief Key under which stored type of object for which \c action has been triggered
         * (\c uuid / \c channel / \c membership).
         */
        __unsafe_unretained NSString *type;
        /**
         * @brief Key under which version of service which triggered event.
         */
        __unsafe_unretained NSString *version;
        
        /**
         * @brief Key under which stored object's event data.
         */
        __unsafe_unretained NSString *data;
    } object;
    
    struct {
        /**
         * @brief Key under which stored message which has been sent along with file.
         *
         * @since 4.15.0
         */
        __unsafe_unretained NSString *message;
        
        /**
         * @brief Uploaded file information.
         *
         * @since 4.15.0
         */
        struct PNFileMessageDataStructure file;
    } file;
} PNEventEnvelope = {
    .senderTimeToken = { .key = @"o" },
    .publishTimeToken = { .key = @"p" },
    .channel = @"c",
    .subscriptionMatch = @"b",
    .payload = @"d",
    .presence = { .action = @"action", .data = @"data", .occupancy = @"occupancy",
        .timestamp = @"timestamp", .uuid = @"uuid", .joined = @"join", .leaved = @"leave", 
        .timeouted = @"timeout"
    },
    .object = {
        .event = @"event",
        .source = @"source",
        .type = @"type",
        .version = @"version",
        .data = @"data"
    },
    .file = {
        .message = @"message",
        .file = @"file"
    }
};


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface

@interface PNSubscribeParser ()


#pragma mark - Events processing

/**
 * @brief Parse real-time event received from data object live feed.
 *
 * @param data Service-provided data about event.
 * @param additionalData Additional information provided by client to complete parsing.
 *
 * @return Pre-processed event information (depending on stored data).
 *
 * @since 4.3.0
 */
+ (NSMutableDictionary *)eventFromData:(NSDictionary<NSString *, id> *)data
              withAdditionalParserData:(nullable NSDictionary<NSString *, id> *)additionalData;

/**
 * @brief Parse provided data as new message event.
 *
 * @param data Data which should be parsed to required 'message' object format.
 * @param additionalData Additional information provided by client to complete parsing.
 *
 * @return Processed and parsed 'message' object.
 */
+ (NSMutableDictionary *)messageFromData:(id)data
                withAdditionalParserData:(nullable NSDictionary<NSString *, id> *)additionalData;

/**
 * @brief Parse provided data as \c object event.
 *
 * @param data Data which should be parsed to required 'object event' object format.
 *
 * @return Processed and parsed 'object event' object.
 *
 * @since 4.10.0
 */
+ (NSMutableDictionary *)objectFromData:(NSDictionary<NSString *, id> *)data;

/**
 * @brief Parse provided data as \c file event.
 *
 * @param data Data which should be parsed to required 'file event' object format.
 * @param additionalData Additional information provided by client to complete parsing.
 *
 * @return Processed and parsed 'file event' object.
 *
 * @since 4.15.0
 */
+ (NSMutableDictionary *)fileFromData:(NSDictionary<NSString *, id> *)data
             withAdditionalParserData:(NSDictionary<NSString *, id> *)additionalData;

/**
 * @brief Parse provided data as \c action event.
 *
 * @param data Data which should be parsed to required 'action event' object format.
 * @param envelope Object with additional information about parsed \c data.
 *
 * @return Processed and parsed 'action event' object.
 *
 * @since 4.11.0
 */
+ (NSMutableDictionary *)actionFromData:(NSDictionary<NSString *, id> *)data
                           withEnvelope:(PNEnvelopeInformation *)envelope;

/**
 * @brief Parse provided data as presence event.
 *
 * @param data Data which should be parsed to required 'presence event' object format.
 *
 * @return Processed and parsed 'presence event' object.
 */
+ (NSMutableDictionary *)presenceFromData:(NSDictionary<NSString *, id> *)data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSubscribeParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    return @[ @(PNSubscribeOperation) ];
}

+ (BOOL)requireAdditionalData {
    return YES;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response
                                               withData:(NSDictionary<NSString *, id> *)additionalData {
    
    NSDictionary *processedResponse = nil;
    if ([response isKindOfClass:[NSDictionary class]]) {
        NSDictionary<NSString *, NSString *> *timeTokenDictionary = response[kPNResponseEventTimeKey];
        NSNumber *timeToken = @(timeTokenDictionary[PNEventTimeToken.timeToken].longLongValue);
        NSNumber *region = @(timeTokenDictionary[PNEventTimeToken.region].longLongValue);
        NSArray<NSDictionary *> *feedEvents = response[kPNResponseEventsListKey];

        if (feedEvents.count) {
            NSMutableArray<NSDictionary *> *events = [[NSMutableArray alloc] initWithCapacity:feedEvents.count];

            for (NSUInteger eventIdx = 0; eventIdx < [feedEvents count]; eventIdx++) {
                NSMutableDictionary *event = [self eventFromData:feedEvents[eventIdx]
                                        withAdditionalParserData:additionalData];

                if (!event[@"timetoken"]) {
                    event[@"timetoken"] = timeToken;
                }

                [events addObject:event];
            }

            feedEvents = [events copy];
        }

        processedResponse = @{ @"events": feedEvents, @"timetoken": timeToken, @"region": region };
    }
    
    return processedResponse;
}


#pragma mark - Events processing

+ (NSMutableDictionary *)eventFromData:(NSDictionary<NSString *, id> *)data
              withAdditionalParserData:(NSDictionary<NSString *, id> *)additionalData {
    
    NSMutableDictionary *event = [NSMutableDictionary new];
    NSString *channel = data[PNEventEnvelope.channel];
    NSString *subscriptionMatch = data[PNEventEnvelope.subscriptionMatch];

    if ([channel isEqualToString:subscriptionMatch]) {
        subscriptionMatch = nil;
    }

    event[@"envelope"] = [PNEnvelopeInformation envelopeInformationWithPayload:data];

    event[@"subscription"] = (subscriptionMatch ?: channel);
    event[@"channel"] = channel;
    PNMessageType messageType = ((PNEnvelopeInformation *)event[@"envelope"]).messageType;
    BOOL isEncryptionSupported = messageType == PNRegularMessageType ||
                                 messageType == PNFileMessageType;

    id timeTokenData = (data[PNEventEnvelope.senderTimeToken.key] ?:
                        data[PNEventEnvelope.publishTimeToken.key]);

    if ([timeTokenData isKindOfClass:[NSDictionary class]]) {
        NSDictionary<NSString *, NSString *> *timeToken = timeTokenData;
        event[@"timetoken"] = @(timeToken[PNEventTimeToken.timeToken].longLongValue);
        event[@"region"] = @(timeToken[PNEventTimeToken.region].longLongValue);
    }
    
    if ([PNChannel isPresenceObject:event[@"subscription"]] || 
        [PNChannel isPresenceObject:event[@"channel"]]) {
        
        [event addEntriesFromDictionary:[self presenceFromData:data[PNEventEnvelope.payload]]];
        event[@"subscription"] = [PNChannel channelForPresence:event[@"subscription"]];
        event[@"channel"] = [PNChannel channelForPresence:event[@"channel"]];
    } else if (messageType == PNObjectMessageType) {
        NSDictionary *objectData = [self objectFromData:data[PNEventEnvelope.payload]];
        
        if (objectData.count) {
            [event addEntriesFromDictionary:objectData];
        }
    } else if (messageType == PNMessageActionType) {
        NSDictionary *action = [self actionFromData:data[PNEventEnvelope.payload]
                                       withEnvelope:event[@"envelope"]];
        
        [event addEntriesFromDictionary:action];
    } else if (messageType == PNFileMessageType) {
        NSDictionary *parserData = isEncryptionSupported ? additionalData : nil;
        NSDictionary *fileMessage = [self fileFromData:data[PNEventEnvelope.payload]
                              withAdditionalParserData:parserData];
        
        if (fileMessage.count) {
            [event addEntriesFromDictionary:fileMessage];
        }
    } else {
        NSDictionary *parserData = isEncryptionSupported ? additionalData : nil;

        [event addEntriesFromDictionary:[self messageFromData:data[PNEventEnvelope.payload]
                                     withAdditionalParserData:parserData]];
    }
    
    return event;
}

+ (NSMutableDictionary *)messageFromData:(id)data 
                withAdditionalParserData:(NSDictionary<NSString *, id> *)additionalData {

    NSMutableDictionary *message = nil;

    if (additionalData[@"cryptoModule"]) {
        id<PNCryptoProvider> cryptoModule = additionalData[@"cryptoModule"];
        BOOL isDictionary = [data isKindOfClass:[NSDictionary class]];
        NSError *decryptionError;
        id decryptedEvent = nil;
        message = [NSMutableDictionary new];
        id encryptedData = isDictionary ? ((NSDictionary *)data)[@"pn_other"] : data;

        if ([encryptedData isKindOfClass:[NSString class]]) {
            NSCharacterSet *trimCharSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
            encryptedData = [PNString base64DataFrom:[encryptedData stringByTrimmingCharactersInSet:trimCharSet]];
            PNResult<NSData *> *decryptResult = [cryptoModule decryptData:encryptedData];
            NSString *decryptedEventData = nil;

            if (decryptResult.isError) decryptionError = decryptResult.error;
            else decryptedEventData = [[NSString alloc] initWithData:decryptResult.data encoding:NSUTF8StringEncoding];

            if (decryptedEventData && ![decryptedEventData isEqualToString:encryptedData]) {
                decryptedEvent = [PNJSON JSONObjectFrom:decryptedEventData withError:nil];
            }
        }
        
        if (decryptionError || !decryptedEvent) {
            PNLLogger *logger = [PNLLogger loggerWithIdentifier:kPNClientIdentifier];
#ifndef PUBNUB_DISABLE_LOGGER
            [logger enableLogLevel:PNAESErrorLogLevel];
#endif // PUBNUB_DISABLE_LOGGER
            PNLogAESError(logger, @"<PubNub::AES> Message decryption error: %@", decryptionError);
            message[@"decryptError"] = @YES;
            message[@"message"] = isDictionary ? ((NSDictionary *)data)[@"pn_other"] : data;
        } else {
            if (isDictionary) {
                NSMutableDictionary *mutableData = [(NSDictionary *)data mutableCopy];
                [mutableData removeObjectForKey:@"pn_other"];

                if (![decryptedEvent isKindOfClass:[NSDictionary class]]) {
                    mutableData[@"pn_other"] = decryptedEvent;
                } else {
                    [mutableData addEntriesFromDictionary:decryptedEvent];
                }

                decryptedEvent = [mutableData copy];
            }            
            
            message[@"message"] = decryptedEvent;
        }
    } else {
        message = [@{ @"message": data } mutableCopy];
    }
    
    return message;
}

+ (NSMutableDictionary *)objectFromData:(NSDictionary<NSString *, id> *)data {
    NSString *sourceVersion = data[PNEventEnvelope.object.version];
    NSMutableDictionary *object = [NSMutableDictionary new];
    
    if (![data[PNEventEnvelope.object.source] isEqualToString:@"objects"]) {
        return object;
    }
    
    // Check whether minimum supported event source version is present (at moment of release - 2).
    if ([sourceVersion componentsSeparatedByString:@"."].firstObject.integerValue != 2) {
        return object;
    }
    
    NSArray *eventKeys = @[
        PNEventEnvelope.object.event,
        PNEventEnvelope.object.source,
        PNEventEnvelope.object.type,
        PNEventEnvelope.object.version
    ];
    [object addEntriesFromDictionary:[data dictionaryWithValuesForKeys:eventKeys]];
    
    if ([data[PNEventEnvelope.object.type] isEqualToString:@"membership"]) {
        object[@"membership"] = data[@"data"];
    }
    
    if ([data[PNEventEnvelope.object.type] isEqualToString:@"uuid"]) {
        object[@"uuid"] = data[@"data"];
    }
    
    if ([data[PNEventEnvelope.object.type] isEqualToString:@"channel"]) {
        object[@"channel"] = data[@"data"];
    }
    
    return object;
}

+ (NSMutableDictionary *)fileFromData:(NSDictionary<NSString *, id> *)data
             withAdditionalParserData:(NSDictionary<NSString *, id> *)additionalData {
    
    NSMutableDictionary *fileMessage = [NSMutableDictionary new];
    NSDictionary *messagePayload = [self messageFromData:data
                                withAdditionalParserData:additionalData];
    
    if (!((NSNumber *)messagePayload[@"decryptError"]).boolValue) {
        fileMessage[@"message"] = [messagePayload valueForKeyPath:@"message.message"];
        fileMessage[@"file"] = [messagePayload valueForKeyPath:@"message.file"];
    } else {
        fileMessage = [messagePayload mutableCopy];
    }
    
    return fileMessage;
}

+ (NSMutableDictionary *)actionFromData:(NSDictionary<NSString *, id> *)data
                           withEnvelope:(PNEnvelopeInformation *)envelope {
    
    NSMutableDictionary *action = [@{ @"action": data[@"data"] } mutableCopy];
    NSString *messageTimetoken = action[@"action"][@"messageTimetoken"];
    NSString *actionTimetoken = action[@"action"][@"actionTimetoken"];
    
    action[@"action"][@"messageTimetoken"] = @(messageTimetoken.longLongValue);
    action[@"action"][@"actionTimetoken"] = @(actionTimetoken.longLongValue);
    action[@"action"][@"uuid"] = envelope.senderIdentifier;
    
    NSArray *eventKeys = @[@"event", @"source", @"version"];
    [action addEntriesFromDictionary:[data dictionaryWithValuesForKeys:eventKeys]];
    
    return action;
}

+ (NSMutableDictionary *)presenceFromData:(NSDictionary<NSString *, id> *)data {
    NSMutableDictionary *presence = [NSMutableDictionary new];
    
    // Processing common for all presence events data.
    presence[@"presenceEvent"] = (data[PNEventEnvelope.presence.action] ?: @"interval");
    presence[@"presence"] = [NSMutableDictionary new];
    presence[@"presence"][@"timetoken"] = data[PNEventEnvelope.presence.timestamp];

    if (data[@"uuid"]) {
        presence[@"presence"][@"uuid"] = data[PNEventEnvelope.presence.uuid];
    }

    presence[@"presence"][@"occupancy"] = (data[PNEventEnvelope.presence.occupancy] ?: @0);

    if (data[PNEventEnvelope.presence.data]) {
        presence[@"presence"][@"state"] = data[PNEventEnvelope.presence.data];
    }
    
    if ([presence[@"presenceEvent"] isEqualToString:@"interval"]) {
        if (data[PNEventEnvelope.presence.joined]) {
            presence[@"presence"][@"join"] = data[PNEventEnvelope.presence.joined];
        }
        
        if (data[PNEventEnvelope.presence.leaved]) {
            presence[@"presence"][@"leave"] = data[PNEventEnvelope.presence.leaved];
        }
        
        if (data[PNEventEnvelope.presence.timeouted]) {
            presence[@"presence"][@"timeout"] = data[PNEventEnvelope.presence.timeouted];
        }
    }
    
    return presence;
}

#pragma mark -


@end
