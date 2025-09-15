/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNDeleteFileRequest.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Delete file` request private extension.
@interface PNDeleteFileRequest ()


#pragma mark - Properties

/// Unique `file` identifier which has been assigned during `file` upload.
@property(copy, nonatomic) NSString *identifier;

/// Name of channel from which `file` with `name` should be `deleted`.
@property(copy, nonatomic) NSString *channel;

/// Name under which uploaded `file` is stored for `channel`.
@property(copy, nonatomic) NSString *name;


#pragma mark - Initialization and Configuration

/// Initialize `Delete file` request.
///
/// - Parameters:
///   - channel: Name of channel from which `file` with `name` should be `deleted`.
///   - identifier Unique `file` identifier which has been assigned during `file` upload.
///   - name Name under which uploaded `file` is stored for `channel`.
/// - Returns: Initialized `delete file` request.
- (instancetype)initWithChannel:(NSString *)channel identifier:(NSString *)identifier name:(NSString *)name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNDeleteFileRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNDeleteFileOperation;
}

- (TransportMethod)httpMethod {
    return TransportDELETEMethod;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [([super query] ?: @{}) mutableCopy];

    if (self.arbitraryQueryParameters.count) [query addEntriesFromDictionary:self.arbitraryQueryParameters];

    return query.count ? query : nil;
}

- (NSString *)path {
    return PNStringFormat(@"/v1/files/%@/channels/%@/files/%@/%@",
                          self.subscribeKey,
                          [PNString percentEscapedString:self.channel], 
                          self.identifier,
                          [PNString percentEscapedString:self.name]);
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithChannel:(NSString *)channel identifier:(NSString *)identifier name:(NSString *)name {
    return [[self alloc] initWithChannel:channel identifier:identifier name:name];
}

- (instancetype)initWithChannel:(NSString *)channel identifier:(NSString *)identifier name:(NSString *)name {
    if ((self = [super init])) {
        _identifier = [identifier copy];
        _channel = [channel copy];
        _name = [name copy];
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}


#pragma mark - Prepare

- (PNError *)validate {
    if (self.identifier.length == 0) return [self missingParameterError:@"identifier" forObjectRequest:@"Request"];
    if (self.channel.length == 0) return [self missingParameterError:@"channel" forObjectRequest:@"Request"];
    if (self.name.length == 0) return [self missingParameterError:@"name" forObjectRequest:@"Request"];
    
    return nil;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"identifier": self.identifier ?: @"missing",
        @"channel": self.channel ?: @"missing",
        @"name": self.name ?: @"missing"
    }];
    
    if (self.arbitraryQueryParameters) dictionary[@"arbitraryQueryParameters"] = self.arbitraryQueryParameters;
    
    return dictionary;
}

#pragma mark -


@end
