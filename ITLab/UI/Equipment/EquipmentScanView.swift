//
//  EquipmentScanView.swift
//  ITLab
//
//  Created by Даниил on 10.07.2021.
//

import SwiftUI
import CarBode

struct EquipmentScanView: View {
    @State private var flashIsOn = false
    
    var body: some View {
            VStack {
                CBScanner (
                    supportBarcode: .constant([.qr, .code128]),
                    torchLightIsOn: $flashIsOn,
                    scanInterval: .constant(5)
                ) { _ in
                    // TODO
                } onDraw: {
                    let lineWidth = CGFloat(2)
                    //line color
                    let lineColor = UIColor.yellow

                    //Fill color with opacity
                    //You also can use UIColor.clear if you don't want to draw fill color
                    let fillColor = UIColor(red: 0, green: 1, blue: 0.2, alpha: 0.4)
                    
                    //Draw box
                    $0.draw(lineWidth: lineWidth, lineColor: lineColor, fillColor: fillColor)
                }
            
                HStack {
                    Button(
                        action: {
                            self.flashIsOn.toggle()
                        },
                        label: {
                            Image(systemName: flashIsOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .foregroundColor(flashIsOn ? .blue : .gray)
                        }
                    )
                    .frame(width: 30, height: 30)
                }
            }
            
    }
}

struct EquipmentScanView_Previews: PreviewProvider {
    static var previews: some View {
        EquipmentScanView()
    }
}
