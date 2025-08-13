import Foundation
import Image

struct ImageInfo {
    let filename: String?
    let scale: String
    let idiom: String
    let size: String?
}

/**
 替換圖標 (僅支援 MacOS 不支援 Linux)
 
 替換流程如下
 1. 用 acextract 指令(MacOS Only)，提取原始的 Assets.car 內的圖檔
 2. 重新建立 .xcassets 檔案結構
 3. 替換AppIcon.appiconset下所有圖標成新的圖檔
 4. 用 actool 指令(MacOS Only)，重新建立新的 Assets.car
 5. 複製生成的 Assets.car 到目標位置
 */
public class AssetsParser {
    public let tempDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent("AssetsParser")
        .appendingPathComponent(UUID().uuidString)
    
    public private(set) var assetsURL: URL
    lazy public private(set) var xcassetsDirURL: URL = {
        tempDirectory.appendingPathComponent("xcassets")
    }()
    
    public init(assetsURL: URL) throws {
        self.assetsURL = assetsURL
        
        // 提取 Assets.car 內所有圖檔到暫存資料夾
        let extractedDirURL = tempDirectory.appendingPathComponent("extracted")
        try FileManager.default.createDirectory(at: extractedDirURL, withIntermediateDirectories: true)
        try extractAssets(assetsURL: assetsURL, extractedDirURL: extractedDirURL)
        
        // 重新建立 .xcassets 檔案結構
        try FileManager.default.createDirectory(at: xcassetsDirURL, withIntermediateDirectories: true)
        try createXCAssetsCatalog(extractedDirURL: extractedDirURL, outputDirURL: xcassetsDirURL)
    }
    
    deinit {
        do {
            try FileManager.default.removeItem(atPath: tempDirectory.path)
        }
        catch {
            print("⚠️⚠️ AssetsParser remove tempDirectory error: \(error)")
        }
    }
}

private extension AssetsParser {
    func extractAssets(assetsURL: URL, extractedDirURL: URL) throws {
        let possiblePaths = [
            "/usr/local/bin/acextract",
            "/opt/homebrew/bin/acextract",
            "./acextract",
            "acextract"
        ]
        
        var acextractPath: String?
        for path in possiblePaths {
            if path == "acextract" || FileManager.default.isExecutableFile(atPath: path) {
                acextractPath = path
                break
            }
        }
        
        guard let toolPath = acextractPath else {
            throw AssetsParserError.acextractNotFound
        }
        
        do {
            print("Extracting with acextract: \(toolPath) -i \(assetsURL.path) -o \(extractedDirURL.path)")
            try runCommand(toolPath, arguments: ["-i", assetsURL.path, "-o", extractedDirURL.path])
            print("extracted assets ✅")
        } catch {
            debugPrint("❌❌ extracted assets failed: \(error.localizedDescription)")
            throw AssetsParserError.extractAssetsFailed(error.localizedDescription)
        }
    }
    
    // 重新建立 .xcassets 檔案結構
    func createXCAssetsCatalog(extractedDirURL: URL, outputDirURL: URL) throws {
        // 讀取所有圖片
        let imageFiles = try FileManager.default.contentsOfDirectory(at: extractedDirURL, includingPropertiesForKeys: nil)
            .filter { ["png", "jpg", "jpeg", "pdf"].contains($0.pathExtension.lowercased()) }
        
        // 分組
        let grouped = Dictionary(grouping: imageFiles) { file -> String in
            let rawName = file.deletingPathExtension().lastPathComponent
            if rawName.lowercased().hasPrefix("appicon") {
                return "AppIcon.appiconset"
            } else {
                return baseImageName(rawName) + ".imageset"
            }
        }
        
        // 生成 xcassets
        for (folderName, files) in grouped {
            let assetFolder = outputDirURL.appendingPathComponent(folderName)
            try FileManager.default.createDirectory(at: assetFolder, withIntermediateDirectories: true)

            var imagesInfo: [ImageInfo] = []
            for file in files {
                let filename = file.lastPathComponent
                let scale = scaleFromFilename(filename)
                let idiom = idiomFromFilename(filename)
                
                let image = try Image(url: file)
                // 複製檔案
                let dest = assetFolder.appendingPathComponent(filename)
                try? FileManager.default.copyItem(at: file, to: dest)

                imagesInfo.append(ImageInfo(filename: filename, scale: scale, idiom: idiom, size: image.size?.toString()))
            }

            // 生成 Contents.json
            let json = try createContentsJSON(for: imagesInfo)
            try json.write(to: assetFolder.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
        }
    }
}
