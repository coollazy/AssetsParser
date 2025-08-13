# AssetsParser

![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SPM](https://img.shields.io/badge/SPM-Supported-green)
[![CI](https://github.com/coollazy/AssetsParser/actions/workflows/ci.yml/badge.svg)](https://github.com/coollazy/AssetsParser/actions/workflows/ci.yml)

## Introduction

Parse and rebuild `Assets.car` files.

## SPM Installation

- Add to Package.swift dependencies:

```
.package(name: "AssetsParser", url: "https://github.com/coollazy/AssetsParser.git", from: "1.0.0"),
```

- Add to target dependencies:

```
.product(name: "AssetsParser", package: "AssetsParser"),
```

## Usage

### AssetsParser

- Parse Assets.car

```swift
// Initialize AssetsParser
let assetsPath = URL(string: "path_to_your_assets_car")!
let assetsParser = try AssetsParser(assetsURL: assetsPath)

// After parsing Assets.car, generate an xcassets folder
assetsParser.xcassetsDirURL
```

- Rebuild Assets.car

```swift
// Recompress the previously extracted folder back into Assets.car
let toPath = URL(string: "path_to_new_assets_car")!
try assetsParser.build(toPath: toPath)
```

- Replace App Icon (supports only 1024x1024)

```swift
let iconURL = URL(string: "local_or_remote_icon_path")
try assetsParser.replace(icon: iconURL)
```
