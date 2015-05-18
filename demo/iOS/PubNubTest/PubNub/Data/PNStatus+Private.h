/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNStatus.h"


@interface PNStatus ()


#pragma mark - Information

@property (nonatomic, assign, getter = isError) BOOL error;


#pragma mark - Initialization and configuration

+ (instancetype)statusForRequest:(PNRequest *)request withResponse:(NSHTTPURLResponse *)response
                           error:(NSError *)error andData:(id <NSObject, NSCopying>)data;
- (instancetype)initForRequest:(PNRequest *)request withResponse:(NSHTTPURLResponse *)response
                         error:(NSError *)error andData:(id <NSObject, NSCopying>)data;

- (void)retry;

#pragma mark - 


@end
