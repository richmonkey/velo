import Foundation

enum AppStoreConfig {
    static let appStoreId = "6781742277"

    static var appStoreURL: URL {
        URL(string: "https://apps.apple.com/app/id\(appStoreId)")!
    }

    static var writeReviewURL: URL {
        URL(string: "https://apps.apple.com/app/id\(appStoreId)?action=write-review")!
    }

    static let privacyPolicyURL = URL(string: "https://daibou007.github.io/PrivacyAndSupport/Velochat/privacy.html")!

    static let termsOfServiceURL = URL(string: "https://daibou007.github.io/PrivacyAndSupport/Velochat/terms.html")!

    static let supportURL = URL(string: "https://daibou007.github.io/PrivacyAndSupport/Velochat/support.html")!
}
