#import "PNResult.h"

@interface PNStatus : PNResult


///------------------------------------------------
/// @name Information
///------------------------------------------------

@property (nonatomic, assign) int category;
@property (nonatomic, assign) BOOL secureConnection;
@property (nonatomic, copy) NSArray *channels;
@property (nonatomic, copy) NSArray *groups;
@property (nonatomic, copy) NSString *clientIdentifier;
@property (nonatomic, copy) NSString *authorizationKey;
@property (nonatomic, copy) NSDictionary *state;
@property (nonatomic, assign) NSUInteger currentTimetoken;
@property (nonatomic, assign) NSUInteger lastTimetoken;


#pragma mark -

@end
