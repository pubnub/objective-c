//
//  PNOperationStatus.h
// 
//
//  Created by moonlight on 1/15/13.
//
//

#import "PNOperationStatus+Protected.h"
#import "PNError.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub operation status must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNOperationStatus ()


#pragma mark - Properties

@property (nonatomic, getter = isSuccessful) BOOL successful;
@property (nonatomic, strong) PNError *error;
@property (nonatomic, copy) NSString *statusDescription;
@property (nonatomic, strong) NSNumber *timeToken;


@end


#pragma mark - Public interface methods

@implementation PNOperationStatus


#pragma mark - Instance methods

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p) <successful: %@, time token: %@, description: %@, error: %@>",
            NSStringFromClass([self class]), self, self.isSuccessful?@"YES":@"NO", self.timeToken,
            self.statusDescription, self.error];
}

- (NSString *)logDescription {
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    return [NSString stringWithFormat:@"<%@|%@|%@|%@>", @(self.isSuccessful), self.timeToken,
            (self.statusDescription ? self.statusDescription : [NSNull null]),
            (self.error ? [self.error performSelector:@selector(logDescription)] : [NSNull null])];
    #pragma clang diagnostic pop
}

#pragma mark -


@end
