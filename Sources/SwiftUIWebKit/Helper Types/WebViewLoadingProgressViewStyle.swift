//
//  WebViewLoadingProgressViewStyle.swift
//
//
//  Created by Edon Valdman on 1/25/24.
//

import SwiftUI

private struct ProgressLine: Shape, Animatable {
    @available(iOS 17.0, macOS 14.0, *)
    var layoutDirectionBehavior: LayoutDirectionBehavior { .mirrors }
    
    @available(iOS 15.0, macOS 12.0, *)
    static var role: ShapeRole { .stroke }
    
    var fractionCompleted: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: .init(x: 0, y: rect.midY))
        path.addLine(to: .init(x: rect.maxX * fractionCompleted, y: rect.midY))
        
        return path
    }
    
    var animatableData: Double {
        get { fractionCompleted }
        set { fractionCompleted = newValue }
    }
}

/// A progress view that visually indicates its progress using a horizontal bar, but with no rounded corners.
///
/// Its color can be set with the `tint(_:)` modifier.
@available(iOS 14.0, macOS 11.0, *)
struct WebViewLoadingProgressViewStyle: ProgressViewStyle {
    private let tint: Color?
    
    @available(iOS, introduced: 14.0, deprecated: 15.0, message: "Use `tint(_:)` modifier instead.")
    @available(macOS, introduced: 11.0, deprecated: 13.0, message: "Use `tint(_:)` modifier instead.")
    init(tint: Color? = nil) {
        self.tint = tint ?? Color.accentColor
    }
    
    init() {
        self.tint = nil
    }
    
    func makeBody(configuration: Configuration) -> some View {
        if let fractionCompleted = configuration.fractionCompleted {
            progressShape(fractionCompleted: fractionCompleted)
                .frame(height: 3)
                .animation(.default, value: configuration.fractionCompleted)
            
        } else {
            ProgressView(configuration)
                .progressViewStyle(.linear)
        }
    }
    
    @ViewBuilder
    private func progressShape(fractionCompleted: Double) -> some View {
        if #available(iOS 15.0, macOS 12.0, *),
           tint == nil {
            ProgressLine(fractionCompleted: fractionCompleted)
                .stroke(.tint, lineWidth: 3)
        } else {
            ProgressLine(fractionCompleted: fractionCompleted)
                .stroke(tint ?? Color.accentColor, lineWidth: 3)
        }
    }
}

@available(iOS 14.0, macOS 11.0, *)
extension ProgressViewStyle where Self == WebViewLoadingProgressViewStyle {
    static var webViewLoading: Self {
        .init()
    }
    
    @available(iOS, introduced: 14.0, deprecated: 15.0, message: "Use `tint(_:)` modifier instead.")
    @available(macOS, introduced: 11.0, deprecated: 13.0, message: "Use `tint(_:)` modifier instead.")
    static func webViewLoading(tint: Color?) -> Self {
        .init(tint: tint)
    }
}

extension View {
    @available(iOS 16.0, macOS 13.0, *)
    public func webViewLoadingBar<S: ShapeStyle>(progress: Double, isHidden: Bool, style: S? = nil) -> some View {
        self.overlayBackport(alignment: .top) {
            ProgressView(value: progress)
                .progressViewStyle(.webViewLoading)
                .tint(style)
                .offset(y: -3)
                .opacity(isHidden ? 0 : 1)
        }
    }
    
    @available(iOS, introduced: 14.0, deprecated: 16.0, message: "Use `webViewLoadingBar(progress:isHidden:style:)` modifier instead.")
    @available(macOS, introduced: 11.0, deprecated: 13.0, message: "Use `webViewLoadingBar(progress:isHidden:style:)` modifier instead.")
    public func webViewLoadingBar(progress: Double, isHidden: Bool, tint: Color?) -> some View {
        self.overlayBackport(alignment: .top) {
            if #available(iOS 15.0, macOS 12.0, *) {
                ProgressView(value: progress)
                    .progressViewStyle(.webViewLoading(tint: tint))
                    .tint(tint as Color?)
                    #if os(iOS)
                    .offset(y: -3)
                    #endif
                    .opacity(isHidden ? 0 : 1)
            } else {
                ProgressView(value: progress)
                    .progressViewStyle(.webViewLoading)
                    #if os(iOS)
                    .offset(y: -3)
                    #endif
                    .opacity(isHidden ? 0 : 1)
            }
        }
    }
}

@available(iOS 16.0, macOS 13.0, *)
#Preview {
    VStack {
        ProgressView(value: 0.3)
            .progressViewStyle(.webViewLoading)
            .tint(Color.purple)
        
        ProgressView(value: 1)
            .progressViewStyle(.webViewLoading)
            .tint(Color.purple.gradient)
    }
}

private extension View {
    @ViewBuilder
    func overlayBackport<V>(
        alignment: Alignment = .center,
        @ViewBuilder content: () -> V
    ) -> some View where V: View {
        if #available(iOS 15.0, macOS 12.0, *) {
            self.overlay(alignment: alignment, content: content)
        } else {
            self.overlay(content(), alignment: alignment)
        }
    }
}
