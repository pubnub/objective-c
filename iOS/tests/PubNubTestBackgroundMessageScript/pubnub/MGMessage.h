// MGMessage.h
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

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <UIKit/UIKit.h>
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
#import <Cocoa/Cocoa.h>
#endif

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
typedef NS_ENUM(NSUInteger, ImageAttachmentType) {
    PNGFileType,
    JPEGFileType,
};
#endif

typedef NS_ENUM(NSUInteger, ClickTrackingType) {
    TrackHTMLClicks,
    TrackAllClicks
};

@interface MGMessage : NSObject

///-----------------------------
/// @name Managing Message Setup
///-----------------------------

/**
 Email address for From header
*/
@property (nonatomic, strong) NSString *from;

/**
Email address of the recipient(s). Example: "Bob <bob@host.com>".
*/
@property (nonatomic, strong) NSArray *to;

/**
 Email address of the CC recipient(s). Example: "Bob <bob@host.com>".
 */
@property (nonatomic, strong) NSArray *cc;

/**
 Email address of the BCC recipient(s). Example: "Bob <bob@host.com>".
 */
@property (nonatomic, strong) NSArray *bcc;

/**
 Message subject
*/
@property (nonatomic, strong) NSString *subject;

/**
 Body of the message, text version
*/
@property (nonatomic, strong) NSString *text;

/**
 Body of the message. HTML version
*/
@property (nonatomic, strong) NSString *html;

///------------------------------------
/// @name Mailgun Message Configuration
///------------------------------------

/**
 ID of the campaign the message belongs to. See [Campaign Analytics](http://documentation.mailgun.net/user_manual.html#um-campaign-analytics) for details.
*/
@property (nonatomic, strong) NSString *campaign;

/**
 An `NSArray` of tag strings. See [Tagging](http://documentation.mailgun.net/user_manual.html#tagging) for more information.
*/
@property (nonatomic, strong, readonly) NSArray *tags;

/**
 `NSMutableDictionary` of custom MIME headers to the message. For example, `Reply-To` to specify a Reply-To address.
*/
@property (nonatomic, strong, readonly) NSMutableDictionary *headers;

/**
 `NSMutableDictionary` for attaching custom JSON data to the message. See [Attaching Data to Messages](http://documentation.mailgun.net/user_manual.html#manual-customdata) for more information.
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *variables;

/**
 `NSMutableDictionary` of attachments to the message.
*/
@property (nonatomic, strong, readonly) NSMutableDictionary *attachments;

/**
 `NSMutableDictionary` of inline message attachments.
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *inlineAttachments;

/**
 Enables/disables DKIM signatures on per-message basis.
*/
@property (nonatomic) BOOL *dkim;

/**
 Enables sending in test mode. See [Sending in Test Mode](http://documentation.mailgun.net/user_manual.html#manual-testmode)
*/
@property (nonatomic) BOOL *testing;

/**
 Toggles tracking on a per-message basis, see [Tracking Messages](http://documentation.mailgun.net/user_manual.html#tracking-messages) for details.
*/
@property (nonatomic) BOOL *tracking;

/**
 Toggles opens tracking on a per-message basis. Has higher priority than domain-level setting.
*/
@property (nonatomic) BOOL *trackOpens;

/**
 An `NSDate` representing the desired time of delivery.
*/
@property (nonatomic, strong) NSDate *deliverAt;

/**
 Toggles clicks tracking on a per-message basis. Has higher priority than domain-level setting.
*/
@property (nonatomic) ClickTrackingType trackClicks;

///--------------------------------------------------
/// @name Creating and Initializing a Mailgun Message
///--------------------------------------------------

/**
 Creates and initializes a message with the provided details.
 
 @param to The message recipient. Must not be nil.
 @param from The message sender. Must not be nil.
 @param subject The message subject. Must not be nil.
 @param body The body of the message.
 */
+ (instancetype)messageFrom:(NSString *)from
                         to:(NSString *)to
                    subject:(NSString *)subject
                       body:(NSString *)body;

/**
 The designated initializer to create a message with the provided details.
 
 @param to The message recipient. Must not be nil.
 @param from The message sender. Must not be nil.
 @param subject The message subject. Must not be nil.
 @param body The body of the message.
 */
- (id)initWithFrom:(NSString *)from
                to:(NSString *)to
           subject:(NSString *)subject
              body:(NSString *)body;

- (NSDictionary *)dictionary;

///------------------------------
/// @name Adding Message Metadata
///------------------------------

/**
 Adds a single tag to this recevier's metadata.
 
 @param tag The tag to add to this recevier's metadata. Must not be nil.
 */
- (void)addTag:(NSString *)tag;

/**
 Adds multiple tags to the recevier's metadata.
 
 @param tags An `NSArray` containing the tags to add to this recevier's metadata. Must not be nil.
 */
- (void)addTags:(NSArray *)tags;

/**
 Adds a header and value to the receiver's metadata.
 
 @param header The header identifier to add. Must not be nil.
 @param value The value for the identifier. Must not be nil.
 */
- (void)addHeader:(NSString *)header value:(NSString *)value;

/**
 Adds a variable and a value to the receiver.
 
 @param var The variable name. Must not be nil.
 @param value The value of the variable to display in the message.
 */
- (void)addVariable:(NSString *)var value:(NSString *)value;

///-----------------------------------
/// @name Adding Additional Recipients
///-----------------------------------

/**
 Adds an additional recipient to the receiver.
 
 @param recipient The recipient to add to the message. Must not be nil.
 */
- (void)addRecipient:(NSString *)recipient;

/**
 Adds a CC recipient to the receiver.
 
 @param recipient The recipient to add to the CC field of the message. Must not be nil.
 */
- (void)addCc:(NSString *)recipient;

/**
 Adds a BCC recipient to the receiver.
 
 @param recipient The recipient to add to the BCC field of the message. Must not be nil.
 */
- (void)addBcc:(NSString *)recipient;

///-------------------------
/// @name Adding Attachments
///-------------------------

/**
 Adds an attachment to the receiver.
 
 @param data The `NSData` to be attached to the message. Must not be nil.
 @param name The name used to identify this attachment in the message. Must not be nil.
 @param type The MIME type used to describe the contents of `data`. Must not be nil.
 */
- (void)addAttachment:(NSData *)data withName:(NSString *)name type:(NSString *)type;

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

/**
 Adds a `UIImage` as an attachment to the receiver.
 
 @param image The `UIImage` to be attached to the message. Must not be nil.
 @param name The name used to identify this image attachment in the message. Must not be nil.
 @param type The `ImageAttachmentType` to identify this image as a JPEG or a PNG.
 */
- (void)addImage:(UIImage *)image withName:(NSString *)name type:(ImageAttachmentType)type;

/**
 Adds a `UIImage` as an attachment to the receiver but inline in the message body.
 
 @param image The `UIImage` to be attached to the message. Must not be nil.
 @param name The name used to identify this attachment in the message. Must not be nil.
 @param type The `ImageAttachmentType` to identify this image as a JPEG or a PNG.
 */
- (void)addImage:(UIImage *)image withName:(NSString *)name type:(ImageAttachmentType)type inline:(BOOL)inlineAttachment;

#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)

/**
 Adds a `NSImage` as an attachment to the receiver.
 
 @param image The `NSImage` to be attached to the message. Must not be nil.
 @param name The name used to identify this image attachment in the message. Must not be nil.
 @param type The `NSBitmapImageFileType` identifying the type of image as JPEG or a PNG.
*/
- (void)addImage:(NSImage *)image withName:(NSString *)name type:(NSBitmapImageFileType)type;

/**
 Adds a `UIImage` as an attachment to the receiver but inline in the message body.
 
 @param image The `UIImage` to be attached to the message. Must not be nil.
 @param name The name used to identify this attachment in the message. Must not be nil.
 @param type The `NSBitmapImageFileType` identifying the type of image as JPEG or a PNG.
 */
- (void)addImage:(NSImage *)image withName:(NSString *)name type:(NSBitmapImageFileType)type inline:(BOOL)inlineAttachment;

#endif

@end
