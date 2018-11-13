/**
 @author Sergey Mamontov
 @since 4.0.5
 @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNClientInformation.h"
#import "PNConstants.h"


#pragma mark Interface implementation

@implementation PNClientInformation


#pragma mark - Information

- (NSString *)version {
    
    return kPNLibraryVersion;
}

- (NSString *)commit {
    
    return kPNCommit;
}

#pragma mark -


@end
