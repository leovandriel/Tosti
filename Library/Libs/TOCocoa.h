//
//  TOCocoa.h
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TOCocoa : NSObject

+ (id(^)(id))NSStringFromClass;
+ (id(^)(id))NSClassFromString;
+ (id(^)(id))NSStringFromSelector;
+ (id(^)(id))NSSelectorFromString;
+ (id(^)(id))NSStringFromProtocol;
+ (id(^)(id))NSProtocolFromString;
+ (id(^)(id))NSLocalizedString;
+ (id(^)(id,...))NSLog;

+ (id(^)(id,id))NSMakeRange;
+ (id(^)(id,id))NSMakePoint;
+ (id(^)(id,id,id,id))NSMakeRect;
+ (id(^)(id,id))NSMakeSize;

+ (id(^)(id,id,id,id))CGRectMake;
+ (id(^)(id,id))CGSizeMake;
+ (id(^)(id,id,id,id))UIEdgeInsetsMake;

+ (id(^)(id))NSStringFromRect;
+ (id(^)(id))NSStringFromPoint;
+ (id(^)(id))NSStringFromSize;
+ (id(^)(id))NSStringFromCGRect;
+ (id(^)(id))NSStringFromCGPoint;
+ (id(^)(id))NSStringFromCGSize;

+ (id(^)(id,id,id))dispatch_after;
+ (id(^)(id,id))dispatch_async;
+ (id(^)(id,id))dispatch_sync;
+ (id(^)())dispatch_get_main_queue;
+ (id(^)(id))dispatch_get_global_queue;

@end
