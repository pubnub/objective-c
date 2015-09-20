//
//  PNBasicClientCryptTestCase.h
//  PubNub Tests
//
//  Created by Vadim Osovets on 9/11/15.
//
//

#import "PNBasicClientTestCase.h"

@interface PNBasicClientCryptTestCase : PNBasicClientTestCase

@property (nonatomic) PubNub *cryptedClient;
@property (nonatomic) PNConfiguration *cryptedConfiguration;

@end
