import Foundation

extension AssetsParser {
    /**
     產生新的 Assets.car
     toDirectory: 要產生新的 Assets.car 的完整路徑
     */
    public func build(toPath: URL) throws {
        // 用 actool 指令(MacOS Only)，重新建立新的 Assets.car
        let newAssetsCarURL = try compileAssets(xcassetsDirURL: xcassetsDirURL)
        guard FileManager.default.fileExists(atPath: newAssetsCarURL.path) else {
            throw AssetsParserError.compileAssetsFailed
        }
        
        // 判斷路徑的資料夾是否存在，不存在就自動建立
        if FileManager.default.fileExists(atPath: toPath.deletingLastPathComponent().path) == false {
            try FileManager.default.createDirectory(at: toPath.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        }
        
        // 若是檔案已經存在，就先刪除
        if FileManager.default.fileExists(atPath: toPath.path) {
            try FileManager.default.removeItem(at: toPath)
        }
        
        // 複製生成的 Assets.car 到目標位置
        try FileManager.default.copyItem(at: newAssetsCarURL, to: toPath)
    }
    
    private func compileAssets(xcassetsDirURL: URL) throws -> URL {
        let tempDirURL = tempDirectory.appendingPathComponent("car")
        try FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true)
        
        try runCommand("/usr/bin/actool", arguments: [
            "--compile", tempDirURL.path,
            "--platform", "iphoneos",
            "--minimum-deployment-target", "12.0",
            "--app-icon", "AppIcon",
            "--output-partial-info-plist", "/dev/null",
            xcassetsDirURL.path
        ])
        
        return tempDirURL.appendingPathComponent("Assets.car")
    }
}
