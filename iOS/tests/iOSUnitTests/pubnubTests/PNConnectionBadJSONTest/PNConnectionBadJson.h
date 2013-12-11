//
//  PNConnection+BadJson.h
//  pubnub
//
//  Created by Valentin Tuller on 10/2/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNConnection.h"
#import <Security/SecureTransport.h>
#import "PNConnection+Protected.h"
#import "PNResponseDeserialize.h"
#import "PNResponseProtocol.h"
#import "PubNub+Protected.h"
#import "PNWriteBuffer.h"

@interface PNConnection (BadJson) {
}

-(NSString*)name;
//-(int)state;
-(CFReadStreamRef)socketReadStream;
-(PNResponseDeserialize*)deserializer;
-(NSMutableData*)temporaryRetrievedData;
-(NSMutableData*)retrievedData;


-(void)processResponse;
-(void)handleStreamError:(CFErrorRef)error;


@end
