//
//  ColorPaletterView.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 14.05.2021.
//

import SwiftUI

struct СolorPaletteView: View {
    
    @ObservedObject private var colorPalatte = ColorPaletteModel()
    
    @State private var totalHeight = CGFloat(100)
    
    var body: some View {
        VStack {
            Rectangle()
                .frame(width: 300,
                       height: 300,
                       alignment: .center)
                .foregroundColor(colorPalatte.mainColor)
                .padding(.top, 20.0)
            
            Spacer()
            
            Text("\(colorPalatte.scope)")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            VStack {
                GeometryReader { geometry in
                    HStack {
                        Spacer()
                        
                        Text("1")
                            .fontWeight(.bold)
                            .frame(width: geometry.size.width / 4,
                                   height: geometry.size.width / 4)
                            .background(Rectangle()
                                            .foregroundColor(colorPalatte.oneButtonColor))
                            .onTapGesture {
                                colorPalatte.changeScope(colorPalatte.oneButtonColor)
                            }
                        
                        Text("2")
                            .fontWeight(.bold)
                            .frame(width: geometry.size.width / 4,
                                   height: geometry.size.width / 4)
                            .background(Rectangle()
                                            .foregroundColor(colorPalatte.twoButtonColor))
                            .padding(.horizontal)
                            .onTapGesture {
                                colorPalatte.changeScope(colorPalatte.twoButtonColor)
                            }
                        
                        Text("3")
                            .fontWeight(.bold)
                            .frame(width: geometry.size.width / 4,
                                   height: geometry.size.width / 4)
                            .background(Rectangle()
                                            .foregroundColor(colorPalatte.threeButtonColor))
                            .onTapGesture {
                                colorPalatte.changeScope(colorPalatte.threeButtonColor)
                            }
                        
                        Spacer()
                    }
                    .frame(width: geometry.size.width,
                           height: geometry.size.width / 4,
                           alignment: .center)
                    .background(GeometryReader {geometryReader -> Color in
                        DispatchQueue.main.async {
                            self.totalHeight = geometryReader.size.height
                        }
                        return Color.clear
                    })
                }
                
            }
            .frame(height: totalHeight)
            .padding(.bottom, 20.0)
        }
    }
}
