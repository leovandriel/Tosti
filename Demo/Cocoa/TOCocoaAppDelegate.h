//
//  TOCocoaAppDelegate.h
//  TostiCocoaDemo
//
//  Created by Leo on 10/19/12.
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import "TOConsoleController.h"

@interface TOCocoaAppDelegate : NSObject <NSApplicationDelegate, NSTextViewDelegate, TOConsoleTextDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (readonly) 	NSTextView *view;
@property (nonatomic) 	CGFloat consoleTextSize;
@property (nonatomic) 	BOOL contrast;
@end
