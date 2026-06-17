import Foundation
import XMTPiOS

public let ContentTypeMemberNickname = ContentTypeID(
    authorityID: "velo.app",
    typeID: "member_nickname",
    versionMajor: 1,
    versionMinor: 0
)

enum MemberNicknameCodecError: Error {
    case invalidEncoding
}

public struct MemberNicknameCodec: ContentCodec {
    public typealias T = String

    public init() {}

    public var contentType = ContentTypeMemberNickname

    public func encode(content: String) throws -> EncodedContent {
        var encoded = EncodedContent()
        encoded.type = ContentTypeMemberNickname
        encoded.content = Data(content.utf8)
        return encoded
    }

    public func decode(content: EncodedContent) throws -> String {
        guard let value = String(data: content.content, encoding: .utf8) else {
            throw MemberNicknameCodecError.invalidEncoding
        }
        return value
    }

    public func fallback(content _: String) throws -> String? {
        nil
    }

    public func shouldPush(content _: String) throws -> Bool {
        false
    }
}
