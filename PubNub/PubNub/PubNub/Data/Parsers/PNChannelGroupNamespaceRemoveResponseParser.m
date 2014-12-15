//
//  PNChannelGroupNamespaceRemoveResponseParser.m
//  pubnub
//
//  Created by Sergey Mamontov on 9/21/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelGroupNamespaceRemoveResponseParser.h"
#import "PNResponse+Protected.h"


#pragma mark Private interfacePNChannelGroupNamespaceRemoveResponseParserdeclaration

@interface PNChannelGroupNamespaceRemoveResponseParser ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *namespaceName;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNChannelGroupNamespaceRemoveResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {
    
    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);
    
    
    return nil;
}

+ (BOOL)isResponseConformToRequiredStructure:(PNResponse *)response {
    
    return YES;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {
    
    // Check whether initialization successful or not
    if ((self = [super init])) {
        
        self.namespaceName = response.additionalData;
    }
    
    
    return self;
}

- (id)parsedData {
    
    return self.namespaceName;
}

#pragma mark -


@end
