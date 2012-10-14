//
//  TORead.h
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TODelegate;


@interface TORead : NSObject

@property (nonatomic, strong) NSString *code;
@property (nonatomic, readonly) NSUInteger warnings;
@property (nonatomic, weak) id<TODelegate>delegate;

- (id)initWithCode:(NSString *)code;
- (NSArray *)read;
+ (NSArray *)readCode:(NSString *)code;

@end
