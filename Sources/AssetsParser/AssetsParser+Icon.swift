import Foundation
import Image

extension AssetsParser {
    /**
     icon: 新的圖標檔案位置(支援本地跟遠端)，僅支援 1024x1024 圖檔
     */
    @discardableResult
    public func replace(icon: URL) throws -> Self {
        if icon.scheme == "file" {
            try replace(localIcon: icon)
        }
        else {
            try replace(remoteIcon: icon)
        }
        return self
    }
    
    /// 使用遠端 icon 鏈結替換 icon
    private func replace(remoteIcon : URL) throws {
        // 下載遠端 icon 到本地暫存資料夾
        let iconURL = tempDirectory.appendingPathComponent("\(UUID().uuidString).png")
        do {
            try download(url: remoteIcon, toURL: iconURL)
        }
        catch {
            throw AssetsParserError.downloadImageFailed
        }
        try replace(localIcon: iconURL)
    }
    
    /// 使用本地 icon 路徑替換 icon
    private func replace(localIcon: URL) throws {
        guard let image = try? Image(url: localIcon) else {
            throw AssetsParserError.invalidImageFormat
        }
        // 僅支援 PNG
        guard image.format == .png else {
            throw AssetsParserError.invalidImageFormat
        }
        // 僅支援 1024x1024 的圖片
        guard image.size?.width == 1024, image.size?.height == 1024 else {
            throw AssetsParserError.invalidImageSize
        }
        
        // 替換AppIcon.appiconset下所有圖標成新的圖檔
        try replaceNewIcon(iconURL: localIcon, xcassetsDirURL: xcassetsDirURL)
    }
    
    // 替換AppIcon.appiconset下所有圖標成新的圖檔
    private func replaceNewIcon(iconURL: URL, xcassetsDirURL: URL) throws {
        let iconImage = try Image(url: iconURL)
        
        let appIconDirURL = xcassetsDirURL.appendingPathComponent("AppIcon.appiconset")
        let enumerator = FileManager.default.enumerator(atPath: appIconDirURL.path)
        
        while let filePath = enumerator?.nextObject() as? String {
            let currentFullURL = appIconDirURL.appendingPathComponent(filePath)
            guard ["png", "jpg", "jpeg", "pdf"].contains(currentFullURL.pathExtension.lowercased()) else {
                continue
            }
            
            let currentImage = try Image(url: currentFullURL)
            guard let currentImageSize = currentImage.size else {
                continue
            }
            let newImage = try iconImage.resize(to: currentImageSize)
            try newImage.data.write(to: currentFullURL)
        }
    }
}
