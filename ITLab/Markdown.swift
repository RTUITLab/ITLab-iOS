//
//  MarkdownTestWebView.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 10/11/20.
//

import SwiftUI
import Down
import WebKit

struct Markdown: View {
    
   
    
    private struct DownViewSwiftUI : UIViewRepresentable {
        var markdown: String
       
        @EnvironmentObject var markdownSize: EventPage.MarkdownSize
        
        @State var isResizeView: Bool = true
        
        func makeUIView(context: Context) -> DownView {
            
            let webView = try? DownView(frame: UIScreen.main.bounds, markdownString: markdown)
            return webView!
            
        }
        
        func updateUIView(_ uiView: DownView, context: Context) {
            
            if isResizeView && markdownSize.height <= 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isResizeView = false
                    
                    uiView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, error) in
                        
                        if let height = height as? CGFloat {
                            
                            markdownSize.height = height
                            uiView.scrollView.isScrollEnabled = false
                        }
                    })
                }
            }
            
            
        }

    }
    
    @State var markdown: String
    @EnvironmentObject var markdownSize: EventPage.MarkdownSize
    
    var body: some View {
        VStack(alignment: .leading) {
            
            if markdownSize.height <= 0 {
                ProgressView()
                    .padding(.vertical, 20.0)
                    .padding(.horizontal, (UIScreen.main.bounds.width / 2) - 30)
            }
            
            DownViewSwiftUI(markdown: markdown).environmentObject(markdownSize)
                .frame(height: markdownSize.height <= 0 ? 0.01 : markdownSize.height)
        }
    }
    
    
    
}


struct Markdown_Previews: PreviewProvider {
    static var previews: some View {
        Markdown(markdown: "## Test")
    }
}
