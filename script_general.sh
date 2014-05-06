#!/bin/bash

EXIT_STATUS=0

# =================     Set environment variables     ===========
export ATTR_PROJECT="-project libObjCAttr.xcodeproj"
export GENERATOR_PROJECT="-project tools/ROADAttributesCodeGenerator/ROADAttributesCodeGenerator.xcodeproj"
if [[ $PROJECT_SCHEME == ROADAttributesCodeGenerator ]]; then export PATCH_FOR_PROJECT_OR_WORKSPACE=$GENERATOR_PROJECT; else export PATCH_FOR_PROJECT_OR_WORKSPACE=$ATTR_PROJECT; fi

# =================     Install cpp-coveralls    ===========
sudo easy_install cpp-coveralls > /dev/null

# =================     Run build, test and oclint check     ===========
xctool $PATCH_FOR_PROJECT_OR_WORKSPACE -scheme $PROJECT_SCHEME -reporter pretty -reporter json-compilation-database:compile_commands.json build || EXIT_STATUS=$?
if [[ $PROJECT_SCHEME == libObjCAttr ]]; then xctool $PATCH_FOR_PROJECT_OR_WORKSPACE -scheme $PROJECT_SCHEME test -sdk iphonesimulator7.0 || EXIT_STATUS=$?; fi
if [[ $PROJECT_SCHEME == libObjCAttrMac ]]; then xctool $PATCH_FOR_PROJECT_OR_WORKSPACE -scheme $PROJECT_SCHEME test || EXIT_STATUS=$?; fi

# =================     Download oclint, unzip    ===========

wget https://www.dropbox.com/s/gd890zrni02gkoy/oclint-0.9.dev.90b12ca.zip > /dev/null
unzip oclint-0.9.dev.90b12ca.zip > /dev/null

# =================     Setup oclint    ===========
OCLINT_HOME=$('pwd')/oclint-0.9.dev.90b12ca
PATH=$OCLINT_HOME/bin:$PATH

# =================     Run oclint    ===========
oclint-json-compilation-database -e ROADGeneratedAttributes -- -rc=LONG_LINE=500 -rc=LONG_VARIABLE_NAME=50 -max-priority-2 30 -max-priority-3 152 || EXIT_STATUS=$?;

exit $EXIT_STATUS
