# AssetsParser

![Platform](https://img.shields.io/badge/platform-macOS-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SPM](https://img.shields.io/badge/SPM-Supported-green)
[![CI](https://github.com/coollazy/AssetsParser/actions/workflows/ci.yml/badge.svg)](https://github.com/coollazy/AssetsParser/actions/workflows/ci.yml)

## 介紹

解析及重新製作 Assets.car

## SPM安裝

- Package.swift 的 dependencies 增加

```swift
.package(name: "AssetsParser", url: "https://github.com/coollazy/AssetsParser.git", from: "1.0.0"),
```

- target 的 dependencies 增加

```swift
.product(name: "AssetsParser", package: "AssetsParser"),
```

## 使用範例

### AssetsParser

- 解析 Assets.car

```swift
// 初始化 AssetsParser
let assetsPath = URL(string: "path_to_your_assets_car")!
let assetsParser = try AssetsParser(assetsURL: assetsPath)

// 解析 Assets.car 之後，換產生一個 xcassets 的資料夾
assetsParser.xcassetsDirURL
```

- 重新產生 Assets.car

```swift
// 將剛剛解壓縮後的資料夾路徑 重新壓縮成 IPA
let toPath = URL(string: "path_to_new_assets_car")!
try assetsParser.build(toPath: toPath)
```

- 替換 Icon (僅支援 1024x1024)

```swift
let iconURL = URL(string: "local_or_remote_icon_path")
try assetsParser.replace(icon: iconURL)
```