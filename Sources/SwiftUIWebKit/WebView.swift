//
//  WebView.swift
//
//
//  Created by Edon Valdman on 1/21/24.
//

import SwiftUI
import WebKit

/// A view that displays interactive web content, such as for an in-app browser.
public struct WebView {
    @ObservedObject
    public var delegate: WebViewDelegate
    
    public var configuration: WKWebViewConfiguration?
    
    public init(delegate: WebViewDelegate, configuration: WKWebViewConfiguration? = nil) {
        self._delegate = .init(initialValue: delegate)
        self.configuration = configuration
    }
    
    /// Returns a Boolean value that indicates whether WebKit natively supports resources with the specified URL scheme.
    /// - Parameter urlScheme: The URL scheme associated with the resource.
    /// - Returns: `true` if WebKit provides native support for the URL scheme, or `false` if it doesn't.
    public static func handlesURLScheme(_ urlScheme: String) -> Bool {
        WKWebView.handlesURLScheme(urlScheme)
    }
    
    /// Adds a navigation bar with the title of the webpage, including a progress bar overlayed at the bottom that hides itself when loading is stopped. It won't do any if `WebView` is not placed in a `NavigationStack` or `NavigationView`.
    ///
    /// To color the progress bar, use [`tint(_:)`](https://developer.apple.com/documentation/swiftui/view/tint(_:)-23xyq) or [`tint(_:)`](https://developer.apple.com/documentation/swiftui/view/tint(_:)-93mfq) (or [`accentColor(_:)`](https://developer.apple.com/documentation/familycontrols/familyactivitypicker/accentcolor(_:)) if on iOS 14). It will default to the app's accent color.
    @available(iOS 14.0, macOS 11.0, *)
    public func standardNavigationBar() -> some View {
        self
            .navigationTitle(delegate.pageTitle)
            .webViewLoadingBar(progress: delegate.loadingProgress, isHidden: !delegate.isLoading, tint: nil)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if delegate.pageTitle.isEmpty {
                        Text(" ")
                    }
                }
            }
    }
}
