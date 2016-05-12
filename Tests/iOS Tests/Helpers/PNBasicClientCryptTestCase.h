//
//  PNBasicClientCryptTestCase.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 3/23/16.
//
//

#import "PNBasicClientTestCase.h"

@interface PNBasicClientCryptTestCase : PNBasicClientTestCase

@property (nonatomic) PubNub *cryptedClient;
@property (nonatomic) PNConfiguration *cryptedConfiguration;

@end
