#import <objc/runtime.h>
#import "NSInputStream+PNCrypto.h"


#pragma mark Static

/// Key which is used to store associated stream overall data length.
static void *kPNStreamDataLengthKey = &kPNStreamDataLengthKey;


#pragma mark Interface implementation

@implementation NSInputStream (PNCrypto)


#pragma mark - Information

- (NSUInteger)pn_dataLength {
    return ((NSNumber *)objc_getAssociatedObject(self, kPNStreamDataLengthKey)).unsignedIntegerValue;
}

- (void)setPn_dataLength:(NSUInteger)pn_dataLength {
    objc_setAssociatedObject(self, kPNStreamDataLengthKey, @(pn_dataLength), OBJC_ASSOCIATION_RETAIN);
}

#pragma mark -


@end
