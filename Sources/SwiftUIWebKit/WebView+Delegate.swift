//
//  WebView+ViewModel.swift
//
//
//  Created by Edon Valdman on 1/21/24.
//

import SwiftUI
import WebKit
import Combine

// MARK: Shared Logic

extension WebView {
    internal func makeView(_ view: WKWebView, context: Context) {
        context.coordinator.setUpObservers(on: view)
    }
    
    internal func updateView(_ view: WKWebView, context: Context) {
        let wasInternalChange = context.coordinator.updateView(view)
        guard !wasInternalChange else { return }
        
        // Only call updatingWebView(_:context:) if it's not an internally-managed update.
        delegate.updatingWebView(view, context: context)
    }
    
    public func makeCoordinator() -> WebViewDelegate { delegate }
}

// MARK: Delegate

public class WebViewDelegate: NSObject, ObservableObject, WKNavigationDelegate, WKUIDelegate {
    private var observers = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    
    /// An estimate of what fraction of the current navigation has been loaded.
    ///
    /// This value ranges from `0.0` to `1.0` based on the total number of bytes received, including the main document and all of its potential subresources. After navigation loading completes, the `loadingProgress` value remains at `1.0` until a new navigation starts, at which point the `loadingProgress` value resets to `0.0`.
    @Published final public private(set) var loadingProgress: Double = 0.0
    
    /// A Boolean value that indicates whether the view is currently loading content.
    ///
    /// Set to `true` if the view is still loading content; otherwise, `false`.
    @Published final public private(set) var isLoading: Bool = false
    
    /// The page title.
    @Published final public private(set) var pageTitle: String = ""
    /// The URL for the current webpage.
    ///
    /// This property contains the URL for the webpage that the web view currently displays. Use this URL in places where you reflect the webpage address in your app’s user interface.
    @Published final public private(set) var currentURL: URL? = nil
    
    /// A Boolean value that indicates whether there is a valid back item in the back-forward list.
    @Published final public private(set) var canGoBack: Bool = false
    /// A Boolean value that indicates whether there is a valid forward item in the back-forward list.
    @Published final public private(set) var canGoForward: Bool = false
    
    // MARK: - Private Properties
    
    @Published private var currentAction: WebViewAction? = nil
    private var lastAction: WebViewAction? = nil
    fileprivate var lastLoadRequest: LoadRequest? = nil
    
    public override init() {
        
    }
    
    // MARK: - Private Functions
    
    private func storeObserver<P, T>(
        _ input: P,
        published: inout Published<T>,
        backportAssign keyPath: ReferenceWritableKeyPath<WebViewDelegate, T>
    ) where P: Publisher, P.Output == T, P.Failure == Never {
        if #available(iOS 14.0, *) {
            input.assign(to: &published.projectedValue)
        } else {
            input
                .sink { [weak self] newValue in
                    self?[keyPath: keyPath] = newValue
                }
                .store(in: &observers)
        }
    }
    
    fileprivate func setUpObservers(on webView: WKWebView) {
        let progressUpdate = webView.publisher(for: \.estimatedProgress, options: .new)
            .receive(on: DispatchQueue.main)
        let isLoadingUpdate = webView.publisher(for: \.isLoading, options: .new)
            .receive(on: DispatchQueue.main)
        let titleUpdate = webView.publisher(for: \.title, options: .new)
            .replaceNil(with: "")
            .receive(on: DispatchQueue.main)
        let urlUpdate = webView.publisher(for: \.url, options: .new)
            .receive(on: DispatchQueue.main)
        let canGoBackUpdate = webView.publisher(for: \.canGoBack, options: .new)
            .receive(on: DispatchQueue.main)
        let canGoForwardUpdate = webView.publisher(for: \.canGoForward, options: .new)
            .receive(on: DispatchQueue.main)
        
        // MARK: Loading Progress
        storeObserver(progressUpdate,
                      published: &_loadingProgress,
                      backportAssign: \.loadingProgress)
        
        // MARK: Is Loading
        storeObserver(isLoadingUpdate,
                      published: &_isLoading,
                      backportAssign: \.isLoading)
        
        // MARK: Page Title
        storeObserver(titleUpdate,
                      published: &_pageTitle,
                      backportAssign: \.pageTitle)
        
        // MARK: Current URL
        storeObserver(urlUpdate,
                      published: &_currentURL,
                      backportAssign: \.currentURL)
        
        // MARK: Can Go Back
        storeObserver(canGoBackUpdate,
                      published: &_canGoBack,
                      backportAssign: \.canGoBack)
        
        // MARK: Can Go Forward
        storeObserver(canGoForwardUpdate,
                      published: &_canGoForward,
                      backportAssign: \.canGoForward)
    }
    
    private func newAction(_ action: WebViewAction) {
        currentAction = action
    }
    
    /// Returns a `Bool` describing if it the change was an internal one, and was acted on.
    fileprivate func updateView(_ view: WKWebView) -> Bool {
        guard currentAction != lastAction else { return false }
        
        var completedAction = false
        switch currentAction {
        case .goBack where view.canGoBack:
            view.goBack()
            completedAction = true
        case .goForward where view.canGoForward:
            view.goForward()
            completedAction = true
            
        case .loadRequest(let newRequest):
            newRequest.handleLoad(for: view)
            completedAction = true
            
        case .reload(let fromOrigin):
            if fromOrigin {
                view.reloadFromOrigin()
            } else {
                view.reload()
            }
            completedAction = true
            
        case .stop:
            view.stopLoading()
            completedAction = true
            
        default:
            break
        }
        
        if completedAction {
            lastAction = currentAction
            return true
        } else {
            return false
        }
    }
    
    // MARK: Public (Final) Functions
    
    /// Navigates to the back item in the back-forward list.
    public final func goBack() {
        newAction(.goBack)
    }
    
    /// Navigates to the forward item in the back-forward list.
    public final func goForward() {
        newAction(.goForward)
    }
    
    /// Loads the web content that the specified request object references and navigates to that content.
    /// - Parameter request: A request that specifies the resource to display.
    @MainActor
    public final func load(_ request: LoadRequest) {
        guard lastLoadRequest != request else { return }
        lastLoadRequest = request
        newAction(.loadRequest(request))
    }
    
    /// Loads the web content that the specified URL and navigates to that content.
    /// - Parameter request: A URL that specifies the resource to display.
    @MainActor
    public final func load(_ url: URL?) {
        guard let url else { return }
        self.load(.url(url))
    }
    
    /// Reloads the current webpage.
    /// - Parameter fromOrigin: When `true`, performs end-to-end revalidation of the content using cache-validating conditionals, if possible.
    @MainActor
    public final func reload(fromOrigin: Bool) {
        newAction(.reload(fromOrigin: fromOrigin))
    }
    
    /// Reloads the current webpage.
    @MainActor
    public final func reload() {
        newAction(.reload(fromOrigin: false))
    }
    
    /// Reloads the current webpage, and performs end-to-end revalidation of the content using cache-validating conditionals, if possible.
    @MainActor
    public final func reloadFromOrigin() {
        newAction(.reload(fromOrigin: true))
    }
    
    /// Stops loading all resources on the current page.
    @MainActor
    public final func stopLoading() {
        newAction(.stop)
    }
    
    // MARK: Overridable Functions
    
    /// Called when a `@Published` property is changed. To take advantage of it, override it.
    ///
    /// This only applies to `@Published` properties added to this type via subclassing. Any pre-existing `@Published` properties are internally managed and this function will not be called.
    /// - Parameters:
    ///   - webView: The `WKWebView`.
    ///   - context: The context.
    public func updatingWebView(_ webView: WKWebView, context: WebView.Context) {}
}

private enum WebViewAction: Hashable {
    case goBack
    case goForward
    
    case loadRequest(LoadRequest)
    
    case reload(fromOrigin: Bool)
    
    case stop
}
