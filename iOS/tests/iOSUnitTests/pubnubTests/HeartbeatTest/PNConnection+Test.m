//
//  PNConnection+Test.m
//  pubnub
//
//  Created by Valentin Tuller on 2/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNConnection+Test.h"
#import "PubNub.h"
#import "PNConfiguration.h"
#import "PNConnection.h"
#import "MyPNConnection.h"

static int const kPNStreamBufferSize = 32768;

@interface PNConnection (Test)

@property NSMutableData *retrievedData;
- (id)initWithConfiguration:(PNConfiguration *)configuration;
+ (PNConnection *)connectionFromPoolWithIdentifier:(NSString *)identifier;
+ (void)storeConnection:(PNConnection *)connection withIdentifier:(NSString *)identifier;
@property (nonatomic, strong) NSString *name;

@end

@implementation PNConnection (Test)

+ (PNConnection *)connectionWithIdentifier:(NSString *)identifier {

    // Try to retrieve connection from pool
    PNConnection *connection = [MyPNConnection connectionFromPoolWithIdentifier:identifier];

    if (connection == nil) {

        connection = [[MyPNConnection alloc] initWithConfiguration:[[PubNub sharedInstance] performSelector:@selector(configuration)]];
        connection.name = identifier;
        [self storeConnection:connection withIdentifier:identifier];
    }

    return connection;
}

@end
