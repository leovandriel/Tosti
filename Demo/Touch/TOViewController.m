//
//  TOViewController.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import "TOViewController.h"
#import "NWLLogView.h"
#import "TORead.h"
#import "TOMem.h"
#import "TOEval.h"


@implementation TOViewController {
    NWLLogView *_editor;
    NWLLogView *_console;
    TOConsoleController *_controller;
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
    
    TOConsoleController *controller = [[TOConsoleController alloc] init];
    [controller setup];
    controller.delegate = self;
    _controller = controller;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return [_controller shouldType:text];
}

- (NSString *)input
{
    return _editor.text;
}

- (void)setInput:(NSString *)input
{
    _editor.text = input;
}

- (void)append:(NSString *)text
{
    [_console safeAppendAndFollowText:text];
}

@end
