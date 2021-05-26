//
//  MarkdownTestWebView.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 10/11/20.
//

import SwiftUI

struct EventDescription: View {

    @State var markdown: String
    @State private var height: CGFloat = .zero
    @State private var isLoading: Bool = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                if isLoading {
                    GeometryReader { geometry in
                        ProgressView()
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height,
                                   alignment: .center)
                    }
                }
                
                Markdown(text: markdown, height: $height, isLoading: $isLoading)
                    .frame(height: height)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

}
