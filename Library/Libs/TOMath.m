//
//  TOMath.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import "TOMath.h"


@implementation TOMath

+ (id(^)(id,id))add
{
    return ^id(id a, id b) {
        if (![a isKindOfClass:NSArray.class]) a = a && b ? @[a, b] : a ? @[a] : nil;
        double result = 0;
        for (id i in a) {
            if (![i isKindOfClass:NSNumber.class]) return @0;
            result += [i doubleValue];
        }
        return @(result);
    };
}

+ (id(^)(id,id))mul
{
    return ^id(id a, id b) {
        if (![a isKindOfClass:NSArray.class]) a = a && b ? @[a, b] : a ? @[a] : nil;
        double result = 1;
        for (id i in a) {
            if (![i isKindOfClass:NSNumber.class]) return @0;
            result *= [i doubleValue];
        }
        return @(result);
    };
}

+ (id(^)(id,id))sub
{
    return ^id(id a, id b) {
        if (![a isKindOfClass:NSArray.class]) a = a && b ? @[a, b] : a ? @[a] : nil;
        double result = 0; BOOL first = YES;
        for (id i in a) {
            if (![i isKindOfClass:NSNumber.class]) return @0;
            if (first) result += [i doubleValue];
            else result -= [i doubleValue];
            first = NO;
        }
        return @(result);
    };
}

+ (id(^)(id,id))div
{
    return ^id(id a, id b) {
        if (![a isKindOfClass:NSArray.class]) a = a && b ? @[a, b] : a ? @[a] : nil;
        double result = 1; BOOL first = YES;
        for (id i in a) {
            if (![i isKindOfClass:NSNumber.class]) return @0;
            if (first) result *= [i doubleValue];
            else result /= [i doubleValue];
            first = NO;
        }
        return @(result);
    };
}

+ (id(^)(id,id))avg
{
    return ^id(id a, id b) {
        if (![a isKindOfClass:NSArray.class]) a = a && b ? @[a, b] : a ? @[a] : nil;
        double sum = 0;
        for (id i in a) {
            if (![i isKindOfClass:NSNumber.class]) return @0;
            sum += [i doubleValue];
        }
        return @(sum / [a count]);
    };
}

+ (id(^)(id,id))min
{
    return ^id(id a, id b) {
        if (![a isKindOfClass:NSArray.class]) a = a && b ? @[a, b] : a ? @[a] : nil;
        double result = 0; BOOL first = YES;
        for (id i in a) {
            if (![i isKindOfClass:NSNumber.class]) return @0;
            if (first) result = [i doubleValue];
            else if (result > [i doubleValue]) result = [i doubleValue];
            first = NO;
        }
        return @(result);
    };
}

+ (id(^)(id,id))max
{
    return ^id(id a, id b) {
        if (![a isKindOfClass:NSArray.class]) a = a && b ? @[a, b] : a ? @[a] : nil;
        double result = 0; BOOL first = YES;
        for (id i in a) {
            if (![i isKindOfClass:NSNumber.class]) return @0;
            if (first) result = [i doubleValue];
            else if (result < [i doubleValue]) result = [i doubleValue];
            first = NO;
        }
        return @(result);
    };
}

+ (id(^)(id))inc
{
    return ^id(id value) {
        if (![value isKindOfClass:NSNumber.class]) return @0;
        return @([value doubleValue] + 1);
    };
}

+ (id(^)(id))dec
{
    return ^id(id value) {
        if (![value isKindOfClass:NSNumber.class]) return @0;
        return @([value doubleValue] - 1);
    };
}

+ (id(^)(id))neg
{
    return ^id(id value) {
        if (![value isKindOfClass:NSNumber.class]) return @0;
        return @(-[value doubleValue]);
    };
}

+ (id(^)(id))inv
{
    return ^id(id value) {
        if (![value isKindOfClass:NSNumber.class]) return @0;
        return @(1/[value doubleValue]);
    };
}

+ (id(^)(id,id))less
{
    return ^id(id a, id b) {
        if (![a isKindOfClass:NSArray.class]) a = a && b ? @[a, b] : a ? @[a] : nil;
        double last = 0; BOOL first = YES;
        for (id i in a) {
            if (![i isKindOfClass:NSNumber.class]) return @NO;
            if (first) first = NO;
            else if (!(last < [i doubleValue])) return @NO;
            last = [i doubleValue];
        }
        return @YES;
    };
}

+ (id(^)(id,id))lessEq
{
    return ^id(id a, id b) {
        if (![a isKindOfClass:NSArray.class]) a = a && b ? @[a, b] : a ? @[a] : nil;
        double last = 0; BOOL first = YES;
        for (id i in a) {
            if (![i isKindOfClass:NSNumber.class]) return @NO;
            if (first) first = NO;
            else if (!(last <= [i doubleValue])) return @NO;
            last = [i doubleValue];
        }
        return @YES;
    };
}

+ (id(^)(id,id))greater
{
    return ^id(id a, id b) {
        if (![a isKindOfClass:NSArray.class]) a = a && b ? @[a, b] : a ? @[a] : nil;
        double last = 0; BOOL first = YES;
        for (id i in a) {
            if (![i isKindOfClass:NSNumber.class]) return @NO;
            if (first) first = NO;
            else if (!(last > [i doubleValue])) return @NO;
            last = [i doubleValue];
        }
        return @YES;
    };
}

+ (id(^)(id,id))greaterEq
{
    return ^id(id a, id b) {
        if (![a isKindOfClass:NSArray.class]) a = a && b ? @[a, b] : a ? @[a] : nil;
        double last = 0; BOOL first = YES;
        for (id i in a) {
            if (![i isKindOfClass:NSNumber.class]) return @NO;
            if (first) first = NO;
            else if (!(last >= [i doubleValue])) return @NO;
            last = [i doubleValue];
        }
        return @YES;
    };
}

@end
