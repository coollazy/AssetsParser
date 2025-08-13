import Foundation

public enum AssetsParserError: Error, CustomStringConvertible, LocalizedError {
    case invalidImageFormat
    case invalidImageSize
    case downloadImageFailed
    case acextractNotFound
    case extractAssetsFailed(String)
    case commandFailed(String)
    case compileAssetsFailed
    
    public var description: String {
        switch self {
        case .invalidImageFormat:
            NSLocalizedString("❌❌ [AssetsParserError] invalid image format !!", comment: "")
        case .invalidImageSize:
            NSLocalizedString("❌❌ [AssetsParserError] invalid image size !! Should be 1024 * 1024", comment: "")
        case .downloadImageFailed:
            NSLocalizedString("❌❌ [AssetsParserError] download image from remote failed !!", comment: "")
        case .acextractNotFound:
            NSLocalizedString("❌❌ [AssetsParserError] acextract not found !! Please install from: https://github.com/bartoszj/acextract", comment: "")
        case .extractAssetsFailed(let errorMessage):
            NSLocalizedString("❌❌ [AssetsParserError] acextract extract assets failed: \(errorMessage) !!", comment: "")
        case .commandFailed(let errorMessage):
            NSLocalizedString("❌❌ [AssetsParserError] execute command failed: \(errorMessage) !!", comment: "")
        case .compileAssetsFailed:
            NSLocalizedString("❌❌ [AssetsParserError] compile Assets.car failed !!", comment: "")
        }
    }
    
    public var errorDescription: String? {
        description
    }
}
