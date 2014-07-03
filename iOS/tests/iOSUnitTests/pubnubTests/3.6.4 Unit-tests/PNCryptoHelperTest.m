//
//  PNCryptoHelperTest.m
//  pubnub
//
//  Created by Sergey Mamontov on 6/21/13.
//
//

#import "PNCryptoHelperTest.h"
#import "PNJSONSerialization.h"
#import "PNConfiguration.h"
#import "PNCryptoHelper.h"

@implementation PNCryptoHelperTest


- (void)setUp {

    [super setUp];
    
    NSLog(@"Start %@ test", self.name);
    
    PNError *helperInitializationError = nil;
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:nil
                                                                  publishKey:nil
                                                                subscribeKey:nil
                                                                   secretKey:nil
                                                                   cipherKey:@"enigma"];
    [[PNCryptoHelper sharedInstance] updateWithConfiguration:configuration withError:&helperInitializationError];
    if (helperInitializationError) {

        NSLog(@"%@ setup error: %@", self.name, helperInitializationError);
    }
}

- (void)testStringEncryption {
    
    NSString *testObject = @"Hello World";
    id expectedResponse = @"06UDjczkvAAYcqWfNwkOiQ==";
    PNError *processingError = nil;
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
    NSString *decodedMessage = [[PNCryptoHelper sharedInstance] encryptedStringFromString:[NSString stringWithFormat:@"\"%@\"", testObject]
                                                                                    error:&processingError];
#else
    expectedResponse = @"UzIyeVhanI+QnyaNqVob2A==";
    id decodedMessage = [[PNCryptoHelper sharedInstance] encryptedObjectFromObject:testObject error:&processingError];
#endif
    STAssertNil(processingError, @"String encryption failed with error: %@", processingError);
    STAssertEqualObjects(decodedMessage, expectedResponse, @"Unexpected encrypted object");
}

- (void)testStringDecryption {
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
#endif
    
    NSString *testObject = @"06UDjczkvAAYcqWfNwkOiQ==";
    id expectedResponse = @"Hello World";
    PNError *processingError = nil;
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
    __block id decodedMessage = [[PNCryptoHelper sharedInstance] decryptedStringFromString:testObject error:&processingError];
    [PNJSONSerialization JSONObjectWithString:decodedMessage
                              completionBlock:^(id result, BOOL isJSONP, NSString *callbackMethodName){
                                  
                                  decodedMessage = result;
                                  dispatch_semaphore_signal(semaphore);
                              }
                                   errorBlock:^(NSError *error) {
                                       
                                       decodedMessage = nil;
                                       dispatch_semaphore_signal(semaphore);
                                   }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {

        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
#else
    testObject = @"UzIyeVhanI+QnyaNqVob2A==";
    id decodedMessage = [[PNCryptoHelper sharedInstance] decryptedObjectFromObject:testObject error:&processingError];
#endif
    STAssertNil(processingError, @"String encryption failed with error: %@", processingError);
    STAssertEqualObjects(decodedMessage, expectedResponse, @"Unexpected decrypted object");
}

- (void)testArrayDecryption {
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
#endif
    
    id testObject = @"A3Q8UJ2N/QmCI3x6qDcEwZZbfvNki7Ai7NWUiJiivR9YG+JSaIpFUT5dFY3AJVr5Fg8ZM+dydjDqFPyx/NZQpQ==";
    id expectedResponse = @[@"seven", @"eight", @{@"food": @"Cheeseburger", @"drink": @"Coffee"}];
    PNError *processingError = nil;
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
    __block id decodedMessage = [[PNCryptoHelper sharedInstance] decryptedStringFromString:testObject
                                                                                     error:&processingError];
    
    [PNJSONSerialization JSONObjectWithString:decodedMessage
                              completionBlock:^(id result, BOOL isJSONP, NSString *callbackMethodName){
                                  
                                  decodedMessage = result;
                                  dispatch_semaphore_signal(semaphore);
                              }
                                   errorBlock:^(NSError *error) {
                                       
                                       decodedMessage = nil;
                                       dispatch_semaphore_signal(semaphore);
                                   }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {

        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
#else
    testObject = @[@"0ZRaiDryY0rdklgVVU80pQ==", @"Ti5YyHCCUEjg\/op0Zm393w==", @{@"food": @"zu9G3gtmiAxYLpehtuQngw==", @"drink": @"vJYgOIZdbL4rRqdigAcujA=="}];
    id decodedMessage = [[PNCryptoHelper sharedInstance] decryptedObjectFromObject:testObject error:&processingError];
#endif
    STAssertNil(processingError, @"String encryption failed with error: %@", processingError);
    STAssertEqualObjects(decodedMessage, expectedResponse, @"Unexpected decrypted object");
}

- (void)testDictionaryDecryption {
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
#endif
    
    id testObject = @"XKdMklyMPIHk5XJkkAMCRm7P4jf+L5q/Owx+sfQDFHq3PPdwouV4rkhJ4gsV41VB9/Gq4E8IwnojON0kF20pDBXHRFd3qhAsnorjYnF+hwo=";
    id expectedResponse = @{@"Editer": @"X-code->ÇÈ°∂@#$%^&*()!", @"Language": @"Objective-c"};
    PNError *processingError = nil;
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
    __block id decodedMessage = [[PNCryptoHelper sharedInstance] decryptedStringFromString:testObject
                                                                                    error:&processingError];
    
    [PNJSONSerialization JSONObjectWithString:decodedMessage
                              completionBlock:^(id result, BOOL isJSONP, NSString *callbackMethodName){
                                  
                                  decodedMessage = result;
                                  dispatch_semaphore_signal(semaphore);
                              }
                                   errorBlock:^(NSError *error) {
                                       
                                       decodedMessage = nil;
                                       dispatch_semaphore_signal(semaphore);
                                   }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {

        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
#else
    testObject = @{@"Editer": @"e\/T2o0Y2ebkCZ4kqmYniQvZ7vsyY3lryf+7VNNWgecI=", @"Language": @"iJcNzxkNtWw1ktbExVn9xg=="};
    id decodedMessage = [[PNCryptoHelper sharedInstance] decryptedObjectFromObject:testObject error:&processingError];
#endif
    STAssertNil(processingError, @"String encryption failed with error: %@", processingError);
    STAssertEqualObjects(decodedMessage, expectedResponse, @"Unexpected decrypted object");
}

- (void)tearDown {
    NSLog(@"%@ test completed", self.name);
	[NSThread sleepForTimeInterval:0.1];
    [super tearDown];
}

@end
