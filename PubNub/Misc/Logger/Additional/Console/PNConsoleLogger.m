#import "PNConsoleLogger.h"
#import "PNNetworkResponseLogEntry.h"
#import "PNNetworkRequestLogEntry.h"
#import "PNLogEntry+Private.h"
#import "PNFunctions.h"
#import "PNHelpers.h"
#import <os/log.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Console logger private extension.
@interface PNConsoleLogger ()


#pragma mark - Properties

/// Map of logger objects to the log categories.
@property(strong, nonatomic) NSDictionary<NSString *, os_log_t> *logObjects;

/// Formatter that is used to translate log entry timestamp to ISO8601 standardized string.
@property(strong, nonatomic) NSISO8601DateFormatter *dateFormatter;


#pragma mark - Logging

/// Print log entry to the console.
///
/// - Parameter message: Entry which should be stringified and printed to the console.
- (void)logMessage:(PNLogEntry *)message;


#pragma mark - Misc

/// Serialize log entry into string.
///
/// - Parameter logEntry: Generated log entry for serialization.
/// - Returns: String that can be used for the console or written to the file.
- (NSString *)stringifiedLogEntry:(PNLogEntry *)logEntry;

/// Stringify dictionary object.
///
/// Dictionary object could be received from the log entry with structured data or from pre-processed data created for
/// other log entry types.
///
/// - Parameters:
///   - dictionary: `NSDictionary` which may contain nested data for stringification.
///   - level: Current nesting level for proper entries indention.
///   - skipIndentOnce: Whether the first entry in the collection shouldn't have indention or not.
/// - Returns: Stringified `NSDictionary` representation.
- (NSString *)stringifiedDictionary:(NSDictionary<NSString *, id> *)dictionary
                       nestingLevel:(NSUInteger)level
                     skipIndentOnce:(BOOL)skipIndentOnce;

/// Stringify array object.
///
/// Dictionary object could be received from the log entry with structured data or from pre-processed data created for
/// other log entry types.
///
/// - Parameters:
///   - array: `NSArray` which may contain nested data for stringification.
///   - level: Current nesting level for proper entries indention.
/// - Returns: Stringified `NSArray` representation.
- (NSString *)stringifiedArray:(NSArray *)array nestingLevel:(NSUInteger)level;

/// Stringify request object.
///
/// - Parameter logEntry: Generated log entry with transport request as a `message`.
/// - Returns: Stringified `PNNetworkRequestLogEntry` representation.
- (NSString *)stringifiedNetworkRequestLogEntry:(PNNetworkRequestLogEntry *)logEntry;

/// Stringify response object.
///
/// - Parameter logEntry: Generated log entry with transport response as a `message`.
/// - Returns: Stringified `PNNetworkResponseLogEntry` representation.
- (NSString *)stringifiedNetworkLogEntry:(PNNetworkResponseLogEntry *)logEntry;

/// Stringify error object.
///
/// - Parameters:
///   - error: Generated log entry with `NSError` as a `message`.
///   - level: Current nesting level for proper entries indention.
/// - Returns: Stringified `NSError` representation.
- (NSString *)stringifiedError:(NSError *)error nestingLevel:(NSUInteger)level;

/// Stringify log level.
///
/// - Parameter logLevel: One of log level enum fields.
/// - Returns: Stringified log level representation.
- (NSString *)stringifiedLogLevel:(PNLogLevel)logLevel;

/// Retrieve OS log object suitable for log `entry` representation.
///
/// - Parameter entry: Generated log entry that should be printed out.
/// - Returns: Appropriate OS log object.
- (os_log_t)logObjectForEntry:(PNLogEntry *)entry;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNConsoleLogger


#pragma mark - Initialization and Configuration

- (instancetype)init {
    if ((self = [super init])) {
        _dateFormatter = [NSISO8601DateFormatter new];
        _dateFormatter.formatOptions = NSISO8601DateFormatWithInternetDateTime|NSISO8601DateFormatWithFractionalSeconds;
        
        _logObjects = @{
            @"api": os_log_create("com.pubnub.sdk", "api"),
            @"transport": os_log_create("com.pubnub.transport", "network"),
        };
    }
    
    return self;
}


#pragma mark - PNLogger protocol

- (void)debugWithMessage:(PNLogEntry *)message {
    [self logMessage:message];
}

- (void)errorWithMessage:(PNLogEntry *)message {
    [self logMessage:message];
}

- (void)infoWithMessage:(PNLogEntry *)message {
    [self logMessage:message];
}

- (void)traceWithMessage:(PNLogEntry *)message {
    [self logMessage:message];
}

- (void)warnWithMessage:(PNLogEntry *)message {
    [self logMessage:message];
}


#pragma mark - Logging

- (void)logMessage:(PNLogEntry *)message {
    os_log_t logObject = [self logObjectForEntry:message];
    NSString *logMessage = message.preProcessedString ?: [self stringifiedLogEntry:message];
    if (!message.preProcessedString) message.preProcessedString = logMessage;
    
    switch (message.logLevel) {
        case PNTraceLogLevel:
        case PNDebugLogLevel:
            os_log_debug(logObject, "%{public}@", logMessage);
            break;
        case PNInfoLogLevel:
        case PNWarnLogLevel:
            os_log_info(logObject, "%{public}@", logMessage);
            break;
        case PNErrorLogLevel:
            os_log_error(logObject, "%{public}@", logMessage);
            break;
        default:
            // NO-OP
            break;
    }
}


#pragma mark - Misc

- (NSString *)stringifiedLogEntry:(PNLogEntry *)logEntry {
    NSMutableString *string = [NSMutableString stringWithFormat:@"%@ PubNub-%@ %@ %@ ",
                               [self.dateFormatter stringFromDate:logEntry.timestamp],
                               logEntry.pubNubId,
                               [self stringifiedLogLevel:logEntry.logLevel],
                               logEntry.location];
    
    if (logEntry.messageType == PNTextLogMessageType) [string appendString:logEntry.message];
    else if (logEntry.messageType == PNObjectLogMessageType) {
        [string appendFormat:@"%@\n%@",
         logEntry.details ?: @"",
         [self stringifiedDictionary:logEntry.message nestingLevel:1 skipIndentOnce:NO]];
    } else if (logEntry.messageType == PNNetworkRequestLogMessageType) {
        [string appendString:[self stringifiedNetworkRequestLogEntry:(PNNetworkRequestLogEntry *)logEntry]];
    } else if (logEntry.messageType == PNNetworkResponseLogMessageType) {
        [string appendString:[self stringifiedNetworkLogEntry:(PNNetworkResponseLogEntry *)logEntry]];
    } else if (logEntry.messageType == PNErrorLogMessageType) {
        [string appendString:[self stringifiedError:logEntry.message nestingLevel:1]];
    } else [string appendString:@"unknown log message data"];
    
    return string;
}

- (NSString *)stringifiedDictionary:(NSDictionary<NSString *, id> *)dictionary
                       nestingLevel:(NSUInteger)level
                     skipIndentOnce:(BOOL)skipIndentOnce {
    NSUInteger longestKeyLength = ((NSNumber *)[dictionary.allKeys valueForKeyPath:@"@max.length"]).unsignedIntValue;
    NSString *indent = [@"" stringByPaddingToLength:level * 2 withString:@" " startingAtIndex:0];
    NSMutableArray *lines = [NSMutableArray new];
    __block BOOL shouldSkipOneIndent = skipIndentOnce;
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, __unused BOOL *stop) {
        NSString *paddedKey = [key stringByPaddingToLength:longestKeyLength withString:@" " startingAtIndex:0];
        BOOL breakLine = [obj respondsToSelector:@selector(count)];
        
        if (breakLine && [obj isKindOfClass:[NSArray class]]) {
            obj = [self stringifiedArray:obj nestingLevel:(level +1)];
            breakLine = ![obj isEqualToString:@"[]"];
        } else if (breakLine && [obj isKindOfClass:[NSDictionary class]]) {
            obj = [self stringifiedDictionary:obj nestingLevel:(level +1) skipIndentOnce:NO];
            breakLine = ![obj isEqualToString:@"{}"];
        } else if ([obj isKindOfClass:[NSNumber class]] &&
                   CFGetTypeID((__bridge CFTypeRef)obj) == CFBooleanGetTypeID()) {
            obj = ((NSNumber *)obj).intValue == 1 ? @"YES" : @"NO";
        }
        
        [lines addObject:[NSString stringWithFormat:@"%@%@:%@%@",
                          !shouldSkipOneIndent ? indent : @"",
                          paddedKey, breakLine ? @"\n" : @" ",
                          obj]];
        shouldSkipOneIndent = NO;
    }];
    
    return lines.count == 0 ? @"{}" : [lines componentsJoinedByString:@"\n"];
}

- (NSString *)stringifiedArray:(NSArray *)array nestingLevel:(NSUInteger)level {
    NSString *indent = [@"" stringByPaddingToLength:level * 2 withString:@" " startingAtIndex:0];
    NSMutableArray *lines = [NSMutableArray new];
    
    [array enumerateObjectsUsingBlock:^(id obj, __unused NSUInteger idx, __unused BOOL *stop) {
        BOOL isCollection = [obj respondsToSelector:@selector(count)];
        BOOL breakLine = NO;
        
        if (isCollection && [obj isKindOfClass:[NSArray class]]) {
            obj = [self stringifiedArray:obj nestingLevel:(level +1)];
            breakLine = ![obj isEqualToString:@"[]"];
        } else if (isCollection && [obj isKindOfClass:[NSDictionary class]]) {
            obj = [self stringifiedDictionary:obj nestingLevel:(level +1) skipIndentOnce:YES];
            breakLine = NO;
        } else if ([obj isKindOfClass:[NSNumber class]] &&
                   CFGetTypeID((__bridge CFTypeRef)obj) == CFBooleanGetTypeID()) {
            obj = ((NSNumber *)obj).intValue == 1 ? @"YES" : @"NO";
        }
        
        [lines addObject:PNStringFormat(@"%@-%@%@", indent, breakLine ? @"\n" : @" ", obj)];
    }];
    
    return lines.count == 0 ? @"[]" : [lines componentsJoinedByString:@"\n"];
}

- (NSString *)stringifiedNetworkRequestLogEntry:(PNNetworkRequestLogEntry *)logEntry {
    PNTransportRequest *request = logEntry.message;
    BOOL onlyBasicInfo = request.cancelled || request.failed;
    NSMutableString *string = [!onlyBasicInfo ? @"Sending" : (request.cancelled ? @"Canceled" : @"Failed") mutableCopy];
    NSMutableDictionary *details = [@{ @"Method": request.stringifiedMethod } mutableCopy];
    if (logEntry.details) [string appendFormat:@" %@", logEntry.details];
    [string appendFormat:@" HTTP request:\n"];
    
    // Prepare URL string.
    NSMutableString *url = [PNStringFormat(@"%@%@", request.origin, request.path) mutableCopy];
    if (request.query.count > 0) {
        NSMutableArray *keyValuePairs = [NSMutableArray arrayWithCapacity:request.query.count];
        [request.query enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, __unused BOOL *stop) {
            value = [value isKindOfClass:[NSString class]] ? [PNString percentEscapedString:value] : value;
            [keyValuePairs addObject:PNStringFormat(@"%@=%@", key, value)];
        }];
        
        [url appendFormat:@"?%@", [keyValuePairs componentsJoinedByString:@"&"]];
    }
    details[@"URL"] = url;
    
    if (logEntry.minimumLogLevel == PNTraceLogLevel && !onlyBasicInfo && request.headers.count) {
        details[@"Headers"] = request.headers;
    }
    
    // Append body information if needed
    if (!onlyBasicInfo && (request.body || request.formData)) {
        if (request.formData) details[@"FormData"] = request.formData;
        if (request.headers.count && request.body) {
            NSString *contentType = request.headers[@"content-type"] ?: request.headers[@"Content-Type"];
            if ([contentType containsString:@"javascript"] || [contentType containsString:@"json"]) {
                NSString *body = [[NSString alloc] initWithData:request.body encoding:NSUTF8StringEncoding];
                details[@"Body"] = PNStringFormat(@"\n%@", body);
            } else details[@"Body"] = PNStringFormat(@"NSData (length: %lu)", request.body.length);
        }
    }
    [string appendString:[self stringifiedDictionary:details nestingLevel:1 skipIndentOnce:NO]];
    
    return string;
}

- (NSString *)stringifiedNetworkLogEntry:(PNNetworkResponseLogEntry *)logEntry {
    id<PNTransportResponse> response = logEntry.message;
    NSMutableString *string = [@"Received HTTP response:\n" mutableCopy];
    NSMutableDictionary *details = [@{ @"URL": response.url } mutableCopy];
    
    if (logEntry.minimumLogLevel == PNTraceLogLevel && response.headers.count) details[@"Headers"] = response.headers;
    
    // Append body information if needed
    if (response.body && response.headers.count) {
        NSString *contentType = response.headers[@"content-type"];
        if ([contentType containsString:@"javascript"] || [contentType containsString:@"json"]) {
            NSString *body = [[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding];
            details[@"Body"] = PNStringFormat(@"\n%@", body);
        } else details[@"Body"] = PNStringFormat(@"NSData (length: %lu)", response.body.length);
    }
    [string appendString:[self stringifiedDictionary:details nestingLevel:1 skipIndentOnce:NO]];
    
    return string;
}

- (NSString *)stringifiedError:(NSError *)error nestingLevel:(NSUInteger)level {
    NSMutableDictionary *info = [error.userInfo ?: @{} mutableCopy];
    NSMutableString *string = [NSMutableString new];
    NSMutableDictionary<NSString *, id> *details = [@{
        @"domain": [NSString stringWithFormat:@"%@ (%li)", error.domain, (long)error.code]
    } mutableCopy];
    
    [info removeObjectsForKeys:@[
        NSDebugDescriptionErrorKey,
        NSHelpAnchorErrorKey,
        NSLocalizedRecoveryOptionsErrorKey,
        NSRecoveryAttempterErrorKey,
        NSStringEncodingErrorKey,
    ]];
    
    if (level == 1) [string appendString:error.localizedFailureReason ?: error.localizedDescription ?: @"Error"];
    if (error.localizedDescription) {
        details[@"description"] = error.localizedDescription;
        [info removeObjectForKey:NSLocalizedDescriptionKey];
    }
    if (error.localizedFailureReason) {
        details[@"failureReason"] = error.localizedFailureReason;
        [info removeObjectForKey:NSLocalizedFailureReasonErrorKey];
        [info removeObjectForKey:NSLocalizedFailureErrorKey];
    }
    if (error.localizedRecoverySuggestion) {
        details[@"recovery"] = error.localizedRecoverySuggestion;
        [info removeObjectForKey:NSLocalizedRecoverySuggestionErrorKey];
    }
    if (info[NSURLErrorFailingURLErrorKey] || info[NSURLErrorKey]) {
        details[@"url"] = info[NSURLErrorFailingURLErrorKey] ?: info[NSURLErrorKey];
        [info removeObjectForKey:NSURLErrorFailingURLErrorKey];
        [info removeObjectForKey:NSURLErrorKey];
    }
    if (info[@"_kCFStreamErrorHTTPStatusCode"] || info[@"NSHTTPURLResponseStatusCode"]) {
        details[@"statusCode"] = info[@"_kCFStreamErrorHTTPStatusCode"] ?: info[@"NSHTTPURLResponseStatusCode"];
        [info removeObjectForKey:@"_kCFStreamErrorHTTPStatusCode"];
        [info removeObjectForKey:@"NSHTTPURLResponseStatusCode"];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    if (info[NSUnderlyingErrorKey] || info[NSMultipleUnderlyingErrorsKey]) {
        NSMutableArray<NSError *> *errors = [(@[info[NSUnderlyingErrorKey]] ?: @[]) mutableCopy];
        NSMutableArray *underlyingErrors = [NSMutableArray new];
        
        if (info[NSMultipleUnderlyingErrorsKey]) [errors addObjectsFromArray:info[NSMultipleUnderlyingErrorsKey]];
        [errors enumerateObjectsUsingBlock:^(NSError *error, __unused NSUInteger idx, __unused BOOL *stop) {
            [underlyingErrors addObject:[self stringifiedError:error nestingLevel:(level + 2)]];
        }];
        
        details[@"underlying"] = underlyingErrors;
        [info removeObjectForKey:NSMultipleUnderlyingErrorsKey];
        [info removeObjectForKey:NSUnderlyingErrorKey];
    }
#pragma clang diagnostic pop
    
    NSMutableDictionary *filteredUserInfo = [NSMutableDictionary dictionaryWithCapacity:info.count];
    [info enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, __unused BOOL *stop) {
        if (![key hasPrefix:@"_"]) filteredUserInfo[key] = obj;
    }];
    if (filteredUserInfo.count) details[@"userInfo"] = filteredUserInfo;
    
    if (details.count) {
        if (level == 1) [string appendString:@"\n"];
        [string appendString:[self stringifiedDictionary:details nestingLevel:level skipIndentOnce:level != 1]];
    }
    
    return string;
}

- (NSString *)stringifiedLogLevel:(PNLogLevel)logLevel {
    static NSArray<NSString *> *_logLevelNames;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _logLevelNames = @[
            @"TRACE", // PNTraceLogLevel
            @"DEBUG", // PNDebugLogLevel
            @"INFO ", // PNInfoLogLevel
            @"WARN ", // PNWarnLogLevel
            @"ERROR" // PNErrorLogLevel
        ];
    });
    
    return logLevel != PNNoneLogLevel && logLevel <= PNErrorLogLevel ? _logLevelNames[logLevel] : @"UNKNW";
}

- (os_log_t)logObjectForEntry:(PNLogEntry *)entry {
    if (entry.messageType == PNNetworkRequestLogMessageType ||
        entry.messageType == PNNetworkResponseLogMessageType ||
        [entry.location containsString:@"Transport"]) {
        return self.logObjects[@"transport"];
    }
    
    return self.logObjects[@"api"];
}

#pragma mark -


@end
