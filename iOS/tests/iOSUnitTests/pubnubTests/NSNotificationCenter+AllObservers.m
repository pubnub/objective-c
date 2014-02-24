#import <Foundation/Foundation.h>
#import <objc/runtime.h>


@interface NSNotificationCenter (AllObservers)

- (NSSet *) my_observersForNotificationName:(NSString *)notificationName;

@end


@implementation NSNotificationCenter (AllObservers)

const static void *namesKey = &namesKey;

+ (void) load
{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(addObserver:selector:name:object:)),
                                   class_getInstanceMethod(self, @selector(my_addObserver:selector:name:object:)));
}

- (void) my_addObserver:(id)notificationObserver selector:(SEL)notificationSelector name:(NSString *)notificationName object:(id)notificationSender
{
    [self my_addObserver:notificationObserver selector:notificationSelector name:notificationName object:notificationSender];

    if (!notificationObserver || !notificationName)
        return;

    NSMutableDictionary *names = objc_getAssociatedObject(self, namesKey);
    if (!names)
    {
        names = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, namesKey, names, OBJC_ASSOCIATION_RETAIN);
    }

    NSMutableSet *observers = [names objectForKey:notificationName];
	NSDictionary *observerInfo = @{@"observer":notificationObserver, @"selector":NSStringFromSelector(notificationSelector)};
    if (!observers)
    {
        observers = [NSMutableSet setWithObject:observerInfo];
        [names setObject:observers forKey:notificationName];
    }
    else
    {
        [observers addObject:observerInfo];
    }
}

- (NSSet *) my_observersForNotificationName:(NSString *)notificationName
{
    NSMutableDictionary *names = objc_getAssociatedObject(self, namesKey);
    return [names objectForKey:notificationName] ?: [NSSet set];
}

@end