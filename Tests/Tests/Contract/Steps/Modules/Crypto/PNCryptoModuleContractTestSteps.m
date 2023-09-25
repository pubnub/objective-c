#import "PNCryptoModuleContractTestSteps.h"
#import <PubNub/NSArray+PNMap.h>
#import <PubNub/PubNub.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNCryptoModuleContractTestSteps ()

/// List of cryptor identifiers which should be used in test.
@property(nonatomic, nullable, strong) NSArray<NSString *> *cryptorIdentifiers;

/// Data processing error.
@property(nonatomic, nullable, strong) NSError *processingError;

/// Error which is expected during processing.
@property(nonatomic, nullable, strong) NSError *expectedError;

/// Cipher key which should be use by cryptor for data processing.
@property(nonatomic, nullable, strong) NSString *cipherKey;

/// Cryptor module encrypt result.
@property(nonatomic, nullable, strong) NSData *encryptedData;

/// Cryptor module decrypt result.
@property(nonatomic, nullable, strong) NSData *decryptedData;

/// Content of file which has been processed.
@property(nonatomic, nullable, strong) NSData *fileContent;

/// Whether cryptors should use random initialization vector or not.
@property(nonatomic, assign) BOOL useRandomIV;


#pragma mark - Helpers

/// Encrypt provided `data`.
///
/// Cryptor module is able to _encrypt_ data both as `binary` and using `streams`.
///
/// - Parameters:
///   - data: Data which should be _encrypted_ by configured cryptor.
///   - asBinary: Whether data should be processed as `binary` or `stream`.
- (void)encryptData:(NSData *)data asBinary:(BOOL)asBinary;

/// Decrypt provided `data`.
///
/// Cryptor module is able to _decrypt_ data both as `binary` and using `streams`.
///
/// - Parameters:
///   - data: Data which should be _decrypted_ by configured cryptor.
///   - asBinary: Whether data should be processed as `binary` or `stream`.
- (void)decryptData:(NSData *)data asBinary:(BOOL)asBinary;

/// Cryptors with specified identifiers.
///
/// Initiate list of the cryptors using values from feature test steps.
///
/// - Parameter identifiers: Identifiers of the cryptors which should be created.
/// - Returns: List of the cryptor instances.
- (NSArray<id<PNCryptor>> *)cryptorsWithIdentifiers:(NSArray<NSString *> *)identifiers;

/// Cryptor with specified identifier.
///
/// Initiate cryptor using values from feature test steps.
///
/// - Parameter identifier: Identifier of the cryptor which should be created.
/// - Returns: Cryptor instance or `nil` if unknown identifier has been passed.
- (nullable id<PNCryptor>)cryptorWithIdentifier:(NSString *)identifier;

/// Load content of the `fileName` stored in cryptor's assets folder.
///
/// - Parameter name: Name of file who's content should be loaded.
/// - Returns: Content of specified file or `nil` if file can't be found.
- (nullable NSData *)cryptorAssetDataForFileWithName:(NSString *)name;

/// Full path to the `fileName` from cryptor assets folder.
///
/// - Parameter name: Name of the file for which asset path should be retrieved.
/// - Returns: Full path to the file.
- (NSString *)cryptorAssetPathForFileWithName:(NSString *)name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNCryptoModuleContractTestSteps


#pragma mark - Initialization and configuration

- (void)handleBeforeHook {
    self.cryptorIdentifiers = nil;
    self.processingError = nil;
    self.expectedError = nil;
    self.encryptedData = nil;
    self.decryptedData = nil;
    self.fileContent = nil;
    self.useRandomIV = NO;
    self.cipherKey = nil;
}

- (void)setup {
    [self startCucumberHookEventsListening];

    Given(@"^Crypto module with '([a-zA-Z0-9]+)' cryptor$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.cryptorIdentifiers = @[args.firstObject];
    });

    Given(@"^Crypto module with default '([a-zA-Z0-9]+)' and additional '([a-zA-Z0-9]+)' cryptors$",
          ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.cryptorIdentifiers = args;
    });

    Given(@"^Legacy code with '([a-zA-Z0-9]+)' cipher key and '(random|constant)' vector$",
          ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        // Do nothing because no cryptor instance can be created.
    });

    When(@"^I decrypt '(.*)' file( as '(.*)')?$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        NSData *encryptedData = [self cryptorAssetDataForFileWithName:args.firstObject];
        [self decryptData:encryptedData asBinary:(args.count == 1 || [args.lastObject isEqualToString:@"binary"])];
    });

    When(@"^I encrypt '(.*)' file( as '(.*)')?$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        NSData *originalData = [self cryptorAssetDataForFileWithName:args.firstObject];
        [self encryptData:originalData asBinary:(args.count == 1 || [args.lastObject isEqualToString:@"binary"])];
    });

    Then(@"Successfully decrypt an encrypted file with legacy code", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        NSString *base64Data = [self.encryptedData base64EncodedStringWithOptions:0];
        NSError *decryptError = nil;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSData *decryptedData = [PNAES decrypt:base64Data
                                  withRandomIV:self.useRandomIV
                                     cipherKey:self.cipherKey
                                      andError:&decryptError];
#pragma clang diagnostic pop

        XCTAssertNil(decryptError);
        XCTAssertTrue([decryptedData isEqualToData:self.fileContent]);
    });

    Then(@"^Decrypted file content equal to the '(.*)' file content$", ^
         (NSArray<NSString *> *args, NSDictionary *userInfo) {

        NSData *fileContent = [self cryptorAssetDataForFileWithName:args.firstObject];

        XCTAssertNotNil(self.decryptedData);
        XCTAssertNotNil(fileContent);
        XCTAssertTrue([self.decryptedData isEqualToData:fileContent]);
    });

    Then(@"^I receive '(.*)'$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        if ([args.firstObject isEqual:@"decryption error"]) {
            XCTAssertNotNil(self.processingError);
            XCTAssertEqualObjects(self.processingError.domain, kPNCryptorErrorDomain);
            XCTAssertEqual(self.processingError.code, kPNCryptorDecryptionError);
        } else if ([args.firstObject isEqual:@"unknown cryptor error"]) {
            XCTAssertNotNil(self.processingError);
            XCTAssertEqualObjects(self.processingError.domain, kPNCryptorErrorDomain);
            XCTAssertEqual(self.processingError.code, kPNCryptorUnknownCryptorError);
        } else if ([args.firstObject isEqual:@"success"]) {
            XCTAssertNil(self.processingError);
            XCTAssertTrue(self.encryptedData != nil || self.decryptedData != nil);
        }
    });

    Match(@[@"*"], @"^with '([a-zA-Z0-9]+)' cipher key$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.cipherKey = args.firstObject;
    });

    Match(@[@"*"], @"^with '(random|constant|-)' vector$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
        self.useRandomIV = [args.firstObject isEqual:@"random"];
    });
}


#pragma mark - Helpers

- (void)encryptData:(NSData *)data asBinary:(BOOL)asBinary {
    NSArray<id<PNCryptor>> *cryptors = [self cryptorsWithIdentifiers:self.cryptorIdentifiers];
    id<PNCryptor> defaultCryptor = cryptors.firstObject;
    if (cryptors.count > 1) cryptors = [cryptors subarrayWithRange:NSMakeRange(1, cryptors.count - 1)];
    PNResult<NSInputStream *> *streamResult;
    PNResult<NSData *> *dataResult;

    XCTAssertGreaterThan(cryptors.count, 0);

    PNCryptoModule *cryptorModule = [PNCryptoModule moduleWithDefaultCryptor:defaultCryptor cryptors:cryptors];
    if (asBinary) dataResult = [cryptorModule encryptData:data];
    else streamResult = [cryptorModule encryptStream:[NSInputStream inputStreamWithData:data] dataLength:data.length];

    XCTAssertTrue(streamResult != nil || dataResult != nil);

    if (dataResult.isError || streamResult.isError) self.processingError = dataResult.error ?: streamResult.error;
    else if (dataResult) self.encryptedData = dataResult.data;
    else {
        NSUInteger bufferSize = 1024 * 1024;
        NSMutableData *buffer = [NSMutableData dataWithLength:bufferSize];
        
        [streamResult.data open];
        NSInteger dataLength = [streamResult.data read:buffer.mutableBytes maxLength:bufferSize];

        if (dataLength >= 0) {
            buffer.length = dataLength;
            self.encryptedData = buffer;
        } else self.processingError = streamResult.data.streamError;
    }
}

- (void)decryptData:(NSData *)data asBinary:(BOOL)asBinary {
    NSArray<id<PNCryptor>> *cryptors = [self cryptorsWithIdentifiers:self.cryptorIdentifiers];
    id<PNCryptor> defaultCryptor = cryptors.firstObject;
    if (cryptors.count > 1) cryptors = [cryptors subarrayWithRange:NSMakeRange(1, cryptors.count - 1)];
    PNResult<NSInputStream *> *streamResult;
    PNResult<NSData *> *dataResult;

    XCTAssertGreaterThan(cryptors.count, 0);

    PNCryptoModule *cryptorModule = [PNCryptoModule moduleWithDefaultCryptor:defaultCryptor cryptors:cryptors];
    if (asBinary) dataResult = [cryptorModule decryptData:data];
    else streamResult = [cryptorModule decryptStream:[NSInputStream inputStreamWithData:data] dataLength:data.length];

    XCTAssertTrue(streamResult != nil || dataResult != nil);

    if (dataResult.isError || streamResult.isError) self.processingError = dataResult.error ?: streamResult.error;
    else if (dataResult) self.decryptedData = dataResult.data;
    else {
        NSUInteger bufferSize = 1024 * 1024;
        NSMutableData *buffer = [NSMutableData dataWithLength:bufferSize];
        NSInteger dataLength = [streamResult.data read:buffer.mutableBytes maxLength:bufferSize];

        if (dataLength >= 0) {
            buffer.length = dataLength;
            self.decryptedData = buffer;
        } else self.processingError = streamResult.data.streamError;
    }
}

- (NSArray<id<PNCryptor>> *)cryptorsWithIdentifiers:(NSArray<NSString *> *)identifiers {
    return [identifiers pn_mapWithBlock:^id _Nonnull(NSString *identifier, NSUInteger index) {
        id<PNCryptor> cryptor = [self cryptorWithIdentifier:identifier];
        XCTAssertNotNil(cryptor);
        return cryptor;
    }];
}

- (id<PNCryptor>)cryptorWithIdentifier:(NSString *)identifier {
    id<PNCryptor> cryptor = nil;

    if ([identifier isEqualToString:@"legacy"]) {
        cryptor = [PNLegacyCryptor cryptorWithCipherKey:self.cipherKey randomInitializationVector:self.useRandomIV];
    } else if ([identifier isEqualToString:@"acrh"]) {
        cryptor = [PNAESCBCCryptor cryptorWithCipherKey:self.cipherKey];
    }

    return cryptor;
}

- (NSData *)cryptorAssetDataForFileWithName:(NSString *)name {
    self.fileContent = [NSData dataWithContentsOfFile:[self cryptorAssetPathForFileWithName:name]];
    XCTAssertNotNil(self.fileContent, @"File is missing: %@", [self cryptorAssetPathForFileWithName:name]);
    return self.fileContent;
}

- (NSString *)cryptorAssetPathForFileWithName:(NSString *)name {
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    return [NSString pathWithComponents:@[testBundle.resourcePath, @"Features", @"encryption", @"assets", name]];
}

#pragma mark -


@end
