#import "ExampleInObjc.h"
#import "HelloWorld-Swift.h"

@interface ExampleInObjc()
@property (nonatomic, strong) NSString *someString;
@property (nonatomic, strong) NSString *someOtherString;
@end

@implementation ExampleInObjc

+ (void) doSomethingClass {}

- (void) doSomething {
    ExampleInSwift *thing = [[ExampleInSwift alloc] init];
    NSLog(@"yes I have a swift class %@", thing);
    NSLog(@"%@", _someString);
}

-(void)setSomeOtherString:(NSString *)someOtherString {
    _someOtherString = someOtherString;
}

//-(NSString *)someOtherString {
//    return _someOtherString;
//}

@end
