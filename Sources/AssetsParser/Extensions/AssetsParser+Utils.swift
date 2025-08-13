import Foundation

extension AssetsParser {
    func runCommand(_ command: String, arguments: [String]) throws {
        let process = Process()
        process.launchPath = command
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        process.launch()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AssetsParserError.commandFailed("Command failed: \(command) \(arguments.joined(separator: " "))\n\(output)")
        }
    }
    
    // 取得 scale
    func scaleFromFilename(_ name: String) -> String {
        if name.contains("@3x") { return "3x" }
        if name.contains("@2x") { return "2x" }
        return "1x"
    }

    // 取得 idiom
    func idiomFromFilename(_ name: String) -> String {
        if name.lowercased().contains("ipad") { return "ipad" }
        if name.lowercased().contains("iphone") { return "iphone" }
        return "universal"
    }

    // 從檔名取得基底名稱（去除尺寸與 scale）
    func baseImageName(_ filename: String) -> String {
        var name = filename
            .replacingOccurrences(of: "@2x", with: "")
            .replacingOccurrences(of: "@3x", with: "")
        // 移除最後的尺寸資訊（例如 "20x20" 或 "60x60"）
        if let range = name.range(of: #"(\d+x\d+)$"#, options: .regularExpression) {
            name.removeSubrange(range)
        }
        return name
    }
    
    // 生成 Contents.json
    func createContentsJSON(for images: [ImageInfo]) throws -> String {
        let dict: [String: Any] = [
            "images": images.map { [
                "idiom": $0.idiom,
                "scale": $0.scale,
                "filename": $0.filename,
                "size": $0.size,
            ]},
            "info": [
                "version": 1,
                "author": "xcode"
            ]
        ]
        let data = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])
        return String(data: data, encoding: .utf8)!
    }
    
    /// 下載遠端檔案到指定的路徑上，會自動建立資料夾結構。但若路徑上已經有檔案，無法覆蓋。
    func download(url: URL, toURL: URL) throws {
        if FileManager.default.fileExists(atPath: toURL.deletingLastPathComponent().path) == false {
            try FileManager.default.createDirectory(at: toURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        }
        let data = try Data(contentsOf: url)
        try data.write(to: toURL)
    }
}
