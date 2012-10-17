//
//  TOValue.h
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import <Foundation/Foundation.h>


#define TOValueGet(__value, __type) ({__type __x; [self getValue:&__x]; __x;})


@interface TOValue : NSObject

- (id)initWithBytes:(const void *)bytes objCType:(const char *)type;
- (id)initWithPointer:(const void *)pointer objCType:(const char *)type;
- (void)getValue:(void *)bytes;
- (const char *)objCType;

@end