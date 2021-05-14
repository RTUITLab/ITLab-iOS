//
//  ColorPaletteObservable.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 14.05.2021.
//

import SwiftUI
import Combine

class ColorPaletteObservable: ObservableObject {
    @Published var mainColor: Color = Color.blue
    @Published var oneButtonColor: Color = Color.green
    @Published var twoButtonColor: Color = Color.green
    @Published var threeButtonColor: Color = Color.green
    
    @Published var scope: Int = 0
    
    init() {
        changeColor()
    }
    
    func generateColor() -> UIColor {
        let hue: CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation: CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness: CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    func changeColor() {
        mainColor = Color(generateColor())
        let randomButton = arc4random_uniform(3)
        switch randomButton {
        case 0:
            oneButtonColor = mainColor
            twoButtonColor = Color(generateColor())
            threeButtonColor = Color(generateColor())
        case 1:
            oneButtonColor = Color(generateColor())
            twoButtonColor = mainColor
            threeButtonColor = Color(generateColor())
        case 2:
            oneButtonColor = Color(generateColor())
            twoButtonColor = Color(generateColor())
            threeButtonColor = mainColor
        default:
            oneButtonColor = mainColor
            twoButtonColor = Color(generateColor())
            threeButtonColor = Color(generateColor())
        }
    }
    
    func changeScope (_ color: Color) {
        if mainColor == color {
            scope += 1
        } else {
            scope -= 1
        }
        
        changeColor()
    }
}
