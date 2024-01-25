//
//  WebViewTest.swift
//
//
//  Created by Edon Valdman on 1/21/24.
//

import SwiftUI
import WebKit

@available(iOS 14.0, *)
private struct WebViewTest: View {
    @StateObject
    private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            WebView(delegate: viewModel)
                // Replace with ProgressViewStyle and its own modifier that uses alignment guide to stick to safe area
                // Replace that with backport viewbuilder modifier
                .overlay(loadingBar
                    .offset(y: -3),
                         alignment: .top)
                .navigationTitle(viewModel.pageTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        if viewModel.pageTitle.isEmpty {
                            Text(" ")
                        }
                    }
                    
                    ToolbarItemGroup(placement: .bottomBar) {
//                        if #available(iOS 15.0, *) {
//                            Menu {
//                                ForEach(viewModel.backList) { item in
//                                    #warning("maybe this uses indices and sends an Int of how many times to go back?")
//                                    Button {
//                                        viewModel.load(item.url)
//                                    } label: {
//                                        Text(item.title)
//                                    }
//                                }
//                            } label: {
//                                Label("Back", systemImage: "chevron.backward")
//                            } primaryAction: {
//                                viewModel.goBack()
//                            }
//                            .disabled(!viewModel.canGoBack)
//                        }
                        
                        Button {
                            viewModel.goBack()
                        } label: {
                            Label("Back", systemImage: "chevron.backward")
                        }
//                        .contextMenu {
//                            ForEach(viewModel.backList) { item in
//                                #warning("maybe this uses indices and sends an Int of how many times to go back?")
//                                Button {
//                                    viewModel.load(item.url)
//                                } label: {
//                                    Text(item.title)
//                                }
//                            }
//                        }
                        .disabled(!viewModel.canGoBack)
                        
                        Button {
                            viewModel.goForward()
                        } label: {
                            Label("Forward", systemImage: "chevron.forward")
                        }
                        .disabled(!viewModel.canGoForward)
                        
                        Button {
                            if viewModel.isLoading {
                                viewModel.stopLoading()
                            } else {
                                viewModel.reload()
                            }
                        } label: {
                            if viewModel.isLoading {
                                Label("Stop", systemImage: "xmark")
                            } else {
                                Label("Reload", systemImage: "arrow.clockwise")
                            }
                        }
                    }
                }
                .onAppear {
                    viewModel.load(URL(string: "https://apple.com/ipad"))
                }
//                .onChange(of: viewModel.currentURL) { _ in
//                    print("Back List:", viewModel.backList)
//                    print("Forward List:", viewModel.forwardList)
//                }
        }
    }
    
    @ViewBuilder
    private var loadingBar: some View {
        Color.clear
            .frame(height: 3)
            .overlay(
                GeometryReader { reader in
                    Rectangle()
                        .size(width: reader.size.width * (viewModel.loadingProgress), height: reader.size.height)
                        .fill(.blue)
                },
                alignment: .leading
            )
            .animation(.default, value: viewModel.loadingProgress)
            .opacity(viewModel.isLoading ? 1 : 0)
    }
}

@available(iOS 14.0, *)
extension WebViewTest {
    private class ViewModel: WebViewDelegate {
        override init() {
            super.init()
            
        }
//        @Published var url: URL? = URL(string: "https://google.com/")
//        var urlRequest: URLRequest? {
//            guard let url else { return nil }
//            return .init(url: url)
//        }
        
        override func updatingWebView(_ webView: WKWebView, context: WebView.Context) {
//            super.updatingWebView(webView, context: context)
            
//            if let urlRequest,
//               webView.url != urlRequest.url {
//                webView.load(urlRequest)
//            }
//            
//            print("Updating")
        }
    }
}

@available(iOS 14.0, *)
#Preview {
    WebViewTest()
}
