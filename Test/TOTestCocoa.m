//
//  TOTestCocoa.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TORead.h"
#import "TOEval.h"
#import "TOMem.h"

@interface TOTestCocoa : XCTestCase <TODelegate> @end

@implementation TOTestCocoa {
    NSString *_logs;
    TOMem *_mem;
}

- (void)setUp
{    
    [super setUp];
    _logs = @"";
    _mem = [[TOMem alloc] init];
    [self eval:@"TO.load(_mem, TOCocoa)"];
}

- (void)log:(NSString *)line
{
    _logs = [_logs stringByAppendingFormat:@"%@\n", line];
}

- (void)eval:(NSString *)code
{
    [_mem eval:code delegate:self];
}


- (void)testFoundation
{
    [self eval:@"x=NSStringFromClass(NSClassFromString('TO'))"];
    XCTAssertEqualObjects([_mem get:@"x"], @"TO", @"");
    [self eval:@"x=NSStringFromProtocol(NSProtocolFromString('TODelegate'))"];
    XCTAssertEqualObjects([_mem get:@"x"], @"TODelegate", @"");
    [self eval:@"x=NSStringFromSelector(NSSelectorFromString('stringByAppendingString:'))"];
    XCTAssertEqualObjects([_mem get:@"x"], @"stringByAppendingString:", @"");
    [self eval:@"y=NSMakeRange(1 2) x=y.location"];
    XCTAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self eval:@"x=y.length"];
    XCTAssertEqualObjects([_mem get:@"x"], @2, @"");
    XCTAssertEqualObjects(_logs, @"", @"");
}


- (void)testCoreGraphics
{
    [self eval:@"y=CGRectMake(1 2 3 4) x=y.origin.x"];
    XCTAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self eval:@"x=y.origin.y"];
    XCTAssertEqualObjects([_mem get:@"x"], @2, @"");
    [self eval:@"x=y.size.width"];
    XCTAssertEqualObjects([_mem get:@"x"], @3, @"");
    [self eval:@"x=y.size.height"];
    XCTAssertEqualObjects([_mem get:@"x"], @4, @"");
    XCTAssertEqualObjects(_logs, @"", @"");
}

- (void)testStringFrom
{
    [self eval:@"x=NSStringFromRect(NSMakeRect(1 2 3 4))"];
    XCTAssertEqualObjects([_mem get:@"x"], @"{{1, 2}, {3, 4}}", @"");
    [self eval:@"x=NSStringFromPoint(NSMakePoint(1 2))"];
    XCTAssertEqualObjects([_mem get:@"x"], @"{1, 2}", @"");
    [self eval:@"x=NSStringFromSize(NSMakeSize(2 3))"];
    XCTAssertEqualObjects([_mem get:@"x"], @"{2, 3}", @"");
    [self eval:@"x=NSStringFromCGRect(CGRectMake(1 2 3 4))"];
    XCTAssertEqualObjects([_mem get:@"x"], @"{{1, 2}, {3, 4}}", @"");
    [self eval:@"x=NSStringFromCGPoint(CGPointMake(1 2))"];
    XCTAssertEqualObjects([_mem get:@"x"], @"{1, 2}", @"");
    [self eval:@"x=NSStringFromCGSize(CGSizeMake(2 3))"];
    XCTAssertEqualObjects([_mem get:@"x"], @"{2, 3}", @"");
}

@end
