//
//  NSDate+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 8/4/13.
//
//

#import <Foundation/Foundation.h>


// ARC check
#if !__has_feature(objc_arc)
#error PubNub date category must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark - Public category interface implementation

@implementation NSDate (PNAdditions)

- (NSString *)logDescription {
    
    return [NSString stringWithFormat:@"<%@>", @([self timeIntervalSince1970] * 1000)];
}

#pragma mark -


@end
