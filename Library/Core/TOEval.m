//
//  TOEval.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import "TOEval.h"
#import "TOMem.h"
#import "TOValue.h"


#define TO_EIGHT(__d,__e) __d(0) __e __d(1) __e __d(2) __e __d(3) __e __d(4) __e __d(5) __e __d(6) __e __d(7)

static const char TOTypeMethod       = 'm';
static const char TOTypeAssignment   = 'a';
static const char TOTypeValue        = 'v';
static const char TOTypeReference    = 'r';
static const char TOTypeScope        = 's';
static const char TOTypeBlock        = 'b';
static const char TOTypeInvoke       = 'i';
static const char TOTypeReturn       = 'e';

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


#pragma mark - Evaluation

- (id)resolve:(id)target
{
    if ([target isKindOfClass:NSArray.class]) return [self evalStatement:target];
    if ([target isKindOfClass:NSString.class]) return [_mem get:target];
    if (target) [self logAt:index line:@"Unable to resolve '%@'", target];
    return nil;
}

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
            case TOTypeAssignment: result = [self evalAssignment:statement index:index]; break;
            case TOTypeBlock: result = [self evalBlock:statement index:index]; break;
            case TOTypeInvoke: result = [self evalInvoke:statement index:index]; break;
            case TOTypeMethod: result = [self evalMethod:statement index:index]; break;
            case TOTypeReference: result = [self evalReference:statement index:index]; break;
            case TOTypeScope: result = [self evalScope:statement index:index]; break;
            case TOTypeValue: result = [self evalValue:statement index:index]; break;
            default: [self logAt:index line:@"Unknown statement type '%@'", statement[0]]; break;
        }
    }
    _depth--;
    return result;
}

- (id)evalAssignment:(NSArray *)statement index:(NSUInteger)index
{
    id target = statement.count > 2 ? statement[2] : nil;
    id value = statement.count > 3 ? [self evalStatement:statement[3]] : nil;
    if ([target isKindOfClass:NSArray.class]) {
        if ([target count] == 4 && [target[0] characterAtIndex:0] == TOTypeMethod) {
            id t = [self resolve:target[2]];
            NSString *s = [[NSString alloc] initWithFormat:@"set%@%@:", [target[3] substringToIndex:1].uppercaseString, [target[3] substringFromIndex:1]];
            [self performOnTarget:t selectorString:s arguments:@[value ?: TONil] index:index];
        } else if ([target count] == 4 && [target[0] characterAtIndex:0] == TOTypeReference) {
            id t = [self resolve:target[2]];
            id sub = [self resolve:target[3]];
            if ([t isKindOfClass:NSMutableArray.class]) {
                if ([sub isKindOfClass:NSNumber.class] && value) {
                    NSUInteger i = [sub unsignedIntegerValue];
                    if (i <= [t count]) t[i] = value;
                    else [self logAt:index line:@"Index out-of-bounds '%u'", i];
                } else if (value) [self logAt:index line:@"Invalid array index '%@'", sub];
                else [self logAt:index line:@"Unable to assign nil to array"];
            } else if ([t isKindOfClass:NSMutableDictionary.class]) {
                if (sub && value) t[sub] = value;
                else if (value) [self logAt:index line:@"Invalid dictionary key '%@'", sub];
                else [self logAt:index line:@"Unable to assign nil to dictionary"];
            } else if (t) [self logAt:index line:@"Object not assignable '%@'", t];
        } else [self logAt:index line:@"Not assignable"];
    } else if ([target isKindOfClass:NSString.class]) [_mem set:value name:target];
    return value;
}

- (id)evalBlock:(NSArray *)statement index:(NSUInteger)index
{
    id result = nil;
    NSArray *scope = statement.count > 2 ? statement[2] : nil;
    NSArray *arguments = statement.count > 3 ? statement[3] : nil;
    id(^block)(id, id, id, id, id, id, id, id) = ^(__unsafe_unretained id v0, __unsafe_unretained id v1, __unsafe_unretained id v2, __unsafe_unretained id v3, __unsafe_unretained id v4, __unsafe_unretained id v5, __unsafe_unretained id v6, __unsafe_unretained id v7){
#define TO_BLOCK_A(__i) if (arguments.count > __i) [_mem set:v0 name:arguments[__i]]
        TO_EIGHT(TO_BLOCK_A, ;);
        return [self evalStatement:scope];
    };
    result = [block copy];
    return result;
}

- (id)evalInvoke:(NSArray *)statement index:(NSUInteger)index
{
    id result = nil;
    id target = [self resolve:statement.count > 2 ? statement[2]: nil];
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
    return result;
}

- (id)evalMethod:(NSArray *)statement index:(NSUInteger)index
{
    id result = nil;
    id target = [self resolve:statement.count > 2 ? statement[2]: nil];
    NSString *selector = statement.count > 3 ? statement[3] : nil;
    NSArray *arguments = statement.count > 4 ? statement[4] : nil;
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:arguments.count];
    for (id argument in arguments) {
        id value = [self evalStatement:argument == TONil ? nil : argument];
        [values addObject:value ? value : TONil];
    }
    result = [self performOnTarget:target selectorString:selector arguments:values index:index];
    return result;
}

- (id)evalReference:(NSArray *)statement index:(NSUInteger)index
{
    id result = nil;
    id target = [self resolve:statement.count > 2 ? statement[2]: nil];
    if (statement.count > 3) {
        id sub = [self evalStatement:statement[3]];
        if ([target isKindOfClass:NSArray.class]) {
            if ([sub isKindOfClass:NSNumber.class]) {
                NSUInteger i = [sub unsignedIntegerValue];
                if (i <= [target count]) result = target[i];
                else [self logAt:index line:@"Index out-of-bounds '%u'", i];
            } else [self logAt:index line:@"Invalid array index '%@'", sub];
        } else if ([target isKindOfClass:NSDictionary.class]) {
            if (sub) result = target[sub];
            else [self logAt:index line:@"Invalid dictionary key '%@'", sub];
        }
    } else result = target;
    return result;
}

- (id)evalScope:(NSArray *)statement index:(NSUInteger)index
{
    id result = nil;
    NSArray *scope = statement.count > 2 ? statement[2] : nil;
    for (NSArray *s in scope) {
        BOOL brk = NO;
        if ([s isKindOfClass:NSArray.class]) {
            char t = s.count > 0 ? [s[0] characterAtIndex:0] : '\0';
            switch (t) {
                case TOTypeReturn: result = s.count > 2 ? [self evalStatement:s[2]] : nil; brk = YES; break;
                case TOTypeValue: case TOTypeReference: // fallthrough
                default: result = [self evalStatement:s]; break;
            }
        } else [self logAt:index line:@"Unknown statement '%@'", s];
        if (brk) break;
    }
    return result;
}

- (id)evalValue:(NSArray *)statement index:(NSUInteger)index
{
    id result = nil;
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
                result[key ? key : NSNull.null] = value ? value : NSNull.null;
            }
        } break;
        case TOTypeScope: result = [self evalStatement:value]; break;
        case TOTypeValue: result = value; break;
        case 'l': {
            SEL s = NSSelectorFromString(value);
            result = [[TOValue alloc] initWithBytes:&s objCType:":"];
        } break;
        default: [self logAt:index line:@"Unknown value type '%c'", type]; result = value;
    }
    return result;
}


#pragma mark - Message sending

- (id)performOnTarget:(id)target selectorString:(NSString *)selector arguments:(NSArray *)arguments index:(NSUInteger)index
{
    if (target) {
        SEL sel = NSSelectorFromString(selector);
        if ([target respondsToSelector:sel]) {
            NSMethodSignature *signature = [target methodSignatureForSelector:sel];
            if (signature.numberOfArguments < arguments.count + 2) {
                NSMutableString *s = @"".mutableCopy;
                char c = '@';
                for (NSUInteger i = 0; i < arguments.count + 2; i++) {
                    if (i < signature.numberOfArguments) c = [signature getArgumentTypeAtIndex:i][0];
                    [s appendFormat:@"%c", c];
                }
                [s insertString:@"@" atIndex:0]; //bug?
                signature = [NSMethodSignature signatureWithObjCTypes:[s cStringUsingEncoding:NSUTF8StringEncoding]];
            }
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
