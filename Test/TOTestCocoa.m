//
//  TOTestCocoa.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TORead.h"
#import "TOEval.h"
#import "TOMem.h"

@interface TOTestCocoa : SenTestCase <TODelegate> @end

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
    STAssertEqualObjects([_mem get:@"x"], @"TO", @"");
    [self eval:@"x=NSStringFromProtocol(NSProtocolFromString('TODelegate'))"];
    STAssertEqualObjects([_mem get:@"x"], @"TODelegate", @"");
    [self eval:@"x=NSStringFromSelector(NSSelectorFromString('stringByAppendingString:'))"];
    STAssertEqualObjects([_mem get:@"x"], @"stringByAppendingString:", @"");
    [self eval:@"y=NSMakeRange(1 2) x=y.location"];
    STAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self eval:@"x=y.length"];
    STAssertEqualObjects([_mem get:@"x"], @2, @"");
    STAssertEqualObjects(_logs, @"", @"");
}


- (void)testCoreGraphics
{
    [self eval:@"y=CGRectMake(1 2 3 4) x=y.origin.x"];
    STAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self eval:@"x=y.origin.y"];
    STAssertEqualObjects([_mem get:@"x"], @2, @"");
    [self eval:@"x=y.size.width"];
    STAssertEqualObjects([_mem get:@"x"], @3, @"");
    [self eval:@"x=y.size.height"];
    STAssertEqualObjects([_mem get:@"x"], @4, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

@end
