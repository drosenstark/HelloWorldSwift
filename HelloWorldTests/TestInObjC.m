#import <XCTest/XCTest.h>
#import "ExampleInObjc.h"

@import Kiwi;

@interface TestInObjC : XCTestCase

@end

@implementation TestInObjC

- (void)testStubbingWithKiwiExamples {
    ExampleInObjc *stubMe = [[ExampleInObjc alloc] init];
    [stubMe stub:@selector(doSomething) andReturn:nil];

    [stubMe doSomething];

    [stubMe stub:@selector(processArgument:) andReturn:nil];

    [stubMe processArgument:@"whatever"];
}

@end
