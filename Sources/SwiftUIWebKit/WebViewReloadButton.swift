//
//  WebViewReloadButton.swift
//
//
//  Created by Edon Valdman on 1/26/24.
//

import SwiftUI

public struct WebViewReloadButton: View {
    @ObservedObject
    private var delegate: WebViewDelegate
    private var reloadFromOrigin: Bool
    private var useMenu: Bool = false
    
    public init(delegate: WebViewDelegate, reloadFromOrigin: Bool = false) {
        self._delegate = .init(initialValue: delegate)
        self.reloadFromOrigin = reloadFromOrigin
    }
    
    @available(iOS 15.0, *)
    public init(delegate: WebViewDelegate, useMenu: Bool) {
        self._delegate = .init(initialValue: delegate)
        self.reloadFromOrigin = false
        self.useMenu = useMenu
    }
    
    public var body: some View {
        if #available(iOS 15.0, *),
           useMenu {
            menu
        } else {
            button
        }
    }
    
    private var button: some View {
        Button {
            buttonPressed()
        } label: {
            buttonLabel
        }
    }
    
    @available(iOS 15.0, *)
    private var menu: some View {
        Menu {
            if !delegate.isLoading {
                Button {
                    delegate.reloadFromOrigin()
                } label: {
                    Label("Reload from Origin", systemImage: "arrow.clockwise")
                }
            }
        } label: {
            buttonLabel
        } primaryAction: {
            buttonPressed()
        }
    }
    
    private func buttonPressed() {
        if delegate.isLoading {
            delegate.stopLoading()
        } else {
            delegate.reload(fromOrigin: reloadFromOrigin)
        }
    }
    
    @ViewBuilder
    private var buttonLabel: some View {
        if delegate.isLoading {
            stopLabel
        } else {
            reloadLabel
        }
    }
    
    @ViewBuilder
    private var stopLabel: some View {
        if #available(iOS 14.0, *) {
            Label("Stop", systemImage: "xmark")
        } else {
            Image(systemName: "xmark")
        }
    }
    
    @ViewBuilder
    private var reloadLabel: some View {
        if #available(iOS 14.0, *) {
            Label("Reload", systemImage: "arrow.clockwise")
        } else {
            Image(systemName: "arrow.clockwise")
        }
    }
}

//#Preview {
//    WebViewReloadButton(delegate: <#T##WebViewDelegate#>)
//}
