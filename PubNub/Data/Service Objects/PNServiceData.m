/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNServiceData+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNServiceData ()


#pragma mark - Information

@property (nonatomic, strong) NSDictionary<NSString *, id> *serviceData;


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize data object using \b PubNub service response dictionary.
 
 @param response Reference on dictionary which should be stored internally and used by subclasses
                 when give access to entries to the user.
 
 @return Initialized and ready to use service data object.
 
 @since 4.0
 */
- (instancetype)initWithServiceResponse:(NSDictionary<NSString *, id> *)response;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNServiceData


#pragma mark - Initialization and Configuration

+ (instancetype)dataWithServiceResponse:(NSDictionary *)response {
    
    return [[self alloc] initWithServiceResponse:response];
}

- (instancetype)initWithServiceResponse:(NSDictionary *)response {
    
    // Check whether initialization was successful or not
    if ((self = [super init])) {
        
        self.serviceData = (response?: @{});
        if (![response isKindOfClass:[NSDictionary class]]) { 
            self.serviceData = @{
                @"information": (response?: @"Something went really wrong or method has been called on "
                                 "inappropriate object.")
            }; 
        }
    }
    
    return self;
}

- (id)objectForKeyedSubscript:(id)key {
    
    return [self.serviceData objectForKeyedSubscript:key];
}

- (NSString *)description {
    
    return [self.serviceData description];
}

#pragma mark -


@end
