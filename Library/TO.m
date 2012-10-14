//
//  TO.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import "TO.h"
#import "TOMem.h"
#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>


@implementation TO

#pragma mark - Control flow helpers

+ (void)while:(id(^)(void))block
{
    if (block) for (BOOL b = YES; b; b = [block() boolValue]);
}

+ (void)for:(void(^)(id))block to:(id)to
{
    if (block) for (int i = 0; i < [to integerValue]; i++) block(@(i));
}

+ (id)if:(id)condition then:(id(^)(void))t
{
    if ([condition boolValue]) return t(); return nil;
}

+ (id)if:(id)condition then:(id(^)(void))t else:(id(^)(void))e
{
    if ([condition boolValue]) return t(); else return e();
}

+ (id)if:(id)condition then:(id(^)(void))t elseif:(id)condition2 then:(id(^)(void))t2 else:(id(^)(void))e
{
    if ([condition boolValue]) return t(); else if ([condition2 boolValue]) return t2(); else return e();
}


#pragma mark - Math helpers

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


#pragma mark - C function wrappers

+ (id(^)(id))NSStringFromClass
{
    return ^id(id value) {
        if (class_isMetaClass(object_getClass(value))) return NSStringFromClass(value);
        else return NSStringFromClass([value class]);
    };
}

+ (id(^)(id,id,id,id))CGRectMake
{
    return ^id(id x, id y, id w, id h) {
        if ([x isKindOfClass:NSArray.class] && [x count] == 4) {
            h = x[3]; w = x[2]; y = x[1]; x = x[0];
        }
        if ([x isKindOfClass:NSNumber.class] && [y isKindOfClass:NSNumber.class] && [w isKindOfClass:NSNumber.class] && [h isKindOfClass:NSNumber.class]) {
            CGRect rect = CGRectMake([x floatValue], [y floatValue], [w floatValue], [h floatValue]);
            return [[TOValue alloc] initWithBytes:&rect objCType:@encode(CGRect)];
        }
        return nil;
    };
}

+ (id(^)(id,id))CGSizeMake
{
    return ^id(id w, id h) {
        if ([w isKindOfClass:NSArray.class] && [w count] == 2) {
            h = w[1]; w = w[0];
        }
        if ([w isKindOfClass:NSNumber.class] && [h isKindOfClass:NSNumber.class]) {
            CGSize size = CGSizeMake([w floatValue], [h floatValue]);
            return [[TOValue alloc] initWithBytes:&size objCType:@encode(CGSize)];
        }
        return nil;
    };
}

+ (id(^)(id,id,id))dispatch_after
{
    return ^id(id delay, id queue, id block) {
        if ([delay isKindOfClass:NSArray.class] && [delay count] == 3) {
            block = delay[2]; queue = delay[1]; delay = delay[0];
        } else if (!block) {
            block = queue;
            queue = nil;
        }
        if (block) {
            double d = [delay isKindOfClass:NSNumber.class] ? [delay doubleValue] : 0.0;
            dispatch_time_t t = dispatch_time(DISPATCH_TIME_NOW, d * NSEC_PER_SEC);
            dispatch_queue_t q = [queue isKindOfClass:TOValue.class] ? (dispatch_queue_t)[queue pointerValue] : dispatch_get_main_queue();
            dispatch_after(t, q, block);
            return @YES;
        }
        return @NO;
    };
}

+ (id(^)(id,id))dispatch_async
{
    return ^id(id queue, id block) {
        if ([queue isKindOfClass:NSArray.class] && [queue count] == 2) {
            block = queue[1]; queue = queue[0];
        } else if (!block) {
            block = queue;
            queue = nil;
        }
        if (block) {
            dispatch_queue_t q = [queue isKindOfClass:TOValue.class] ? (dispatch_queue_t)[queue pointerValue] : dispatch_get_main_queue();
            dispatch_async(q, block);
            return @YES;
        }
        return @NO;
    };
}


#pragma mark - Inspection

+ (NSArray *)selectorsForObject:(id)object
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    unsigned int count = 0;
    Method *methods = class_copyMethodList(object_getClass(object), &count);
    for (NSUInteger i = 0; i < count; i++) {
        [result addObject:NSStringFromSelector(method_getName(methods[i]))];
    }
    free(methods);
    return result;
}

+ (id(^)(id))selectors
{
    return ^id(id value) {
        return [[self selectorsForObject:value] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    };
}

+ (id(^)(id))super
{
    return ^id(id value) {
        return class_getSuperclass([value class]);
    };
}

+ (id(^)(id,id,id,id))load
{
    return ^id(id mem, id targets, id target2, id target3) {
        if (![targets isKindOfClass:NSArray.class]) {
            NSMutableArray *t = [[NSMutableArray alloc] init];
            if (targets) [t addObject:targets];
            if (target2) [t addObject:target2];
            if (target3) [t addObject:target3];
            targets = t;
        }
        if ([mem isKindOfClass:TOMem.class]) {
            NSMutableArray *result = [[NSMutableArray alloc] init];
            for (id target in targets) {
                for (NSString *selector in [self selectorsForObject:target]) {
                    SEL sel = NSSelectorFromString(selector);
                    NSMethodSignature *signature = [target methodSignatureForSelector:sel];
                    if (signature.numberOfArguments == 2 && !strcmp(signature.methodReturnType, @encode(void(^)(void))) && [target respondsToSelector:sel]) {
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                        [invocation setSelector:sel];
                        @try {
                            [invocation invokeWithTarget:target];
                            id value = nil;
                            [invocation getReturnValue:&value];
                            [mem set:value name:selector];
                            [result addObject:selector];
                        } @catch (NSException *exception) {}
                    }
                }
            }
            return result;
        }
        return nil;
    };
}

@end
