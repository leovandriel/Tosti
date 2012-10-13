//
//  TOTest.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TORead.h"
#import "TOEval.h"
#import "TOMem.h"

@interface TOTest : SenTestCase <TODelegate> @end

@implementation TOTest {
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

- (void)run:(NSString *)code
{
    [_mem run:code delegate:self];
}


#pragma mark - Values and Types

- (void)testNil
{
    STAssertEqualObjects([_mem get:@"nil"], nil, @"");
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self run:@"x"];
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self run:@"x=nil"];
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self run:@"x=[nil length]"];
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self run:@"x=y"];
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self run:@"x=z()"];
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self run:@"x=[a b]"];
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testNumberAndString
{
    [self run:@"x=1"];
    STAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self run:@"x=\"1\""];
    STAssertEqualObjects([_mem get:@"x"], @"1", @"");
    [self run:@"x='1'"];
    STAssertEqualObjects([_mem get:@"x"], @"1", @"");
    [self run:@"x=@1"];
    STAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self run:@"x=@\"1\""];
    STAssertEqualObjects([_mem get:@"x"], @"1", @"");
    [self run:@"x=@'1'"];
    STAssertEqualObjects([_mem get:@"x"], @"1", @"");
    [self run:@"x=@y"];
    STAssertEqualObjects([_mem get:@"x"], @"y", @"");
    [self run:@"x=@\"1\\\"\""];
    STAssertEqualObjects([_mem get:@"x"], @"1\"", @"");
    [self run:@"x=@\"\\\"1\""];
    STAssertEqualObjects([_mem get:@"x"], @"\"1", @"");
    [self run:@"x=@'1\\''"];
    STAssertEqualObjects([_mem get:@"x"], @"1'", @"");
    [self run:@"x=@'\\'1'"];
    STAssertEqualObjects([_mem get:@"x"], @"'1", @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testArray
{
    [self run:@"x=@[]"];
    STAssertEqualObjects([_mem get:@"x"], @[], @"");
    [self run:@"x=@[@1]"];
    STAssertEqualObjects([_mem get:@"x"], @[@1], @"");
    [self run:@"x = @ [ @ \"1\" , @ 1 ] "]; id x = @ [ @ "1" , @ 1 ];
    STAssertEqualObjects([_mem get:@"x"], x, @"");
    [self run:@"x=@[1]x=x[0]"];
    STAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self run:@"x=@[1 2][1]"];
    STAssertEqualObjects([_mem get:@"x"], @2, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testDictionary
{
    [self run:@"x=@{}"];
    STAssertEqualObjects([_mem get:@"x"], @{}, @"");
    [self run:@"x=@{@1}"];
    STAssertEqualObjects([_mem get:@"x"], @{@1:NSNull.null}, @"");
    [self run:@"x=@{@1:}"];
    STAssertEqualObjects([_mem get:@"x"], @{@1:NSNull.null}, @"");
    [self run:@"x=@{@1:@2}"];
    STAssertEqualObjects([_mem get:@"x"], @{@1:@2}, @"");
    [self run:@"x=@{@\"1\":@\"2\",@1:@2}"]; id x = @{@"1":@"2",@1:@2};
    STAssertEqualObjects([_mem get:@"x"], x, @"");
    [self run:@"x = @ { 1 : 2 } x = x[ 1 ] "];
    STAssertEqualObjects([_mem get:@"x"], @ 2, @"");
    STAssertEqualObjects(_logs, @"", @"");
}


#pragma mark - Basic syntax

- (void)testAssignment
{
    [self run:@"x='test'"];
    STAssertEqualObjects([_mem get:@"x"], @"test", @"");
    [self run:@"x=3"];
    STAssertEqualObjects([_mem get:@"x"], @3, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testDotNotation
{
    [self run:@"x='A'x=x.lowercaseString"];
    STAssertEqualObjects([_mem get:@"x"], @"a", @"");
    [self run:@"x=x.lowercaseString.uppercaseString"];
    STAssertEqualObjects([_mem get:@"x"], @"A", @"");
    [self run:@"x=['B' lowercaseString].uppercaseString"];
    STAssertEqualObjects([_mem get:@"x"], @"B", @"");
    [self run:@"x.string='b'.description"];
    STAssertEqualObjects([_mem get:@"x"], @"b", @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testSpaces
{
    [self run:@"  x  =  3  "];
    STAssertEqualObjects([_mem get:@"x"], @3, @"");
    [self run:@"  x  =  '  test  '  "];
    STAssertEqualObjects([_mem get:@"x"], @"  test  ", @"");
    [self run:@"  x  =  [  [  '  test  '  stringByAppendingString  :  '  ing..  '  ]  stringByAppendingString  :  [  x  stringByAppendingString  :  '  ..  '  ]  ]  "];
    STAssertEqualObjects([_mem get:@"x"], @"  test    ing..    test    ..  ", @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testScope
{
    [self run:@"{}x={}"];
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    [self run:@"{x=1}"];
    STAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self run:@"{{x=2}}"];
    STAssertEqualObjects([_mem get:@"x"], @2, @"");
    [self run:@"x={x=2 y=3}"];
    STAssertEqualObjects([_mem get:@"x"], @3, @"");
    [self run:@"x={x=3{y=4}}"];
    STAssertEqualObjects([_mem get:@"x"], @4, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testBlocks
{
    [self run:@"x=^{y=7 return;y=5}x()"];
    STAssertEqualObjects([_mem get:@"y"], @7, @"");
    [self run:@"x=^{return 5}y=x()"];
    STAssertEqualObjects([_mem get:@"y"], @5, @"");
    [self run:@"x=^{2}()"];
    STAssertEqualObjects([_mem get:@"x"], @2, @"");
    [self run:@"x=^{@[3 4]}()[1]"];
    STAssertEqualObjects([_mem get:@"x"], @4, @"");
    [self run:@"x=^{@[3 ^{5}]}()[1]()"];
    STAssertEqualObjects([_mem get:@"x"], @5, @"");
    STAssertEqualObjects(_logs, @"", @"");
}


#pragma mark - Classes

- (void)testClass
{
    [self run:@"x=[[NSArray alloc]init]"];
    STAssertEqualObjects([_mem get:@"x"], [NSArray array], @"");
    [self run:@"x=[NSArray array]"];
    STAssertEqualObjects([_mem get:@"x"], [NSArray array], @"");
    [self run:@"x=[[NSArray arrayWithObject:x]count]"];
    STAssertEqualObjects([_mem get:@"x"], @1, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testString
{
    [self run:@"a='test'"];
    [self run:@"v1=[a length]"];
    STAssertEqualObjects([_mem get:@"v1"], @4, @"");
    [self run:@"v2=[a stringByReplacingOccurrencesOfString:'st'withString:'sted']"];
    STAssertEqualObjects([_mem get:@"v2"], @"tested", @"");
    
    [self run:@"b='ing' v2=[a stringByAppendingString:b]"];
    STAssertEqualObjects([_mem get:@"v2"], @"testing", @"");
    
    [self run:@"x=[['test'stringByAppendingString:'ing..']stringByAppendingString:[v2 stringByAppendingString:'..']]"];
    STAssertEqualObjects([_mem get:@"x"], @"testing..testing..", @"");
    
    [self run:@"v4=4 v3=[v2 substringFromIndex:v4]"];
    STAssertEqualObjects([_mem get:@"v3"], @"ing", @"");
    STAssertEqualObjects(_logs, @"", @"");
}


#pragma mark - Debug

- (void)xtestException
{
    [self run:@"x=['' stringByAppendingString:nil]"];
    STAssertEqualObjects([_mem get:@"x"], nil, @"");
    STAssertEqualObjects(_logs, @"Exception '*** -[__NSCFString stringByAppendingString:]: nil argument' at 'x=`['' stringByAppendin..' (2)\n", @"");
}

- (void)testIllegals
{
    _logs = @""; [self run:@"["];
    STAssertEqualObjects(_logs, @"expecting method target at '[`'\n", @"");
    _logs = @""; [self run:@"[]"];
    STAssertEqualObjects(_logs, @"expecting method target at '[]`'\n", @"");
    _logs = @""; [self run:@"[x]"];
    STAssertEqualObjects(_logs, @"expecting method selector at '[x]`'\n", @"");
    _logs = @""; [self run:@"("];
    STAssertEqualObjects(_logs, @"expecting scope at '`('\n", @"");
}


#pragma mark - TO toolkit

- (void)testMath
{
    [self run:@"x=TO.add()"];
    STAssertEqualObjects([_mem get:@"x"], @0, @"");
    [self run:@"x=TO.add(1)"];
    STAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self run:@"x=TO.add(1 2)"];
    STAssertEqualObjects([_mem get:@"x"], @3, @"");
    [self run:@"x=TO.add(1 2 3)"];
    STAssertEqualObjects([_mem get:@"x"], @3, @"");
    [self run:@"x=TO.add(@[])"];
    STAssertEqualObjects([_mem get:@"x"], @0, @"");
    [self run:@"x=TO.add(@[1])"];
    STAssertEqualObjects([_mem get:@"x"], @1, @"");
    [self run:@"x=TO.add(@[1 2])"];
    STAssertEqualObjects([_mem get:@"x"], @3, @"");
    [self run:@"x=TO.add(@[1 2 3])"];
    STAssertEqualObjects([_mem get:@"x"], @6, @"");
    [self run:@"x=TO.add('1' 2)"];
    STAssertEqualObjects([_mem get:@"x"], @0, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testFor
{
    [self run:@"x=0 [TO while:^{x=TO.inc(x)TO.less(@[x 5])}]"];
    STAssertEqualObjects([_mem get:@"x"], @5, @"");
    STAssertEqualObjects(_logs, @"", @"");
}


#pragma mark - Integration

- (void)testArrayAverage
{
    [self run:@"id a = @ [ @ 1 , @ 2 , @ 4 ] ; __block id x = @ 0 ; [ TO for : ^ ( id i ) { x = TO.add ( @ [ x , a[ [ i integerValue ] ] ] ) ; } to : @ ( [ a count ] ) ] ;"];
    STAssertEqualObjects([_mem get:@"x"], @7, @"");
    [self run:@"a=@[1 2 6]x=0 [TO for:^(i){x=TO.add(x a[i])} to:a.count]x=TO.div(x,a.count)"];
    STAssertEqualObjects([_mem get:@"x"], @3, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

- (void)testMeta
{
    [self run:@"x=3"];
    STAssertEqualObjects([_mem get:@"x"], @3, @"");
    [self run:@"mem = [[TOMem alloc] init];[mem run:'x=3'];y=[mem get:'x'];"];
    STAssertEqualObjects([_mem get:@"y"], @3, @"");
    [self run:@"mem = [[TOMem alloc] init];[mem run:'mem = [[TOMem alloc] init];[mem run:\\'x=3\\'];y=[mem get:\\'x\\'];'];z=[mem get:'y'];"];
    STAssertEqualObjects([_mem get:@"z"], @3, @"");
    STAssertEqualObjects(_logs, @"", @"");
}

@end
