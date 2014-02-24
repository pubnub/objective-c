// MailGun.h
//
// Copyright (c) 2013 Rackspace Hosting (http://rackspace.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <Availability.h>

#if !__has_feature(objc_arc)
#error Mailgun must be built with ARC.
// You can turn on ARC for Mailgun by adding -fobjc-arc on the build phase tab for each of its files.
#endif

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <UIKit/UIKit.h>
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
#import <Cocoa/Cocoa.h>
#endif

#import "AFNetworking.h"
#import "AFHTTPClient.h"

#import "MGMessage.h"

/**
 The Mailgun SDK allows your Mac OS X or iOS application to connect with the [Mailgun](http://www.mailgun.com) programmable email platform. Send and manage mailing list subscriptions from your desktop or mobile applications and connect with your users directly in your application.
 
 *Requirements* The AFNetworking library is required for the `Mailgun` client library.
 
 ## Easy Image Attaching
 
 Using MGMessage will allow you to attach `UIImage` or `NSImage` instances to a message. It will handle converting the image for you and attaching it either inline or to the message header.
 
 ## This SDK is not 1:1 to the REST API
 
 At this time the full Mailgun REST API is not supported. Currently support is only provided to send messages, subscribe/unsubscribe from mailing lists and to check mailing lists subscriptions.
 
 *Note* These features may be implemented at a later date.
 
 ## Sending Example
 
     Mailgun *mailgun = [Mailgun clientWithDomain:@"samples.mailgun.org" apiKey:@"key-3ax6xnjp29jd6fds4gc373sgvjxteol0"];
     [mailgun sendMessageTo:@"Jay Baird <jay.baird@rackspace.com>" 
                       from:@"Excited User <someone@sample.org>" 
                    subject:@"Mailgun is awesome!" 
                       body:@"A unicode snowman for you! ☃"];
 
 ## Installing
 
 1. Install via Cocoapods
 
     pod install mailgun
 
 2. Install via Source
 
    1. Clone the repository.
    2. Copy Mailgun.h/.m and MGMessage.h/.m to your project.
    3. There's no step three!
 
 */

@interface Mailgun : AFHTTPClient

///---------------------------
/// @name Mailgun Client Setup
///---------------------------

/**
 Returns the value for the HTTP headers set in request objects created by the HTTP client.
 
 @param header The HTTP header to return the default value for
 
 @return The default value for the HTTP header, or `nil` if unspecified
 */
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *domain;

///---------------------------------------------------
/// @name Creating and Initializing the Mailgun Client
///---------------------------------------------------

/**
 Creates and initializes an `Mailgun` object with the specified.
 
 @warning *Important:* You will need to set a domain and an API key on this object after creation in order to use the client.
 
 @return The newly-initialized Mailgun client
 */
+ (instancetype)client;

/**
 Creates and initializes an `Mailgun` object with the domain and api key specified.
 
 @param domain The domain for this client. Must not be nil.
 @param apiKey The API key for your Mailgun account. Must not be nil.
 
 @return The newly-initialized Mailgun client
 */
+ (instancetype)clientWithDomain:(NSString *)domain apiKey:(NSString *)apiKey;


///-------------------------------------------------------
/// @name Sending a Previously Constructed Mailgun Message
///-------------------------------------------------------

/**
 Sends a previously constructed MGMessage without success or failure blocks.

 @param message The MGMessage instance to send.
 */
- (void)sendMessage:(MGMessage *)message;

/**
 Sends a previously constructed MGMessage with the provided success and failure blocks.
 
 @param success A block called when the message is sent successfully called with a parameter `NSString` of the message id.
 @param failure A block called when the underlying HTTP request fails. It will be called with an `NSError` set by the underlying `AFNetworking` client.
 */
- (void)sendMessage:(MGMessage *)message success:(void (^)(NSString *messageId))success failure:(void (^)(NSError *error))failure;

///----------------------------------------
/// @name Sending an Ad-Hoc Mailgun Message
///----------------------------------------

/**
 Sends a simple message without success or failure blocks.
 
 @param to The message recipient. Must not be nil.
 @param from The message sender. Must not be nil.
 @param subject The message subject. Must not be nil.
 @param body The body of the message.
 */
- (void)sendMessageTo:(NSString *)to from:(NSString *)from subject:(NSString *)subject body:(NSString *)body;

/**
 Sends a simple message with success or failure blocks.
 
 @param to The message recipient. Must not be nil.
 @param from The message sender. Must not be nil.
 @param subject The message subject. Must not be nil.
 @param body The body of the message.
 @param success A block called when the message is sent successfully called with a parameter `NSString` of the message id.
 @param failure A block called when the underlying HTTP request fails. It will be called with an `NSError` set by the underlying `AFNetworking` client.
 */
- (void)sendMessageTo:(NSString *)to
                 from:(NSString *)from
              subject:(NSString *)subject
                 body:(NSString *)body
              success:(void (^)(NSString *messageId))success
              failure:(void (^)(NSError *error))failure;

///-----------------------------------------
/// @name Checking Mailing List Subscription
///-----------------------------------------

/**
 Checks if the given email address is a current subscriber to the specified mailing list.
 
 @param list The mailing list to check for the provided email address. Must not be nil.
 @param emailAddress Email address to check for list membership. Must not be nil.
 @param success A block called when the email address is found as a subscriber to `list`, called with a `NSDictionary` of member information.
 @param failure A block called when the email address is not found as a subscriber to `list`. The `NSError` will be an HTTP 404.
 */
- (void)checkSubscriptionToList:(NSString *)list
                          email:(NSString *)emailAddress
                        success:(void (^)(NSDictionary *member))success
                        failure:(void (^)(NSError *error))failure;

///-------------------------------------------------
/// @name Subscribing/Unsubscribing to Mailing Lists
///-------------------------------------------------

/**
 Unsubscribes the given email address to the specified mailing list.
 
 @param list The mailing list to unsubscribe the given email address from. Must not be nil.
 @param emailAddress Email address to check for list membership. Must not be nil.
 @param success A block called when the email address is successfully removed from the mailing list.
 @param failure A block called when the email address is not found as a subscriber to `list`. The `NSError` will be an HTTP 404.
 */
- (void)unsubscribeToList:(NSString *)list
                    email:(NSString *)emailAddress
                  success:(void (^)())success
                  failure:(void (^)(NSError *error))failure;

/**
 Subscribes the given email address to the specified mailing list.
 
 @param list The mailing list to subscribe the provided email address to. Must not be nil.
 @param emailAddress Email address to subscribe. Must not be nil.
 @param success A block called when the email address is successfully subscribed to the mailing list.
 @param failure A block called when there is an error subscribing the user to the given mailing list.
 */
- (void)subscribeToList:(NSString *)list 
                  email:(NSString *)emailAddress
                success:(void (^)())success
                failure:(void (^)(NSError *error))failure;
@end
