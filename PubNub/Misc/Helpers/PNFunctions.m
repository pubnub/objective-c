#import "PNFunctions.h"


#pragma mark - Object

BOOL PNNSObjectIsKindOfAnyClass(id object, NSArray<Class> *classes) {
    for (Class cls in classes) {
        if ([object isKindOfClass:cls]) return YES;
    }

    return NO;
}

BOOL PNNSObjectIsSubclassOfAnyClass(id object, NSArray<Class> *classes) {
    Class aClass = [object class];

    for (Class listedClass in classes) {
        if ([aClass isSubclassOfClass:listedClass]) return YES;
    }

    return NO;
}


#pragma mark - String

NSString *PNStringFormat(NSString *format, ...) {
    va_list args;
    va_start (args, format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    return string;
}


#pragma mark - Error

NSDictionary * PNErrorUserInfo(NSString *description, NSString *reason, NSString *recovery, NSError *error) {
    NSMutableDictionary *info = [NSMutableDictionary new];

    info[NSLocalizedDescriptionKey] = description;
    info[NSLocalizedFailureReasonErrorKey] = reason;
    info[NSLocalizedRecoverySuggestionErrorKey] = recovery;
    info[NSUnderlyingErrorKey] = error;

    return info;
}
