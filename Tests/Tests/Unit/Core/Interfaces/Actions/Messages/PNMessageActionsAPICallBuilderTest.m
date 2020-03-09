/**
* @author Serhii Mamontov
* @copyright © 2010-2020 PubNub, Inc.
*/
#import <PubNub/PNAPICallBuilder+Private.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNMessageActionsAPICallBuilderTest : XCTestCase


#pragma mark - Misc

- (PNAddMessageActionAPICallBuilder *)addMessageActionBuilder;
- (PNRemoveMessageActionAPICallBuilder *)removeMessageActionBuilder;
- (PNFetchMessagesActionsAPICallBuilder *)fetchMessagesActionsBuilder;

- (void)expect:(BOOL)shouldCall mock:(id)mockedObject toSetValue:(id)value toParameter:(NSString *)parameter;
- (NSString *)mockedParameterFrom:(NSString *)parameter;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNMessageActionsAPICallBuilderTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: add :: messageTimetoken

- (void)testItShouldReturnAddBuilderWhenMessageTimetokenSpecifiedInChain {
    id builder = [self addMessageActionBuilder];
    
    id addBuilder = ((PNAddMessageActionAPICallBuilder *)builder).messageTimetoken(@(2010));
    XCTAssertEqual(addBuilder, builder);
}

- (void)testItShouldSetMessageTimetokenWhenNSNumberPassedAsAddMessageTimetoken {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSNumber *expected = @(2010);
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"messageTimetoken"];
    
    builder.messageTimetoken(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetMessageTimetokenWhenNonNSNumberPassedAsAddMessageTimetoken {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSNumber *expected = (id)@"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"messageTimetoken"];
    
    builder.messageTimetoken(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: add :: type

- (void)testItShouldReturnAddBuilderWhenActionTypeSpecifiedInChain {
    id builder = [self addMessageActionBuilder];
    
    id addBuilder = ((PNAddMessageActionAPICallBuilder *)builder).type(@"receipt");
    XCTAssertEqual(addBuilder, builder);
}

- (void)testItShouldSetTypeWhenNSStringPassedAsAddActionType {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = @"receipt";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"type"];
    
    builder.type(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetTypeWhenEmptyNSStringPassedAsAddActionType {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"type"];
    
    builder.type(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetTypeWhenNonNSStringPassedAsAddActionType {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"type"];
    
    builder.type(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: add :: channel

- (void)testItShouldReturnAddBuilderWhenChannelSpecifiedInChain {
    id builder = [self addMessageActionBuilder];
    
    id addBuilder = ((PNAddMessageActionAPICallBuilder *)builder).channel(@"secret");
    XCTAssertEqual(addBuilder, builder);
}

- (void)testItShouldSetChannelWhenNSStringPassedAsAddChannel {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = @"secret";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenEmptyNSStringPassedAsAddChannel {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenNonNSStringPassedAsAddChannel {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: add :: value

- (void)testItShouldReturnAddBuilderWhenValueSpecifiedInChain {
    id builder = [self addMessageActionBuilder];
    
    id addBuilder = ((PNAddMessageActionAPICallBuilder *)builder).value(@"smile");
    XCTAssertEqual(addBuilder, builder);
}

- (void)testItShouldSetValueWhenNSStringPassedAsAddValue {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = @"smile";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"value"];
    
    builder.value(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetValueWhenEmptyNSStringPassedAsAddValue {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"value"];
    
    builder.value(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetValueWhenNonNSStringPassedAsAddValue {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"value"];
    
    builder.value(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: messageTimetoken

- (void)testItShouldReturnRemoveBuilderWhenMessageTimetokenSpecifiedInChain {
    id builder = [self removeMessageActionBuilder];
    
    id removeBuilder = ((PNRemoveMessageActionAPICallBuilder *)builder).messageTimetoken(@(2010));
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetMessageTimetokenWhenNSNumberPassedAsRemoveMessageTimetoken {
    PNRemoveMessageActionAPICallBuilder *builder = [self removeMessageActionBuilder];
    NSNumber *expected = @(2010);
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"messageTimetoken"];
    
    builder.messageTimetoken(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetMessageTimetokenWhenNonNSNumberPassedAsRemoveMessageTimetoken {
    PNRemoveMessageActionAPICallBuilder *builder = [self removeMessageActionBuilder];
    NSNumber *expected = (id)@"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"messageTimetoken"];
    
    builder.messageTimetoken(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: actionTimetoken

- (void)testItShouldReturnAddBuilderWhenActionTimetokenSpecifiedInChain {
    id builder = [self removeMessageActionBuilder];
    
    id removeBuilder = ((PNRemoveMessageActionAPICallBuilder *)builder).actionTimetoken(@(2010));
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetActionTimetokenWhenNSNumberPassedAsRemoveActionTimetoken {
    PNRemoveMessageActionAPICallBuilder *builder = [self removeMessageActionBuilder];
    NSNumber *expected = @(2010);
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"actionTimetoken"];
    
    builder.actionTimetoken(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetActionTimetokenWhenNonNSNumberPassedAsRemoveActionTimetoken {
    PNRemoveMessageActionAPICallBuilder *builder = [self removeMessageActionBuilder];
    NSNumber *expected = (id)@"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"actionTimetoken"];
    
    builder.actionTimetoken(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: remove :: channel

- (void)testItShouldReturnRemoveBuilderWhenChannelSpecifiedInChain {
    id builder = [self removeMessageActionBuilder];
    
    id removeBuilder = ((PNRemoveMessageActionAPICallBuilder *)builder).channel(@"secret");
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testItShouldSetChannelWhenNSStringPassedAsRemoveChannel {
    PNRemoveMessageActionAPICallBuilder *builder = [self removeMessageActionBuilder];
    NSString *expected = @"secret";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenEmptyNSStringPassedAsRemoveChannel {
    PNRemoveMessageActionAPICallBuilder *builder = [self removeMessageActionBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenNonNSStringPassedAsRemoveChannel {
    PNRemoveMessageActionAPICallBuilder *builder = [self removeMessageActionBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: channel

- (void)testItShouldReturnFetchBuilderWhenChannelSpecifiedInChain {
    id builder = [self fetchMessagesActionsBuilder];
    
    id fetchBuilder = ((PNFetchMessagesActionsAPICallBuilder *)builder).channel(@"secret");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetChannelWhenNSStringPassedAsFetchChannel {
    PNFetchMessagesActionsAPICallBuilder *builder = [self fetchMessagesActionsBuilder];
    NSString *expected = @"secret";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenEmptyNSStringPassedAsFetchChannel {
    PNFetchMessagesActionsAPICallBuilder *builder = [self fetchMessagesActionsBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetChannelWhenNonNSStringPassedAsFetchChannel {
    PNFetchMessagesActionsAPICallBuilder *builder = [self fetchMessagesActionsBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerifyAll(builderMock);
}

#pragma mark - Tests :: fetch :: start

- (void)testItShouldReturnFetchBuilderWhenStartTokenSpecifiedInChain {
    id builder = [self fetchMessagesActionsBuilder];
    
    id fetchBuilder = ((PNFetchMessagesActionsAPICallBuilder *)builder).start(@(2010));
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetStartWhenNSNumberPassedAsFetchStartToken {
    PNFetchMessagesActionsAPICallBuilder *builder = [self fetchMessagesActionsBuilder];
    NSNumber *expected = @(2010);
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetStartWhenNonNSNumberPassedAsFetchStartToken {
    PNFetchMessagesActionsAPICallBuilder *builder = [self fetchMessagesActionsBuilder];
    NSNumber *expected = (id)@"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: end

- (void)testItShouldReturnFetchAllBuilderWhenEndTokenSpecifiedInChain {
    id builder = [self fetchMessagesActionsBuilder];
    
    id fetchBuilder = ((PNFetchMessagesActionsAPICallBuilder *)builder).end(@(2010));
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetEndWhenNSStringPassedAsFetchEndToken {
    PNFetchMessagesActionsAPICallBuilder *builder = [self fetchMessagesActionsBuilder];
    NSNumber *expected = @(2010);
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerifyAll(builderMock);
}

- (void)testItShouldNotSetEndWhenNonNSStringPassedAsFetchEndToken {
    PNFetchMessagesActionsAPICallBuilder *builder = [self fetchMessagesActionsBuilder];
    NSNumber *expected = (id)@"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Tests :: fetch :: limit

- (void)testItShouldReturnFetchAllBuilderWhenLimitSpecifiedInChain {
    id builder = [self fetchMessagesActionsBuilder];
    
    id fetchBuilder = ((PNFetchMessagesActionsAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testItShouldSetLimitWhenFetchLimitSpecifiedInChain {
    PNFetchMessagesActionsAPICallBuilder *builder = [self fetchMessagesActionsBuilder];
    NSNumber *expected = @35;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];
    
    builder.limit(35);
    
    OCMVerifyAll(builderMock);
}


#pragma mark - Misc

- (PNAddMessageActionAPICallBuilder *)addMessageActionBuilder {
    return [PNAddMessageActionAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                         NSDictionary *arguments) {
    }];
}

- (PNRemoveMessageActionAPICallBuilder *)removeMessageActionBuilder {
    return [PNRemoveMessageActionAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                            NSDictionary *arguments) {
    }];
}

- (PNFetchMessagesActionsAPICallBuilder *)fetchMessagesActionsBuilder {
    return [PNFetchMessagesActionsAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                             NSDictionary *arguments) {
    }];
}

- (void)expect:(BOOL)shouldCall mock:(id)mockedObject toSetValue:(id)value toParameter:(NSString *)parameter {
    parameter = [self mockedParameterFrom:parameter];
    
    if (shouldCall) {
        OCMExpect([mockedObject setValue:value forParameter:parameter]);
    } else {
        OCMReject([mockedObject setValue:value forParameter:parameter]);
    }
}

- (NSString *)mockedParameterFrom:(NSString *)parameter {
    return [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
}

#pragma mark -

#pragma clang diagnostic pop

@end
