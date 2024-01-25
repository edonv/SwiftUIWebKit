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
    @ObservedObject var delegate: WebViewDelegate
    
    var configuration: WKWebViewConfiguration?
    
    /// Returns a Boolean value that indicates whether WebKit natively supports resources with the specified URL scheme.
    /// - Parameter urlScheme: The URL scheme associated with the resource.
    /// - Returns: `true` if WebKit provides native support for the URL scheme, or `false` if it doesn't.
    static func handlesURLScheme(_ urlScheme: String) -> Bool {
        WKWebView.handlesURLScheme(urlScheme)
    }
}
