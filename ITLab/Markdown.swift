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
    
    class MarkdownSize: ObservableObject {
        @Published var height: CGFloat = 0;
    }
    
   private struct WebView : UIViewRepresentable {
        var markdown: String
    
   @State var maxHeight: CGFloat = -1
    
    @EnvironmentObject var markdownSize : MarkdownSize
        
        func makeUIView(context: Context) -> DownView {
            
            let webView = try? DownView(frame: UIScreen.main.bounds, markdownString: markdown)
            webView!.scrollView.isScrollEnabled = false
            
            return webView!
            
        }
        
        func updateUIView(_ uiView: DownView, context: Context) {
//            uiView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, error) in
//                if markdownSize.height != height as! CGFloat {
//                    
//                
//                markdownSize.height = height as! CGFloat
//                }
////                markdownSize.height = height as! CGFloat
//                    print(height as! CGFloat)
//                
//                
//                print("Kek")
//              })
        }
    }
    
    @State var markdown: String
    @State var webView : DownView?
    
    @ObservedObject var markdownSize : MarkdownSize = MarkdownSize()
   
    var body: some View {
        VStack(alignment: .leading) {
            WebView(markdown: markdown).environmentObject(markdownSize)
                .frame(height: 500)
        }
        
        
    }
}


struct Markdown_Previews: PreviewProvider {
    static var previews: some View {
        Markdown(markdown: "## Test")
    }
}
