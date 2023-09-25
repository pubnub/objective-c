/**
 * @author Serhii Mamontov
 * @version 4.17.0
 * @since 4.17.0
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PNConfiguration+Private.h"
#import "PubNub+CorePrivate.h"
#import "PNPAMToken+Private.h"
#import "PubNub+PAMPrivate.h"
#import "PNConfiguration.h"
#import "PNHelpers.h"


#pragma mark Public interface implementation

@implementation PubNub (PAM)


#pragma mark - PAM

- (PNPAMToken *)parseAuthToken:(NSString *)token {
    return [PNPAMToken tokenFromBase64String:token forUUID:self.configuration.userID];
}

- (void)setAuthToken:(NSString *)token {
    pn_safe_property_write(self.resourceAccessQueue, ^{
        self.configuration.authToken = token;
    });
}


#pragma mark - Request helper

- (void)addAuthParameter:(PNRequestParameters *)parameters {
    pn_safe_property_read(self.resourceAccessQueue, ^{
        if (self.configuration.authToken.length) {
            [parameters addQueryParameter:self.configuration.authToken forFieldName:@"auth"];
        } else if (self.configuration.authKey.length) {
            [parameters addQueryParameter:self.configuration.authKey forFieldName:@"auth"];
        }
    });
}

#pragma mark -


@end
