/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <PubNub/PNAPICallBuilder+Private.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


#pragma mark Test interface declaration

@interface PNMessageActionsAPICallBuilderTest : XCTestCase


#pragma mark - Misc

- (PNAddMessageActionAPICallBuilder *)addMessageActionBuilder;
- (PNRemoveMessageActionAPICallBuilder *)removeMessageActionBuilder;
- (PNFetchMessagesActionsAPICallBuilder *)fetchMessagesActionsBuilder;

- (void)expect:(BOOL)shouldCall mock:(id)mockedObject toSetValue:(id)value toParameter:(NSString *)parameter;
- (NSString *)mockedParameterFrom:(NSString *)parameter;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNMessageActionsAPICallBuilderTest


#pragma mark - Tests :: add :: messageTimetoken

- (void)testAddMessageTimetoken_ShouldReturnAddBuilder_WhenCalled {
    id builder = [self addMessageActionBuilder];
    
    id addBuilder = ((PNAddMessageActionAPICallBuilder *)builder).messageTimetoken(@(2010));
    XCTAssertEqual(addBuilder, builder);
}

- (void)testAdd_ShouldSetMessageTimetoken_WhenNSNumberPassed {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSNumber *expected = @(2010);
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"messageTimetoken"];
    
    builder.messageTimetoken(expected);
    
    OCMVerify(builderMock);
}

- (void)testAdd_ShouldNotSetMessageTimetoken_WhenNonNSNumberPassed {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSNumber *expected = (id)@"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"messageTimetoken"];
    
    builder.messageTimetoken(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: add :: type

- (void)testAddType_ShouldReturnAddBuilder_WhenCalled {
    id builder = [self addMessageActionBuilder];
    
    id addBuilder = ((PNAddMessageActionAPICallBuilder *)builder).type(@"receipt");
    XCTAssertEqual(addBuilder, builder);
}

- (void)testAdd_ShouldSetType_WhenNSStringPassed {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = @"receipt";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"type"];
    
    builder.type(expected);
    
    OCMVerify(builderMock);
}

- (void)testAdd_ShouldNotSetType_WhenEmptyNSStringPassed {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"type"];
    
    builder.type(expected);
    
    OCMVerify(builderMock);
}

- (void)testAdd_ShouldNotSetType_WhenNonNSStringPassed {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"type"];
    
    builder.type(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: add :: channel

- (void)testAddChannel_ShouldReturnAddBuilder_WhenCalled {
    id builder = [self addMessageActionBuilder];
    
    id addBuilder = ((PNAddMessageActionAPICallBuilder *)builder).channel(@"secret");
    XCTAssertEqual(addBuilder, builder);
}

- (void)testAdd_ShouldSetChannel_WhenNSStringPassed {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = @"secret";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerify(builderMock);
}

- (void)testAdd_ShouldNotSetChannel_WhenEmptyNSStringPassed {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerify(builderMock);
}

- (void)testAdd_ShouldNotSetChannel_WhenNonNSStringPassed {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: add :: value

- (void)testAddValue_ShouldReturnAddBuilder_WhenCalled {
    id builder = [self addMessageActionBuilder];
    
    id addBuilder = ((PNAddMessageActionAPICallBuilder *)builder).value(@"smile");
    XCTAssertEqual(addBuilder, builder);
}

- (void)testAdd_ShouldSetValue_WhenNSStringPassed {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = @"smile";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"value"];
    
    builder.value(expected);
    
    OCMVerify(builderMock);
}

- (void)testAdd_ShouldNotSetValue_WhenEmptyNSStringPassed {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"value"];
    
    builder.value(expected);
    
    OCMVerify(builderMock);
}

- (void)testAdd_ShouldNotSetValue_WhenNonNSStringPassed {
    PNAddMessageActionAPICallBuilder *builder = [self addMessageActionBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"value"];
    
    builder.value(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: remove :: messageTimetoken

- (void)testRemoveMessageTimetoken_ShouldReturnAddBuilder_WhenCalled {
    id builder = [self removeMessageActionBuilder];
    
    id removeBuilder = ((PNRemoveMessageActionAPICallBuilder *)builder).messageTimetoken(@(2010));
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testRemove_ShouldSetMessageTimetoken_WhenNSNumberPassed {
    PNRemoveMessageActionAPICallBuilder *builder = [self removeMessageActionBuilder];
    NSNumber *expected = @(2010);
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"messageTimetoken"];
    
    builder.messageTimetoken(expected);
    
    OCMVerify(builderMock);
}

- (void)testRemove_ShouldNotSetMessageTimetoken_WhenNonNSNumberPassed {
    PNRemoveMessageActionAPICallBuilder *builder = [self removeMessageActionBuilder];
    NSNumber *expected = (id)@"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"messageTimetoken"];
    
    builder.messageTimetoken(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: remove :: actionTimetoken

- (void)testRemoveActionTimetoken_ShouldReturnAddBuilder_WhenCalled {
    id builder = [self removeMessageActionBuilder];
    
    id removeBuilder = ((PNRemoveMessageActionAPICallBuilder *)builder).actionTimetoken(@(2010));
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testRemove_ShouldSetActionTimetoken_WhenNSNumberPassed {
    PNRemoveMessageActionAPICallBuilder *builder = [self removeMessageActionBuilder];
    NSNumber *expected = @(2010);
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"actionTimetoken"];
    
    builder.actionTimetoken(expected);
    
    OCMVerify(builderMock);
}

- (void)testRemove_ShouldNotSetActionTimetoken_WhenNonNSNumberPassed {
    PNRemoveMessageActionAPICallBuilder *builder = [self removeMessageActionBuilder];
    NSNumber *expected = (id)@"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"actionTimetoken"];
    
    builder.actionTimetoken(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: remove :: channel

- (void)testRemoveChannel_ShouldReturnAddBuilder_WhenCalled {
    id builder = [self removeMessageActionBuilder];
    
    id removeBuilder = ((PNRemoveMessageActionAPICallBuilder *)builder).channel(@"secret");
    XCTAssertEqual(removeBuilder, builder);
}

- (void)testRemove_ShouldSetChannel_WhenNSStringPassed {
    PNRemoveMessageActionAPICallBuilder *builder = [self removeMessageActionBuilder];
    NSString *expected = @"secret";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerify(builderMock);
}

- (void)testRemove_ShouldNotSetChannel_WhenEmptyNSStringPassed {
    PNRemoveMessageActionAPICallBuilder *builder = [self removeMessageActionBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerify(builderMock);
}

- (void)testRemove_ShouldNotSetChannel_WhenNonNSStringPassed {
    PNRemoveMessageActionAPICallBuilder *builder = [self removeMessageActionBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: channel

- (void)testFetchChannel_ShouldReturnFetchBuilder_WhenCalled {
    id builder = [self fetchMessagesActionsBuilder];
    
    id fetchBuilder = ((PNFetchMessagesActionsAPICallBuilder *)builder).channel(@"secret");
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetch_ShouldSetChannel_WhenNSStringPassed {
    PNFetchMessagesActionsAPICallBuilder *builder = [self fetchMessagesActionsBuilder];
    NSString *expected = @"secret";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetChannel_WhenEmptyNSStringPassed {
    PNFetchMessagesActionsAPICallBuilder *builder = [self fetchMessagesActionsBuilder];
    NSString *expected = @"";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetChannel_WhenNonNSStringPassed {
    PNFetchMessagesActionsAPICallBuilder *builder = [self fetchMessagesActionsBuilder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"channel"];
    
    builder.channel(expected);
    
    OCMVerify(builderMock);
}

#pragma mark - Tests :: fetch :: start

- (void)testFetchStart_ShouldReturnFetchBuilder_WhenCalled {
    id builder = [self fetchMessagesActionsBuilder];
    
    id fetchBuilder = ((PNFetchMessagesActionsAPICallBuilder *)builder).start(@(2010));
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetch_ShouldSetStart_WhenNSNumberPassed {
    PNFetchMessagesActionsAPICallBuilder *builder = [self fetchMessagesActionsBuilder];
    NSNumber *expected = @(2010);
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetStart_WhenNonNSNumberPassed {
    PNFetchMessagesActionsAPICallBuilder *builder = [self fetchMessagesActionsBuilder];
    NSNumber *expected = (id)@"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"start"];
    
    builder.start(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: end

- (void)testFetchEnd_ShouldReturnFetchAllBuilder_WhenCalled {
    id builder = [self fetchMessagesActionsBuilder];
    
    id fetchBuilder = ((PNFetchMessagesActionsAPICallBuilder *)builder).end(@(2010));
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetch_ShouldSetEnd_WhenNSStringPassed {
    PNFetchMessagesActionsAPICallBuilder *builder = [self fetchMessagesActionsBuilder];
    NSNumber *expected = @(2010);
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerify(builderMock);
}

- (void)testFetch_ShouldNotSetEnd_WhenNonNSStringPassed {
    PNFetchMessagesActionsAPICallBuilder *builder = [self fetchMessagesActionsBuilder];
    NSNumber *expected = (id)@"PubNub";
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:NO mock:builderMock toSetValue:expected toParameter:@"end"];
    
    builder.end(expected);
    
    OCMVerify(builderMock);
}


#pragma mark - Tests :: fetch :: limit

- (void)testFetchLimit_ShouldReturnFetchAllBuilder_WhenCalled {
    id builder = [self fetchMessagesActionsBuilder];
    
    id fetchBuilder = ((PNFetchMessagesActionsAPICallBuilder *)builder).limit(20);
    XCTAssertEqual(fetchBuilder, builder);
}

- (void)testFetchAll_ShouldSetLimit_WhenCalled {
    PNFetchMessagesActionsAPICallBuilder *builder = [self fetchMessagesActionsBuilder];
    NSNumber *expected = @YES;
    
    
    id builderMock = OCMPartialMock(builder);
    [self expect:YES mock:builderMock toSetValue:expected toParameter:@"limit"];
    
    builder.limit(35);
    
    OCMVerify(builderMock);
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
        OCMExpect([[mockedObject reject] setValue:value forParameter:parameter]);
    }
}

- (NSString *)mockedParameterFrom:(NSString *)parameter {
    return [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
}

#pragma mark -


@end
