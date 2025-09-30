#import <Foundation/Foundation.h>
#import "PNCryptoProvider.h"
#import "PubNub+Core.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Files manager.
///
/// Manager able to upload / download regular data or make encryption / decryption if required.
@interface PNFilesManager : NSObject


#pragma mark - Initialization and configuration

/// Create file manager instance.
///
/// - Parameter client: **PubNub** client for which files manager should be created.
/// - Returns: Initialized file manager instance.
+ (instancetype)filesManagerForClient:(PubNub *)client;


#pragma mark - Download data

/// Handle downloaded file from specified URL.
///
/// - Parameters:
///   - url: Location on the local file system where file has been temporarily stored.
///   - localURL: Location on the local file system where file should be stored.
///   - cryptoModule: Crypto module which should be used to _decrypt_ downloaded file.
///   - block Downloaded data processing completion block.
- (void)handleDownloadedFileAtURL:(nullable NSURL *)url
                     withStoreURL:(nullable NSURL *)localURL
                     cryptoModule:(nullable id<PNCryptoProvider>)cryptoModule
                       completion:(void(^)( NSURL * _Nullable location, NSError * _Nullable error))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
