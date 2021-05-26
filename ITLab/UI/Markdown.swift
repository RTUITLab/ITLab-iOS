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
    @ObservedObject var markdownObject: MarkdownObservable
    
    init(text: String, height: Binding<CGFloat>, isLoading: Binding<Bool>) {
        self.text = text
        self._dynamicHeight = height
        self.markdownObject = MarkdownObservable(text: text, isLoading: isLoading)
    }
    
    func makeUIView(context: Context) -> UITextView {
        
        markdownObject.textView.textAlignment = .justified
        markdownObject.textView.isScrollEnabled = false
        markdownObject.textView.isUserInteractionEnabled = false
        markdownObject.textView.showsVerticalScrollIndicator = false
        markdownObject.textView.showsHorizontalScrollIndicator = false
        markdownObject.textView.allowsEditingTextAttributes = false
        markdownObject.textView.backgroundColor = .clear
        
        return markdownObject.textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        DispatchQueue.main.async {
            uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            uiView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
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
                if let data = data,
                   let img = UIImage(data: data) {
                    let image1Attachment = NSTextAttachment()
                    
                    image1Attachment.image = self.resizeImg(img: img)
                    
                    let image1String = NSAttributedString(attachment: image1Attachment)
                    
                    str.setAttributedString(image1String)
                }
                
                semaphore.signal()
            }.resume()
            
            semaphore.wait()
        }
    }
    
    func resizeImg(img: UIImage) -> UIImage {
        
        if UIScreen.main.bounds.width < img.size.width {

            let newImg = img.scalePreservingAspectRatio(width: UIScreen.main.bounds.width - 10)
            
            return newImg
        }
        
        return img
    }
}

extension UIImage {
    
    func scalePreservingAspectRatio(width: CGFloat) -> UIImage {
        let widthRatio = size.width / width
        let heightRatio = size.height / widthRatio
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: width,
            height: heightRatio
        )
        
        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )
        
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
    
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )
        
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}
