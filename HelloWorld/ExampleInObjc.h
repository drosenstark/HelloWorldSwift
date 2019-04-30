#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExampleInObjc : NSObject

+ (void) doSomethingClass;
- (void) doSomething;
- (void) processArgument:(NSString*)someArg;

@end

NS_ASSUME_NONNULL_END
