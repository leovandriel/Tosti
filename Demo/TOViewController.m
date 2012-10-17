//
//  TOViewController.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import "TOViewController.h"
#import <NWLogging/NWLogging.h>
#import "TORead.h"
#import "TOMem.h"
#import "TOEval.h"


@implementation TOViewController {
    NWLLogView *_editor;
    NWLLogView *_console;
    NSMutableArray *_history;
    NSUInteger _back;
    TOEval *_eval;
    TOMem *_mem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NWLLogView *console = [[NWLLogView alloc] init];
    console.frame = CGRectMake(10, 10, self.view.bounds.size.width - 20, self.view.bounds.size.height - 320);
    [self.view addSubview:console];
    console.text = @"Enter 'help' for help.\n";
    _console = console;
    
    NWLLogView *editor = [[NWLLogView alloc] init];
    editor.frame = CGRectMake(10, self.view.bounds.size.height - 300, self.view.bounds.size.width - 20, 80);
    editor.editable = YES;  
    editor.delegate = self;
    [self.view addSubview:editor];
    [editor becomeFirstResponder];
    _editor = editor;
    
    _history = [NSUserDefaults.standardUserDefaults objectForKey:@"history"];
    if (!_history.count) {
        _history = [NSMutableArray arrayWithObject:@""];
    }
    
    _mem = [TOMem eval:@"[[TOMem alloc] init]"];
    [_mem eval:@"TO.load(_mem,TO)"];
    [_mem eval:@"load(_mem,TOMath)"];
    [_mem eval:@"load(_mem,TOCocoa)"];
    
    [_mem set:self name:@"self"];
}

- (void)run
{
    NSString *text = _editor.text;
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
    _editor.text = @"";
    [_history addObject:_editor.text];
    [NSUserDefaults.standardUserDefaults setObject:_history forKey:@"history"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (void)log:(NSString *)line
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_console appendAndFollowText:[[NSString alloc] initWithFormat:@"%@\n", line]];
    });
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (text.length == 1) {
        switch ((int)[text characterAtIndex:0]) {
            case 167: { // §
                if (_back < _history.count - 1) {
                    _back++;
                }
                _editor.text = _history[_history.count - _back - 1];
                [_history removeLastObject]; [_history addObject:_editor.text];
            } return NO;
            case 177: { // ±
                if (_back > 0) {
                    _back--;
                }
                _editor.text = _history[_history.count - _back - 1];
                [_history removeLastObject]; [_history addObject:_editor.text];
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
                TORead *read = [[TORead alloc] initWithCode:_editor.text];
                read.delegate = self;
                id statement = [read read];
                NSString *compact = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:statement options:0 error:nil] encoding:NSUTF8StringEncoding];
                [self log:compact];
            } return NO;
            case '\n': {
                if ([_editor.text isEqualToString:@"help"]) {
                    _editor.text = @"";
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
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [_history removeLastObject]; [_history addObject:_editor.text];
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
