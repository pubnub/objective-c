/**
 * @author Serhii Mamontov
 * @version 4.17.0
 * @since 4.17.0
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PubNub+CorePrivate.h"
#import "PNPAMToken+Private.h"
#import "PNConfiguration.h"
#import "PubNub+PAM.h"
#import "PNHelpers.h"


#pragma mark Public interface implementation

@implementation PubNub (PAM)


#pragma mark - PAM

- (PNPAMToken *)parseAuthToken:(NSString *)token {
    return [PNPAMToken tokenFromBase64String:token];
}

- (void)setAuthToken:(NSString *)token {
    self.configuration.authToken = token;
}

#pragma mark -


@end
