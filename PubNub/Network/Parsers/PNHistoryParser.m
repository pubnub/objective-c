/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNHistoryParser.h"
#import "PubNub+CorePrivate.h"
#import "PNLogMacro.h"
#import "PNHelpers.h"
#import "PNAES.h"
#import "PNLog.h"


#pragma mark CocoaLumberjack logging support

/**
 @brief  Cocoa Lumberjack logging level configuration for history parser.
 
 @since 4.0
 */
static DDLogLevel ddLogLevel = (DDLogLevel)PNAESErrorLogLevel;


#pragma mark - Interface implementation

@implementation PNHistoryParser


#pragma mark - Logger

+ (DDLogLevel)ddLogLevel {
    
    return ddLogLevel;
}

+ (void)ddSetLogLevel:(DDLogLevel)logLevel {
    
    ddLogLevel = logLevel;
}


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    
    return @[@(PNHistoryOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return YES;
}


#pragma mark - Parsing

+ (nullable NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response 
   withData:(nullable NSDictionary<NSString *, id> *)additionalData {
    
    // To handle case when response is unexpected for this type of operation processed value sent through 
    // 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Array is valid response type for history request.
    if ([response isKindOfClass:[NSArray class]] && ((NSArray *)response).count == 3) {
        
        NSMutableDictionary *data = [@{@"start": (NSArray *)response[1], @"end": (NSArray *)response[2],
                                       @"messages": [NSMutableArray new]} mutableCopy];
        NSArray *messages = (NSArray *)response[0];
        [messages enumerateObjectsUsingBlock:^(id messageObject, __unused NSUInteger messageObjectIdx,
                                               __unused BOOL *messageObjectEnumeratorStop) {
            
            NSNumber *timeToken = nil;
            id message = messageObject;
            
            // Check whether history response returned with 'timetoken' or not.
            if ([messageObject isKindOfClass:[NSDictionary class]] &&messageObject[@"message"] && 
                messageObject[@"timetoken"]) {
                
                timeToken = messageObject[@"timetoken"];
                message = messageObject[@"message"];
                messageObject = message;
            }
            
            // Try decrypt message if possible.
            if (((NSString *)additionalData[@"cipherKey"]).length){
                
                NSError *decryptionError;
                id decryptedMessage = nil;
                id dataForDecryption = ([message isKindOfClass:[NSDictionary class]] ? ((NSDictionary *)message)[@"pn_other"] : message);
                if ([dataForDecryption isKindOfClass:[NSString class]]) {
                    
                    NSData *eventData = [PNAES decrypt:dataForDecryption withKey:additionalData[@"cipherKey"]
                                              andError:&decryptionError];
                    NSString *decryptedMessageString = nil;
                    if (eventData) {
                        
                        decryptedMessageString = [[NSString alloc] initWithData:eventData
                                                                       encoding:NSUTF8StringEncoding];
                    }
                    
                    // In case if decrypted message (because of error suppression) is equal to original 
                    // message, there is no need to retry JSON de-serialization.
                    if (decryptedMessageString && ![decryptedMessageString isEqualToString:dataForDecryption]) {
                        
                        decryptedMessage = [PNJSON JSONObjectFrom:decryptedMessageString withError:nil];
                    }
                }
                
                if (decryptionError || !decryptedMessage) {
                    
                    DDLogAESError([self ddLogLevel], @"<PubNub::AES> History entry decryption error: %@",
                                  decryptionError);
                    data[@"decryptError"] = @YES;
                    
                    // Restore message to original form.
                    message = messageObject;
                }
                else { message = decryptedMessage; }
            }
            
            if (message) {
                
                if ([message isKindOfClass:[NSDictionary class]] &&
                    (message[@"pn_apns"] || message[@"pn_gcm"] || message[@"pn_mpns"])) {
                    
                    id decomposedMessage = message;
                    if (!message[@"pn_other"]) {
                        
                        NSMutableDictionary *dictionaryData = [message mutableCopy];
                        [dictionaryData removeObjectsForKeys:@[@"pn_apns", @"pn_gcm", @"pn_mpns"]];
                        decomposedMessage = dictionaryData;
                    }
                    else { decomposedMessage = message[@"pn_other"]; }
                    message = decomposedMessage;
                }
                
                message = (timeToken ? @{@"message":message, @"timetoken":timeToken} : message);
                [data[@"messages"] addObject:message];
            }
        }];
        processedResponse = data;
    }
    
    return processedResponse;
}

#pragma mark -


@end
