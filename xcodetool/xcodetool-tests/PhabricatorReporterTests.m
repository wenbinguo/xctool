// Copyright 2004-present Facebook. All Rights Reserved.


#import <SenTestingKit/SenTestingKit.h>

#import "Options.h"
#import "PJSONKit.h"
#import "PhabricatorReporter.h"
#import "TestUtil.h"

@interface PhabricatorReporterTests : SenTestCase
@end

@implementation PhabricatorReporterTests

- (PhabricatorReporter *)reporterPumpedWithEventsFrom:(NSString *)path options:(Options *)options
{
  PhabricatorReporter *reporter = (PhabricatorReporter *)[Reporter reporterWithName:@"phabricator"
                                                                         outputPath:@"-"
                                                                            options:options];
  [reporter openWithStandardOutput:[NSFileHandle fileHandleWithNullDevice] error:nil];

  NSString *pathContents = [NSString stringWithContentsOfFile:path
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];

  for (NSString *line in [pathContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
    if (line.length == 0) {
      break;
    }

    [reporter handleEvent:[line XT_objectFromJSONString]];
  }

  return reporter;
}

- (void)testGoodBuild
{
  Options *options = [[Options alloc] init];
  options.workspace = TEST_DATA @"TestProject-Library/TestProject-Library.xcodeproj";
  options.scheme = @"TestProject-Library";
  PhabricatorReporter *reporter = [self reporterPumpedWithEventsFrom:TEST_DATA @"RawReporter-build-good.txt" options:options];

  NSArray *results = [[reporter arcUnitJSON] XT_objectFromJSONString];
  assertThat(results, notNilValue());
  assertThat(results,
             equalTo(@[
                     @{
                     @"name" : @"TestProject-Library: Build TestProject-Library:TestProject-Library",
                     @"result" : @"pass",
                     @"userdata" : @"",
                     @"link" : [NSNull null],
                     @"extra" : [NSNull null],
                     @"coverage" : [NSNull null],
                     },
                     @{
                     @"name" : @"TestProject-Library: Build TestProject-Library:TestProject-LibraryTests",
                     @"result" : @"pass",
                     @"userdata" : @"",
                     @"link" : [NSNull null],
                     @"extra" : [NSNull null],
                     @"coverage" : [NSNull null],
                     },
                     ]));
}

- (void)testBadBuild
{
  Options *options = [[Options alloc] init];
  options.workspace = TEST_DATA @"TestProject-Library/TestProject-Library.xcodeproj";
  options.scheme = @"TestProject-Library";
  PhabricatorReporter *reporter = [self reporterPumpedWithEventsFrom:TEST_DATA @"RawReporter-build-bad.txt" options:options];

  NSArray *results = [[reporter arcUnitJSON] XT_objectFromJSONString];
  assertThat(results, notNilValue());
  assertThat(results,
             equalTo(@[
                     @{
                     @"name" : @"TestProject-Library: Build TestProject-Library:TestProject-Library",
                     @"result" : @"pass",
                     @"userdata" : @"",
                     @"link" : [NSNull null],
                     @"extra" : [NSNull null],
                     @"coverage" : [NSNull null],
                     },
                     @{
                     @"name" : @"TestProject-Library: Build TestProject-Library:TestProject-LibraryTests",
                     @"result" : @"broken",
                     @"userdata" : @"CompileC /Users/fpotter/Library/Developer/Xcode/DerivedData/TestProject-Library-gpcgrfaidrhstlbqbvqcqcehbnqc/Build/Intermediates/TestProject-Library.build/Debug-iphonesimulator/TestProject-LibraryTests.build/Objects-normal/i386/SomeTests.o TestProject-LibraryTests/SomeTests.m normal i386 objective-c com.apple.compilers.llvm.clang.1_0.compiler\n    cd /Users/fpotter/fb/git/fbobjc/Tools/xcodetool/xcodetool/xcodetool-tests/TestData/TestProject-Library\n    setenv LANG en_US.US-ASCII\n    setenv PATH \"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin\"\n    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -x objective-c -arch i386 -fmessage-length=0 -std=gnu99 -Wno-trigraphs -fpascal-strings -O0 -Wno-missing-field-initializers -Wno-missing-prototypes -Wreturn-type -Wno-implicit-atomic-properties -Wno-receiver-is-weak -Wduplicate-method-match -Wformat -Wno-missing-braces -Wparentheses -Wswitch -Wno-unused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wempty-body -Wuninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wno-constant-conversion -Wno-int-conversion -Wno-enum-conversion -Wno-shorten-64-to-32 -Wpointer-sign -Wno-newline-eof -Wno-selector -Wno-strict-selector-match -Wno-undeclared-selector -Wno-deprecated-implementations -DDEBUG=1 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator6.1.sdk -fexceptions -fasm-blocks -fstrict-aliasing -Wprotocol -Wdeprecated-declarations -g -Wno-sign-conversion -fobjc-abi-version=2 -fobjc-legacy-dispatch -mios-simulator-version-min=6.0 -iquote /Users/fpotter/Library/Developer/Xcode/DerivedData/TestProject-Library-gpcgrfaidrhstlbqbvqcqcehbnqc/Build/Intermediates/TestProject-Library.build/Debug-iphonesimulator/TestProject-LibraryTests.build/TestProject-LibraryTests-generated-files.hmap -I/Users/fpotter/Library/Developer/Xcode/DerivedData/TestProject-Library-gpcgrfaidrhstlbqbvqcqcehbnqc/Build/Intermediates/TestProject-Library.build/Debug-iphonesimulator/TestProject-LibraryTests.build/TestProject-LibraryTests-own-target-headers.hmap -I/Users/fpotter/Library/Developer/Xcode/DerivedData/TestProject-Library-gpcgrfaidrhstlbqbvqcqcehbnqc/Build/Intermediates/TestProject-Library.build/Debug-iphonesimulator/TestProject-LibraryTests.build/TestProject-LibraryTests-all-target-headers.hmap -iquote /Users/fpotter/Library/Developer/Xcode/DerivedData/TestProject-Library-gpcgrfaidrhstlbqbvqcqcehbnqc/Build/Intermediates/TestProject-Library.build/Debug-iphonesimulator/TestProject-LibraryTests.build/TestProject-LibraryTests-project-headers.hmap -I/Users/fpotter/Library/Developer/Xcode/DerivedData/TestProject-Library-gpcgrfaidrhstlbqbvqcqcehbnqc/Build/Products/Debug-iphonesimulator/include -I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include -I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include -I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include -I/Users/fpotter/Library/Developer/Xcode/DerivedData/TestProject-Library-gpcgrfaidrhstlbqbvqcqcehbnqc/Build/Intermediates/TestProject-Library.build/Debug-iphonesimulator/TestProject-LibraryTests.build/DerivedSources/i386 -I/Users/fpotter/Library/Developer/Xcode/DerivedData/TestProject-Library-gpcgrfaidrhstlbqbvqcqcehbnqc/Build/Intermediates/TestProject-Library.build/Debug-iphonesimulator/TestProject-LibraryTests.build/DerivedSources -F/Users/fpotter/Library/Developer/Xcode/DerivedData/TestProject-Library-gpcgrfaidrhstlbqbvqcqcehbnqc/Build/Products/Debug-iphonesimulator -F/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator6.1.sdk/Developer/Library/Frameworks -F/Applications/Xcode.app/Contents/Developer/Library/Frameworks -include /Users/fpotter/fb/git/fbobjc/Tools/xcodetool/xcodetool/xcodetool-tests/TestData/TestProject-Library/TestProject-Library/TestProject-Library-Prefix.pch -MMD -MT dependencies -MF /Users/fpotter/Library/Developer/Xcode/DerivedData/TestProject-Library-gpcgrfaidrhstlbqbvqcqcehbnqc/Build/Intermediates/TestProject-Library.build/Debug-iphonesimulator/TestProject-LibraryTests.build/Objects-normal/i386/SomeTests.d --serialize-diagnostics /Users/fpotter/Library/Developer/Xcode/DerivedData/TestProject-Library-gpcgrfaidrhstlbqbvqcqcehbnqc/Build/Intermediates/TestProject-Library.build/Debug-iphonesimulator/TestProject-LibraryTests.build/Objects-normal/i386/SomeTests.dia -c /Users/fpotter/fb/git/fbobjc/Tools/xcodetool/xcodetool/xcodetool-tests/TestData/TestProject-Library/TestProject-LibraryTests/SomeTests.m -o /Users/fpotter/Library/Developer/Xcode/DerivedData/TestProject-Library-gpcgrfaidrhstlbqbvqcqcehbnqc/Build/Intermediates/TestProject-Library.build/Debug-iphonesimulator/TestProject-LibraryTests.build/Objects-normal/i386/SomeTests.o\n/Users/fpotter/fb/git/fbobjc/Tools/xcodetool/xcodetool/xcodetool-tests/TestData/TestProject-Library/TestProject-LibraryTests/SomeTests.m:17:1: error: use of undeclared identifier 'WTF'\nWTF\n^\n/Users/fpotter/fb/git/fbobjc/Tools/xcodetool/xcodetool/xcodetool-tests/TestData/TestProject-Library/TestProject-LibraryTests/SomeTests.m:63:20: warning: implicit declaration of function 'backtrace' is invalid in C99 [-Wimplicit-function-declaration]\n  int numSymbols = backtrace(exceptionSymbols, 256);\n                   ^\n/Users/fpotter/fb/git/fbobjc/Tools/xcodetool/xcodetool/xcodetool-tests/TestData/TestProject-Library/TestProject-LibraryTests/SomeTests.m:64:3: warning: implicit declaration of function 'backtrace_symbols_fd' is invalid in C99 [-Wimplicit-function-declaration]\n  backtrace_symbols_fd(exceptionSymbols, numSymbols, STDERR_FILENO);\n  ^\n2 warnings and 1 error generated.\n",
                     @"link" : [NSNull null],
                     @"extra" : [NSNull null],
                     @"coverage" : [NSNull null],
                     },
                     ]));
}

- (void)testTestResults
{
  Options *options = [[Options alloc] init];
  options.workspace = TEST_DATA @"TestProject-Library/TestProject-Library.xcodeproj";
  options.scheme = @"TestProject-Library";
  PhabricatorReporter *reporter = [self reporterPumpedWithEventsFrom:TEST_DATA @"RawReporter-runtests.txt" options:options];

  NSArray *results = [[reporter arcUnitJSON] XT_objectFromJSONString];
  assertThat(results, notNilValue());
  assertThat(results,
             equalTo(@[
                     @{
                     @"name" : @"TestProject-Library: -[SomeTests testOutputMerging]",
                     @"result" : @"pass",
                     @"userdata" : @"stdout-line1\nstderr-line1\nstdout-line2\nstdout-line3\nstderr-line2\nstderr-line3\n",
                     @"coverage" : [NSNull null],
                     @"extra" :  [NSNull null],
                     @"link" : [NSNull null],
                     },
                     @{
                     @"name" : @"TestProject-Library: -[SomeTests testPrintSDK]",
                     @"result" : @"pass",
                     @"userdata" : @"2013-03-28 11:35:43.956 otest[64678:707] SDK: 6.1\n",
                     @"coverage" : [NSNull null],
                     @"extra" :  [NSNull null],
                     @"link" : [NSNull null],
                     },
                     @{
                     @"name" : @"TestProject-Library: -[SomeTests testStream]",
                     @"result" : @"pass",
                     @"userdata" : @"2013-03-28 11:35:43.957 otest[64678:707] >>>> i = 0\n2013-03-28 11:35:44.208 otest[64678:707] >>>> i = 1\n2013-03-28 11:35:44.459 otest[64678:707] >>>> i = 2\n",
                     @"coverage" : [NSNull null],
                     @"extra" :  [NSNull null],
                     @"link" : [NSNull null],
                     },
                     @{
                     @"name" : @"TestProject-Library: -[SomeTests testWillFail]",
                     @"result" : @"fail",
                     @"userdata" : @"/Users/fpotter/fb/git/fbobjc/Tools/xcodetool/xcodetool/xcodetool-tests/TestData/TestProject-Library/TestProject-LibraryTests/SomeTests.m:40: SenTestFailureException: 'a' should be equal to 'b' Strings aren't equal",
                     @"coverage" : [NSNull null],
                     @"extra" :  [NSNull null],
                     @"link" : [NSNull null],
                     },
                     @{
                     @"name" : @"TestProject-Library: -[SomeTests testWillPass]",
                     @"result" : @"pass",
                     @"userdata" : @"",
                     @"coverage" : [NSNull null],
                     @"extra" :  [NSNull null],
                     @"link" : [NSNull null],
                     },
                     ]));
}

@end