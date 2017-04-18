# Attribute Generator

An attribute generator is executable file that takes your source code and generate attribute files for it. When you install our `pod`, CocoaPods copies the attribute generator here: `${PODS_ROOT}/libObjCAttr/tools/binaries/ROADAttributesCodeGenerator`. It's also adds a build phase to a target in your project where it calls the attribute generator with specific arguments. Meaning of these arguments as well as example you can find below.

## Usage

The attribute generator have two required arguments and bunch of optional.

Required arguments:

* `-src`.  Source folder for attribute generator. You can specify as many folders as you want. By default it include two source, `Pods` folder and you target folder. Let's say you want to include source files from `Target1` and `Target3`, but not from `Target2`. It should looks like this:
```
"${PODS_ROOT}/libObjCAttr/tools/binaries/ROADAttributesCodeGenerator" -src="MyProject/Target1" -src="MyProject/Target3" -dst="MyProject/Target1/ROADGeneratedAttributes"
```
* `-dst`. Destination folder for attribute generator. You can specify only one folder. After you call attribute generator, this folder will have `ROADGeneratedAttribute.m` file and one file for each attributed class you have in source path. You should include into your project only `ROADGeneratedAttribute.m` in order your build is succeed.

Optional arguments:

* `-def_file`. File with `#define` preprocessor macro. Attribute generator will use only these defines while generating attributes. Include only those files that has defines for attributes, you can skip other safely. You can specify as many define files as you want.
* `-e`. Exclude string pattern. You can specify few of such arguments. It helps you to exclude from processing some files by simple patterns. Currently it supports only one special symbol - `*`. `*` - means any character or group of characters. Attribute generator searchs this pattern by containing in absolute file path. So it does not necessary to have `*` symbol from both side of pattern if you want to exclude files that contains some substring. For example:
```
-e=App*.m
//Excudes file:
AppDelegate.m
// but not
Appy.h
```
* `-v`. Enable verbose mode of attribute generator. It will logs any warnings and info message while processing files. (Will be implemented soon).

**Important:** arguments can't contain whitespace, unless you escape them or place double quotes around value. (Legit: `-src=My\ Project` or `-src="My Project"`)

### ROADConfigurator.yml

You can and should setup arguments from `ROADConfigurator.yml` file. You can specify path to this file as second parameter in `post_install` hook in your `Podfile`. 

```
post_install do |installer|
  require File.expand_path('ROADConfigurator.rb', './Pods/libObjCAttr/libObjCAttr/Resources/')
  ROADConfigurator::post_install(installer, './path/to/ROADConfigurator.yml')
end
```

By default it searchs such file near you `*.xcodeproj` file.

Here is mapping of arrguments on properties of file:

* `-e` = `exclude`
* `-def_file` = `define_file`
* `-src` = `source`

All properties supports both single value and array. Syntax of file is default yml syntax with named properties. Look at example of `ROADConfigurator.yml` file:

```
exclude: 
  - App*.m
  - Delegate.h
  - Pods
define_file: "\"My Project/Defines.h\""
```
**Important:** In order to have whitespaces in paths in `ROADConfigurator` file, you need to escape them or guard path with quotes. Check example above to see how to guard path with quotes.
