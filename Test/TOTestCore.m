//
//  TOTestCore.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TORead.h"
#import "TOEval.h"
#import "TOMem.h"


@interface TOTestCore : XCTestCase <TODelegate> @end

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

- (id)eval:(NSString *)code
{
    return [_mem eval:code delegate:self];
}


#pragma mark - Values and Types

- (void)testNil
{
    XCTAssertEqualObjects([_mem get:@"nil"], nil, @"");
    XCTAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self eval:@"x"];
    XCTAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self eval:@"x=nil"];
    XCTAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self eval:@"x=[nil length]"];
    XCTAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self eval:@"x=y"];
    XCTAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self eval:@"x=z()"];
    XCTAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self eval:@"x=[a b]"];
    XCTAssertEqualObjects([_mem get:@"x"], nil, @"");
    XCTAssertEqualObjects(_logs, @"", @"");
}

- (void)testNumberAndString
{
    [self eval:@"x=1"];
    XCTAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self eval:@"x=\"1\""];
    XCTAssertEqualObjects([_mem get:@"x"], @"1", @"");
    [self eval:@"x='1'"];
    XCTAssertEqualObjects([_mem get:@"x"], @"1", @"");
    [self eval:@"x=@1"];
    XCTAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self eval:@"x=@\"1\""];
    XCTAssertEqualObjects([_mem get:@"x"], @"1", @"");
    [self eval:@"x=@'1'"];
    XCTAssertEqualObjects([_mem get:@"x"], @"1", @"");
    [self eval:@"x=@y"];
    XCTAssertEqualObjects([_mem get:@"x"], @"y", @"");
    [self eval:@"x=@\"1\\\"\""];
    XCTAssertEqualObjects([_mem get:@"x"], @"1\"", @"");
    [self eval:@"x=@\"\\\"1\""];
    XCTAssertEqualObjects([_mem get:@"x"], @"\"1", @"");
    [self eval:@"x=@'1\\''"];
    XCTAssertEqualObjects([_mem get:@"x"], @"1'", @"");
    [self eval:@"x=@'\\'1'"];
    XCTAssertEqualObjects([_mem get:@"x"], @"'1", @"");
    [self eval:@"x=-1"];
    XCTAssertEqualObjects([_mem get:@"x"], @-1, @"");
    [self eval:@"x=.1"];
    XCTAssertEqualObjects([_mem get:@"x"], @.1, @"");
    [self eval:@"x=1.1"];
    XCTAssertEqualObjects([_mem get:@"x"], @1.1, @"");
    [self eval:@"x=-.1"];
    XCTAssertEqualObjects([_mem get:@"x"], @-.1, @"");
    XCTAssertEqualObjects(_logs, @"", @"");
}

- (void)testArray
{
    XCTAssertEqualObjects([self eval:@"@[]"], @[], @"");
    XCTAssertEqualObjects([self eval:@"@[@1]"], @[@1], @"");
    id x = @ [ @ "1" , @ 1 ]; XCTAssertEqualObjects([self eval:@"@ [ @ \"1\" , @ 1 ] "], x, @"");
    [self eval:@"x=@[1]x=x[0]"];
    XCTAssertEqualObjects([_mem get:@"x"], @1, @"");
    XCTAssertEqualObjects([self eval:@"@[1 2][1]"], @2, @"");
    XCTAssertEqualObjects(_logs, @"", @"");
}

- (void)testDictionary
{
    XCTAssertEqualObjects([self eval:@"@{}"], @{}, @"");
    XCTAssertEqualObjects([self eval:@"@{@1}"], @{@1:NSNull.null}, @"");
    XCTAssertEqualObjects([self eval:@"@{@1:}"], @{@1:NSNull.null}, @"");
    XCTAssertEqualObjects([self eval:@"@{@1:@2}"], @{@1:@2}, @"");
    id x = @{@"1":@"2",@1:@2}; XCTAssertEqualObjects([self eval:@"@{@\"1\":@\"2\",@1:@2}"], x, @"");
    [self eval:@"x = @ { 1 : 2 } x = x[ 1 ] "];
    XCTAssertEqualObjects([_mem get:@"x"], @ 2, @"");
    XCTAssertEqualObjects(_logs, @"", @"");
}


#pragma mark - Basic syntax

- (void)testAssignment
{
    [self eval:@"x='test'"];
    XCTAssertEqualObjects([_mem get:@"x"], @"test", @"");
    [self eval:@"x=3"];
    XCTAssertEqualObjects([_mem get:@"x"], @3, @"");
    [self eval:@"x='' x.string='b'.description"];
    XCTAssertEqualObjects([_mem get:@"x"], @"b", @"");
    [self eval:@"x=@[] x[0]='b'"];
    XCTAssertEqualObjects([_mem get:@"x"], @[@"b"], @"");
    [self eval:@"x=@{} x['a']='b'"];
    XCTAssertEqualObjects([_mem get:@"x"], @{@"a":@"b"}, @"");
    XCTAssertEqualObjects(_logs, @"", @"");
}

- (void)testDotNotation
{
    [self eval:@"x='A'x=x.lowercaseString"];
    XCTAssertEqualObjects([_mem get:@"x"], @"a", @"");
    [self eval:@"x=x.lowercaseString.uppercaseString"];
    XCTAssertEqualObjects([_mem get:@"x"], @"A", @"");
    [self eval:@"x=['B' lowercaseString].uppercaseString"];
    XCTAssertEqualObjects([_mem get:@"x"], @"B", @"");
    XCTAssertEqualObjects(_logs, @"", @"");
}

- (void)testSpaces
{
    [self eval:@"  x  =  3  "];
    XCTAssertEqualObjects([_mem get:@"x"], @3, @"");
    [self eval:@"  x  =  '  test  '  "];
    XCTAssertEqualObjects([_mem get:@"x"], @"  test  ", @"");
    [self eval:@"  x  =  [  [  '  test  '  stringByAppendingString  :  '  ing..  '  ]  stringByAppendingString  :  [  x  stringByAppendingString  :  '  ..  '  ]  ]  "];
    XCTAssertEqualObjects([_mem get:@"x"], @"  test    ing..    test    ..  ", @"");
    XCTAssertEqualObjects(_logs, @"", @"");
}

- (void)testScope
{
    [self eval:@"{}x={}"];
    XCTAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self eval:@"{x=1}"];
    XCTAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self eval:@"{{x=2}}"];
    XCTAssertEqualObjects([_mem get:@"x"], @2, @"");
    [self eval:@"x={x=2 y=3}"];
    XCTAssertEqualObjects([_mem get:@"x"], @3, @"");
    [self eval:@"x={x=3{y=4}}"];
    XCTAssertEqualObjects([_mem get:@"x"], @4, @"");
    XCTAssertEqualObjects(_logs, @"", @"");
}

- (void)testBlocks
{
    [self eval:@"x=^{y=7 return;y=5}x()"];
    XCTAssertEqualObjects([_mem get:@"y"], @7, @"");
    [self eval:@"x=^{return 5}y=x()"];
    XCTAssertEqualObjects([_mem get:@"y"], @5, @"");
    [self eval:@"x=^{2}()"];
    XCTAssertEqualObjects([_mem get:@"x"], @2, @"");
    [self eval:@"x=^{@[3 4]}()[1]"];
    XCTAssertEqualObjects([_mem get:@"x"], @4, @"");
    [self eval:@"x=^{@[3 ^{5}]}()[1]()"];
    XCTAssertEqualObjects([_mem get:@"x"], @5, @"");
    XCTAssertEqualObjects(_logs, @"", @"");
}

- (void)testPointer
{
    [self eval:@"NSString *a = @'hello'"];
    XCTAssertEqualObjects([_mem get:@"a"], @"hello", @"");
    [self eval:@"NSString* b = @'hello'"];
    XCTAssertEqualObjects([_mem get:@"b"], @"hello", @"");
    [self eval:@"NSString * c = @'hello'"];
    XCTAssertEqualObjects([_mem get:@"c"], @"hello", @"");
}


#pragma mark - Classes

- (void)testClass
{
    XCTAssertEqualObjects([self eval:@"[[NSArray alloc]init]"], @[], @"");
    XCTAssertEqualObjects([self eval:@"[NSArray array]"], @[], @"");
    XCTAssertEqualObjects([self eval:@"[[NSArray arrayWithObject:@[]]count]"], @1, @"");
    XCTAssertEqualObjects(_logs, @"", @"");
}

- (void)testString
{
    [self eval:@"a='test'"];
    XCTAssertEqualObjects([self eval:@"[a length]"], @4, @"");
    XCTAssertEqualObjects([self eval:@"[a stringByReplacingOccurrencesOfString:'st'withString:'sted']"], @"tested", @"");
    [self eval:@"b='ing' x=[a stringByAppendingString:b]"];
    XCTAssertEqualObjects([_mem get:@"x"], @"testing", @"");
    [self eval:@"x=[['test'stringByAppendingString:'ing..']stringByAppendingString:[x stringByAppendingString:'..']]"];
    XCTAssertEqualObjects([_mem get:@"x"], @"testing..testing..", @"");
    [self eval:@"y=10 x=[x substringFromIndex:y]"];
    XCTAssertEqualObjects([_mem get:@"x"], @"esting..", @"");
    XCTAssertEqualObjects(_logs, @"", @"");
}


#pragma mark - Runtime

- (void)testSelector
{
    XCTAssertEqualObjects([self eval:@"['a' performSelector:@selector(uppercaseString)]"], @"A", @"");
    XCTAssertEqualObjects([self eval:@"['a' performSelector:@selector(stringByAppendingString:) withObject:'b']"], @"ab", @"");
    XCTAssertEqualObjects([self eval:@"['a' performSelector:@uppercaseString]"], @"A", @"");
    id x = @[@"a",@"b"]; XCTAssertEqualObjects([self eval:@"[@['b' 'a'] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]"], x, @"");
    XCTAssertEqualObjects([self eval:@"[NSString stringWithFormat:'a']"], @"a", @"");
    XCTAssertEqualObjects([self eval:@"[NSString stringWithFormat:'a%@c%@e','b','d']"], @"abcde", @"");
    XCTAssertEqualObjects([self eval:@"['a' stringByAppendingString:'b','c','d']"], @"ab", @"");
    XCTAssertEqualObjects(_logs, @"", @"");
}


#pragma mark - Debug

- (void)xtestException
{
    [self eval:@"x=['' stringByAppendingString:nil]"];
    XCTAssertEqualObjects([_mem get:@"x"], nil, @"");
    XCTAssertEqualObjects(_logs, @"Exception '*** -[__NSCFString stringByAppendingString:]: nil argument' at 'x=`['' stringByAppendin..' (2)\n", @"");
}

- (void)testIllegals
{
    _logs = @""; [self eval:@"["];
    XCTAssertEqualObjects(_logs, @"expecting method target at '[`'\n", @"");
    _logs = @""; [self eval:@"[]"];
    XCTAssertEqualObjects(_logs, @"expecting method target at '[]`'\n", @"");
    _logs = @""; [self eval:@"[x]"];
    XCTAssertEqualObjects(_logs, @"expecting method selector at '[x]`'\n", @"");
    _logs = @""; [self eval:@"("];
    XCTAssertEqualObjects(_logs, @"expecting scope at '`('\n", @"");
}


#pragma mark - Math Lib

- (void)testMath
{
    [self eval:@"TO.load(_mem, TOMath)"];
    XCTAssertEqualObjects([self eval:@"add()"], @0, @"");
    XCTAssertEqualObjects([self eval:@"add(1)"], @1, @"");
    XCTAssertEqualObjects([self eval:@"add(1 2)"], @3, @"");
    XCTAssertEqualObjects([self eval:@"add(1 2 3)"], @3, @"");
    XCTAssertEqualObjects([self eval:@"add(@[])"], @0, @"");
    XCTAssertEqualObjects([self eval:@"add(@[1])"], @1, @"");
    XCTAssertEqualObjects([self eval:@"add(@[1 2])"], @3, @"");
    XCTAssertEqualObjects([self eval:@"add(@[1 2 3])"], @6, @"");
    XCTAssertEqualObjects([self eval:@"add('1' 2)"], @0, @"");
    XCTAssertEqualObjects(_logs, @"", @"");
}

- (void)testFor
{
    [self eval:@"x=0 [TO while:^{x=TOMath.inc(x)TOMath.less(@[x 5])}]"];
    XCTAssertEqualObjects([_mem get:@"x"], @5, @"");
    XCTAssertEqualObjects(_logs, @"", @"");
}

@end
