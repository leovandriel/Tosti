//
//  TOMath.h
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TOMath : NSObject

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

@end
