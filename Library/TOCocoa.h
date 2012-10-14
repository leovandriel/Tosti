//
//  TOCocoa.h
//  Tosti
//
//  Created by Leo on 10/14/12.
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TOCocoa : NSObject

+ (id(^)(id,id,id,id))CGRectMake;
+ (id(^)(id,id))CGSizeMake;
+ (id(^)(id))NSStringFromClass;
+ (id(^)(id,id,id))dispatch_after;
+ (id(^)(id,id))dispatch_async;

@end
