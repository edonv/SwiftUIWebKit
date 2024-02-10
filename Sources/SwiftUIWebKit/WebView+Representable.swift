//
//  WebView+Representable.swift
//
//
//  Created by Edon Valdman on 1/25/24.
//

import SwiftUI
import WebKit

// MARK: - NSViewRepresentable

// This applies only to native macOS, not Catalyst
#if os(macOS)
extension WebView: NSViewRepresentable {
    public func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: configuration ?? .init())
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        self.makeView(webView, context: context)
        
        return webView
    }
    
    
    public func updateNSView(_ nsView: WKWebView, context: Context) {
        self.updateView(nsView, context: context)
    }
}
#endif

// MARK: - UIViewRepresentable

#if canImport(UIKit)
extension WebView: UIViewRepresentable {
    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: configuration ?? .init())
        webView.scrollView.clipsToBounds = false
        
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        self.makeView(webView, context: context)
        
        return webView
    }
    
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        self.updateView(uiView, context: context)
    }
}
#endif
