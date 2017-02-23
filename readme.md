# phaxio-ios

Send faxes with [Phaxio](http://www.phaxio.com).

## Installation

####Cocoa-Pods
1. If you haven't already, install the latest version of [CocoaPods](https://guides.cocoapods.org/using/getting-started.html)

2. Add this line to your `Podfile`:
```pod 'Phaxio'```

3. Run `pod install`

4. Don't forget to use `.workspace` to open your project in Xcode

####Carthage
1. If you haven't alrady, install the latest version of [Carthage](https://github.com/Carthage/Carthage#installing-carthage)

2. Add this line to your `Cartfile`: 
```github "phaxio/phaxio-ios"```

3. Follow the Carthage [installation instructions](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos)

####Dynamic Framework
1. Head to our GitHub releases page and download and unzip Phaxio.framework.zip

2. Drag Phaxio.framework to the "Embedded Binaries" section of your Xcode project's "General" settings and be sure to select "Copy items if needed"

3. Head to the "Build Phases" section of your Xcode project settings, and create a new "Run Script Build Phase". Paste the followoing snippet into the text field:
`bash "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Phaxio.framework/integrate-dynamic-framework.sd"`

####Static Framework
1. Head to our GitHub releases page and download and unzip PhaxioiOS.zip

2. In Xcode, with your project open, click on "File" then "Add files to Project..."

3. Select Phaxio.framework in the directory you just unzipped.

4. Make sure "Copy items if needed" is checked.

5. Click "Add."

6. In Xcode, click on "File", then "Add files to Project...".

7. Select Phaxio.bundle, located within Phaxio.framework.

8. Make sure "Copy items if needed" is checked.

9. Click "Add".


## Setup

Sets the key and secret for Phaxio.
```objective-c

[PhaxioAPI setAPIKey:@"thisisthekey" andSecret:@"thisisthesecret"];

```

## Author

[Nick Schulze](http://twitter.com/nickschulze) ([nschulze16@gmail.com](mailto:nschulze16@gmail.com)).

## License

This project is [UNLICENSED](http://unlicense.org/) and not endorsed by or affiliated with [Phaxio](http://www.phaxio.com).

