//
//  TOMem.h
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import <Foundation/Foundation.h>

extern id const TONil;
@protocol TODelegate;


@interface TOMem : NSObject

- (id)get:(NSString *)name;
- (void)set:(id)object name:(NSString *)name;
- (void)unset:(NSString *)name;
- (void)clear;

- (NSArray *)dump;
- (id)eval:(NSString *)code;
- (id)eval:(NSString *)code delegate:(id<TODelegate>)delegate;
+ (id)eval:(NSString *)code;
+ (NSString *)formatAt:(NSUInteger)index code:(const char *)code string:(NSString *)string;

@end


@protocol TODelegate <NSObject>

- (void)log:(NSString *)string;

@end
