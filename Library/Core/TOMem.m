//
//  TOMem.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import "TOMem.h"
#import "TORead.h"
#import "TOEval.h"


id const TONil = @"TONil";


@implementation TOMem {
    NSMutableDictionary *_memory;
    TOMem *_parent;
}

- (id)init
{
    self = [super init];
    if (self) {
        _memory = @{}.mutableCopy;
        [self set:self name:@"_mem"];
    }
    return self;
}

- (id)get:(NSString *)name
{
    if (name) {
        id result = [self getInternal:name];
        if (!result) result = NSClassFromString(name);
        if (!result) result = NSProtocolFromString(name);
        if (result == TONil) result = nil;
        return result;
    }
    return nil;
}

- (id)getInternal:(NSString *)name
{
    id result = _memory[name];
    if (!result) result = [_parent getInternal:name];
    return result;
}

- (void)set:(id)value name:(NSString *)name
{
    if (name) {
        if (!value) value = TONil;
        [self setInternal:value name:name];
    }
}

- (void)setInternal:(id)value name:(NSString *)name
{
    BOOL set = !_parent || !!_memory[name];
    if (set) _memory[name] = value;
    else [_parent setInternal:value name:name];
}

- (void)unset:(NSString *)name
{
    if (name) [self unsetInternal:name];
}

- (void)unsetInternal:(NSString *)name
{
    BOOL set = !_parent || !!_memory[name];
    if (set) [_memory removeObjectForKey:name];
    else [_parent unsetInternal:name];
}

- (void)clear
{
    [_memory removeAllObjects];
}

- (NSArray *)dump
{
    NSMutableArray *result = @[].mutableCopy;
    [self dumpInto:result];
    return result;
}

- (void)dumpInto:(NSMutableArray *)array
{
    NSMutableArray *dump = @[].mutableCopy;
    for (NSString *name in [_memory.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
        id i = [self get:name];
        if (i) {
            [dump addObject:@[name, i]];
        } else {
            [dump addObject:@[name]];
        }
    }
    [array addObject:dump];
    [_parent dumpInto:array];
}

- (id)eval:(NSString *)code
{
    return [self eval:code delegate:nil];
}

- (id)eval:(NSString *)code delegate:(id<TODelegate>)delegate
{
    TORead *read = [[TORead alloc] initWithCode:code];
    read.delegate = delegate;
    id statement = [read read];
    if (!read.warnings) {
        TOEval *eval = [[TOEval alloc] initWithStatement:statement mem:self];
        eval.source = code;
        eval.delegate = delegate;
        return [eval eval];
    }
    return nil;
}

+ (id)eval:(NSString *)code
{
    return [TOEval evalStatement:[TORead readCode:code]];
}

+ (NSString *)formatAt:(NSUInteger)index code:(const char *)code string:(NSString *)string
{
    static NSUInteger const range = 20;
    NSUInteger i = index < range ? 0 : index - range;
    NSUInteger len = strlen(code + index);
    NSUInteger j = len < range ? len : range;
    NSString *result = [[NSString alloc] initWithFormat:@"%@%@'%s%.*s`%.*s%s'", string, string.length ? @" at ": @"", index > range ? ".." : "", (int)(index - i), code + i, (int)j, code + index, len > range ? ".." : ""];
    return result;
}

@end
