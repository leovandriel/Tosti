<img src="icon.png" alt="Tosti Icon" width="72"/>


Tosti
=====

*An Objective-C interpreter without C support.*


About
-----
Tosti can read and evaluate Objective-C source code at runtime, without the need to compile it into a binary or do any low-level fiddling. It supports a lot of the syntax Objective-C adds on top of C, but hardly any pure C. This means that you can run simple stuff like:

    id a = @"Objective-C"; id b = [a substringToIndex:9];

But *not* C code like:

    int a = 2, b = 6; if (a > 0) b /= a; printf("%i", b);

This limitation has made Tosti small and comprehensible. To deal with the absence of `if`, `for`, and the C standard library, Tosti provides a library of blocks-based wrappers. For example, you *can* do:

    a = 2 b = 6 [TO if:greater(a 0) then:^{b=div(b a)}]

Note that some of the above line is not valid Objective-C code. Tosti supports Objective-C syntax, but also allows a more relaxed syntax if unambiguous.

Although the interpeter does not have C support, Tosti is equipped with a rich set of C-wrappers. These provide a C-like experience, while still being based on Objective-C syntax. This allows for code like:

    range = NSMakeRange(1, 2); NSLog("(%@,%@)", range.location, range.length);

Note the `%@` in the `NSLog` format string: all entities in Tosti are objects. C structs like `NSRange` are dynamically boxed based on method signatues. Tosti can be easily extended to support your custom C structs and functions.


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

    x=^{x()} x()
    stackoverflow at 'x=^`{x()} x()'

    ["" substringToIndex:3]
    Exception '*** -[__NSCFString substringToIndex:]: Range or index ...

In this demo app, the view controller has been assigned to `self`. On iOS this allows for:

    console = self.delegate.view.subviews[0]
    console.textColor = UIColor.greenColor
    frame = console.frame
    dispatch_async(^{console.frame = CGRectMake(10, 10, 100, 100)})
    dispatch_async(^{console.frame = frame})

With some minor modifications, this code also runs on Mac:

    console = self.delegate.console
    dispatch_async(^{console.textColor = NSColor.greenColor})

Including Tosti in your project is fairly straightforward. You can run the `TostiUniversal` target which builds a `Tosti.framework` in the project root. Alternatively, you can add the library sources to your project. Make sure you read the disclaimer below if you plan to submit your app to Apple's App Store.


Extending C-support
-------------------
Tosti relies on the Objective-C runtime to send messages and infer type information. In fact, Tosti is a fairly basic interpreter, and the runtime does most of the work. C does not have this layer of reflection and therefore cannot be interpreted that easy. Take for example a look at [CINT](http://root.cern.ch/drupal/content/cint).

Still, Objective-C and C are tightly connected. To comfortably work with Apple's frameworks, one needs to bridge the gap. This is done with with Tosti's block-based C-wrappers, utilizing the similarity between blocks and functions pointers. These wrappers are written in Objective-C and can therefore be dynamically loaded into the interpeter. For example, to load Cocoa functions, run:

    TO.load(_mem, TOCocoa)

Here `TO.load` calls the `load` class method on `TO`, which returns a block that provides dynamic loading of selectors into the Tosti interpreter. It inspects the `TOCocoa` class and lists all getter class methods. These are then assigned to variables with the same name. For example, `TOCocoa` has the class method `CGRectMake`, which is now assigned to the `CGRectMake` variable:

    CGRectMake
    <__NSGlobalBlock__: 0xabcdef>

Since Tosti does support blocks, you can now create a `CGRect` using:

    rect = CGRectMake(1, 2, 3, 4)
    NSRect: {{1, 2}, {3, 4}}

Also the struct fields of common Cocoa structs have been wrapped, for example:

    width = rect.size.width
    3

Currently Tosti provides C-wrappers for some common types, which covers only a small fraction of Apple's standard frameworks. However, Tosti can be easily extended to accomodate for the structs you use. By loading your wrappers at runtime, as demonstrated above, you can add these without the need to dig into the internals of Tosti.


Disclaimer
----------
Apple is not very fond of interpeters in App Store binaries. To quote Apple's Developer Program License Agreement:

> *Interpreted code may only be used in an Application if all scripts, code and interpreters are packaged in the Application and not downloaded.*

Although it might be very easy to include all sources in the bundle, it will be very hard to guarantee no code will be downloaded with or without your consent. Therefore I highly recommend not to include Tosti or any of its parts in your App Store builds.


License
-------
Tosti is licensed under the terms of the BSD 2-Clause License, see the included LICENSE file.


Authors
-------
- [Leo Vandriel](http://www.leovandriel.com/)
