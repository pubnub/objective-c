#import "PNGenerateFileDownloadURLRequest.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `File upload URL` request private extension.
@interface PNGenerateFileDownloadURLRequest ()


#pragma mark - Properties

/// Unique file identifier.
@property(strong, nullable, nonatomic, readonly) NSString *fileIdentifier;

/// Name which will be used to store user data on server.
@property(strong, nullable, nonatomic, readonly) NSString *filename;

/// Name of the channel where file with ``fileIdentifier`` ID has been shared.
@property(strong, nullable, nonatomic, readonly) NSString *channel;


#pragma mark - Initialization and Configuration

/// Initialize `File download URL generate` request.
///
/// - Parameters:
///   - channel: Name of the channel where file with ``fileIdentifier`` ID has been shared.
///   - fileId: Unique file identifier.
///   - fileName: Name which will be used to store user data on server.
/// - Returns: Initialized `File download URL generate` request.
- (instancetype)initWithChannel:(NSString *)channel fileIdentifier:(NSString *)fileId fileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNGenerateFileDownloadURLRequest


#pragma mark - Propeties

- (TransportMethod)httpMethod {
    return TransportLOCALMethod;
}

- (NSString *)path {
    return PNStringFormat(@"/v1/files/%@/channels/%@/files/%@/%@",
                          self.subscribeKey, 
                          [PNString percentEscapedString:self.channel],
                          self.fileIdentifier,
                          [PNString percentEscapedString:self.filename]);
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithChannel:(NSString *)channel fileIdentifier:(NSString *)fileId fileName:(NSString *)fileName {
    return [[self alloc] initWithChannel:channel fileIdentifier:fileId fileName:fileName];
}

- (instancetype)initWithChannel:(NSString *)channel fileIdentifier:(NSString *)fileId fileName:(NSString *)fileName {
    if ((self = [super init])) {
        _fileIdentifier = [fileId copy];
        _filename = [fileName copy];
        _channel = [channel copy];
    }

    return self;
}

#pragma mark -


@end
