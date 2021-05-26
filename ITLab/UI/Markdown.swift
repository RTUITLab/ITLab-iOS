//
//  ReportMarkdown.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 25.05.2021.
//

import SwiftUI
import UIKit
import Down

class MarkdownObservable: ObservableObject {
    var int: UIColor = UIColor.black
    let textView = UITextView()
    @Binding var isLoading: Bool
    init(text: String, isLoading: Binding<Bool>) {
        
        let down = Down(markdownString: text)
        _isLoading = isLoading
        self.isLoading = true
        DispatchQueue.main.async {
            let attributedText = try? down.toAttributedString(styler: ITLabStyler())
            self.textView.attributedText = attributedText
            self.isLoading = false
        }
    }
}

struct Markdown: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    private var text: String
    @Binding var dynamicHeight: CGFloat
    @ObservedObject var test: MarkdownObservable
    
    init(text: String, height: Binding<CGFloat>, isLoading: Binding<Bool>) {
        self.text = text
        self._dynamicHeight = height
        self.test = MarkdownObservable(text: text, isLoading: isLoading)
    }
    
    func makeUIView(context: Context) -> UITextView {
        
        test.textView.textAlignment = .justified
        test.textView.isScrollEnabled = false
        test.textView.isUserInteractionEnabled = false
        test.textView.showsVerticalScrollIndicator = false
        test.textView.showsHorizontalScrollIndicator = false
        test.textView.allowsEditingTextAttributes = false
        test.textView.backgroundColor = .clear
        test.textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        test.textView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return test.textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        DispatchQueue.main.async {
            uiView.textColor = colorScheme == .dark ? UIColor.white : UIColor.black
            DispatchQueue.main.async {
                dynamicHeight = uiView.sizeThatFits(CGSize(width: uiView.bounds.width,
                                                           height: CGFloat.greatestFiniteMagnitude))
                    .height
            }
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
