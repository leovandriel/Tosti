//
//  TOTestCore.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TORead.h"
#import "TOEval.h"
#import "TOMem.h"


@interface TOTestCore : SenTestCase <TODelegate> @end

@implementation TOTestCore {
    NSString *_logs;
    TOMem *_mem;
}

- (void)setUp
{
    [super setUp];
    _logs = @"";
    _mem = [[TOMem alloc] init];
}

- (void)log:(NSString *)line
{
    _logs = [_logs stringByAppendingFormat:@"%@\n", line];
}

- (void)eval:(NSString *)code
{
    [_mem eval:code delegate:self];
}


#pragma mark - Values and Types

- (void)testNil
{
    STAssertEqualObjects([_mem get:@"nil"], nil, @"");
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self eval:@"x"];
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self eval:@"x=nil"];
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self eval:@"x=[nil length]"];
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self eval:@"x=y"];
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self eval:@"x=z()"];
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self eval:@"x=[a b]"];
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testNumberAndString
{
    [self eval:@"x=1"];
    STAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self eval:@"x=\"1\""];
    STAssertEqualObjects([_mem get:@"x"], @"1", @"");
    [self eval:@"x='1'"];
    STAssertEqualObjects([_mem get:@"x"], @"1", @"");
    [self eval:@"x=@1"];
    STAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self eval:@"x=@\"1\""];
    STAssertEqualObjects([_mem get:@"x"], @"1", @"");
    [self eval:@"x=@'1'"];
    STAssertEqualObjects([_mem get:@"x"], @"1", @"");
    [self eval:@"x=@y"];
    STAssertEqualObjects([_mem get:@"x"], @"y", @"");
    [self eval:@"x=@\"1\\\"\""];
    STAssertEqualObjects([_mem get:@"x"], @"1\"", @"");
    [self eval:@"x=@\"\\\"1\""];
    STAssertEqualObjects([_mem get:@"x"], @"\"1", @"");
    [self eval:@"x=@'1\\''"];
    STAssertEqualObjects([_mem get:@"x"], @"1'", @"");
    [self eval:@"x=@'\\'1'"];
    STAssertEqualObjects([_mem get:@"x"], @"'1", @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testArray
{
    [self eval:@"x=@[]"];
    STAssertEqualObjects([_mem get:@"x"], @[], @"");
    [self eval:@"x=@[@1]"];
    STAssertEqualObjects([_mem get:@"x"], @[@1], @"");
    [self eval:@"x = @ [ @ \"1\" , @ 1 ] "]; id x = @ [ @ "1" , @ 1 ];
    STAssertEqualObjects([_mem get:@"x"], x, @"");
    [self eval:@"x=@[1]x=x[0]"];
    STAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self eval:@"x=@[1 2][1]"];
    STAssertEqualObjects([_mem get:@"x"], @2, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testDictionary
{
    [self eval:@"x=@{}"];
    STAssertEqualObjects([_mem get:@"x"], @{}, @"");
    [self eval:@"x=@{@1}"];
    STAssertEqualObjects([_mem get:@"x"], @{@1:NSNull.null}, @"");
    [self eval:@"x=@{@1:}"];
    STAssertEqualObjects([_mem get:@"x"], @{@1:NSNull.null}, @"");
    [self eval:@"x=@{@1:@2}"];
    STAssertEqualObjects([_mem get:@"x"], @{@1:@2}, @"");
    [self eval:@"x=@{@\"1\":@\"2\",@1:@2}"]; id x = @{@"1":@"2",@1:@2};
    STAssertEqualObjects([_mem get:@"x"], x, @"");
    [self eval:@"x = @ { 1 : 2 } x = x[ 1 ] "];
    STAssertEqualObjects([_mem get:@"x"], @ 2, @"");
    STAssertEqualObjects(_logs, @"", @"");
}


#pragma mark - Basic syntax

- (void)testAssignment
{
    [self eval:@"x='test'"];
    STAssertEqualObjects([_mem get:@"x"], @"test", @"");
    [self eval:@"x=3"];
    STAssertEqualObjects([_mem get:@"x"], @3, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testDotNotation
{
    [self eval:@"x='A'x=x.lowercaseString"];
    STAssertEqualObjects([_mem get:@"x"], @"a", @"");
    [self eval:@"x=x.lowercaseString.uppercaseString"];
    STAssertEqualObjects([_mem get:@"x"], @"A", @"");
    [self eval:@"x=['B' lowercaseString].uppercaseString"];
    STAssertEqualObjects([_mem get:@"x"], @"B", @"");
    [self eval:@"x.string='b'.description"];
    STAssertEqualObjects([_mem get:@"x"], @"b", @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testSpaces
{
    [self eval:@"  x  =  3  "];
    STAssertEqualObjects([_mem get:@"x"], @3, @"");
    [self eval:@"  x  =  '  test  '  "];
    STAssertEqualObjects([_mem get:@"x"], @"  test  ", @"");
    [self eval:@"  x  =  [  [  '  test  '  stringByAppendingString  :  '  ing..  '  ]  stringByAppendingString  :  [  x  stringByAppendingString  :  '  ..  '  ]  ]  "];
    STAssertEqualObjects([_mem get:@"x"], @"  test    ing..    test    ..  ", @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testScope
{
    [self eval:@"{}x={}"];
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self eval:@"{x=1}"];
    STAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self eval:@"{{x=2}}"];
    STAssertEqualObjects([_mem get:@"x"], @2, @"");
    [self eval:@"x={x=2 y=3}"];
    STAssertEqualObjects([_mem get:@"x"], @3, @"");
    [self eval:@"x={x=3{y=4}}"];
    STAssertEqualObjects([_mem get:@"x"], @4, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testBlocks
{
    [self eval:@"x=^{y=7 return;y=5}x()"];
    STAssertEqualObjects([_mem get:@"y"], @7, @"");
    [self eval:@"x=^{return 5}y=x()"];
    STAssertEqualObjects([_mem get:@"y"], @5, @"");
    [self eval:@"x=^{2}()"];
    STAssertEqualObjects([_mem get:@"x"], @2, @"");
    [self eval:@"x=^{@[3 4]}()[1]"];
    STAssertEqualObjects([_mem get:@"x"], @4, @"");
    [self eval:@"x=^{@[3 ^{5}]}()[1]()"];
    STAssertEqualObjects([_mem get:@"x"], @5, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testPointer
{
    [self eval:@"NSString *a = @'hello'"];
    STAssertEqualObjects([_mem get:@"a"], @"hello", @"");
    [self eval:@"NSString* b = @'hello'"];
    STAssertEqualObjects([_mem get:@"b"], @"hello", @"");
    [self eval:@"NSString * c = @'hello'"];
    STAssertEqualObjects([_mem get:@"c"], @"hello", @"");
}


#pragma mark - Classes

- (void)testClass
{
    [self eval:@"x=[[NSArray alloc]init]"];
    STAssertEqualObjects([_mem get:@"x"], [NSArray array], @"");
    [self eval:@"x=[NSArray array]"];
    STAssertEqualObjects([_mem get:@"x"], [NSArray array], @"");
    [self eval:@"x=[[NSArray arrayWithObject:x]count]"];
    STAssertEqualObjects([_mem get:@"x"], @1, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testString
{
    [self eval:@"a='test'"];
    [self eval:@"v1=[a length]"];
    STAssertEqualObjects([_mem get:@"v1"], @4, @"");
    [self eval:@"v2=[a stringByReplacingOccurrencesOfString:'st'withString:'sted']"];
    STAssertEqualObjects([_mem get:@"v2"], @"tested", @"");
    
    [self eval:@"b='ing' v2=[a stringByAppendingString:b]"];
    STAssertEqualObjects([_mem get:@"v2"], @"testing", @"");
    
    [self eval:@"x=[['test'stringByAppendingString:'ing..']stringByAppendingString:[v2 stringByAppendingString:'..']]"];
    STAssertEqualObjects([_mem get:@"x"], @"testing..testing..", @"");
    
    [self eval:@"v4=4 v3=[v2 substringFromIndex:v4]"];
    STAssertEqualObjects([_mem get:@"v3"], @"ing", @"");
    STAssertEqualObjects(_logs, @"", @"");
}


#pragma mark - Runtime

- (void)testSelector
{
    [self eval:@"x=['a' performSelector:@selector(uppercaseString)]"];
    STAssertEqualObjects([_mem get:@"x"], @"A", @"");
    [self eval:@"x=['a' performSelector:@selector(stringByAppendingString:) withObject:'b']"];
    STAssertEqualObjects([_mem get:@"x"], @"ab", @"");
    [self eval:@"x=['a' performSelector:@uppercaseString]"];
    STAssertEqualObjects([_mem get:@"x"], @"A", @"");
    [self eval:@"x=[@['b' 'a'] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]"];
    id x = @[@"a",@"b"]; STAssertEqualObjects([_mem get:@"x"], x, @"");
    STAssertEqualObjects(_logs, @"", @"");
}


#pragma mark - Debug

- (void)xtestException
{
    [self eval:@"x=['' stringByAppendingString:nil]"];
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    STAssertEqualObjects(_logs, @"Exception '*** -[__NSCFString stringByAppendingString:]: nil argument' at 'x=`['' stringByAppendin..' (2)\n", @"");
}

- (void)testIllegals
{
    _logs = @""; [self eval:@"["];
    STAssertEqualObjects(_logs, @"expecting method target at '[`'\n", @"");
    _logs = @""; [self eval:@"[]"];
    STAssertEqualObjects(_logs, @"expecting method target at '[]`'\n", @"");
    _logs = @""; [self eval:@"[x]"];
    STAssertEqualObjects(_logs, @"expecting method selector at '[x]`'\n", @"");
    _logs = @""; [self eval:@"("];
    STAssertEqualObjects(_logs, @"expecting scope at '`('\n", @"");
}


#pragma mark - Math Lib

- (void)testMath
{
    [self eval:@"TO.load(_mem, TOMath)"];
    [self eval:@"x=add()"];
    STAssertEqualObjects([_mem get:@"x"], @0, @"");
    [self eval:@"x=add(1)"];
    STAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self eval:@"x=add(1 2)"];
    STAssertEqualObjects([_mem get:@"x"], @3, @"");
    [self eval:@"x=add(1 2 3)"];
    STAssertEqualObjects([_mem get:@"x"], @3, @"");
    [self eval:@"x=add(@[])"];
    STAssertEqualObjects([_mem get:@"x"], @0, @"");
    [self eval:@"x=add(@[1])"];
    STAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self eval:@"x=add(@[1 2])"];
    STAssertEqualObjects([_mem get:@"x"], @3, @"");
    [self eval:@"x=add(@[1 2 3])"];
    STAssertEqualObjects([_mem get:@"x"], @6, @"");
    [self eval:@"x=add('1' 2)"];
    STAssertEqualObjects([_mem get:@"x"], @0, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testFor
{
    [self eval:@"x=0 [TO while:^{x=TOMath.inc(x)TOMath.less(@[x 5])}]"];
    STAssertEqualObjects([_mem get:@"x"], @5, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

@end
