---
description: Work through issues until the app compiles (for Apple platform development)
---

Make the app compile. Run xcbuild so that it tells you all the build errors and warnings. Fix each of these. Do not stop working until the app compiles with no errors and no warnings.

The following command worked properly to get warnings and errors

```
cd /Users/vincentdeaugustine/VinWareLLC/<ProjectName> && xcodebuild -project <ProjectName>.xcodeproj -scheme <ProjectName> -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build 2>&1 | grep -E "(error:|warning:|BUILD)" | head -50
```


Make sure it compiles for all targets & schemes of the project. For example, if it is a multiplatform app in Xcode, make sure it compiles for MacOS, TVOS, or whatever platforms are selected in the app configuration settings files.

try this for compiling for macOS
```
xcodebuild -project <ProjectName>.xcodeproj -scheme <ProjectName> -destination 'platform=macOS' build 2>&1 | grep -E "(error:|warning:|BUILD)" | head -100
```