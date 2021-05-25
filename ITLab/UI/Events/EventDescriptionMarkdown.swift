//
//  MarkdownTestWebView.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 10/11/20.
//

import SwiftUI
import Down
import WebKit
import Combine

struct EventDescriptionMarkdown: View {

    @State var markdown: String
    @EnvironmentObject var markdownSize: EventPage.MarkdownSize

    var body: some View {
        VStack(alignment: .leading) {

            EventDownViewSwiftUI(markdown: markdown).environmentObject(markdownSize)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

}

struct EventDownViewSwiftUI: UIViewRepresentable {
    var markdown: String

    @EnvironmentObject var markdownSize: EventPage.MarkdownSize

    func makeUIView(context: Context) -> DownView {

        let webView = try? DownView(frame: UIScreen.main.bounds, markdownString: markdown)
        webView?.navigationDelegate = context.coordinator
        return webView!

    }

    class Coordinator: NSObject, WKNavigationDelegate {
        private var markdownSize: EventPage.MarkdownSize

        init(_ markdownSize: EventPage.MarkdownSize) {
                    self.markdownSize = markdownSize
                }

        func webView(_ webView: WKWebView,
                     didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.documentElement.scrollHeight") { (height, _) in

                if let height = height as? CGFloat {

                    self.markdownSize.height = height
//                        webView.scrollView.isScrollEnabled = false
                }
            }
        }
    }

    func makeCoordinator() -> EventDownViewSwiftUI.Coordinator {
            Coordinator(markdownSize)
        }

    func updateUIView(_ uiView: DownView, context: Context) {

    }

}
