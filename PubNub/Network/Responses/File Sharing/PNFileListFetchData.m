#import "PNFileListFetchData+Private.h"
#import <PubNub/PNJSONDecoder.h>
#import <PubNub/PNCodable.h>
#import "PNFile+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `List files` request response private extension.
@interface PNFileListFetchData () <PNCodable>


#pragma mark - Properties

/// List of channel `files`.
@property(strong, nullable, nonatomic) NSArray<PNFile *> *files;

/// Cursor bookmark for fetching the next page.
@property(strong, nullable, nonatomic) NSString *next;

/// How many `files` has been returned.
@property(assign, nonatomic) NSUInteger count;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNFileListFetchData


#pragma mark - Initialization and Configuration

- (instancetype)initWithFiles:(NSArray<PNFile *> *)files count:(NSUInteger)count next:(NSString *)next {
    if ((self = [super init])) {
        _files = files;
        _count = count;
        _next = next;
    }

    return self;
}

- (instancetype)initObjectWithCoder:(id<PNDecoder>)coder {
    NSDictionary *payload = [coder decodeObjectOfClass:[NSDictionary class]];
    if (![payload isKindOfClass:[NSDictionary class]] || !payload[@"data"]) return nil;

    
    NSUInteger count = ((NSNumber *)payload[@"count"]).unsignedIntegerValue;
    NSString *next = payload[@"next"];
    NSError *error;
    NSArray<PNFile *> *files = [PNJSONDecoder decodedObjectsOfClass:[PNFile class]
                                                          fromArray:payload[@"data"]
                                                          withError:&error];
    if (error) return nil;

    return [self initWithFiles:files count:count next:next];
}


#pragma mark - Helpers

- (void)setFilesDownloadURLWithBlock:(NSURL *(^)(NSString *dentifier, NSString *name))block {
    [self.files enumerateObjectsUsingBlock:^(PNFile *file, __unused NSUInteger fileIdx, __unused BOOL *stop) {
        file.downloadURL = block(file.identifier, file.name);
    }];
}

#pragma mark -


@end
