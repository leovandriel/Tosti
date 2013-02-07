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

+ (id(^)(id))selectorsOf;
+ (id(^)(id))superOf;
+ (id(^)(id,id,id,id))load;

+ (id)_YES;
+ (id)_NO;
+ (id)_true;
+ (id)_false;

@end
