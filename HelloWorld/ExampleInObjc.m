#import "ExampleInObjc.h"
#import "HelloWorld-Swift.h"

@implementation ExampleInObjc

+ (void) doSomethingClass {}

- (void) doSomething {
    ExampleInSwift *thing = [[ExampleInSwift alloc] init];
    NSLog(@"yes I have a swift class %@", thing);
}

- (void) processArgument:(NSString*)someArg {
    NSLog(@"Did something with %@", someArg);
}

@end
