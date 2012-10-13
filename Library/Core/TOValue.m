//
//  TOValue.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import "TOValue.h"
#import <CoreGraphics/CoreGraphics.h>

#include "TargetConditionals.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif


#define TOStructReturn(__type, __prop) if (strcmp(self.objCType, @encode(__type)) == 0) return TOValueGet(self, __type).__prop


@implementation TOValue {
    NSValue *_value;
}


#pragma mark - NSValue Wrap

- (id)initWithBytes:(const void *)bytes objCType:(const char *)type
{
    self = [super init];
    if (self) {
        _value = [[NSValue alloc] initWithBytes:bytes objCType:type];
    }
    return self;
}

- (id)initWithPointer:(const void *)pointer objCType:(const char *)type
{
    self = [super init];
    if (self) {
        _value = [[NSValue alloc] initWithBytes:&pointer objCType:type];
    }
    return self;
}

- (void)getValue:(void *)bytes
{
    [_value getValue:bytes];
}

- (void *)pointerValue
{
    return [_value pointerValue];
}

- (const char *)objCType
{
    return [_value objCType];
}

- (NSString *)description
{
    return [_value description];
}


#pragma mark - Foundation Struct Helpers

- (NSUInteger)length
{
    TOStructReturn(NSRange, length);
    return 0;
}

- (NSUInteger)location
{
    TOStructReturn(NSRange, location);
    return 0;
}


#pragma mark - Core Graphics Struct Helpers

- (CGPoint)origin
{
#if TARGET_OS_IPHONE
    TOStructReturn(CGRect, origin);
#else
    TOStructReturn(NSRect, origin);
#endif
    return CGPointZero;
}

- (CGSize)size
{
#if TARGET_OS_IPHONE
    TOStructReturn(CGRect, size);
#else
    TOStructReturn(NSRect, size);
#endif
    return CGSizeZero;
}

- (CGFloat)x
{
#if TARGET_OS_IPHONE
    TOStructReturn(CGPoint, x);
#else
    TOStructReturn(NSPoint, x);
#endif
    return 0.f;
}

- (CGFloat)y
{
#if TARGET_OS_IPHONE
    TOStructReturn(CGPoint, y);
#else
    TOStructReturn(NSPoint, y);
#endif
    return 0.f;
}

- (CGFloat)width
{
#if TARGET_OS_IPHONE
    TOStructReturn(CGSize, width);
#else
    TOStructReturn(NSSize, width);
#endif
    return 0.f;
}

- (CGFloat)height
{
#if TARGET_OS_IPHONE
    TOStructReturn(CGSize, height);
#else
    TOStructReturn(NSSize, height);
#endif
    return 0.f;
}

- (CGFloat)top
{
#if TARGET_OS_IPHONE
    TOStructReturn(UIEdgeInsets, top);
#endif
    return 0.f;
}

- (CGFloat)left
{
#if TARGET_OS_IPHONE
    TOStructReturn(UIEdgeInsets, left);
#endif
    return 0.f;
}

- (CGFloat)bottom
{
#if TARGET_OS_IPHONE
    TOStructReturn(UIEdgeInsets, bottom);
#endif
    return 0.f;
}

- (CGFloat)right
{
#if TARGET_OS_IPHONE
    TOStructReturn(UIEdgeInsets, right);
#endif
    return 0.f;
}

@end
