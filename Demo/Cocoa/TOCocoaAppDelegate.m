//
//  TOCocoaAppDelegate.m
//  TostiCocoaDemo
//
//  Created by Leo on 10/19/12.
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import "TOCocoaAppDelegate.h"
#import <NWLogging/NWLogging.h>

@implementation TOCocoaAppDelegate {
	IBOutlet NWLLogView *_console, *_editor;
	TOConsoleController *_controller;
}

- (NSView*) view { return  _console.superview; }

- (void)awakeFromNib	{

	TOConsoleController *controller;
	[controller = TOConsoleController.new setup];
	self.consoleTextSize = 18;
	_console.string 		= @"Enter 'help' for help.\n";
	_editor.editable 		= YES;
	controller.delegate 	= self;
	_controller 			= controller;
	[_window makeFirstResponder:_editor];

}

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
	return [_controller shouldType:replacementString];
}

- (NSString*) input { NWAssertMainThread(); return [_editor.string copy]; }

- (void)setInput:(NSString*) input	{	NWAssertMainThread(); _editor.string = [input copy]; }

- (void)append:(NSString*) text	{	[_console safeAppendAndFollowText:text]; }

- (void) setConsoleTextSize:(CGFloat)consoleTextSize {
	_editor.font = _console.font = [NSFont fontWithName:@"Menlo" size:consoleTextSize];
}
- (void) setContrast:(BOOL)contrast {
	_editor.textColor = _console.textColor = contrast ? NSColor.blackColor : NSColor.whiteColor;
	_editor.backgroundColor = _console.backgroundColor = contrast ? NSColor.whiteColor : NSColor.blackColor;
}
- (void) getConsole:(id)sender {
	[_editor insertText:@"console = self.delegate.view.subviews.lastObject"];
}


@end
