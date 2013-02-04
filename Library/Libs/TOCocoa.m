//
//  TOCocoa.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import "TOCocoa.h"
#import "TOMem.h"
#import "TOValue.h"
#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>

#include "TargetConditionals.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@implementation TOCocoa


#pragma mark - Foundation

+ (id(^)(id))NSStringFromClass
{
    return ^id(id value) {
        if (class_isMetaClass(object_getClass(value))) return NSStringFromClass(value);
        else return NSStringFromClass([value class]);
    };
}

+ (id(^)(id))NSClassFromString
{
    return ^id(id value) {
        return NSClassFromString([value description]);
    };
}

+ (id(^)(id))NSStringFromSelector
{
    return ^id(id value) {
        if ([value isKindOfClass:TOValue.class] && TOValueIsType(value, SEL)) {
            return NSStringFromSelector(TOValueGet(value, SEL));
        }
        return nil;
    };
}

+ (id(^)(id))NSSelectorFromString
{
    return ^id(id value) {
        SEL selector = NSSelectorFromString([value description]);
        if (selector) {
            return [[TOValue alloc] initWithBytes:&selector objCType:":"];
        }
        return nil;
    };
}

+ (id(^)(id))NSStringFromProtocol
{
    return ^id(id value) {
        return NSStringFromProtocol(value);
    };
}

+ (id(^)(id))NSProtocolFromString
{
    return ^id(id value) {
        return NSProtocolFromString([value description]);
    };
}

+ (id(^)(id))NSLocalizedString
{
    return ^id(id key) {
        return NSLocalizedString(key, nil);
    };
}

+ (id(^)(id,...))NSLog
{
    return ^id(id format, ...) {
        va_list args;
        va_start(args, format);
        NSString *result = [[NSString alloc] initWithFormat:format arguments:args];
        NSLog(@"%@", result);
        va_end(args);
        return result;
    };
}


#pragma mark - Foundation Make

+ (id(^)(id,id))NSMakeRange
{
    return ^id(id w, id h) {
        if ([w isKindOfClass:NSNumber.class] && [h isKindOfClass:NSNumber.class]) {
            NSRange range = NSMakeRange([w integerValue], [h integerValue]);
            return [[TOValue alloc] initWithBytes:&range objCType:@encode(NSRange)];
        }
        return nil;
    };
}

#if TARGET_OS_IPHONE

+ (id(^)(id,id))NSMakePoint
{
    return [self CGPointMake];
}

+ (id(^)(id,id,id,id))NSMakeRect
{
    return [self CGRectMake];
}

+ (id(^)(id,id))NSMakeSize
{
    return [self CGSizeMake];
}

#else

+ (id(^)(id,id))NSMakePoint
{
    return ^id(id w, id h) {
        if ([w isKindOfClass:NSNumber.class] && [h isKindOfClass:NSNumber.class]) {
            NSPoint point = NSMakePoint([w floatValue], [h floatValue]);
            return [[TOValue alloc] initWithBytes:&point objCType:@encode(NSPoint)];
        }
        return nil;
    };
}

+ (id(^)(id,id,id,id))NSMakeRect
{
    return ^id(id x, id y, id w, id h) {
        if ([x isKindOfClass:NSNumber.class] && [y isKindOfClass:NSNumber.class] && [w isKindOfClass:NSNumber.class] && [h isKindOfClass:NSNumber.class]) {
            NSRect rect = NSMakeRect([x floatValue], [y floatValue], [w floatValue], [h floatValue]);
            return [[TOValue alloc] initWithBytes:&rect objCType:@encode(NSRect)];
        }
        return nil;
    };
}

+ (id(^)(id,id))NSMakeSize
{
    return ^id(id w, id h) {
        if ([w isKindOfClass:NSNumber.class] && [h isKindOfClass:NSNumber.class]) {
            NSSize size = NSMakeSize([w floatValue], [h floatValue]);
            return [[TOValue alloc] initWithBytes:&size objCType:@encode(NSSize)];
        }
        return nil;
    };
}
#endif


#pragma mark - Core Graphics

+ (id(^)(id,id,id,id))CGRectMake
{
    return ^id(id x, id y, id w, id h) {
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
        if ([w isKindOfClass:NSNumber.class] && [h isKindOfClass:NSNumber.class]) {
            CGSize size = CGSizeMake([w floatValue], [h floatValue]);
            return [[TOValue alloc] initWithBytes:&size objCType:@encode(CGSize)];
        }
        return nil;
    };
}

+ (id(^)(id,id))CGPointMake
{
    return ^id(id w, id h) {
        if ([w isKindOfClass:NSNumber.class] && [h isKindOfClass:NSNumber.class]) {
            CGPoint point = CGPointMake([w floatValue], [h floatValue]);
            return [[TOValue alloc] initWithBytes:&point objCType:@encode(CGPoint)];
        }
        return nil;
    };
}

+ (id(^)(id,id,id,id))UIEdgeInsetsMake
{
    return ^id(id x, id y, id w, id h) {
#if TARGET_OS_IPHONE
        if ([x isKindOfClass:NSNumber.class] && [y isKindOfClass:NSNumber.class] && [w isKindOfClass:NSNumber.class] && [h isKindOfClass:NSNumber.class]) {
            UIEdgeInsets insets = UIEdgeInsetsMake([x floatValue], [y floatValue], [w floatValue], [h floatValue]);
            return [[TOValue alloc] initWithBytes:&insets objCType:@encode(UIEdgeInsets)];
        }
#endif
        return nil;
    };
}


#pragma mark - String From

#if TARGET_OS_IPHONE

+ (id(^)(id))NSStringFromRect
{
    return ^id(id value) {
        if ([value isKindOfClass:TOValue.class] && TOValueIsType(value, CGRect)) {
            return NSStringFromCGRect(TOValueGet(value, CGRect));
        }
        return nil;
    };
}

+ (id(^)(id))NSStringFromPoint
{
    return ^id(id value) {
        if ([value isKindOfClass:TOValue.class] && TOValueIsType(value, CGPoint)) {
            return NSStringFromCGPoint(TOValueGet(value, CGPoint));
        }
        return nil;
    };
}

+ (id(^)(id))NSStringFromSize
{
    return ^id(id value) {
        if ([value isKindOfClass:TOValue.class] && TOValueIsType(value, CGSize)) {
            return NSStringFromCGSize(TOValueGet(value, CGSize));
        }
        return nil;
    };
}

#else

+ (id(^)(id))NSStringFromRect
{
    return ^id(id value) {
        if ([value isKindOfClass:TOValue.class] && TOValueIsType(value, NSRect)) {
            return NSStringFromRect(TOValueGet(value, NSRect));
        }
        return nil;
    };
}

+ (id(^)(id))NSStringFromPoint
{
    return ^id(id value) {
        if ([value isKindOfClass:TOValue.class] && TOValueIsType(value, NSPoint)) {
            return NSStringFromPoint(TOValueGet(value, NSPoint));
        }
        return nil;
    };
}

+ (id(^)(id))NSStringFromSize
{
    return ^id(id value) {
        if ([value isKindOfClass:TOValue.class] && TOValueIsType(value, NSSize)) {
            return NSStringFromSize(TOValueGet(value, NSSize));
        }
        return nil;
    };
}

#endif

+ (id (^)(id))NSStringFromCGRect
{
    return [self NSStringFromRect];
}

+ (id (^)(id))NSStringFromCGPoint
{
    return [self NSStringFromPoint];
}

+ (id (^)(id))NSStringFromCGSize
{
    return [self NSStringFromSize];
}


#pragma mark - Lib Dispatch

+ (id(^)(id,id,id))dispatch_after
{
    return ^id(id delay, id queue, id block) {
        if (!block) {
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
        if (!block) {
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

+ (id(^)(id,id))dispatch_sync
{
    return ^id(id queue, id block) {
        if (!block) {
            block = queue;
            queue = nil;
        }
        if (block) {
            dispatch_queue_t q = [queue isKindOfClass:TOValue.class] ? (dispatch_queue_t)[queue pointerValue] : dispatch_get_main_queue();
            dispatch_sync(q, block);
            return @YES;
        }
        return @NO;
    };
}

+ (id(^)())dispatch_get_main_queue
{
    return ^id() {
        return [[TOValue alloc] initWithPointer:dispatch_get_main_queue() objCType:@encode(dispatch_queue_t)];
    };
}

+ (id(^)(id))dispatch_get_global_queue
{
    return ^id(id value) {
        dispatch_queue_priority_t priority = [value isKindOfClass:NSNumber.class] ? [value longValue] : 0L;
        return [[TOValue alloc] initWithPointer:dispatch_get_global_queue(priority, 0) objCType:@encode(dispatch_queue_t)];
    };
}


@end
