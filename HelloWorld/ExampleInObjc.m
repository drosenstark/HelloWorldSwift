#import "ExampleInObjc.h"
#import "HelloWorld-Swift.h"

@implementation ExampleInObjc

+ (void) doSomethingClass {}

- (void) doSomething {
    ExampleInSwift *thing = [[ExampleInSwift alloc] init];
    NSLog(@"yes I have a swift class %@", thing);
}

@end
