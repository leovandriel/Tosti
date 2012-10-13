//
//  TO.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import "TO.h"
#import "TOMem.h"
#import <objc/runtime.h>


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


#pragma mark - Inspection

+ (NSArray *)selectorsForObject:(id)object
{
    NSMutableArray *result = @[].mutableCopy;
    unsigned int count = 0;
    Method *methods = class_copyMethodList(object_getClass(object), &count);
    for (NSUInteger i = 0; i < count; i++) {
        [result addObject:NSStringFromSelector(method_getName(methods[i]))];
    }
    free(methods);
    return result;
}

+ (id(^)(id))selectorsOf
{
    return ^id(id value) {
        return [[TO selectorsForObject:value] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    };
}

+ (id(^)(id))superOf
{
    return ^id(id value) {
        return class_getSuperclass([value class]);
    };
}

+ (id(^)(id,id,id,id))load
{
    return ^id(id mem, id targets, id target2, id target3) {
        if (![targets isKindOfClass:NSArray.class]) {
            NSMutableArray *t = @[].mutableCopy;
            if (targets) [t addObject:targets];
            if (target2) [t addObject:target2];
            if (target3) [t addObject:target3];
            targets = t;
        }
        if ([mem isKindOfClass:TOMem.class]) {
            NSMutableArray *result = @[].mutableCopy;
            for (id target in targets) {
                for (NSString *selector in [TO selectorsForObject:target]) {
                    SEL sel = NSSelectorFromString(selector);
                    NSMethodSignature *signature = [target methodSignatureForSelector:sel];
                    if (signature.numberOfArguments == 2 && [target respondsToSelector:sel]) {
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                        [invocation setSelector:sel];
                        NSString *name = [selector hasPrefix:@"_"] ? [selector substringFromIndex:1] : selector;
                        @try {
                            [invocation invokeWithTarget:target];
                            id value = nil;
                            [invocation getReturnValue:&value];
                            [mem set:value name:name];
                            [result addObject:name];
                        } @catch (NSException *exception) {}
                    }
                }
            }
            return result;
        }
        return nil;
    };
}

+ (id)_YES
{
    return @(YES);
}

+ (id)_NO
{
    return @(NO);
}

+ (id)_true
{
    return @(true);
}

+ (id)_false
{
    return @(false);
}

@end
