//
//  NWLFilePrinter.h
//  NWLogging
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//

#import "NWLPrinter.h"


@interface NWLFilePrinter : NSObject <NWLPrinter>

@property (nonatomic, assign) NSUInteger maxLogSize;
@property (nonatomic, readonly) NSString *path;

- (id)init;
- (id)initAndOpenName:(NSString *)name;
- (id)initAndOpenPath:(NSString *)path;

- (BOOL)openPath:(NSString *)path;

- (void)sync;
- (void)clear;
- (void)close;

- (NSString *)content;
- (void)append:(NSString *)string;
- (void)appendAsync:(NSString *)string;

- (NSData *)contentData;
- (void)appendData:(NSData *)data;
- (void)appendDataAsync:(NSData *)data;

+ (NSString *)pathForName:(NSString *)name;

@end
