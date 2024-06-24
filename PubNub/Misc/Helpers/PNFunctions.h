#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#ifndef PNFunctions_h
#define PNFunctions_h


#pragma mark - Object

/// Check whether `object` is kind of _any_ provided classes.
///
/// - Parameters:
///   - object: Object which is checked.
///   - classes: List of classes against which check should be done.
/// - Returns: `YES` in case if `aClass` is kind of at least one passes class.
extern BOOL PNNSObjectIsKindOfAnyClass(id object, NSArray<Class> *classes);

/// Check whether `aClass` is subclass of _any_ provided classes.
///
/// - Parameters:
///   - object: Object which is checked.
///   - classes: List of classes against which check should be done.
/// - Returns: `YES` in case if `aClass` is subclass of at least one passes class.
extern BOOL PNNSObjectIsSubclassOfAnyClass(id object, NSArray<Class> *classes);


#pragma mark - String

/// Construct `NSString` instance as formatted string.
///
/// - Parameters:
///   - format: String with placeholders for values in variable arguments list.
///   - ...: List of values which will substitute placeholders in format.
/// - Returns: `NSString` instance with pre-formatted text.
extern NSString * PNStringFormat(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);


#pragma mark - Errors

/// Construct `userInfo` dictionary for error description.
///
/// - Parameters:
///   - description: Short error description.
///   - reason: Insights on what may caused an error.
///   - recovery: Possible ways to recovery after reported error.
///   - error: Underlying error signalled by other sub-system.
/// - Returns: Dictionary with keys describing error.
extern NSDictionary * PNErrorUserInfo(NSString * _Nullable description,
                                      NSString * _Nullable reason,
                                      NSString * _Nullable recovery,
                                      NSError * _Nullable error);

#endif // PNFunctions_h

NS_ASSUME_NONNULL_END
