//
// MGMessage.m
//
// Created by Jay Baird on 1/11/13
// Copyright (c) 2013 Rackspace Hosting. All rights reserved.
//

#import "MGMessage.h"

NSString * const kRFC2822Template = @"EEE, dd MMM yyyy HH:mm:ss Z";
@interface NSDate (RFC2822)
- (NSString *)rfc2822String;
+ (NSDate *)dateFromRFC2822String:(NSString *)string;
@end

@implementation NSDate (RFC2822)
- (NSString *)rfc2822String {
    NSDateFormatter *rfc2822Formatter = [[NSDateFormatter alloc] init];
    rfc2822Formatter.dateFormat = kRFC2822Template;
    return [rfc2822Formatter stringFromDate:self];
}

+ (NSDate *)dateFromRFC2822String:(NSString *)string {
    NSDateFormatter *rfc2822Formatter = [[NSDateFormatter alloc] init];
    rfc2822Formatter.dateFormat = kRFC2822Template;
    return [rfc2822Formatter dateFromString:string];
}
@end

@implementation MGMessage
+ (instancetype)messageFrom:(NSString *)from
                         to:(NSString *)to
                    subject:(NSString *)subject
                       body:(NSString *)body {
    MGMessage *message = [[MGMessage alloc] initWithFrom:from to:to subject:subject body:body];
    return message;
}

- (id)initWithFrom:(NSString *)from
                to:(NSString *)to
           subject:(NSString *)subject
              body:(NSString *)body {
    NSParameterAssert(from);
    NSParameterAssert(to);
    NSParameterAssert(subject);
    NSParameterAssert(body);
    self = [super init];
    if (self) {
        self.from = from;
        self.to = [to componentsSeparatedByString:@","];
        self.subject = subject;
        self.text = body;
    }
    return self;
}

- (void)addRecipient:(NSString *)recipient {
    NSParameterAssert(recipient);
    self.to = [self.to arrayByAddingObject:recipient];
}

- (void)addCc:(NSString *)recipient {
    NSParameterAssert(recipient);
    if (!self.cc) {
        self.cc = [NSArray arrayWithObject:recipient];
    } else {
        self.cc = [self.cc arrayByAddingObject:recipient];
    }
}

- (void)addBcc:(NSString *)recipient {
    NSParameterAssert(recipient);
    if (!self.bcc) {
        self.bcc = [NSArray arrayWithObject:recipient];
    } else {
        self.bcc = [self.bcc arrayByAddingObject:recipient];
    }
}

- (void)addTag:(NSString *)tag {
    NSParameterAssert(tag);
    _tags = [_tags arrayByAddingObject:tag];
}

- (void)addTags:(NSArray *)tags {
    NSParameterAssert(tags);
    if (!_tags) {
        _tags = [NSArray arrayWithArray:tags];
    } else {
        _tags = [_tags arrayByAddingObjectsFromArray:tags];
    }
}

- (void)addHeader:(NSString *)header value:(NSString *)value {
    NSParameterAssert(header);
    NSParameterAssert(value);
    if (!_headers) {
        _headers = [@{header: value} mutableCopy];
    } else {
        [_headers setObject:value forKey:header];
    }
}


- (void)addVariable:(NSString *)var value:(NSString *)value {
    NSParameterAssert(var);
    NSParameterAssert(value);
    if (!_variables) {
        _variables = [@{var: value} mutableCopy];
    } else {
        [_variables setObject:value forKey:var];
    }
}

- (void)addAttachment:(NSData *)data withName:(NSString *)name type:(NSString *)type {
    NSParameterAssert(data);
    NSParameterAssert(name);
    NSParameterAssert(type);
    if (!_attachments) {
        _attachments = [@{name: @[type, data]} mutableCopy];
    } else {
        [_attachments setObject:@[type, data] forKey:name];
    }
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *params = [@{
        @"to": [self.to componentsJoinedByString:@","],
        @"from": self.from,
        @"subject": self.subject,
        @"text": self.text
    } mutableCopy];
    
    if (self.cc) params[@"cc"] = [self.cc componentsJoinedByString:@","];
    if (self.bcc) params[@"bcc"] = [self.bcc componentsJoinedByString:@","];
    if (self.html) params[@"html"] = self.html;
    if (self.campaign) params[@"o:campaign"] = self.campaign;
    if (self.deliverAt) params[@"o:deliverytime"] = [self.deliverAt rfc2822String];
    
    NSDictionary *otherParams = @{
        @"o:dkim": (self.dkim) ? @"yes" : @"no",
        @"o:testmode": (self.testing) ? @"yes" : @"no",
        @"o:tracking": (self.tracking) ? @"yes" : @"no",
        @"o:tracking-clicks": (self.trackClicks == TrackHTMLClicks) ? @"htmlonly" : (self.trackClicks == TrackAllClicks) ? @"yes" : @"no",
        @"o:tracking-opens": (self.trackOpens) ? @"yes" : @"no"
    };
    [params addEntriesFromDictionary:otherParams];
    [_headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [params setObject:obj forKey:[NSString stringWithFormat:@"h:X-%@", key]];
    }];
    [_variables enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [params setObject:obj forKey:[NSString stringWithFormat:@"v:%@", key]];
    }];
    return [NSDictionary dictionaryWithDictionary:params];
}

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
- (void)addImage:(UIImage *)image withName:(NSString *)name type:(ImageAttachmentType)type {
    [self addImage:image withName:name type:type inline:NO];
}

- (void)addImage:(UIImage *)image withName:(NSString *)name type:(ImageAttachmentType)type inline:(BOOL)inlineAttachment {
    NSString *mimeType;
    NSData *data;
    switch (type) {
        case JPEGFileType:
            mimeType = @"image/jpg";
            data = UIImageJPEGRepresentation(image, 0.9f);
            break;
        case PNGFileType:
            mimeType = @"image/png";
            data = UIImagePNGRepresentation(image);
            break;
        default:
            @throw [NSException exceptionWithName:@"MGMessageException" reason:@"Unrecognized image type" userInfo:nil];
            break;
    }
    if (inlineAttachment) {
        if (!_inlineAttachments) {
            _inlineAttachments = [@{name: @[mimeType, data]} mutableCopy];
        } else {
            [_inlineAttachments setObject:@[mimeType, data] forKey:name];
        }
    } else {
        [self addAttachment:data withName:name type:mimeType];
    }
}
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
- (void)addImage:(NSImage *)image withName:(NSString *)name type:(NSBitmapImageFileType)type {
    [self addImage:image withName:name type:type inline:NO];
}

- (void)addImage:(NSImage *)image withName:(NSString *)name type:(NSBitmapImageFileType)type inline:(BOOL)inlineAttachment {
    NSString *mimeType;
    NSData *data;
    switch (type) {
        case NSTIFFFileType:
            mimeType = @"image/tiff";
            break;
        case NSPNGFileType:
            mimeType = @"image/png";
            break;
        case NSGIFFileType:
            mimeType = @"image/gif";
            break;
        case NSJPEGFileType:
            mimeType = @"image/jpg";
            break;
        case NSJPEG2000FileType:
            mimeType = @"image/jp2";
            break;
        default:
            @throw [NSException exceptionWithName:@"MGMessageException" reason:@"Unrecognized image type" userInfo:nil];
            break;
    }
    NSBitmapImageRep *imgRep = [[image representations] objectAtIndex: 0];
    data = [imgRep representationUsingType:type properties:nil];
    if (inlineAttachment) {
        if (!_inlineAttachments) {
            _inlineAttachments = [@{name: @[mimeType, data]} mutableCopy];
        } else {
            [_inlineAttachments setObject:@[mimeType, data] forKey:name];
        }
    } else {
        [self addAttachment:data withName:name type:mimeType];
    }
}
#endif
@end
