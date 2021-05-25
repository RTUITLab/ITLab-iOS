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

    var body: some View {
        VStack(alignment: .leading) {

            Markdown(text: markdown, height: $height)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

}
