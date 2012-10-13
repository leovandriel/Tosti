//
//  TOValue.h
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import <Foundation/Foundation.h>


#define TOValueGet(__value, __type) ({__type __x; [(__value) getValue:&__x]; __x;})
#define TOValueIsType(__value, __type) (strcmp([(__value) objCType], @encode(__type)) == 0)


@interface TOValue : NSObject

- (id)initWithBytes:(const void *)bytes objCType:(const char *)type;
- (id)initWithPointer:(const void *)pointer objCType:(const char *)type;
- (void)getValue:(void *)bytes;
- (const char *)objCType;

@end