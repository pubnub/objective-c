/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNResponse.h"


#pragma mark Protected interface declaration

@interface PNResponse ()


#pragma mark - Information

@property (nonatomic, copy) NSURLRequest *clientRequest;
@property (nonatomic, copy) id data;
@property (nonatomic, copy) NSHTTPURLResponse *response;
@property (nonatomic, copy) NSError *error;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNResponse


#pragma mark - Initialization and configuration

+ (instancetype)responseWith:(NSHTTPURLResponse *)response forRequest:(NSURLRequest *)request
                    withData:(id)data andError:(NSError *)error {

    return [[self alloc] initWith:response forRequest:request withData:data andError:error];
}

- (instancetype)initWith:(NSHTTPURLResponse *)response forRequest:(NSURLRequest *)request
                withData:(id)data andError:(NSError *)error {

    // CHeck whether initialization has been successful or not.
    if ((self = [super init]))  {

        self.response = response;
        self.clientRequest = request;
        self.data = data;
        self.error = error;
    }

    return self;
}

#pragma mark -


@end
