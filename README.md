Tosti
===========

*An Objective-C interpreter without C support.*


About
-----
Tosti can read and evaluate Objective-C source code at runtime, without the need to compile it into a binary or do any low-level fiddling. It supports a lot of the syntax Objective-C adds on top of C, but hardly any pure C. This means that you can run simple stuff like:

    id a = @"Objective-C"; id b = [a substringToIndex:9];
    
But *not* C code like:

    int a = 2, b = 6; if (a > 0) b /= a; printf("%i", b);

This limitation has made TObjectie small and comprehensible. To deal with the absence of `if`, `for`, and the C standard library, Tosti provides a library of blocks-based wrappers. For example, you *can* do:

    a = 2 b = 6 [TO if:TO.greater(a 0) then:^{b=TO.div(b a)}]

Note that the above line is not valid Objective-C code. Tosti supports Objective-C syntax, but also allows a more relaxed syntax if unambiguous.


Getting Started
---------------
First try some lines of code yourself by running the Demo app. This is a basic console onto which you can type and run your source code. It's recommended to run this in the iOS simulator or as Mac app, so you don't have to suffer from an on-screen keyboard.

Try basic assignment and message sending:

    x = "some text"
    [x length]
    x.uppercaseString
    
See how the parser responds to syntax errors:

    x[
    expecting index at 'x[`'
  
    x=@{1:2 3:4]
    expecting dictionary key at 'x=@{1:2 3:4`]'
  
Or how things can go wrong at runtime:

    [[NSString alloc] ini]
    Class NSPlaceholderString does not respond to 'ini' at '`[[NSString alloc] in..'
    
    x=^{x()}x()
    stackoverflow at 'x=^`{x()}x()'
    
    ["" substringToIndex:3]
    Exception '*** -[__NSCFString substringToIndex:]: Range or index ...

In this demo app, the view controller has been assigned to `self`:

    self.class
    console=self.view.subviews[0] console.textColor=UIColor.greenColor
    frame = console.frame
    TO.dispatch_async(nil, ^{console.frame = TO.CGRectMake(10, 10, 100, 100)})
    TO.dispatch_async(nil, ^{console.frame = frame})


Including Tosti in your project is fairly straightforward. You can run the `TostiUniversal` target which builds a `Tosti.framework`. Alternatively, you can add the library sources to your project. Make sure you read the disclaimer below if you plan to submit your app to Apple's App Store.


Disclaimer
----------
Apple is not very fond of interpeters in App Store binaries. To quote Apple's Developer Program License Agreement:

> *Interpreted code may only be used in an Application if all scripts, code and interpreters are packaged in the Application and not downloaded.*

Although it might be very easy to include all sources in the bundle, it will be very hard to guarantee no code will be downloaded with or without your consent. Therefore I highly recommend not to include Tosti or any of its parts in your App Store builds. Think about it: what's the use of Apple's App Review Board if afterwards you can download any code you like?


License
-------
Tosti is licensed under the terms of the BSD 2-Clause License, see the included LICENSE file.


Authors
-------
- [Leonard van Driel](http://www.leonardvandriel.nl/)
