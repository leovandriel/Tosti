//
//  TOConsoleController.h
//  Tosti
//
//  Created by Leo on 10/18/12.
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TOMem.h"

@protocol TOConsoleTextDelegate;


@interface TOConsoleController : NSObject <TODelegate>

@property (nonatomic, weak) id<TOConsoleTextDelegate> delegate;

- (void)setup;
- (BOOL)shouldType:(NSString *)string;

@end


@protocol TOConsoleTextDelegate <NSObject>

@property (nonatomic, strong) NSString *input;

- (void)append:(NSString *)text;

@end