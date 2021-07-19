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
    @State private var showingModal = false
    @ObservedObject var equipmentsObservable = EquipmentsObservable()
    
    var body: some View {
            VStack {
                CBScanner (
                    supportBarcode: .constant([.qr, .code128]),
                    torchLightIsOn: $flashIsOn,
                    scanInterval: .constant(5)
                ) {result in
                    //TODO: Rewrite
                    self.equipmentsObservable.match = "mock_serial_number"
                    
                    showingModal = true
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
                    Text(self.equipmentsObservable.match)
                }.sheet(
                    isPresented: $showingModal,
                    content: {
                        self.content()
                    }
                )
            }
    }
    
    func addPage() -> some View {
        let page = EquipmentAddPage(serialNumber: self.equipmentsObservable.match)
        page.loadData()
        return page
    }
    
    @ViewBuilder func content() -> some View {
        let equip = try? findEquipmentBySerialNumber()
        
        if let equip = equip {
            ShowFullEquipmentInfo(fullMode: true, equipment: equip)
                .environmentObject(self.getUser(equip: equip))
        } else {
            self.addPage()
        }
    }
    
    private func getUser(equip: EquipmentModel) -> UserObservable {
        let user = UserObservable()
        if let ownerId = equip.ownerId {
            user.getUser(userId: ownerId)
        }
        return user
    }
    
    private func findEquipmentBySerialNumber() throws -> EquipmentModel {
        self.equipmentsObservable.getEquipment()
        if self.equipmentsObservable.equipmentModel.count == 1 {
            return equipmentsObservable.equipmentModel[0]
        } else if equipmentsObservable.equipmentModel.count == 0 {
            throw EquipmentError.notFound
        } else {
            throw EquipmentError.matchError
        }
    }
    
    enum EquipmentError: Error {
        case notFound
        case matchError
    }
}

struct EquipmentScanView_Previews: PreviewProvider {
    static var previews: some View {
            EquipmentScanView()
    }
}
