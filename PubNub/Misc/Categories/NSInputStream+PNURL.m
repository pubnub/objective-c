#import "NSInputStream+PNURL.h"


#pragma mark Interface implementation

@implementation NSInputStream (PNURL)


#pragma mark - Helpers

- (void)pn_writeToFileAtURL:(NSURL *)url withBufferSize:(NSUInteger)size error:(NSError **)error {
    NSOutputStream *outputStream = [NSOutputStream outputStreamWithURL:url append:NO];
    NSMutableData *buffer = [NSMutableData dataWithLength:size];
    if (self.streamStatus == NSStreamStatusNotOpen) [self open];
    [outputStream open];

    NSError *processingError = self.streamError ?: outputStream.streamError;

    while (self.streamStatus == NSStreamStatusOpen &&
           outputStream.streamStatus == NSStreamStatusOpen &&
           !processingError) {
        NSInteger bytesRead = [self read:buffer.mutableBytes maxLength:size];
        NSInteger bytesToWrite = bytesRead;

        if (bytesRead > 0) {
            while (outputStream.streamStatus == NSStreamStatusOpen && bytesToWrite > 0) {
                NSInteger bytesWritten = [outputStream write:buffer.mutableBytes + (bytesRead - bytesToWrite)
                                                   maxLength:bytesToWrite];

                if (bytesWritten > 0) bytesToWrite -= bytesWritten;
                else if (bytesWritten < 0) processingError = outputStream.streamError;
            }
            buffer = [NSMutableData dataWithLength:size];
        } else if (bytesRead == 0) {
            [outputStream close];
            [self close];
        } else processingError = self.streamError;
    }

    if (processingError && error != NULL) *error = processingError;
}

#pragma mark -


@end
