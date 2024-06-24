#import "PubNub+PAM.h"
#import "PNConfiguration+Private.h"
#import "PubNub+CorePrivate.h"
#import "PNPAMToken+Private.h"


#pragma mark Interface implementation

@implementation PubNub (PAM)


#pragma mark - PAM

- (PNPAMToken *)parseAuthToken:(NSString *)token {
    return [PNPAMToken tokenFromBase64String:token forUUID:self.configuration.userID];
}

- (void)setAuthToken:(NSString *)token {
    [self.lock asyncWriteAccessWithBlock:^{
        self.configuration.authToken = token;
    }];
}

#pragma mark -


@end
