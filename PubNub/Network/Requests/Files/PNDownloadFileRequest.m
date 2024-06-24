#import "PNDownloadFileRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Download file` request private extension.
@interface PNDownloadFileRequest ()


#pragma mark - Properties

/// Crypto module which should be used for downloaded data _decryption_.
///
/// This property allows setting up data _decryption_ using a different crypto module than the one set during **PubNub**
/// client instance configuration.
@property(strong, nullable, nonatomic) id<PNCryptoProvider> cryptoModule;

/// Unique `file` identifier which has been assigned during `file` upload.
@property(copy, nonatomic) NSString *identifier;

/// Name of channel from which `file` with `name` should be downloaded.
@property(copy, nonatomic) NSString *channel;

/// Name under which uploaded `file` is stored for `channel`.
@property(copy, nonatomic) NSString *name;


#pragma mark - Initialization and configuration

/// Initialize `file download` request instance.
///
/// - Parameters:
///   - channel: Name of channel from which `file` with `name` should be downloaded.
///   - identifier: Unique `file` identifier which has been assigned during `file` upload.
///   - name: Name under which uploaded `file` is stored for `channel`.
/// - Returns: Initialized `file download` request.
- (instancetype)initWithChannel:(NSString *)channel identifier:(NSString *)identifier name:(NSString *)name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNDownloadFileRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNDownloadFileOperation;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [NSMutableDictionary new];
    
    if (self.arbitraryQueryParameters.count) [query addEntriesFromDictionary:self.arbitraryQueryParameters];
    
    return query.count ? query : nil;
}

- (BOOL)responseAsFile {
    return YES;
}

- (NSString *)path {
    return PNStringFormat(@"/v1/files/%@/channels/%@/files/%@/%@",
                          self.subscribeKey,
                          [PNString percentEscapedString:self.channel],
                          self.identifier,
                          [PNString percentEscapedString:self.name]);
}


#pragma mark - Initialization & Configuration

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
    if (self.channel.length == 0) return [self missingParameterError:@"channel" forObjectRequest:@"Request"];
    if (self.identifier.length == 0) return [self missingParameterError:@"identifier" forObjectRequest:@"Request"];
    if (self.name.length == 0) return [self missingParameterError:@"name" forObjectRequest:@"Request"];
    
    return nil;
}

#pragma mark -


@end
