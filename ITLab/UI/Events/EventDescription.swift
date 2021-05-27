//
//  MarkdownTestWebView.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 10/11/20.
//

import SwiftUI

struct EventDescription: View {

    @State var markdown: String
    var body: some View {
                Markdown(text: markdown)
        .navigationBarTitleDisplayMode(.inline)
    }

}
