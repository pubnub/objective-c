/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNSubscribeParser.h"
#import "PubNub+CorePrivate.h"
#import "PNLogMacro.h"
#import "PNHelpers.h"
#import "PNAES.h"


#pragma mark Static

/**
 @brief  Cocoa Lumberjack logging level configuration for subscriber results parser.
 
 @since 4.0
 */
static DDLogLevel ddLogLevel = (DDLogLevel)PNAESErrorLogLevel;

/**
 Stores reference on index under which events list is stored.
 */
static NSUInteger const kPNEventsListElementIndex = 0;

/**
 Stores reference on time token element index in response for events.
 */
static NSUInteger const kPNEventTimeTokenElement = 1;

/**
 Stores reference on index under which channels list is stored.
 */
static NSUInteger const kPNEventChannelsElementIndex = 2;

/**
 @brief Stores reference on index under which channels detalization is stored
 
 @discussion In case if under \c kPNEventChannelsElementIndex stored list of channel groups, under 
             this index will be stored list of actual channels from channel group at which event
             fired.
 
 @since 3.7.0
 */
static NSUInteger const kPNEventChannelsDetailsElementIndex = 3;


#pragma mark - Protected interface

@interface PNSubscribeParser ()


#pragma mark - Events processing

/**
 @brief  Parse real-time event received from data object live feed.
 
 @param data           Reference on service-provided data about event.
 @param channel        Reference on channel for which event has been received.
 @param group          Reference on channel group for which event has been received.
 @param additionalData Additional information provided by client to complete parsing.
 
 @return Pre-processed event information (depending on stored data).
 
 @since 4.0
 */
+ (NSMutableDictionary *)eventFromData:(id)data forChannel:(NSString *)channel
                                 group:(NSString *)group
              withAdditionalParserData:(NSDictionary *)additionalData;

/**
 @brief  Parse provided data as new message event.
 
 @param data           Data which should be parsed to required 'message' object format.
 @param additionalData Additional information provided by client to complete parsing.
 
 @return Processed and parsed 'message' object.
 
 @since 4.0
 */
+ (NSMutableDictionary *)messageFromData:(id)data
                withAdditionalParserData:(NSDictionary *)additionalData;

/**
 @brief  Parse provded data as presence event.
 
 @param data Data which should be parsed to required 'presence event' object format.
 
 @return Processed and parsed 'presence event' object.
 
 @since 4.0
 */
+ (NSMutableDictionary *)presenceFromData:(NSDictionary *)data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNSubscribeParser


#pragma mark - Logger

/**
 @brief  Called by Cocoa Lumberjack during initialization.
 
 @return Desired logger level for \b PubNub client main class.
 
 @since 4.0
 */
+ (DDLogLevel)ddLogLevel {
    
    return ddLogLevel;
}

/**
 @brief  Allow modify logger level used by Cocoa Lumberjack with logging macros.
 
 @param logLevel New log level which should be used by logger.
 
 @since 4.0
 */
+ (void)ddSetLogLevel:(DDLogLevel)logLevel {
    
    ddLogLevel = logLevel;
}


#pragma mark - Identification

+ (NSArray *)operations {
    
    return @[@(PNSubscribeOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return YES;
}


#pragma mark - Parsing

+ (NSDictionary *)parsedServiceResponse:(id)response withData:(NSDictionary *)additionalData {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Array will arrive in case of subscription event
    if ([response isKindOfClass:[NSArray class]]) {
        
        NSArray *feedEvents = response[kPNEventsListElementIndex];
        NSNumber *timeToken = @([response[kPNEventTimeTokenElement] longLongValue]);
        NSArray *channels = nil;
        NSArray *groups = nil;
        if ([(NSArray *)response count] > kPNEventChannelsElementIndex) {
            
            channels = [PNChannel namesFromRequest:response[kPNEventChannelsElementIndex]];
        }
        if ([(NSArray *)response count] > kPNEventChannelsDetailsElementIndex) {
            
            groups = [PNChannel namesFromRequest:response[kPNEventChannelsDetailsElementIndex]];
        }
        
        // Checking whether at least one event arrived or not.
        if ([feedEvents count]) {
            
            NSMutableArray *events = [[NSMutableArray alloc] initWithCapacity:[feedEvents count]];
            for (NSUInteger eventIdx = 0; eventIdx < [feedEvents count]; eventIdx++) {
                
                // Fetching remote data object name on which event fired.
                NSString *objectOrGroupName = (eventIdx < [channels count] ? channels[eventIdx] : channels[0]);
                NSString *objectName = ([groups count] > eventIdx ? groups[eventIdx] : nil);
                NSMutableDictionary *event = [self eventFromData:feedEvents[eventIdx]
                                                      forChannel:(objectName?: objectOrGroupName)
                                                           group:(objectName? objectOrGroupName: nil)
                                        withAdditionalParserData:additionalData];
                event[@"timetoken"] = timeToken;
                [events addObject:event];
            }
            feedEvents = [events copy];
        }
        processedResponse = @{@"events":feedEvents,@"timetoken":timeToken};
    }
    
    return processedResponse;
}


#pragma mark - Events processing

+ (NSMutableDictionary *)eventFromData:(id)data forChannel:(NSString *)channel
                                 group:(NSString *)group
              withAdditionalParserData:(NSDictionary *)additionalData {
    
    NSMutableDictionary *event = [NSMutableDictionary new];
    if ([channel length]) {
        
        event[(![group length] ? @"subscribedChannel": @"actualChannel")] = channel;
    }
    if ([group length]) {
        
        event[@"subscribedChannel"] = group;
    }
    
    BOOL isPresenceEvent = [PNChannel isPresenceObject:channel];
    if (![channel length] && [data isKindOfClass:[NSDictionary class]]) {
        
        isPresenceEvent = (data[@"timestamp"] != nil &&
                           (data[@"action"] != nil || data[@"occupancy"] != nil));
    }
    
    if (isPresenceEvent) {
        
        [event addEntriesFromDictionary:[self presenceFromData:data]];
    }
    else {
        
        [event addEntriesFromDictionary:[self messageFromData:data
                                     withAdditionalParserData:additionalData]];
    }
    
    return event;
}

+ (NSMutableDictionary *)messageFromData:(id)data
                withAdditionalParserData:(NSDictionary *)additionalData {
    
    NSMutableDictionary *message = [@{@"message":data} mutableCopy];
    // Try decrypt message body if possible.
    if ([(NSString *)additionalData[@"cipherKey"] length]){
        
        NSError *decryptionError;
        id decryptedEvent = nil;
        if ([data isKindOfClass:[NSString class]]) {
            
            NSData *eventData = [PNAES decrypt:data withKey:additionalData[@"cipherKey"]
                                      andError:&decryptionError];
            NSString *decryptedEventData = nil;
            if (eventData) {
                
                decryptedEventData = [[NSString alloc] initWithData:eventData
                                                           encoding:NSUTF8StringEncoding];
            }
            
            // In case if after encryption another object has been received client
            // should try to de-serialize it again as JSON object.
            if (decryptedEventData && ![decryptedEventData isEqualToString:data]) {
                
                decryptedEvent = [PNJSON JSONObjectFrom:decryptedEventData withError:nil];
            }
        }
        
        if (decryptionError || !decryptedEvent) {
            
            DDLogAESError([self ddLogLevel], @"<PubNub> Message decryption error: %@",
                          decryptionError);
            message[@"decryptError"] = @YES;
        }
        else {
            
            message[@"message"] = decryptedEvent;
        }
    }
    
    return message;
}

+ (NSMutableDictionary *)presenceFromData:(NSDictionary *)data {
    
    NSMutableDictionary *presence = [NSMutableDictionary new];
    
    // Processing common for all presence events data.
    presence[@"presenceEvent"] = (data[@"action"]?: @"interval");
    presence[@"presence"] = [NSMutableDictionary new];
    presence[@"presence"][@"timetoken"] = data[@"timestamp"];
    if (data[@"uuid"]) {
        
        presence[@"presence"][@"uuid"] = data[@"uuid"];
    }
    
    // Check whether this is not state modification event.
    if (![presence[@"presenceEvent"] isEqualToString:@"state-change"]) {
        
        presence[@"presence"][@"occupancy"] = (data[@"occupancy"]?: @0);
    }
    if (data[@"data"]) {
     
        presence[@"presence"][@"state"] = data[@"data"];
    }
    
    return presence;
}

#pragma mark -


@end
