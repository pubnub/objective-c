/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNChannel.h"
#import "PNString.h"
#import "PNArray.h"


#pragma mark Static

/**
 @brief  Reference on suffix which is used to mark channel as presence channel.
 
 @since 4.0
 */
static NSString * const kPubNubPresenceChannelNameSuffix = @"-pnpres";


#pragma mark Interface implementation

@implementation PNChannel


#pragma mark - Lists encoding

+ (NSString *)namesForRequest:(NSArray<NSString *> *)names {
    
    return [self namesForRequest:names defaultString:nil];
}

+ (NSString *)namesForRequest:(NSArray<NSString *> *)names defaultString:(NSString *)defaultString {
    
    NSString *namesForRequest = defaultString;
    if (names.count) {
        
        NSArray *escapedNames = [PNArray mapObjects:names usingBlock:^NSString *(NSString *object){
            
            return [PNString percentEscapedString:object];
        }];
        
        namesForRequest = [escapedNames componentsJoinedByString:@","];
    }
    
    return namesForRequest;
}


#pragma mark - Lists decoding

+ (NSArray<NSString *> *)namesFromRequest:(NSString *)response {

    return [response componentsSeparatedByString:@","];
}


#pragma mark - Subscriber helper

+ (BOOL)isPresenceObject:(NSString *)object {
    
    return [object hasSuffix:kPubNubPresenceChannelNameSuffix];
}

+ (NSString *)channelForPresence:(NSString *)presenceChannel {
    
    return [presenceChannel stringByReplacingOccurrencesOfString:kPubNubPresenceChannelNameSuffix
                                                      withString:@""];
}

+ (NSArray<NSString *> *)presenceChannelsFrom:(NSArray<NSString *> *)names {
    
    NSMutableSet *presenceNames = [[NSMutableSet alloc] initWithCapacity:names.count];
    for (NSString *name in names) {
        
        NSString *targetName = name;
        if (![name hasSuffix:kPubNubPresenceChannelNameSuffix] && ![name hasSuffix:@".*"]) {
            
            targetName = [name stringByAppendingString:kPubNubPresenceChannelNameSuffix];
        }
        [presenceNames addObject:targetName];
    }
    
    return [presenceNames.allObjects copy];
}

+ (NSArray<NSString *> *)objectsWithOutPresenceFrom:(NSArray<NSString *> *)names {
    
    NSMutableSet *filteredNames = [[NSMutableSet alloc] initWithCapacity:names.count];
    for (NSString *name in names) {
        
        if (![name hasSuffix:kPubNubPresenceChannelNameSuffix]) {
            
            [filteredNames addObject:name];
        }
    }
    
    return [filteredNames.allObjects copy];
}

#pragma mark -


@end
