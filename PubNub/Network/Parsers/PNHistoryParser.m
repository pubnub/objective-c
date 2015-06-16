/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNHistoryParser.h"
#import "PubNub+CorePrivate.h"
#import "PNHelpers.h"
#import "PNAES.h"
#import "PNLog.h"


#pragma mark Interface implementation

@implementation PNHistoryParser


#pragma mark - Identification

+ (NSArray *)operations {
    
    return @[@(PNHistoryOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return YES;
}


#pragma mark - Parsing

+ (NSDictionary *)parsedServiceResponse:(id)response withData:(NSDictionary *)additionalData {
    
    // To handle case when response is unexpected for this type of operation processed value sent
    // through 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Array is valid response type for history request.
    if ([response isKindOfClass:[NSArray class]] && [(NSArray *)response count] == 3) {
        
        NSMutableDictionary *data = [@{@"start": (NSArray *)response[1],
                                       @"end": (NSArray *)response[2],
                                       @"messages": [NSMutableArray new]} mutableCopy];
        NSArray *messages = (NSArray *)response[0];
        [messages enumerateObjectsUsingBlock:^(id messageObject,
                                               __unused NSUInteger messageObjectIdx,
                                               __unused BOOL *messageObjectEnumeratorStop) {
            
            NSNumber *timeToken = nil;
            id message = messageObject;
            
            // Check whether history response returned with 'timetoken' or not.
            if ([messageObject isKindOfClass:[NSDictionary class]] &&
                messageObject[@"message"] && messageObject[@"timetoken"]) {
                
                timeToken = messageObject[@"timetoken"];
                message = messageObject[@"message"];
            }
            
            // Try decrypt message if possible.
            if ([message isKindOfClass:[NSString class]] &&
                [(NSString *)additionalData[@"cipherKey"] length]){
                
                NSError *decryptionError;
                NSData *eventData = [PNAES decrypt:message withKey:additionalData[@"cipherKey"]
                                          andError:&decryptionError];
                if (!decryptionError) {
                    
                    message = [[NSString alloc] initWithData:eventData
                                                    encoding:NSUTF8StringEncoding];
                    
                    // In case if decrypted message (because of error suppression) is equal to
                    // original message, there is no need to retry JSON de-serialization.
                    if (![message isEqualToString:messageObject]) {
                        
                        message = [PNJSON JSONObjectFrom:message withError:nil];
                    }
                }
                else {
                    
                    DDLogAESError(@"<PubNub> History entry decryption error: %@", decryptionError);
                    data[@"decryptError"] = @YES;
                }
            }
            
            if (message) {
                
                message = (timeToken ? @{@"message":message, @"timetoken":timeToken} : message);
                [data[@"messages"] addObject:message];
            }
        }];
        processedResponse = [PNDictionary dictionaryWithDictionary:data];
    }
    
    return processedResponse;
}

#pragma mark -


@end
