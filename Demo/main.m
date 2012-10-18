//
//  main.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

int main(int argc, char *argv[])
{
#if TARGET_OS_IPHONE
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, @"TOTouchAppDelegate");
    }
#else
    return NSApplicationMain(argc, (const char **)argv);
#endif
}
