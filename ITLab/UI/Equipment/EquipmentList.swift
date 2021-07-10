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
    var body: some View {
        VStack {
            EquipmentSearchBar(text: $searchText, placehodler: "Поиск оборудования")
            HStack {
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
                
                Spacer()
            }
            
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
        EquipmentList()
    }
}
