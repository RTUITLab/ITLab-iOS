//
//  Markdown.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 10/10/20.
//

import SwiftUI
import WebKit
import Down

struct MarkdownComponent: UIViewRepresentable {

   let string: String

   func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        
        let down = Down(markdownString: string)
        guard let data = try? down.toAttributedString() else {
            return
        }
        
        uiView.attributedText = data
        
    }
}

struct Markdown: View {
    var markdownString: String
    
    var body: some View {
        MarkdownComponent(string: markdownString)
    }
}

struct Markdown_Previews: PreviewProvider {
    static var previews: some View {
        Markdown(markdownString: "## Test")
    }
}
