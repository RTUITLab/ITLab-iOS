//
//  ReportMarkdown.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 25.05.2021.
//

import SwiftUI
import UIKit
import Down

struct Markdown: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    private var attributedText: NSAttributedString?
    @Binding var dynamicHeight: CGFloat
    
    init(text: String, height: Binding<CGFloat>) {
        self._dynamicHeight = height
        let down = Down(markdownString: text)
        
        self.attributedText = try? down.toAttributedString(styler: ITLabStyler())
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.textAlignment = .justified
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.allowsEditingTextAttributes = false
        textView.backgroundColor = .clear
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
        uiView.textColor = colorScheme == .dark ? UIColor.white : UIColor.black
        DispatchQueue.main.async {
            dynamicHeight = uiView.sizeThatFits(CGSize(width: uiView.bounds.width,
                                                       height: CGFloat.greatestFiniteMagnitude))
                .height
        }
    }
}

// TODO: Waiting for my PR to be accepted into the Down library repository
final class ITLabStyler: DownStyler {
    override func style(image str: NSMutableAttributedString, title: String?, url: String?) {
        if let urlImg = URL(string: url!) {
            let semaphore = DispatchSemaphore(value: 0)
            URLSession.shared.dataTask(with: urlImg) { data, _, _ in
                if let data = data {
                    let image1Attachment = NSTextAttachment()
                    image1Attachment.image = UIImage(data: data)
                    let image1String = NSAttributedString(attachment: image1Attachment)
                    
                    str.setAttributedString(image1String)
                }
                
                semaphore.signal()
            }.resume()
            
            semaphore.wait()
        }
    }
}
