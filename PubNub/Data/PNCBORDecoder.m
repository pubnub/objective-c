/**
 * @author Serhii Mamontov
 * @version 4.17.0
 * @since 4.17.0
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PNCBORDecoder.h"
#import "PNErrorCodes.h"


#pragma mark Struct & Types

/**
 * @brief CBOR data item general types.
 */
typedef NS_ENUM(uint8_t, DataItemType) {
    DataItemTypePositiveInt = 0,
    DataItemTypeNegativeInt = 1,
    DataItemTypeInt = 1,
    DataItemTypeByteString = 2,
    DataItemTypeTextString = 3,
    DataItemTypeArray = 4,
    DataItemTypeDictionary = 5,
    DataItemTypeTag = 6,
    DataItemTypeFloat = 7,
    DataItemTypeUnknown = UINT8_MAX
};

/**
 * @brief CBOR data item head byte representation.
 */
typedef struct DataItemInformation {
    /**
     * @brief CBOR data item information byte.
     */
    UInt8 byte;
    /**
     * @brief Previous data item information byte index.
     */
    NSUInteger previousIndex;
    
    /**
     * @brief Data item information byte index.
     */
    NSUInteger index;
    
    /**
     * @brief Data item major type.
     */
    DataItemType type;
    
    /**
     * @brief Value packed in first data item head byte.
     *
     * @discussion This can be actual value (simple int value) or number of bytes which store information about data item content length.
     */
    UInt8 argument;
    
    /**
     * @brief Whether data item length is known or not.
     */
    BOOL hasLength;
    
    /**
     * @brief Data item content length.
     */
    UInt64 length;
    
    /**
     * @brief Value for int / float data items.
     */
    NSNumber *value;
} DataItemInformation;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface PNCBORDecoder ()


#pragma mark - Information

/**
 * @brief Pointer to a contiguous region of memory.
 */
@property (nonatomic, assign) const void *cborBytes;

/**
 * @brief Length of CBOR data for processing.
 */
@property (nonatomic, assign) NSUInteger cborBytesLength;

/**
 * @brief Previous and current byte index.
 */
@property (nonatomic, assign) NSUInteger previousIndex;
@property (nonatomic, assign) NSUInteger currentIndex;

/**
 * @brief Value decoded from CBOR data item.
 */
@property (nonatomic, nullable, strong) id value;

/**
 * @brief Calculated pointer to currently processed bytes.
 *
 * @return Pointer to memory region which should be processed next.
 */
- (const void *)currentPointer;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize decoder for provided CBOR data.
 *
 * @param data Previously encoded well-formed CBOR data item.
 *
 * @return Initialized and ready to use CBOR decoder.
 */
- (instancetype)initWithCBORData:(NSData *)data;


#pragma mark - CBOR data decoding

/**
 * @brief Try decode current CBOR data item / chunk.
 *
 * @param error Pointer which can be used to store processing error information.
 *
 * @return Value decoded from CBOR data item or \c nil in case of error.
 */
- (nullable id)decodeDataItemWithError:(NSError * __autoreleasing *)error;

/**
 * @brief Get current (if not overridden) byte information and treat it as CBOR data item head byte.
 *
 * @param resetIndex Whether current index should be reset after information read.
 *
 * @return CBOR data item information from current byte.
 */
- (DataItemInformation)readDataItemInformation:(BOOL)resetIndex;

/**
 * @brief Read  \b byte string / chunk data items.
 *
 * @param isIndefiniteLength Whether  \b byte string should be treated as string w/o fixed length or not.
 * @param bytesCount Length of  \b byte string with fixed provided length.
 * @param error Pointer which can be used to store processing error information.
 *
 * @return Parsed data or \c nil in case of error.
 */
- (nullable NSData *)readCStringWithIndefiniteLength:(BOOL)isIndefiniteLength
                                              length:(NSUInteger)bytesCount
                                               error:(NSError * __autoreleasing *)error;

/**
 * @brief Read  \b text string / chunk data items.
 *
 * @param isIndefiniteLength Whether \b text string should be treated as string w/o fixed length or not.
 * @param bytesCount Length of  \b text string with fixed provided length.
 * @param error Pointer which can be used to store processing error information.
 *
 * @return Parsed string or \c nil in case of error.
 */
- (nullable NSString *)readStringWithIndefiniteLength:(BOOL)isIndefiniteLength
                                               length:(NSUInteger)bytesCount
                                                error:(NSError * __autoreleasing *)error;
/**
 * @brief Read integer value.
 *
 * @param positive Whether value should be read as positive or negative.
 * @param bytesCount Number of bytes which represent target integer value.
 *
 * @return Parsed number value or \c nil if unknown size processing requested.
 */
- (nullable NSNumber *)readPositive:(BOOL)positive NSNumberWithLength:(UInt8)bytesCount;

/**
 * @brief Read UInt8 value (1 byte long).
 *
 * @return Parsed UInt8 value from CBOR data item.
 */
- (UInt8)readUInt8;

/**
 * @brief Read UInt16 value (2 byte long).
 *
 * @return Parsed UInt16 value from CBOR data item.
 */
- (UInt16)readUInt16;

/**
 * @brief Read UInt32 value (4 byte long).
 *
 * @return Parsed UInt32 value from CBOR data item.
 */
- (UInt32)readUInt32;

/**
 * @brief Read UInt64 value (8 byte long).
 *
 * @return Parsed UInt64 value from CBOR data item.
 */
- (UInt64)readUInt64;

/**
 * @brief Read array with child items.
 *
 * @param isIndefiniteLength Whether array should be treated as array w/o fixed count or not.
 * @param length Length of array with fixed provided length.
 * @param error Pointer which can be used to store processing error information.
 *
 * @return Parsed array or nil in case of error.
 */
- (nullable NSArray *)readArrayOfIndefiniteLength:(BOOL)isIndefiniteLength
                                       withLength:(NSUInteger)length
                                            error:(NSError * __autoreleasing *)error;

/**
 * @brief Read dictionary with key / value data items.
 *
 * @param isIndefiniteLength Whether dictionary should be treated as dictionary w/o fixed count of pairs or not.
 * @param length Length of dictionary with fixed provided length.
 * @param error Pointer which can be used to store processing error information.
 *
 * @return Parsed dictionary or nil in case of error.
 */
- (nullable NSDictionary *)readDictionaryOfIndefiniteLength:(BOOL)isIndefiniteLength
                                                 withLength:(NSUInteger)length
                                                      error:(NSError * __autoreleasing *)error;


#pragma mark - Misc

/**
 * @brief Check CBOR data is valid.
 *
 * @return \c YES in case if top-level data item has known type.
 */
- (BOOL)isValidCBORData;

/**
 * @brief Check end of data.
 *
 * @return \c YES in case if more data can be read starting from current index.
 */
- (BOOL)canReadCBORHeadByte;

/**
 * @brief Move current read pointer forward on specified count of bytes.
 *
 * @param bytesCount Number of bytes on which current index should be increased.
 */
- (void)increaseIndexBy:(NSUInteger)bytesCount;

/**
 * @brief Endianness change requirement check.
 *
 * @return \c YES in case endianness should be changed before value usage.
 */
- (BOOL)shouldChangeEndianness;

/**
 * @brief Stringify CBOR data item major type.
 *
 * @param type \b DataItemType enum field which should be stringified.
 *
 * @return Stringified major type.
 */
- (NSString *)stringifiedDataItemType:(DataItemType)type;

#pragma mark -


@end


NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNCBORDecoder


#pragma mark - Information

- (const void *)currentPointer {
    return self.cborBytes + self.currentIndex;
}


#pragma mark - Initialization & Configuration

+ (instancetype)decoderWithCBORData:(NSData *)data {
    return [[self alloc] initWithCBORData:data];
}

- (instancetype)initWithCBORData:(NSData *)data {
    if ((self = [super init])) {
        self.cborBytesLength = data.length;
        self.cborBytes = data.bytes;
    }
    
    return self;
}


#pragma mark - CBOR data decoding

- (id)decodeWithError:(NSError **)error {
    id value;
    
    if ([self isValidCBORData]) {
        value = [self decodeDataItemWithError:error];
    } else if (error != NULL) {
        NSDictionary *userInfo = @{
            NSLocalizedFailureReasonErrorKey: @"The given data did not contain a top-level value.",
            NSLocalizedDescriptionKey: @"Data item in given data doesn't have 'head' byte with information about it."
        };
        
        *error = [NSError errorWithDomain:kPNCBORErrorDomain code:kPNCBORMalformedDataError userInfo:userInfo];
    }
    
    return value;
}

- (id)decodeDataItemWithError:(NSError **)error {
    // Check whether it is possible to read more data or not.
    if (![self canReadCBORHeadByte]) return nil;
    
    DataItemInformation info = [self readDataItemInformation:NO];
    NSError *decodeDataItemError;
    NSDictionary *errorUserInfo;
    id data = nil;
    
    if (info.type <= DataItemTypeInt) {
        if (info.hasLength) {
            data = info.value;
        } else {
            errorUserInfo = @{
                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Data item at %lu is not well-formed.",
                                                   (unsigned long)info.index],
                NSLocalizedDescriptionKey: @"Integer item expected to have simple value or defined count of bytes with value."
            };
        }
    } else if (info.type == DataItemTypeByteString) {
        NSData *cStringData = [self readCStringWithIndefiniteLength:!info.hasLength
                                                             length:(NSUInteger)info.length
                                                              error:&decodeDataItemError];
        if (cStringData && !decodeDataItemError) {
            data = [[NSString alloc] initWithData:cStringData encoding:NSUTF8StringEncoding];
            
            if (!data) {
                data = cStringData;
            }
        }
    } else if (info.type <= DataItemTypeTextString) {
        NSString *string = [self readStringWithIndefiniteLength:!info.hasLength
                                                         length:(NSUInteger)info.length
                                                          error:&decodeDataItemError];
        
        if (string && !decodeDataItemError) {
            data = string;
        }
    } else if (info.type == DataItemTypeArray) {
        NSArray *array = [self readArrayOfIndefiniteLength:!info.hasLength
                                                withLength:(NSUInteger)info.length
                                                     error:&decodeDataItemError];
        
        if (array && !decodeDataItemError) {
            data = array;
        }
    } else if (info.type == DataItemTypeDictionary) {
        NSDictionary *dictionary = [self readDictionaryOfIndefiniteLength:!info.hasLength
                                                               withLength:(NSUInteger)info.length
                                                                    error:&decodeDataItemError];
        
        if (dictionary && !decodeDataItemError) {
            data = dictionary;
        }
    } else if (info.type == DataItemTypeTag) {
        
    } else if (info.type == DataItemTypeFloat) {
        if (info.byte == 0xf4 || info.byte == 0xf5) {
            data = @(0xf5 - info.byte == 0);
        } else if (info.byte == 0xf6 || info.byte == 0xf7) {
            data = [NSNull null];
        } else if (info.byte < 0xf8) {
            data = info.value;
        } else if (info.byte == 0xf8) {
            data = [self readPositive:YES NSNumberWithLength:sizeof(UInt8)];
        }
    }
    
    if (decodeDataItemError || errorUserInfo) {
        data = nil;
        
        if (error != NULL) {
            if (decodeDataItemError) {
                *error = decodeDataItemError;
            } else {
                *error = [NSError errorWithDomain:kPNCBORErrorDomain
                                             code:kPNCBORDataItemNotWellFormedError
                                         userInfo:errorUserInfo];
            }
        }
    }
    
    return data;
}

- (DataItemInformation)readDataItemInformation:(BOOL)resetIndex {
    NSUInteger previousIndex = self.previousIndex;
    NSUInteger index = self.currentIndex;
    
    UInt8 byte = [self readUInt8];
    DataItemType type = byte >> 5;
    UInt8 argument = byte & 0x1f;
    UInt64 length = argument != 0x1f ? argument : 0;
    BOOL hasLength = argument != 0x1f;
    BOOL positiveInteger = YES;
    NSNumber *value;
    
    if (type <= DataItemTypeInt && ((byte >= 0x20 && byte <= 0x37) || (byte >= 0x38 && byte <= 0x3b))) {
        positiveInteger = NO;
    }
    
    if (hasLength && length >= 24) {
        /**
         * How many bytes hold additional information (string / collection length or int / float value).
         */
        UInt8 bytesLength = pow(2, argument - 24);
        
        // Value encoded as additional information / value.
        NSNumber *bytesValue = [self readPositive:positiveInteger NSNumberWithLength:bytesLength];
        
        if (type <= DataItemTypeInt) {
            value = bytesValue;
        } else if (type < DataItemTypeTag) {
            length = bytesValue.unsignedIntegerValue;
        }
    } else if (hasLength && (type <= DataItemTypeInt || type == DataItemTypeFloat)) {
        if (type == DataItemTypeFloat && byte < 0xf8) {
            value = @(argument);
        } else {
            value = byte <= 0x17 ? @(argument) : @(-1 * argument - 1);
        }
    }
    
    DataItemInformation info = {
        .byte = byte,
        .previousIndex = previousIndex,
        .index = index,
        .type = type,
        .argument = argument,
        .hasLength = hasLength,
        .length = length,
        .value = value
    };
    
    if (resetIndex) {
        self.previousIndex = previousIndex;
        self.currentIndex = index;
    }
    
    return info;
}

- (NSData *)readCStringWithIndefiniteLength:(BOOL)isIndefiniteLength
                                     length:(NSUInteger)bytesCount
                                      error:(NSError **)error {
    
    NSDictionary *errorUserInfo;
    NSError *cStringReadError;
    NSData *data;
    
    if (!isIndefiniteLength) {
        data = [[NSData alloc] initWithBytes:[self currentPointer] length:bytesCount];
        [self increaseIndexBy:bytesCount];
    } else {
        NSMutableData *chunkedData = [NSMutableData new];
        
        // Last processed chunk information.
        DataItemInformation chunkInfo;
        
        while (true) {
            chunkInfo = [self readDataItemInformation:YES];
            if (chunkInfo.type != DataItemTypeByteString || !chunkInfo.hasLength || chunkInfo.byte == 0xff ||
                chunkInfo.byte == 0x5f) {
                break;
            }
            
            NSData *dataChunk = [self decodeDataItemWithError:&cStringReadError];
            
            if (dataChunk && !cStringReadError) {
                [chunkedData appendData:dataChunk];
            } else if (cStringReadError) {
                break;
            }
        }
        
        if (chunkInfo.type != DataItemTypeByteString) {
            errorUserInfo = @{
                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Data item at %lu is not well-formed.",
                                                   (unsigned long)chunkInfo.index],
                NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Chunk of indefinite-length '%@ expected to be the same type, but got %@",
                                            [self stringifiedDataItemType:DataItemTypeByteString],
                                            [self stringifiedDataItemType:chunkInfo.type]]
            };
        } else if (!chunkInfo.hasLength && chunkInfo.byte != 0xff && chunkInfo.byte != 0x5f) {
            errorUserInfo = @{
                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Data item at %lu is not well-formed.",
                                                   (unsigned long)chunkInfo.index],
                NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Chunk of indefinite-length %@ expected to have length.",
                                            [self stringifiedDataItemType:DataItemTypeByteString]]
            };
        } else {
            data = chunkedData;
        }
    }
    
    if (errorUserInfo || cStringReadError) {
        data = nil;
        
        if (error != NULL) {
            if (cStringReadError) {
                *error = cStringReadError;
            } else {
                *error = [NSError errorWithDomain:kPNCBORErrorDomain
                                             code:kPNCBORDataItemNotWellFormedError
                                         userInfo:errorUserInfo];
            }
        }
    }
    
    return data;
}

- (NSString *)readStringWithIndefiniteLength:(BOOL)isIndefiniteLength
                                      length:(NSUInteger)bytesCount
                                       error:(NSError **)error {
    
    NSDictionary *errorUserInfo;
    NSError *stringReadError;
    NSString *string;
    
    if (!isIndefiniteLength) {
        string = [[NSString alloc] initWithBytes:[self currentPointer] length:bytesCount encoding:NSUTF8StringEncoding];
        [self increaseIndexBy:bytesCount];
    } else {
        NSMutableString *chunkedString = [NSMutableString new];
        
        // Last processed chunk information.
        DataItemInformation chunkInfo;
        
        while (true) {
            chunkInfo = [self readDataItemInformation:YES];
            if (chunkInfo.type != DataItemTypeTextString || !chunkInfo.hasLength || chunkInfo.byte == 0xff ||
                chunkInfo.byte == 0x7f) {
                break;
            }
            
            NSString *stringChunk = [self decodeDataItemWithError:&stringReadError];
            
            if (stringChunk && !stringReadError) {
                [chunkedString appendString:stringChunk];
            } else if (stringReadError) {
                break;
            }
        }
        
        if (chunkInfo.type != DataItemTypeTextString) {
            errorUserInfo = @{
                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Data item at %lu is not well-formed.",
                                                   (unsigned long)chunkInfo.index],
                NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Chunk of indefinite-length '%@ expected to be the same type, but got %@",
                                            [self stringifiedDataItemType:DataItemTypeTextString],
                                            [self stringifiedDataItemType:chunkInfo.type]]
            };
        } else if (!chunkInfo.hasLength && chunkInfo.byte != 0xff && chunkInfo.byte != 0x7f) {
            errorUserInfo = @{
                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Data item at %lu is not well-formed.",
                                                   (unsigned long)chunkInfo.index],
                NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Chunk of indefinite-length %@ expected to have length.",
                                            [self stringifiedDataItemType:DataItemTypeTextString]]
            };
        } else {
            string = chunkedString;
        }
    }
    
    if (errorUserInfo || stringReadError) {
        string = nil;
        
        if (error != NULL) {
            if (stringReadError) {
                *error = stringReadError;
            } else {
                *error = [NSError errorWithDomain:kPNCBORErrorDomain
                                             code:kPNCBORDataItemNotWellFormedError
                                         userInfo:errorUserInfo];
            }
        }
    }
    
    return string;
}

/**
 * @brief Read integer value.
 *
 * @param positive Whether value should be read as positive or negative.
 * @param bytesCount Number of bytes which represent target integer value.
 *
 * @return Parsed number value or \c nil if unknown size processing requested.
 */
- (NSNumber *)readPositive:(BOOL)positive NSNumberWithLength:(UInt8)bytesCount {
    NSNumber *number;
    
    if (bytesCount == 1) {
        UInt8 uint = [self readUInt8];
        number = positive ? @(uint) : @(-1 * uint - 1);
    } else if (bytesCount == 2) {
        UInt16 uint = [self readUInt16];
        number = positive ? @(uint) : @(-1 * uint - 1);
    } else if (bytesCount == 4) {
        UInt32 uint = [self readUInt32];
        number = positive ? @(uint) : @(-1 * uint - 1);
    } else if (bytesCount == 8) {
        UInt64 uint = [self readUInt64];
        number = positive ? @(uint) : @(-1 * uint - 1);
    }
    
    return number;
}

- (UInt8)readUInt8 {
    UInt8 uint;
    memcpy(&uint, [self currentPointer], sizeof(uint));
    [self increaseIndexBy:sizeof(uint)];
    
    return uint;
}

- (UInt16)readUInt16 {
    UInt16 uint;
    memcpy(&uint, [self currentPointer], sizeof(uint));
    [self increaseIndexBy:sizeof(uint)];
    
    return [self shouldChangeEndianness] ? CFSwapInt16BigToHost(uint) : uint;
}

- (UInt32)readUInt32 {
    UInt32 uint;
    memcpy(&uint, [self currentPointer], sizeof(uint));
    [self increaseIndexBy:sizeof(uint)];
    
    return [self shouldChangeEndianness] ? CFSwapInt32BigToHost(uint) : uint;
}

- (UInt64)readUInt64 {
    UInt64 uint;
    memcpy(&uint, [self currentPointer], sizeof(uint));
    [self increaseIndexBy:sizeof(uint)];
    
    return [self shouldChangeEndianness] ? CFSwapInt64BigToHost(uint) : uint;
}

- (NSArray *)readArrayOfIndefiniteLength:(BOOL)isIndefiniteLength
                              withLength:(NSUInteger)length
                                   error:(NSError **)error {
    
    NSMutableArray *array = [NSMutableArray new];
    NSDictionary *errorUserInfo;
    NSUInteger currentCount = 0;
    NSError *arrayReadError;
    
    while (true) {
        if (!isIndefiniteLength && currentCount >= length) {
            break;
        }
        
        if (isIndefiniteLength) {
            if (![self canReadCBORHeadByte]) {
                errorUserInfo = @{
                    NSLocalizedFailureReasonErrorKey: @"Array data item is not well-formed.",
                    NSLocalizedDescriptionKey: @"Indefinite-length array data item should have \"break\" stop code."
                };
                break;
            }  else {
                UInt8 byte = [self readDataItemInformation:YES].byte;
                
                if (byte == 0xff || byte == 0x9f) {
                    [self increaseIndexBy:1];
                    break;
                }
            }
        }
    
        id value = [self decodeDataItemWithError:&arrayReadError];
        
        if (value) {
            [array addObject:value];
        } else if (!arrayReadError && !isIndefiniteLength) {
            errorUserInfo = @{
                NSLocalizedFailureReasonErrorKey: @"Array data item is not well-formed.",
                NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Array expected to have %@ items but only %@ has been found",
                                            @(length), @(array.count)]
            };
            break;
        } else if (arrayReadError) {
            break;
        }
        
        currentCount++;
    }
    
    if (errorUserInfo || arrayReadError) {
        array = nil;
        
        if (error != NULL) {
            if (arrayReadError) {
                *error = arrayReadError;
            } else {
                *error = [NSError errorWithDomain:kPNCBORErrorDomain
                                             code:kPNCBORMissingDataItemError
                                         userInfo:errorUserInfo];
            }
        }
    }
    
    return array;
}

- (NSDictionary *)readDictionaryOfIndefiniteLength:(BOOL)isIndefiniteLength
                                        withLength:(NSUInteger)length
                                             error:(NSError **)error {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    NSDictionary *errorUserInfo;
    NSUInteger currentCount = 0;
    NSError *dictionaryReadError;
    NSString *errorDescription;
    
    while (true) {
        if (!isIndefiniteLength && currentCount >= length) {
            break;
        }
        
        if (isIndefiniteLength) {
            if (![self canReadCBORHeadByte]) {
                errorUserInfo = @{
                    NSLocalizedFailureReasonErrorKey: @"Dictionary data item is not well-formed.",
                    NSLocalizedDescriptionKey: @"Indefinite-length dictionary data item should have \"break\" stop code."
                };
                break;
            } else {
                UInt8 byte = [self readDataItemInformation:YES].byte;
                
                if (byte == 0xff || byte == 0xbf) {
                    [self increaseIndexBy:1];
                    break;
                }
            }
        }
        
        id key = [self decodeDataItemWithError:&dictionaryReadError];
        id value = [self decodeDataItemWithError:&dictionaryReadError];
        
        if (value != nil  && key != nil) {
            dictionary[key] = value;
        } else if (key == nil && !dictionaryReadError) {
            errorDescription = @"Dictionary key data item is missing.";
        } else if (value == nil && !dictionaryReadError) {
            errorDescription = @"Dictionary value data item is missing.";
        } else if (dictionaryReadError) {
            break;
        }
        
        if (errorDescription) {
            errorUserInfo = @{
                NSLocalizedFailureReasonErrorKey: @"Dictionary data item is not well-formed.",
                NSLocalizedDescriptionKey: errorDescription
            };
            break;
        }
        
        currentCount++;
    }
    
    if (errorUserInfo || dictionaryReadError) {
        dictionary = nil;
        
        if (error != NULL) {
            if (dictionaryReadError) {
                *error = dictionaryReadError;
            } else {
                *error = [NSError errorWithDomain:kPNCBORErrorDomain
                                             code:kPNCBORMissingDataItemError
                                         userInfo:errorUserInfo];
            }
        }
    }
    
    return dictionary;
}

#pragma mark - Misc

- (BOOL)isValidCBORData {
    uint8_t byte = ((uint8_t *)self.cborBytes)[0];
    
    return byte >> 5 <= DataItemTypeFloat;
}

- (BOOL)canReadCBORHeadByte {
    return self.currentIndex < self.cborBytesLength;
}

- (void)increaseIndexBy:(NSUInteger)bytesCount {
    self.previousIndex = self.currentIndex;
    self.currentIndex += bytesCount;
}

- (BOOL)shouldChangeEndianness {
    static BOOL _shouldChangeEndianness;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shouldChangeEndianness = CFByteOrderGetCurrent() != CFByteOrderBigEndian;
    });
    
    return _shouldChangeEndianness;
}

- (NSString *)stringifiedDataItemType:(DataItemType)type {
    NSString *stringified;
    
    switch (type) {
        case DataItemTypePositiveInt:
            stringified = @"unsigned integer";
            break;
        case DataItemTypeNegativeInt:
            stringified = @"negative integer";
            break;
        case DataItemTypeByteString:
            stringified = @"byte string";
            break;
        case DataItemTypeTextString:
            stringified = @"text string";
            break;
        case DataItemTypeArray:
            stringified = @"array";
            break;
        case DataItemTypeDictionary:
            stringified = @"map of pairs";
            break;
        case DataItemTypeTag:
            stringified = @"tagged";
            break;
        case DataItemTypeFloat:
            stringified = @"float";
            break;
        case DataItemTypeUnknown:
            stringified = @"unknown";
            break;
    }
    
    return stringified;
}

#pragma mark -


@end

