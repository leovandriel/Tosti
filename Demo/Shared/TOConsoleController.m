//
//  TOConsoleController.m
//  Tosti
//
//  Created by Leo on 10/18/12.
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import "TOConsoleController.h"
#import "TOMem.h"
#import "TOEval.h"
#import "TORead.h"


@implementation TOConsoleController {
    NSMutableArray *_history;
    NSUInteger _back;
    TOEval *_eval;
    TOMem *_mem;
}

- (void)setup
{
    NSArray *history = [[NSUserDefaults.standardUserDefaults stringForKey:@"history"] componentsSeparatedByString:@"\n"];
    _history = history.mutableCopy;
    if (!_history.count) {
        _history = @[@""].mutableCopy;
    }
    
    TOMem *mem = [TOMem eval:@"[[TOMem alloc] init]"];
    [mem eval:@"TO.load(_mem,TO)"];
    [mem eval:@"load(_mem,TOMath)"];
    [mem eval:@"load(_mem,TOCocoa)"];
    [mem set:self name:@"self"];
    _mem = mem;
}

- (void)run
{
    NSString *text = _delegate.input;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self log:[[NSString alloc] initWithFormat:@"run: %@", text]];
        TORead *read = [[TORead alloc] initWithCode:text];
        read.delegate = self;
        id statement = [read read];
        if (!read.warnings) {
            TOEval *eval = [[TOEval alloc] initWithStatement:statement mem:_mem];
            eval.source = text;
            eval.delegate = self;
            [_eval abort]; _eval = eval;
            id result = [eval eval];
            [self log:[[NSString alloc] initWithFormat:@"out: %@", result]];
        } else {
            [self log:[[NSString alloc] initWithFormat:@"break"]];
        }
    });
    _delegate.input = @"";
    [_history addObject:_delegate.input];
    [NSUserDefaults.standardUserDefaults setObject:[_history componentsJoinedByString:@"\n"] forKey:@"history"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (void)log:(NSString *)line
{
    [_delegate append:[[NSString alloc] initWithFormat:@"%@\n", line]];
}

- (BOOL)shouldType:(NSString *)text
{
    if (text.length == 1) {
        switch ((int)[text characterAtIndex:0]) {
            case 167: { // §
                if (_back < _history.count - 1) {
                    _back++;
                }
                _delegate.input = _history[_history.count - _back - 1];
                [_history removeLastObject]; [_history addObject:_delegate.input];
            } return NO;
            case 177: { // ±
                if (_back > 0) {
                    _back--;
                }
                _delegate.input = _history[_history.count - _back - 1];
                [_history removeLastObject]; [_history addObject:_delegate.input];
            } return NO;
            case '~': {
                [_eval abort];
                [self log:[[NSString alloc] initWithFormat:@"abort"]];
            } return NO;
            case '`': {
                NSArray *dump = [_mem dump];
                BOOL empty = YES;
                for (NSArray *d in dump) {
                    for (NSArray *e in d) {
                        NSString *name = e[0];
                        NSString *value = e.count > 1 ? e[1] : nil;
                        [self log:[[NSString alloc] initWithFormat:@"%@ = %@", name, value]];
                        empty = NO;
                    }
                }
                if (empty) [self log:@"empty"];
            } return NO;
            case '\t': {
                TORead *read = [[TORead alloc] initWithCode:_delegate.input];
                read.delegate = self;
                id statement = [read read];
                NSString *compact = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:statement options:0 error:nil] encoding:NSUTF8StringEncoding];
                [self log:compact];
            } return NO;
            case '\n': {
                if ([_delegate.input isEqualToString:@"help"]) {
                    _delegate.input = @"";
                    [self log:[self help]];
                } else {
                    [self run];
                }
                _back = 0;
            } return NO;
            default: {
                _back = 0;
            }
        }
    }
    [_history removeLastObject]; [_history addObject:[_delegate.input stringByAppendingString:text]];
    return YES;
}

- (NSString *)help
{
    return @""
    @"Hi there and welcome to Tosti, an Objective-C interpreter without C support. "
    @"To get started try some simple lines like:\n"
    @"  id a = @2; id b = a;\n"
    @"  [\"Objective-C\" substringToIndex:9];\n"
    @"  [self help];\n"
    @"Feel free to try more exotic code, but avoid the pure C stuff like if, for, +, or *.\n"
    @"Some handy keys:\n"
    @"  § previous code\n"
    @"  ± next code\n"
    @"  ` dump memory\n"
    @"  ~ abort running code\n"
    @"  <enter> run code\n"
    @"  <tab> parse only\n"
    @"Remember to checkout README.md";
}


@end
