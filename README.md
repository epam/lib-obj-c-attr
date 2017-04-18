[![License](https://cocoapod-badges.herokuapp.com/l/libObjCAttr/badge.svg)](http://opensource.org/licenses/BSD-3-Clause) 
[![Platform](https://cocoapod-badges.herokuapp.com/p/libObjCAttr/badge.png)](https://github.com/epam/road-ios-framework/) 
[![Version](https://cocoapod-badges.herokuapp.com/v/libObjCAttr/badge.png)](https://github.com/epam/lib-obj-c-attr/) 
[![Coverage Status](http://img.shields.io/coveralls/epam/lib-obj-c-attr/master.svg?style=flat)](https://coveralls.io/r/epam/lib-obj-c-attr?branch=master) 
[![Build Status](http://img.shields.io/travis/epam/lib-obj-c-attr/master.svg?style=flat)](https://travis-ci.org/epam/lib-obj-c-attr) 


# libObjCAttr - attributes for your code

libObjCAttr is attribute-oriented programming for Objective-C language. It is compile-time based with the support of Xcode auto-completion and errors tracing features. We nailed every aspect of the implementation including performance, so attributes will never be a bottleneck.

Our solution helps reduce the complexity of code, makes it compact and self-documented. There are a lot of languages with attributes support, we added Objective-C into that list.

## Installation

[CocoaPods](http://cocoapods.org) is the only recommended way of libObjCAttr integration. Besides standard configuration of pod dependencies, *pod_install* hook is required as shown below. A typical **Podfile** will look as follows:

```ruby
pod 'libObjCAttr'

post_install do |installer|
    require File.expand_path('ROADConfigurator.rb', './Pods/libObjCAttr/libObjCAttr/Resources/')
    ROADConfigurator::post_install(installer)
end
```

**Note:**
If you want to get rid of warning from Xcodeproj gem, copy-paste and run in terminal next command before running `pod install`:

```
export COCOAPODS_DISABLE_DETERMINISTIC_UUIDS=YES
```


## Samples

It is super easy to mark your code with an attribute. We currently support **4 types** of attributes:

* *Class attributes*
* *IVar attributes*
* *Method attributes*
* *Property attributes*

Check out this example to get to know how to declare them:

```objective-c
RF_ATTRIBUTE(MyAttribute, stringProperty = @"Hello world")
@interface AnnotatedClass : NSObject {

    RF_ATTRIBUTE(MyAttribute, numericProperty = @9000)
    NSObject * _someField;
}

RF_ATTRIBUTE(MyAttribute, blockProperty = ^(int value) { return value; })
- (void)foo;

RF_ATTRIBUTE(MyAttribute, objectProperty = [NSObject new])
@property NSString *name;

@end
```

An attribute can be any class inherited from NSObject or its subclasses. It may or may not have properties.

```objective-c
#import <ROAD/ROADAttribute.h>

@interface MyAttribute : NSObject

@property NSString *stringProperty;
@property NSNumber *numericProperty;
@property (copy) id blockProperty;
@property id objectProperty;

@end
```

Now you can get them in runtime with code like this:

```objective-c
...

NSArray *classAttributes = [AnnotatedClass RF_attributesForClass];
NSArray *ivarAttributes = [AnnotatedClass RF_attributesForIvar:@"_someField"];

// Let's filter it, in case there are many of them
MyAttribute *methodAttributes = [AnnotatedClass RF_attributeForMethod:@"foo" withAttributeType:[MyAttribute class]];
MyAttribute *classAttributes = [AnnotatedClass RF_attributeForProperty:@"name" withAttributeType:[MyAttribute class]];

...
```

Also check out an info about [an attribute generator](./Documents/AttributeGenerator.md), that makes all behind the scene magic.

## Requirements
libObjCAttr requires **iOS 5.0 and above**. The compatibility with 4.3 and older is not tested.

libObjCAttr was initially designed to use **ARC**.

## Solutions powerd by LibObjCAttr
* ROAD Framework — [https://github.com/epam/road-ios-framework](https://github.com/epam/road-ios-framework)
* Add your project here ;)

## Contact
Follow LibObjCAttr on Twitter ([@LibObjCAttr](http://twitter.com/libobjcattr))

## License
libObjCAttr is made available under the terms of the [BSD-3](http://opensource.org/licenses/BSD-3-Clause). Open the LICENSE file that accompanies this distribution to see the full text of the license.

## Contribution

There are three ways you can help us:

* **Raise an issue.** You found something that does not work as expected? Let us know about it.
* **Suggest a feature.** It's even better if you come up with a new feature and write us about it.
* **Write some code.** We would love to see more pull requests to our framework, just make sure you have the latest sources.
