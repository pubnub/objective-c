/**
 @author Sergey Mamontov
 @since 4.2.2
 @copyright © 2009-2016 PubNub, Inc.
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
        if (clientConfiguration[@"publish-key"] && clientConfiguration[@"subscribe-key"]) {
            
            configuration = [PNConfiguration configurationWithPublishKey:clientConfiguration[@"publish-key"]
                                                            subscribeKey:clientConfiguration[@"subscribe-key"]];
        }
        else {
            
            [NSException raise:@"PubNubIntegration"
                        format:@"Make sure 'publish-key' and 'subscribe-key' specified for PubNub kit in Info.plist."];
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
