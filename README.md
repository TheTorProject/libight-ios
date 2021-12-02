# OONI Probe iOS

[![OONI Probe iOS](assets/OONIProbeLogo.png)](https://ooni.org)

<p align="center">
  <a href="https://slack.openobservatory.org/">
        <img src="https://slack.openobservatory.org/badge.svg"
            alt="chat on Slack"></a>

  <a href="https://github.com/ooni/probe/issues?q=label%3Aooni%2Fprobe-ios">
    <img src="https://img.shields.io/github/issues/ooni/probe/ooni/probe-ios" alt="open issues">
  </a>

  <img src="http://img.shields.io/travis/ooni/probe-ios.svg" alt="Emulator Tests Status">

  <a href="https://twitter.com/intent/follow?screen_name=OpenObservatory">
    <img src="https://img.shields.io/twitter/follow/OpenObservatory?style=social&logo=twitter"
    alt="follow on Twitter"></a>
</p>

<div align="left">

<a href='https://play.google.com/store/apps/details?id=org.openobservatory.ooniprobe'>
<img alt='Get it on Google Play' src='assets/play-store-badge.png' height="50px"/>
</a>

<a href="https://itunes.apple.com/us/app/ooni-probe/id1199566366">
<img src="assets/app-store-badge.png" height="50px" />
</a>

</div>

OONI Probe is free and open source software designed to measure internet
censorship and other forms of network interference.

[Click here to report a bug](https://github.com/ooni/probe/issues/new)

Other supported platforms: [Android](https://github.com/ooni/probe-android), [Desktop](https://github.com/ooni/probe-desktop), [CLI](https://github.com/ooni/probe-cli)

## Developer information

If you are interested in building the app yourself, read on.

To download and install the measurement-kit library we use [CocoaPods](https://cocoapods.org).

To install cocoapod use

```
sudo gem install cocoapods # brew install cocoapods on macOS
```

Then use the command:

```
pod install
```

This command will install the latest stable binary measurement-kit library
and its dependencies and install the frameworks inside the Xcode Workspace.

Then open the xcode workspace (not the xcode project!)  located in
`ooniprobe.xcworkspace` and click on run to build it.

### How to complile a specific version of oonimkall for an Xcode project.

The most important dependency is `oonimkall`. This dependency contains
the network measurement engine. Its sources are at
[ooni/probe-cli](https://github.com/ooni/probe-cli). We fetch the `oonimkall`
framework directly from `ooni/probe-cli` releases.

You can use a specific version of `oonimkall` it in your project by
changing the release to which it points to in the `Podfile`.

Then type `pod install` and open `.xcworkspace` file (beware not to open the
`.xcodeproj` file instead, because that alone won't compile).

## Managing translations

To manage translations check out our [translation repo](https://github.com/ooni/translations) and follow the instructions there.

## Contributing

* Write some code

* Open a pull request

* Have fun!

## Fastlane

We use fastlane for creating automatically app screenshots in the various
languages we support.

You first need to have some depedencies installed. On macOS:

To install fastlane:

```
# Using RubyGems
sudo gem install fastlane -NV

# Alternatively using Homebrew
brew cask install fastlane
```

Then:

```
brew install libpng jpeg imagemagick

```

You will then be able to automate screenshot creation with:

```
fastlane screenshots
```

Learn more on the fastlane docs:
https://docs.fastlane.tools/getting-started/ios/screenshots
