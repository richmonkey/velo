import Foundation

/// Placeholder release metadata — update before submitting to the App Store.
enum AppStoreConfig {
    /// TODO: replace with the real numeric App Store ID once the app is published.
    static let appStoreId = "0000000000"

    static var appStoreURL: URL {
        URL(string: "https://apps.apple.com/app/id\(appStoreId)")!
    }

    static var writeReviewURL: URL {
        URL(string: "itms-apps://itunes.apple.com/app/id\(appStoreId)?action=write-review")!
    }

    /// TODO: replace with the real published Privacy Policy URL.
    static let privacyPolicyURL = URL(string: "https://daibou007.com/velochat/privacy")!

    /// TODO: replace with the real published Terms of Service URL.
    static let termsOfServiceURL = URL(string: "https://daibou007.com/velochat/terms")!
}
