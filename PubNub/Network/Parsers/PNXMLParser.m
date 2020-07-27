/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNXML+Private.h"
#import "PNXMLParser.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNXMLParser () <NSXMLParserDelegate>


#pragma mark - Information

/**
 * @brief Stores nested elements stack.
 */
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *elementsStack;

/**
 * @brief Dictionary which hold data which has been parsed by \a XMLParser.
 */
@property (nonatomic, strong) NSMutableDictionary *parsedData;

/**
 * @brief \a NSXMLParser which will be used to handle provided data.
 */
@property (nonatomic, strong) NSXMLParser *xmlParser;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize XML parser.
 *
 * @param data Data which should be parsed.
 *
 * @return Initialized and ready to use XML parser.
 */
- (instancetype)initWithData:(NSData *)data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNXMLParser


#pragma mark - Information

- (NSError *)parserError {
    return self.xmlParser.parserError;
}


#pragma mark - Initialization & Configuration

+ (instancetype)parserWithData:(NSData *)data {
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSData *)data {
    if ((self = [super init])) {
        _xmlParser = [[NSXMLParser alloc] initWithData:data];
        _parsedData = [NSMutableDictionary new];
        _elementsStack = [NSMutableArray arrayWithObject:_parsedData];
        _xmlParser.delegate = self;
    }
    
    return self;
}


#pragma mark - Parse

- (PNXML *)parse {
    PNXML *parsed = nil;
    
    if ([self.xmlParser parse]) {
        parsed = [PNXML xmlWithDictionary:self.parsedData];
    }
    
    return parsed;
}


#pragma mark - XML parser delegate

- (void)parser:(NSXMLParser *)parser
  didStartElement:(NSString *)elementName
     namespaceURI:(NSString *)namespaceURI
    qualifiedName:(NSString *)qName
       attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    
    NSMutableDictionary *element = [NSMutableDictionary dictionaryWithDictionary:@{
        @"name": elementName
    }];
    
    if (attributeDict.count) {
        element[@"attributes"] = attributeDict;
    }
    
    NSMutableDictionary *parentElement = self.elementsStack.lastObject;
    parentElement[elementName] = element;
    
    [self.elementsStack addObject:element];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSMutableDictionary *element = self.elementsStack.lastObject;
    NSMutableString *value = element[@"value"];
    
    if (!value) {
        value = [NSMutableString new];
        element[@"value"] = value;
    }
    
    [value appendString:string];
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
    [self parser:parser foundCharacters:whitespaceString];
}

- (void)parser:(NSXMLParser *)parser
  didEndElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName {
    
    [self.elementsStack removeLastObject];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self.elementsStack removeAllObjects];
}

#pragma mark -


@end
