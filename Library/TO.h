//
//  TO.h
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TO : NSObject

+ (void)while:(id(^)(void))block;
+ (void)for:(void(^)(id))block to:(id)to;
+ (id)if:(id)condition then:(id(^)(void))t;
+ (id)if:(id)condition then:(id(^)(void))t else:(id(^)(void))e;
+ (id)if:(id)condition then:(id(^)(void))t elseif:(id)condition2 then:(id(^)(void))t2 else:(id(^)(void))e;

+ (id(^)(id,id))add;
+ (id(^)(id,id))mul;
+ (id(^)(id,id))sub;
+ (id(^)(id,id))div;
+ (id(^)(id,id))avg;
+ (id(^)(id,id))min;
+ (id(^)(id,id))max;
+ (id(^)(id))inc;
+ (id(^)(id))dec;
+ (id(^)(id))neg;
+ (id(^)(id))inv;
+ (id(^)(id,id))less;
+ (id(^)(id,id))lessEq;
+ (id(^)(id,id))greater;
+ (id(^)(id,id))greaterEq;

+ (id(^)(id,id,id,id))CGRectMake;
+ (id(^)(id,id))CGSizeMake;
+ (id(^)(id))NSStringFromClass;
+ (id(^)(id,id,id))dispatch_after;
+ (id(^)(id,id))dispatch_async;

+ (id(^)(id))selectorsOf;
+ (id(^)(id))superOf;
+ (id(^)(id,id,id,id))load;

@end
