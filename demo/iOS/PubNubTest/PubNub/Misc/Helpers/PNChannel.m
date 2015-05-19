/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNChannel.h"
#import "PNString.h"
#import "PNArray.h"


#pragma mark Interface implementation

@implementation PNChannel


#pragma mark - Lists encoding

+ (NSString *)namesForRequest:(NSArray *)names {
    
    return [self namesForRequest:names defaultString:nil];
}

+ (NSString *)namesForRequest:(NSArray *)names defaultString:(NSString *)defaultString {
    
    NSString *namesForRequest = defaultString;
    if ([names count]) {
        
        NSArray *escapedNames = [PNArray mapObjects:names usingBlock:^NSString *(NSString * object){
            
            return [PNString percentEscapedString:object];
        }];
        namesForRequest = [escapedNames componentsJoinedByString:@","];
    }
    
    return namesForRequest;
}


#pragma mark - Lists decoding

+ (NSArray *)namesFromRequest:(NSString *)response {

    return [response componentsSeparatedByString:@","];
}

#pragma mark -


@end
