//
//  TOEval.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import "TOEval.h"
#import "TOMem.h"
#import "TOValue.h"


static NSUInteger const TOStackSize = 100;

@implementation TOEval {
    const char *_code;
    BOOL _abort;
    NSUInteger _depth;
    NSUInteger _size;
}


#pragma mark - Object life cycle

- (id)initWithStatement:(NSArray *)statement mem:(TOMem *)mem
{
    self = [super init];
    if (self) {
        _statement = statement;
        _mem = mem;
        _size = TOStackSize;
    }
    return self;
}

- (id)eval
{
    _abort = NO;
    [_mem set:self name:@"_eval"];
    id result = [self evalStatement:_statement];
    [_mem unset:@"_eval"];
    _abort = NO;
    return result;
}

- (void)abort
{
    if (_depth) {
        _abort = YES;
    }
}

+ (id)evalStatement:(NSArray *)statement
{
    return [(TOEval *)[[self alloc] initWithStatement:statement mem:[[TOMem alloc] init]] eval];
}


#pragma mark - Running

- (id)evalStatement:(NSArray *)statement
{
    id result = nil;
    NSUInteger index = statement.count > 1 ? [statement[1] integerValue] : 0;
    if (++_depth > _size) {
        [self logAt:index line:@"stackoverflow"];
        _abort = YES;
    } else if (_abort) {
        [self logAt:index line:@"aborted"];
    } else {
        char type = statement.count > 0 ? [statement[0] characterAtIndex:0] : '\0';
        switch (type) {
            case 'a': { // assignment
                id value = statement.count > 3 ? [self evalStatement:statement[3]] : nil;
                [_mem set:value name:statement.count > 2 ? statement[2] : nil];
                result = value;
            } break;
            case 'b': { // block
                NSArray *scope = statement.count > 2 ? statement[2] : nil;
                NSArray *arguments = statement.count > 3 ? statement[3] : nil;
                id(^block)(id, id, id, id, id, id, id, id) = ^(__unsafe_unretained id v0, __unsafe_unretained id v1, __unsafe_unretained id v2, __unsafe_unretained id v3, __unsafe_unretained id v4, __unsafe_unretained id v5, __unsafe_unretained id v6, __unsafe_unretained id v7){
#define TO_EIGHT(__d,__e) __d(0) __e __d(1) __e __d(2) __e __d(3) __e __d(4) __e __d(5) __e __d(6) __e __d(7)
#define TO_BLOCK_A(__i) if (arguments.count > __i) [_mem set:v0 name:arguments[__i]]
                    TO_EIGHT(TO_BLOCK_A, ;);
                    return [self evalStatement:scope];
                };
                result = [block copy];
            } break;
            case 'i': { // invoke
                id target = statement.count > 2 ? statement[2]: nil;
                if ([target isKindOfClass:NSArray.class]) target = [self evalStatement:target];
                else if ([target isKindOfClass:NSString.class]) target = [_mem get:target];
                else [self logAt:index line:@"Unknown invoke target type '%@'", target];
                NSArray *arguments = statement.count > 3 ? statement[3] : nil;
                NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:arguments.count];
                for (id argument in arguments) {
                    id value = [self evalStatement:argument == TONil ? nil : argument];
                    [values addObject:value ? value : TONil];
                }
                id (^block)(id, id, id, id, id, id, id, id) = (id(^)(id, id, id, id, id, id, id, id))target;
#define TO_BLOCK_B(__i) id v##__i = values.count > __i && values[__i] != TONil ? values[__i] : nil
                TO_EIGHT(TO_BLOCK_B, ;);
                if (block) result = block(v0, v1, v2, v3, v4, v5, v6, v7);
            } break;
            case 'm': { // method
                id target = statement.count > 2 ? statement[2]: nil;
                if ([target isKindOfClass:NSArray.class]) target = [self evalStatement:target];
                else if ([target isKindOfClass:NSString.class]) target = [_mem get:target];
                else if (target) [self logAt:index line:@"Unknown method target type '%@'", target];
                NSString *selector = statement.count > 3 ? statement[3] : nil;
                NSArray *arguments = statement.count > 4 ? statement[4] : nil;
                NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:arguments.count];
                for (id argument in arguments) {
                    id value = [self evalStatement:argument == TONil ? nil : argument];
                    [values addObject:value ? value : TONil];
                }
                result = [self performOnTarget:target selectorString:selector arguments:values index:index];
            } break;
            case 'r': { // reference
                id target = statement.count > 2 ? statement[2]: nil;
                if ([target isKindOfClass:NSArray.class]) target = [self evalStatement:target];
                else if ([target isKindOfClass:NSString.class]) target = [_mem get:target];
                else [self logAt:index line:@"Unknown reference target type '%@'", target];
                if (statement.count > 3) {
                    id sub = [self evalStatement:statement[3]];
                    if ([target isKindOfClass:NSArray.class]) {
                        NSUInteger i = [sub unsignedIntegerValue];
                        if (i < [target count]) result = [target objectAtIndex:i];
                        else [self logAt:index line:@"Index out-of-bounds '%@'", sub];
                    }
                    else if ([target isKindOfClass:NSDictionary.class]) result = [target objectForKey:sub];
                } else result = target;
            } break;
            case 's': { // scope
                NSArray *scope = statement.count > 2 ? statement[2] : nil;
                BOOL log = NO;
                for (NSArray *s in scope) {
                    if (log) [self.delegate log:result]; log = NO;
                    BOOL brk = NO;
                    if ([s isKindOfClass:NSArray.class]) {
                        char t = s.count > 0 ? [s[0] characterAtIndex:0] : '\0';
                        switch (t) {
                            case 'e': result = s.count > 2 ? [self evalStatement:s[2]] : nil; brk = YES; break;
                            case 'v': case 'r': log = YES; // fallthrough
                            default: result = [self evalStatement:s]; break;
                        }
                    } else [self logAt:index line:@"Unknown statement '%@'", s];
                    if (brk) break;
                }
            } break;
            case 'v': { // value
                char type = statement.count > 2 ? [statement[2] characterAtIndex:0] : '\0';
                id value = statement.count > 3 ? statement[3] : nil;
                switch (type) {
                    case 'a': {
                        result = [[NSMutableArray alloc] initWithCapacity:[value count]];
                        for (id s in value) {
                            id value = [self evalStatement:s];
                            [result addObject:value ? value : NSNull.null];
                        }
                    } break;
                    case 'd': {
                        result = [[NSMutableDictionary alloc] initWithCapacity:[value count]];
                        for (NSArray *pair in value) {
                            id key = [self evalStatement:pair[0]];
                            id value = pair.count > 1 ? [self evalStatement:pair[1]] : nil;
                            [result setObject:value ? value : NSNull.null forKey:key ? key : NSNull.null];
                        }
                    } break;
                    case 's': result = [self evalStatement:value]; break;
                    case 'v': result = value; break;
                    case 'l': {
                        SEL s = NSSelectorFromString(value);
                        result = [[TOValue alloc] initWithBytes:&s objCType:":"];
                    } break;
                    default: [self logAt:index line:@"Unknown value type '%c'", type]; result = value;
                }
            } break;
            default: [self logAt:index line:@"Unknown statement type '%@'", statement[0]]; break;
        }
    }
    _depth--;
    return result;
}

- (id)performOnTarget:(id)target selectorString:(NSString *)selector arguments:(NSArray *)arguments index:(NSUInteger)index
{
    if (target) {
        SEL sel = NSSelectorFromString(selector);
        if ([target respondsToSelector:sel]) {
            NSMethodSignature *signature = [target methodSignatureForSelector:sel];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setSelector:sel];
            for (NSUInteger i = 2; i < signature.numberOfArguments; i++) {
                const char *type = [signature getArgumentTypeAtIndex:i];
                NSUInteger size = 0;
                NSGetSizeAndAlignment(type, &size, nil);
                void *buffer = calloc(1, size);
                if (i - 2 < arguments.count) {
                    id arg = arguments[i - 2] == TONil ? nil : arguments[i - 2];
                    if ([arg isKindOfClass:NSNumber.class]) {
                        switch (type[0]) {
                            case 'c': *(char              *)buffer = [arg charValue            ]; break;
                            case 'i': *(int               *)buffer = [arg intValue             ]; break;
                            case 's': *(short             *)buffer = [arg shortValue           ]; break;
                            case 'l': *(long              *)buffer = [arg longValue            ]; break;
                            case 'q': *(long long         *)buffer = [arg longLongValue        ]; break;
                            case 'C': *(unsigned char     *)buffer = [arg unsignedCharValue    ]; break;
                            case 'I': *(unsigned int      *)buffer = [arg unsignedIntValue     ]; break;
                            case 'S': *(unsigned short    *)buffer = [arg unsignedShortValue   ]; break;
                            case 'L': *(unsigned long     *)buffer = [arg unsignedLongValue    ]; break;
                            case 'Q': *(unsigned long long*)buffer = [arg unsignedLongLongValue]; break;
                            case 'f': *(float             *)buffer = [arg floatValue           ]; break;
                            case 'd': *(double            *)buffer = [arg doubleValue          ]; break;
                            case 'B': *(bool              *)buffer = [arg boolValue            ]; break;
                            case '*': *(char *            *)buffer = (char *)[[arg stringValue] UTF8String]; break;
                            case '@': *(__unsafe_unretained id *)buffer = arg; break;
                            default: [self logAt:index line:@"Unable to send number argument %@ as type %s (%i)", arg, type, i - 2];
                        }
                    } else if ([arg isKindOfClass:NSString.class]) {
                        switch (type[0]) {
                            case 'c': *(char              *)buffer = [arg intValue     ]; break;
                            case 'i': *(int               *)buffer = [arg intValue     ]; break;
                            case 's': *(short             *)buffer = [arg intValue     ]; break;
                            case 'l': *(long              *)buffer = [arg intValue     ]; break;
                            case 'q': *(long long         *)buffer = [arg longLongValue]; break;
                            case 'C': *(unsigned char     *)buffer = [arg intValue     ]; break;
                            case 'I': *(unsigned int      *)buffer = [arg intValue     ]; break;
                            case 'S': *(unsigned short    *)buffer = [arg intValue     ]; break;
                            case 'L': *(unsigned long     *)buffer = [arg intValue     ]; break;
                            case 'Q': *(unsigned long long*)buffer = [arg longLongValue]; break;
                            case 'f': *(float             *)buffer = [arg floatValue   ]; break;
                            case 'd': *(double            *)buffer = [arg doubleValue  ]; break;
                            case 'B': *(bool              *)buffer = [arg boolValue    ]; break;
                            case '*': *(char *            *)buffer = (char *)[arg UTF8String]; break;
                            case ':': *(SEL               *)buffer = NSSelectorFromString(arg); break;
                            case '#': *(__unsafe_unretained id *)buffer = NSClassFromString(arg); break;
                            case '@': *(__unsafe_unretained id *)buffer = arg; break;
                            default: [self logAt:index line:@"Unable to send string argument %@ as type %s (%i)", arg, type, i - 2];
                        }
                    } else if ([arg isKindOfClass:TOValue.class]) {
                        const char *t = [arg objCType];
                        NSUInteger s = 0;
                        NSGetSizeAndAlignment(t, &s, nil);
                        if (size == s) [arg getValue:buffer];
                        else [self logAt:index line:@"Unable to send argument with type %s as type %s (%i)", t, type, i - 2];
                    } else if (arg) {
                        switch (type[0]) {
                            case '*': *(char **)buffer = (char *)[[arg description] UTF8String]; break;
                            case '@': case '#': *(__unsafe_unretained id *)buffer = arg; break;
                            default: [self logAt:index line:@"Unable to send argument %@ (%@) as type %s (%i)", arg, [arg class], type, i - 2];
                        }
                    }
                } else {
                    [self logAt:index line:@"Missing argument #%i", i - 2];
                }
                [invocation setArgument:buffer atIndex:i];
                free(buffer);
            }
            int failed = NO;
            @try {
                [invocation invokeWithTarget:target];
            }
            @catch (NSException *exception) {
                [self logAt:index line:@"Exception '%@'", exception.reason];
                failed = YES;
            }
            if (signature.methodReturnLength && !failed) {
                const char *type = [signature methodReturnType];
                NSUInteger size = 0;
                NSGetSizeAndAlignment(type, &size, nil);
                if (size) {
                    void *buffer = calloc(1, size);
                    [invocation getReturnValue:buffer];
                    id result = nil;
                    switch (type[0]) {
                        case 'c': result = @(*(char              *)buffer); break;
                        case 'i': result = @(*(int               *)buffer); break;
                        case 's': result = @(*(short             *)buffer); break;
                        case 'l': result = @(*(long              *)buffer); break;
                        case 'q': result = @(*(long long         *)buffer); break;
                        case 'C': result = @(*(unsigned char     *)buffer); break;
                        case 'I': result = @(*(unsigned int      *)buffer); break;
                        case 'S': result = @(*(unsigned short    *)buffer); break;
                        case 'L': result = @(*(unsigned long     *)buffer); break;
                        case 'Q': result = @(*(unsigned long long*)buffer); break;
                        case 'f': result = @(*(float             *)buffer); break;
                        case 'd': result = @(*(double            *)buffer); break;
                        case 'B': result = @(*(bool              *)buffer); break;
                        case '*': result = @(*(char *            *)buffer); break;
                        case '@': case '#':
                            result = *(__unsafe_unretained id *)buffer; break;
                        default: result = [[TOValue alloc] initWithBytes:buffer objCType:type]; break;
                    }
                    free(buffer);
                    return result;
                }
            }
        } else {
            [self logAt:index line:@"Class %@ does not respond to '%@'", [target class], selector];
        }
    }
    return nil;
}


#pragma mark - Logging

- (void)logAt:(NSUInteger)index line:(NSString *)format, ...
{
    NSString *expect = @"";
    if (format.length) {
        va_list args;
        va_start(args, format);
        expect = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
    }
    if (_source) {
        [_delegate log:[TOMem formatAt:index code:_source.UTF8String string:expect]];
    } else if (expect) {
        [_delegate log:[[NSString alloc] initWithFormat:@"%@ at %i", expect, (int)index]];
    }
}

@end
