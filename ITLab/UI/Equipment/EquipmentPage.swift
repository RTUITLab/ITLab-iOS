//
//  EquipmentPage.swift
//  ITLab
//
//  Created by Даниил on 10.07.2021.
//

import SwiftUI

struct EquipmentPage: View {
    enum ChoosenPage: String, CaseIterable {
        case equipment = "Оборудование"
        case addEquipment = "Добавить оборудование"
    }
    
    @State var pickers: ChoosenPage = .equipment
    @ObservedObject var equipmentObservable = EquipmentsObservable()
    
    var body: some View {
        VStack {
            Picker(
                selection: $pickers,
                label: Text("Picker"),
                content: {
                    ForEach(
                        ChoosenPage.allCases,
                        id: \.self
                    ) {
                        Text($0.rawValue).textCase(.none)
                    }
                }
            ).pickerStyle(SegmentedPickerStyle())
            Spacer()
            content
        }
        
    }
    
    var content: some View {
        Group {
            switch self.pickers {
            case .equipment:
                EquipmentList()
                    .environmentObject(self.equipmentObservable)
            case .addEquipment:
                EquipmentScanView()
            }
        }
    }
    
    func loadData() {
        self.equipmentObservable.getEquipment()
    }
    
}

struct EquipmentPage_Previews: PreviewProvider {
    static var previews: some View {
        var page = EquipmentPage()
        page.loadData()
        return page
    }
}
