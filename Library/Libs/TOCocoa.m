//
//  TOCocoa.m
//  Tosti
//
//  Created by Leo on 10/14/12.
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import "TOCocoa.h"
#import "TOMem.h"
#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>


@implementation TOCocoa

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

@end
