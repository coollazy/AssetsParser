import Foundation
import AssetsParser

do {
    let fromPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("Resources")
        .appendingPathComponent("OriginalAssets.car")
    
    let toPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("output")
        .appendingPathComponent("NewAssets.car")

    let iconURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("Resources/test-icon.png")
    
    try AssetsParser(assetsURL: fromPath)
        .replace(icon: iconURL)
        .build(toPath: toPath)
    
    print("🟢 Generate new assets.car with new icon successfully!")
}
catch {
    print("error \(error)")
}

