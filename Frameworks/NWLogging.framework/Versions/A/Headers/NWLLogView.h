//
//  NWLLogView.h
//  NWLogging
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWLPrinter.h"
#include "TargetConditionals.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
@interface NWLLogView : UITextView <NWLPrinter>
#else 
#import <Cocoa/Cocoa.h>
@interface NWLLogView : NSTextView <NWLPrinter>
#endif

@property (nonatomic, assign) NSUInteger maxLogSize;

- (void)appendAndFollowText:(NSString *)text;
- (void)appendAndScrollText:(NSString *)text;
- (void)safeAppendAndFollowText:(NSString *)text;

- (void)scrollDown;

@end
