#import "PNDownloadFileRequest+Private.h"
#import "PNRequest+Private.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Download file` request private extension.
@interface PNDownloadFileRequest ()


#pragma mark - Information

/// Crypto module which should be used for downloaded data _decryption_.
///
/// This property allows setting up data _decryption_ using a different crypto module than the one set during **PubNub**
/// client instance configuration.
@property(nonatomic, nullable, strong) id<PNCryptoProvider> cryptoModule;

/// Unique `file` identifier which has been assigned during `file` upload.
@property (nonatomic, copy) NSString *identifier;

/// Name of channel from which `file` with `name` should be downloaded.
@property (nonatomic, copy) NSString *channel;

/// Name under which uploaded `file` is stored for `channel`.
@property (nonatomic, copy) NSString *name;


#pragma mark - Initialization and configuration

/// Initialize `file download` request instance.
///
/// - Parameters:
///   - channel: Name of channel from which `file` with `name` should be downloaded.
///   - identifier: Unique `file` identifier which has been assigned during `file` upload.
///   - name: Name under which uploaded `file` is stored for `channel`.
/// - Returns: Initialized `file download` request.
- (instancetype)initWithChannel:(NSString *)channel
                     identifier:(NSString *)identifier
                           name:(NSString *)name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNDownloadFileRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNDownloadFileOperation;
}

- (PNRequestParameters *)requestParameters {
    PNRequestParameters *parameters = [super requestParameters];

    if (self.parametersError) return parameters;

    if (self.channel.length) {
        [parameters addPathComponent:[PNString percentEscapedString:self.channel] forPlaceholder:@"{channel}"];
    } else {
        self.parametersError = [self missingParameterError:@"channel" forObjectRequest:@"Request"];
    }

    if (self.identifier.length) [parameters addPathComponent:self.identifier forPlaceholder:@"{id}"];
    else self.parametersError = [self missingParameterError:@"identifier" forObjectRequest:@"Request"];

    if (self.name.length) {
        [parameters addPathComponent:[PNString percentEscapedString:self.name] forPlaceholder:@"{name}"];
    } else {
        self.parametersError = [self missingParameterError:@"name" forObjectRequest:@"Request"];
    }

    return parameters;
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

#pragma mark -


@end
