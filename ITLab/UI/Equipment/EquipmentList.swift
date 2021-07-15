//
//  EquipmentList.swift
//  ITLab
//
//  Created by Даниил on 10.07.2021.
//

import SwiftUI

struct EquipmentList: View {
    @State private var searchText = ""
    @State private var onlyFree = false
    @State private var showOptions = true
    @ObservedObject private var equipmentObject = EquipmentsObservable()
    
    var body: some View {
        VStack {
            if showOptions {
                EquipmentSearchBar(text: $searchText, placehodler: "Поиск оборудования")
            }
            HStack {
                if showOptions {
                    Toggle(
                        isOn: $onlyFree,
                        label: {
                            Text("Только свободное")
                                .font(.system(size: 12, weight: .light, design: .default))
                        }
                    )
                    .toggleStyle(
                        CheckBoxStyle()
                    )
                }
                
                Spacer()
                
                Button(
                    action: {
                        self.showOptions.toggle()
                    },
                    label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                )
            }
            List {
                if equipmentObject.loading {
                    GeometryReader {
                        geometry in
                        ProgressView()
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height,
                                   alignment: .center)
                    }
                } else {
                    EquipmentListHeader()
                    ForEach(self.equipmentObject.equipmentModel, id: \.id ) {
                        equip in
                        EquipmentItem(equipment: equip)
                        
                    }
                }
            }.listStyle(
                GroupedListStyle()
            )
        }
        
    }
    
    func loadData() {
        self.equipmentObject.getEquipment()
    }
}

struct EquipmentListHeader: View {
    var body: some View {
        HStack {
            Text("Тип")
            Spacer()
            Text("Номер")
            Spacer()
        }
        
    }
}

struct CheckBoxStyle: ToggleStyle {
    var width: CGFloat = 20
    var height: CGFloat = 20
    func makeBody(configuration: Self.Configuration) -> some View {
        return HStack {
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle" )
                .frame(width: width, height: height)
                .foregroundColor(configuration.isOn ? .green : .gray)
                .font(.system(size: 20, weight: .bold, design: .default))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            
            configuration.label
        }
    }
}

struct EquipmentList_Previews: PreviewProvider {
    static var previews: some View {
        let view = EquipmentList()
        view.loadData()
        return view
    }
}
