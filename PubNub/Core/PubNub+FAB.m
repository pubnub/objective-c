/**
 @author Sergey Mamontov
 @since 4.2.1
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+FAB.h"
#import "PNConfiguration.h"
#import "Fabric+FABKits.h"


#pragma mark Interface implementation

@implementation PubNub (FAB)


#pragma mark - Initialization and Configuration

+ (instancetype)client {
    
    PNConfiguration *configuration = nil;
    Class fabric = NSClassFromString(@"Fabric");
    if (fabric) {
        
        NSDictionary *clientConfiguration = [fabric configurationDictionaryForKitClass:self];
        
        // Check whether required information passed to kit configuration property list or not.
        if (clientConfiguration[@"pub-key"] && clientConfiguration[@"sub-key"]) {
            
            configuration = [PNConfiguration configurationWithPublishKey:clientConfiguration[@"pub-key"]
                                                            subscribeKey:clientConfiguration[@"sub-key"]];
        }
        else {
            
            [NSException raise:@"PubNubIntegration"
                        format:@"Make sure 'pub-key' and 'sub-key' specified for PubNub kit in Info.plist."];
        }
    }
    else {
        
        [NSException raise:@"PubNubIntegration"
                    format:@"Incomplete project configuration. Fabric framework required."];
    }
    
    return (configuration ? [PubNub clientWithConfiguration:configuration] : nil);
}

#pragma mark - 


@end
