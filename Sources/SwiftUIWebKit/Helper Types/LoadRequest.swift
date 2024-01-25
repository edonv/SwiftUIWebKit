//
//  LoadRequest.swift
//
//
//  Created by Edon Valdman on 1/22/24.
//

import Foundation
import WebKit

/// A type for specifying which `WKWebView.load()` function to call.
///
/// This type is used by ``SwiftUIWebKit/WebViewDelegate/load(_:)-2foh1``.
///
/// > Note: See [Loading web content](https://developer.apple.com/documentation/webkit/wkwebview#1655838).
public enum LoadRequest: Hashable, Sendable {
    /// Loads the web content that the specified URL request object references and navigates to that content.
    ///
    /// Use this method to load a page from a local or network-based URL. For example, you might use this method to navigate to a network-based webpage.
    ///
    /// Provide the source of this load request for app activity data by setting the [`attribution`](https://developer.apple.com/documentation/foundation/urlrequest/3767318-attribution) parameter on your request.
    ///
    /// > See also: [`WKWebView.load(_:)`](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load)
    ///
    /// - Parameter request: A URL request that specifies the resource to display.
    case urlRequest(URLRequest)
    
    /// Loads the web content that the specified URL references and navigates to that content.
    ///
    /// Use this method to load a page from a local or network-based URL. For example, you might use this method to navigate to a network-based webpage.
    ///
    /// > Note: Under the hood, this just wraps the URL is a `URLRequest` and uses ``urlRequest(_:)``.
    ///
    /// > See also: [`WKWebView.load(_:)`](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load)
    ///
    /// - Parameter url: A URL that specifies the resource to display.
    public static func url(_ url: URL) -> LoadRequest {
        .urlRequest(.init(url: url))
    }
    
    /// Loads the content of the specified data object and navigates to it.
    ///
    /// Use this method to navigate to a webpage that you loaded yourself and saved in a data object. For example, if you previously wrote HTML content to a data object, use this method to navigate to that content.
    ///
    /// > See also: [`WKWebView.load(_:mimeType:characterEncodingName:baseURL:)`](https://developer.apple.com/documentation/webkit/wkwebview/1415011-load)
    ///
    /// - Parameters:
    ///   - data: The data to use as the contents of the webpage.
    ///   - mimeType: The MIME type of the information in the `data` parameter. This parameter must not contain an empty string.
    ///   - characterEncodingName: The data's character encoding name.
    ///   - baseURL: A URL that you use to resolve relative URLs within the document.
    case data(Data, mimeType: String, characterEncodingName: String, baseURL: URL)
    
    /// Loads the contents of the specified HTML string and navigates to it.
    ///
    /// Use this method to navigate to a webpage that you loaded or created yourself. For example, you might use this method to load HTML content that your app generates programmatically.
    ///
    /// This method sets the source of this load request for app activity data to [`NSURLRequest.Attribution.developer`](https://developer.apple.com/documentation/foundation/nsurlrequest/attribution/developer).
    ///
    /// > See also: [`WKWebView.loadHTMLString(_:baseURL:)`](https://developer.apple.com/documentation/webkit/wkwebview/1415004-loadhtmlstring)
    ///
    /// - Parameters:
    ///   - string: The string to use as the contents of the webpage.
    ///   - baseURL: The base URL to use when the system resolves relative URLs within the HTML string.
    case htmlString(String, baseURL: URL?)
    
    /// Loads the web content from the file the URL request object specifies and navigates to that content.
    ///
    /// Provide the source of this load request for app activity data by setting the [`attribution`](https://developer.apple.com/documentation/foundation/urlrequest/3767318-attribution) parameter on your request.
    ///
    /// > Important: This option is only available for iOS 15+ and macOS 12+.
    ///
    /// > See also: [`WKWebView.loadFileRequest(_:allowingReadAccessTo:)`](https://developer.apple.com/documentation/webkit/wkwebview/1415004-loadhtmlstring)
    ///
    /// - Parameters:
    ///   - request: A URL request that specifies the file to display. The URL in this request must be a file-based URL.
    ///   - allowingReadAccessTo: The URL of a file or directory containing web content that you grant the system permission to read. This URL must be a file-based URL and must not be empty. To prevent WebKit from reading any other content, specify the same value as the URL parameter. To read additional files related to the content file, specify a directory.
    case fileRequest(URLRequest, allowingReadAccessTo: URL)
    
    /// Loads the web content from the specified file and navigates to it.
    ///
    /// This method sets the source of this load request for app activity data to [`NSURLRequest.Attribution.developer`](https://developer.apple.com/documentation/foundation/nsurlrequest/attribution/developer). To specify the source of this load, use ``fileRequest(_:allowingReadAccessTo:)`` instead.
    ///
    /// > See also: [`WKWebView.loadFileURL(_:allowingReadAccessTo:)`](https://developer.apple.com/documentation/webkit/wkwebview/1414973-loadfileurl)
    ///
    /// - Parameters:
    ///   - url: The URL of a file that contains web content. This URL must be a file-based URL.
    ///   - allowingReadAccessTo: The URL of a file or directory containing web content that you grant the system permission to read. This URL must be a file-based URL and must not be empty. To prevent WebKit from reading any other content, specify the same value as the URL parameter. To read additional files related to the content file, specify a directory.
    case fileURL(URL, allowingReadAccessTo: URL)
    
    /// Loads the web content from the data you provide as if the data were the response to the request.
    ///
    /// > Important: This option is only available for iOS 15+ and macOS 12+.
    ///
    /// > See also: [`WKWebView.loadSimulatedRequest(_:response:responseData:)`](https://developer.apple.com/documentation/webkit/wkwebview/3763094-loadsimulatedrequest)
    ///
    /// - Parameters:
    ///   - request: A URL request that specifies the base URL and other loading details the system uses to interpret the data you provide.
    ///   - response: A response the system uses to interpret the data you provide.
    ///   - data: The data to use as the contents of the webpage.
    case simulatedRequestWithURLResponse(URLRequest, response: URLResponse, responseData: Data)
    
    /// Loads the web content from the HTML you provide as if the HTML were the response to the request.
    ///
    /// > Important: This option is only available for iOS 15+ and macOS 12+.
    ///
    /// > See also: [`WKWebView.loadSimulatedRequest(_:responseHTML:)`](https://developer.apple.com/documentation/webkit/wkwebview/3763095-loadsimulatedrequest)
    ///
    /// - Parameters:
    ///   - request: A URL request that specifies the base URL and other loading details the system uses to interpret the HTML you provide.
    ///   - responseHTML: The HTML code you provide in a string to use as the contents of the webpage.
    case simulatedRequestWithHTMLResponse(URLRequest, responseHTML: String)
    
    internal func handleLoad(for webView: WKWebView) /*-> WKNavigation?*/ {
        switch self {
        case .urlRequest(let urlRequest):
            webView.load(urlRequest)
            
        case .data(let data, let mimeType, let characterEncodingName, let baseURL):
            webView.load(data, mimeType: mimeType, characterEncodingName: characterEncodingName, baseURL: baseURL)
            
        case .htmlString(let string, let baseURL):
            webView.loadHTMLString(string, baseURL: baseURL)
            
        case .fileRequest(let urlRequest, let allowingReadAccessTo):
            if #available(iOS 15.0, macOS 12.0, *) {
                webView.loadFileRequest(urlRequest, allowingReadAccessTo: allowingReadAccessTo)
            } else {
                print("loadFileRequest(_:allowingReadAccessTo:) is only available for iOS 15+ and macOS 12+.")
            }
            
        case .fileURL(let url, let allowingReadAccessTo):
            webView.loadFileURL(url, allowingReadAccessTo: allowingReadAccessTo)
            
        case .simulatedRequestWithURLResponse(let urlRequest, let urlResponse, let responseData):
            if #available(iOS 15.0, macOS 12.0, *) {
                webView.loadSimulatedRequest(urlRequest, response: urlResponse, responseData: responseData)
            } else {
                print("loadSimulatedRequest(_:response:responseData:) is only available for iOS 15+ and macOS 12+.")
            }
            
        case .simulatedRequestWithHTMLResponse(let urlRequest, let responseHTML):
            if #available(iOS 15.0, macOS 12.0, *) {
                webView.loadSimulatedRequest(urlRequest, responseHTML: responseHTML)
            } else {
                print("loadSimulatedRequest(_:responseHTML:) is only available for iOS 15+ and macOS 12+.")
            }
        }
    }
}
