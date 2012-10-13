//
//  TOEval.h
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TODelegate;
@class TOMem;


@interface TOEval : NSObject

@property (nonatomic, strong) NSArray *statement;
@property (nonatomic, strong) TOMem *mem;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, weak) id<TODelegate> delegate;

- (id)initWithStatement:(NSArray *)statement mem:(TOMem *)mem;
- (id)eval;
- (void)abort;
+ (id)evalStatement:(NSArray *)statement;

@end
