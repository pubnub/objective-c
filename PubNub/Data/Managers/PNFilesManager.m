#import "PNFilesManager.h"
#import "PNDictionaryLogEntry.h"
#import "NSInputStream+PNURL.h"
#import "PubNub+CorePrivate.h"
#import "PNFunctions.h"
#import "PNError.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

/// Files manager private extension.
@interface PNFilesManager ()


#pragma mark - Properties

/// Crypto module for data processing.
///
/// **PubNub** client uses this instance to _encrypt_ and _decrypt_ data that has been sent and received from the
/// **PubNub** network.
@property(nonatomic, nullable, strong) id<PNCryptoProvider> cryptoModule;

/// **PubNub** client logger instance which can be used to add additional logs.
@property(weak, nonatomic, readonly) PNLoggerManager *logger;


#pragma mark - Initialization and configuration

/// Initialize files manager.
///
/// - Parameter client: **PubNub** client for which files manager should be created.
/// - Returns: Initialized files manager instance.
- (instancetype)initWithClient:(PubNub *)client;


#pragma mark - Helpers

/// Create data download error using information received from the service.
///
/// - Parameter error: Download request processing error.
/// - Returns: `Error` object with detailed information about file download error.
- (NSError *)downloadErrorForError:(nullable NSError *)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNFilesManager


#pragma mark - Initialization and Configuration

+ (instancetype)filesManagerForClient:(PubNub *)client {
    return [[self alloc] initWithClient:client];
}

- (instancetype)initWithClient:(PubNub *)client {
    if ((self = [super init])) {
        _cryptoModule = client.configuration.cryptoModule;
        _logger = client.logger;
    }
    
    return self;
}


#pragma mark - Download data

- (void)handleDownloadedFileAtURL:(NSURL *)location 
                     withStoreURL:(NSURL *)localURL
                     cryptoModule:(nullable id<PNCryptoProvider>)cryptoModule
                       completion:(void(^)( NSURL *location, NSError *error))block {
    if (!location) block(nil, nil);
    
    cryptoModule = cryptoModule ?: self.cryptoModule;
    BOOL temporary = !localURL;

    if (temporary) {
        localURL = [NSURL URLWithString:[NSString pathWithComponents:@[NSTemporaryDirectory(), [NSUUID UUID].UUIDString]]];
    }

    if (!localURL.isFileURL) localURL = [NSURL fileURLWithPath:localURL.path];

    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSURL *storeURL = temporary ? location : localURL;
    NSError *fileMoveError = nil;

    if (!temporary && [storeURL checkResourceIsReachableAndReturnError:nil]) {
        [fileManager removeItemAtURL:storeURL error:&fileMoveError];
    }

    if (cryptoModule) {  
        if (temporary) storeURL = [storeURL URLByAppendingPathExtension:@"dec"];
    } else if (!fileMoveError && !temporary) [fileManager moveItemAtURL:location toURL:storeURL error:&fileMoveError];

    if (fileMoveError) {
        NSError *error = [self downloadErrorForError:fileMoveError];
        block(location, error);
    } else if(cryptoModule) {
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:location.path error:nil];
        NSUInteger fileSize = ((NSNumber *)[fileAttributes objectForKey:NSFileSize]).unsignedIntegerValue;
        NSInputStream *sourceStream = [NSInputStream inputStreamWithURL:location];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PNResult<NSInputStream *> *decryptResult = [cryptoModule decryptStream:sourceStream dataLength:fileSize];
            NSError *decryptError = decryptResult.error;

            if (!decryptResult.isError) {
                [decryptResult.data pn_writeToFileAtURL:storeURL withBufferSize:1024 * 1024 error:&decryptError];
            }

            block(!decryptResult.isError ? storeURL : nil, decryptError);

            if (temporary && !decryptError && ![fileManager removeItemAtURL:location error:&decryptError]) {
                [self.logger debugWithLocation:@"PNFilesManager" andMessageFactory:^PNLogEntry * {
                    NSString *error = decryptError.localizedFailureReason ?: decryptError.localizedDescription;
                    return [PNDictionaryLogEntry entryWithMessage:@{ @"error": error }
                                                          details:@"Encrypted file clean up error:"];
                }];
            }
        });
    } else {
        NSError *tempRemoveError = nil;
        block(storeURL, tempRemoveError);

        if (temporary && ![fileManager removeItemAtURL:location error:&tempRemoveError]) {
            [self.logger debugWithLocation:@"PNFilesManager" andMessageFactory:^PNLogEntry * {
                NSString *error = tempRemoveError.localizedFailureReason ?: tempRemoveError.localizedDescription;
                return [PNDictionaryLogEntry entryWithMessage:@{ @"error": error }
                                                      details:@"Temporary file clean up error:"];
            }];
        }
    }
}


#pragma mark - Misc

- (NSError *)downloadErrorForError:(NSError *)error {
    NSDictionary *userInfo = PNErrorUserInfo(error.localizedDescription, error.localizedFailureReason, nil, error);
    return [PNError errorWithDomain:PNStorageErrorDomain code:PNErrorUnknown userInfo:userInfo];
}

#pragma mark -


@end
