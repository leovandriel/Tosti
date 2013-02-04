//
//  TORead.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import "TORead.h"
#import "TOMem.h"


static NSString *const TOTypeMethod       = @"m";
static NSString *const TOTypeAssignment   = @"a";
static NSString *const TOTypeValue        = @"v";
static NSString *const TOTypeReference    = @"r";
static NSString *const TOTypeScope        = @"s";
static NSString *const TOTypeBlock        = @"b";
static NSString *const TOTypeInvoke       = @"i";
static NSString *const TOTypeReturn       = @"e";


@implementation TORead{
    const char *_chars;
    NSUInteger _index;
}

- (id)initWithCode:(NSString *)code
{
    self = [super init];
    if (self) {
        self.code = code;
    }
    return self;
}

- (void)setCode:(NSString *)code
{
    _code = code;
    _chars = code.UTF8String;
}

- (NSArray *)read
{
    return [self scope];
}

+ (NSArray *)readCode:(NSString *)code
{
    return [[[TORead alloc] initWithCode:code] read];
}


#pragma mark - Composites

- (NSArray *)scope
{
    NSUInteger start = _index;
    [self char:'{']; [self space];
    NSMutableArray *statements = [[NSMutableArray alloc] initWithCapacity:4];
    for (char c = [self char:'}']; _chars[_index] && c != '}';c = [self char:'}']) {
        NSUInteger s = _index;
        BOOL isReturn = [self keyword:"return"]; [self space];
        [self keyword:"__block"]; [self space];
        [self keyword:"id"]; [self space];
        [self space];
        NSArray *statement = [self statement]; [self space];
        if (isReturn) {
            if (statement) statement = @[TOTypeReturn, @(s), statement];
            else statement = @[TOTypeReturn, @(s)];
        }
        if (statement) {
            [statements addObject:statement];
            [self char:';'];
        } else {
            [self logExpect:@"expecting scope"];
            break;
        }
        [self space];
    }
    if (statements.count) return @[TOTypeScope, @(start), statements];
    else return @[TOTypeScope, @(start)];
}

- (NSArray *)statement
{
    NSUInteger start = _index;
    id result = nil;
    switch (_chars[_index]) {
        case '\0': return nil;
        case '[': result = [self method]; break;
        case '^': result = [self block]; break;
        case '{': result = [self scope]; break;
        case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':
        case '-': case '+': case '.': case '"': case '\'': case '@': result = [self value]; break;
        default: result = [self nameWith:'_']; break;
    }
    [self space];
    if (result) {
        for (char d = 1; d; ) {
            const char *s = _chars + _index - 1;
            if (!strncmp(s, " [", 2) || !strncmp(s, " .", 2)) break;
            d = [self chars:"[(=."]; [self space];
            switch (d) {
                case '=': {
                    id statement = [self statement];
                    if (statement) {
                            return @[TOTypeAssignment, @(start), result, statement];
                    } else [self logExpect:@"expecting statement to assign"];
                } break;
                case '.': {
                    NSString *selector = [self nameWith:'\0']; [self space];
                    if (selector.length) result = @[TOTypeMethod, @(start), result, selector];
                    else [self logExpect:@"expecting dot selector"];
                } break;
                case '(': {
                    NSArray *arguments = [self items:')' names:NO]; [self space];
                    if (arguments.count) result = @[TOTypeInvoke, @(start), result, arguments];
                    else result = @[TOTypeInvoke, @(start), result];
                } break;
                case '[': {
                    id statement = [self statement]; [self space]; [self char:']']; [self space];
                    if (statement) result = @[TOTypeReference, @(start), result, statement];
                    else [self logExpect:@"expecting index"];
                }
            }
        }
        if ([result isKindOfClass:NSString.class]) result = @[TOTypeReference, @(start), result];
    }
    return result;
}

- (NSArray *)method
{
    NSUInteger start = _index;
    [self char:'[']; [self space];
    NSArray *target = [self statement]; [self space];
    NSMutableString *selector = @"".mutableCopy;
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:2];
    for (char c = [self chars:":],"];; c = [self chars:":],"]) {
        [self space];
        if (c == '\0' && _chars[_index]) {
            NSString *n = [self nameWith:'\0'];
            if (n.length) {
                [selector appendString:n];
            } else {
                [self logExpect:@"expecting selector"];
                break;
            }
        } else if (c == ':') {
            [selector appendString:@":"];
            NSArray *s = [self statement];
            if (s) [arguments addObject:s];
            else [self logExpect:@"expecting argument"];
        } else if (c == ',') {
            NSArray *s = [self statement];
            if (s) [arguments addObject:s];
            else [self logExpect:@"expecting argument"];
        } else break;
        [self space];
    }
    NSMutableArray *result = @[TOTypeMethod, @(start)].mutableCopy;
    if (target.count) {
        [result addObject:target];
        if (selector.length) {
            [result addObject:selector];
            if (arguments.count) [result addObject:arguments];
        } else [self logExpect:@"expecting method selector"];
    } else [self logExpect:@"expecting method target"];
    return result;
}

- (NSArray *)block
{
    NSUInteger start = _index;
    [self char:'^']; [self space];
    char c = [self char:'(']; [self space];
    NSArray *arguments = nil;
    if (c == '(') {
        arguments = [self items:')' names:YES];
        [self space];
    } else {
        arguments = @[];
    }
    NSArray *scope = [self scope];
    if (arguments.count) return @[TOTypeBlock, @(start), scope, arguments];
    else return @[TOTypeBlock, @(start), scope];
}

- (id)value
{
    [self char:'@']; [self space];
    NSUInteger start = _index;
    char chr = [self chars:"\"'[{("];
    switch (chr) {
        case '"': case '\'': {
            const char *s = _chars + _index;
            NSMutableString *result = @"".mutableCopy;
            for (char c = *s, escaping = NO; c; c = *++s) {
                if (c == '\\' && !escaping) escaping = YES;
                else if (c == chr && !escaping) break;
                else {
                    [result appendFormat:@"%c", c];
                    escaping = NO;
                }
            }
            _index = s - _chars;
            [self chars:"\"'"];
            return @[TOTypeValue, @(start), @"v", result];
        }
        case '[': {
            [self space];
            return @[TOTypeValue, @(start), @"a", [self items:']' names:NO]];
        }
        case '{': {
            [self space];
            NSMutableArray *dictionary = [[NSMutableArray alloc] initWithCapacity:4];
            for (char c = [self char:'}']; _chars[_index] && c != '}'; c = [self char:'}']) {
                NSArray *key = [self statement]; [self space];
                NSArray *value = nil;
                if ([self char:':']) {
                    [self space];
                    value = [self statement]; [self space];
                }
                if (key && value) [dictionary addObject:@[key, value]];
                else if (key) [dictionary addObject:@[key]];
                else {
                    [self logExpect:@"expecting dictionary key"];
                    break;
                }
                [self char:',']; [self space];
            }
            return @[TOTypeValue, @(start), @"d", dictionary];
        }
        case '(': {
            [self space];
            NSArray *statement = [self statement]; [self space];
            [self char:')'];
            if (statement) return @[TOTypeValue, @(start), @"s", statement];
            [self logExpect:@"expecting value"];
            return @[TOTypeValue, @(start), @"v"];
        }
    }
    const char *s = _chars + _index;
    for (char c = *s; c; c = *++s) {
        if (('a' > c || c > 'z') && ('A' > c || c > 'Z') && ('0' > c || c > '9') && c != '_' && c != '.' && c != '-' && c != '+') break;
    }
    NSUInteger length = s - _chars - _index;
    if (length) {
        NSString *result = [[NSString alloc] initWithBytes:_chars + _index length:length encoding:NSUTF8StringEncoding];
        _index = s - _chars;
        double d = [result doubleValue];
        if (d || [result isEqualToString:@"0.0"]) return @[TOTypeValue, @(start), @"v", @(d)];
        NSInteger i = [result integerValue];
        if (i || [result isEqualToString:@"0"]) return @[TOTypeValue, @(start), @"v", @(i)];
        if ([result isEqualToString:@"YES"]) return @[TOTypeValue, @(start), @"v", @YES];
        if ([result isEqualToString:@"NO"]) return @[TOTypeValue, @(start), @"v", @NO];
        if ([result isEqualToString:@"selector"]) {
            [self char:'(']; [self space];
            NSString *selector = [self nameWith:':']; [self char:')'];
            return @[TOTypeValue, @(start), @"l", selector];
        }
        return @[TOTypeValue, @(start), @"v", result];
    }
    [self logExpect:@"expecting value"];
    return @[TOTypeValue, @(start), @"v"];
}


#pragma mark - Primitives

- (char)chars:(const char *)chars
{
    char c = _chars[_index];
    for (const char *s = chars; *s; s++) {
        if (*s == c) {
            _index++;
            return c;
        }
    }
    return '\0';
}

- (char)char:(char)c
{
    if (c && _chars[_index] == c) {
        _index++;
        return c;
    }
    return '\0';
}

- (void)space
{
    for (const char *s = _chars + _index;; s++) {
        switch (*s) {
            case ' ': case '\t': case '\n': case '\r': case '*': break;
            default: _index = s - _chars; return;
        }
    }
}

- (BOOL)keyword:(const char *)keyword
{
    size_t length = strlen(keyword);
    if (strncmp(_chars + _index, keyword, length)) return NO;
    char c = _chars[_index + length];
    if (('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z') || ('0' <= c && c <= '9') || c == '_') return NO;
    _index += length;
    return YES;
}

- (NSString *)nameWith:(char)separator
{
    const char *s = _chars + _index;
    for (char c = *s; c; c = *++s) {
        if (('a' > c || c > 'z') && ('A' > c || c > 'Z') && ('0' > c || c > '9') && c != separator) break;
    }
    NSUInteger length = s - _chars - _index;
    if (length) {
        NSString *result = [[NSString alloc] initWithBytes:_chars + _index length:length encoding:NSUTF8StringEncoding];
        _index = s - _chars;
        return result;
    }
    return nil;
}

- (NSArray *)items:(char)until names:(BOOL)names
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:4];
    for (char c = [self char:until]; _chars[_index] && c != until; c = [self char:until]) {
        if (names) {
            [self keyword:"id"]; [self space];
            NSString *name = [self nameWith:'_'];
            if (name.length) {
                [result addObject:name]; [self space];
            } else {
                [self logExpect:@"expecting name"];
                break;
            }
        } else {
            NSArray *statement = [self statement]; [self space];
            if (statement) [result addObject:statement];
            else {
                [self logExpect:@"expecting item"];
                break;
            }
        }
        [self char:',']; [self space];
    }
    return result;
}


#pragma mark - Logging

- (void)logExpect:(NSString *)expect
{
    _warnings++;
    [_delegate log:[TOMem formatAt:_index code:_chars string:expect]];
}


@end
