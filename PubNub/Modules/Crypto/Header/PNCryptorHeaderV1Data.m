#import "PNCryptorHeaderV1Data.h"


#pragma mark Interface implementation

@implementation PNCryptorHeaderV1Data


#pragma mark - Initialization and configuration

- (instancetype)initWithIdentifier:(NSData *)identifier metadataLength:(NSInteger)length {
    if ((self = [super init])) {
        _identifier = [identifier copy];
        _metadataLength = length;
    }
    
    return self;
}


#pragma mark - Helpers

- (NSString *)description {
    NSString *identifier = self.identifier ? [[NSString alloc] initWithData:self.identifier encoding:NSUTF8StringEncoding]
                                           : @"legacy";
    return [NSString stringWithFormat:@"\n\t- version: 1\n\t- identifier: %@\n\t- metadata length: %@",
            identifier, @(self.metadataLength)];
}

#pragma mark -


@end
