//
//  TOCocoaAppDelegate.m
//  TostiCocoaDemo
//
//  Created by Leo on 10/19/12.
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import "TOCocoaAppDelegate.h"
#import "NWLLogView.h"
#import "NWLCore.h"

@implementation TOCocoaAppDelegate {
    IBOutlet NWLLogView *_console;
    IBOutlet NWLLogView *_editor;
    TOConsoleController *_controller;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _console.string = @"Enter 'help' for help.\n";
    
    _editor.editable = YES;
    [_window makeFirstResponder:_editor];
    
    TOConsoleController *controller = [[TOConsoleController alloc] init];
    [controller setup];
    controller.delegate = self;
    _controller = controller;
}

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
    return [_controller shouldType:replacementString];
}

- (NSString *)input
{
    NWAssertMainThread();
    return [_editor.string copy];
}

- (void)setInput:(NSString *)input
{
    NWAssertMainThread();
    _editor.string = [input copy];
}

- (void)append:(NSString *)text
{
    [_console safeAppendAndFollowText:text];
}

- (id)console
{
    return _console;
}

@end
