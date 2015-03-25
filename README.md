# ServerReachability
This class help you with access checking to server by host and port.

## Installation

The recommended approach for installing ServerReachability is via the [CocoaPods](http://cocoapods.org/) package manager, as it provides flexible dependency management and dead simple installation. For best results, it is recommended that you install via CocoaPods **>= ** usin0.19.1g Git **>= 1.8.0** installed via Homebrew.

### via CocoaPods

Install CocoaPods if not already available:

``` bash
$ [sudo] gem install cocoapods
$ pod setup
```

Change to the directory of your Xcode project, and Create and Edit your Podfile and add RestKit:

``` bash
$ cd /path/to/MyProject
$ touch Podfile
$ edit Podfile
platform :ios, '5.0' 
# Or platform :osx, '10.7'
pod 'ServerReachability', :git => 'https://github.com/ogubariev/ServerReachability.git', :tag => '0.0.1'
```

Install into your project:

``` bash
$ pod install
```

Open your project in Xcode from the .xcworkspace file (not the usual project file)

``` bash
$ open MyProject.xcworkspace
```

## License

ServerReachability is licensed under the terms of the [MIT License]. Please see the [LICENSE](LICENSE) file for full details.
