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

- (id)eval:(NSString *)code
{
    return [_mem eval:code delegate:self];
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
    [self eval:@"x=-1"];
    STAssertEqualObjects([_mem get:@"x"], @-1, @"");
    [self eval:@"x=.1"];
    STAssertEqualObjects([_mem get:@"x"], @.1, @"");
    [self eval:@"x=1.1"];
    STAssertEqualObjects([_mem get:@"x"], @1.1, @"");
    [self eval:@"x=-.1"];
    STAssertEqualObjects([_mem get:@"x"], @-.1, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testArray
{
    STAssertEqualObjects([self eval:@"@[]"], @[], @"");
    STAssertEqualObjects([self eval:@"@[@1]"], @[@1], @"");
    id x = @ [ @ "1" , @ 1 ]; STAssertEqualObjects([self eval:@"@ [ @ \"1\" , @ 1 ] "], x, @"");
    [self eval:@"x=@[1]x=x[0]"];
    STAssertEqualObjects([_mem get:@"x"], @1, @"");
    STAssertEqualObjects([self eval:@"@[1 2][1]"], @2, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testDictionary
{
    STAssertEqualObjects([self eval:@"@{}"], @{}, @"");
    STAssertEqualObjects([self eval:@"@{@1}"], @{@1:NSNull.null}, @"");
    STAssertEqualObjects([self eval:@"@{@1:}"], @{@1:NSNull.null}, @"");
    STAssertEqualObjects([self eval:@"@{@1:@2}"], @{@1:@2}, @"");
    id x = @{@"1":@"2",@1:@2}; STAssertEqualObjects([self eval:@"@{@\"1\":@\"2\",@1:@2}"], x, @"");
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
    [self eval:@"x='' x.string='b'.description"];
    STAssertEqualObjects([_mem get:@"x"], @"b", @"");
    [self eval:@"x=@[] x[0]='b'"];
    STAssertEqualObjects([_mem get:@"x"], @[@"b"], @"");
    [self eval:@"x=@{} x['a']='b'"];
    STAssertEqualObjects([_mem get:@"x"], @{@"a":@"b"}, @"");
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
    STAssertEqualObjects([self eval:@"[[NSArray alloc]init]"], @[], @"");
    STAssertEqualObjects([self eval:@"[NSArray array]"], @[], @"");
    STAssertEqualObjects([self eval:@"[[NSArray arrayWithObject:@[]]count]"], @1, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testString
{
    [self eval:@"a='test'"];
    STAssertEqualObjects([self eval:@"[a length]"], @4, @"");
    STAssertEqualObjects([self eval:@"[a stringByReplacingOccurrencesOfString:'st'withString:'sted']"], @"tested", @"");
    [self eval:@"b='ing' x=[a stringByAppendingString:b]"];
    STAssertEqualObjects([_mem get:@"x"], @"testing", @"");
    [self eval:@"x=[['test'stringByAppendingString:'ing..']stringByAppendingString:[x stringByAppendingString:'..']]"];
    STAssertEqualObjects([_mem get:@"x"], @"testing..testing..", @"");
    [self eval:@"y=10 x=[x substringFromIndex:y]"];
    STAssertEqualObjects([_mem get:@"x"], @"esting..", @"");
    STAssertEqualObjects(_logs, @"", @"");
}


#pragma mark - Runtime

- (void)testSelector
{
    STAssertEqualObjects([self eval:@"['a' performSelector:@selector(uppercaseString)]"], @"A", @"");
    STAssertEqualObjects([self eval:@"['a' performSelector:@selector(stringByAppendingString:) withObject:'b']"], @"ab", @"");
    STAssertEqualObjects([self eval:@"['a' performSelector:@uppercaseString]"], @"A", @"");
    id x = @[@"a",@"b"]; STAssertEqualObjects([self eval:@"[@['b' 'a'] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]"], x, @"");
    STAssertEqualObjects([self eval:@"[NSString stringWithFormat:'a']"], @"a", @"");
    STAssertEqualObjects([self eval:@"[NSString stringWithFormat:'a%@c%@e','b','d']"], @"abcde", @"");
    STAssertEqualObjects([self eval:@"['a' stringByAppendingString:'b','c','d']"], @"ab", @"");
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
    STAssertEqualObjects([self eval:@"add()"], @0, @"");
    STAssertEqualObjects([self eval:@"add(1)"], @1, @"");
    STAssertEqualObjects([self eval:@"add(1 2)"], @3, @"");
    STAssertEqualObjects([self eval:@"add(1 2 3)"], @3, @"");
    STAssertEqualObjects([self eval:@"add(@[])"], @0, @"");
    STAssertEqualObjects([self eval:@"add(@[1])"], @1, @"");
    STAssertEqualObjects([self eval:@"add(@[1 2])"], @3, @"");
    STAssertEqualObjects([self eval:@"add(@[1 2 3])"], @6, @"");
    STAssertEqualObjects([self eval:@"add('1' 2)"], @0, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testFor
{
    [self eval:@"x=0 [TO while:^{x=TOMath.inc(x)TOMath.less(@[x 5])}]"];
    STAssertEqualObjects([_mem get:@"x"], @5, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

@end
