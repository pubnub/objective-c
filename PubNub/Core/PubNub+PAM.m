#import "PubNub+PAM.h"
#import "PNConfiguration+Private.h"
#import "PubNub+CorePrivate.h"
#import "PNPAMToken+Private.h"
#import "PNLogEntry+Private.h"
#import "PNStringLogEntry.h"
#import "PNFunctions.h"


#pragma mark Interface implementation

@implementation PubNub (PAM)


#pragma mark - PAM

- (PNPAMToken *)parseAuthToken:(NSString *)token {
    return [PNPAMToken tokenFromBase64String:token forUUID:self.configuration.userID];
}

- (void)setAuthToken:(NSString *)token {
    [self.lock asyncWriteAccessWithBlock:^{
        [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * _Nullable{
            return [PNStringLogEntry entryWithMessage:PNStringFormat(@"Set auth key: %@", token)];
        }];
        
        self.configuration.authToken = token;
    }];
}

#pragma mark -


@end
