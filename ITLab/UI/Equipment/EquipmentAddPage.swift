//
//  EquipmentAdd.swift
//  ITLab
//
//  Created by Даниил on 15.07.2021.
//

import SwiftUI

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}

struct EquipmentAddPage: View {
    @Environment(\.presentationMode) var presentationMode
    /// TODO: Сначала по api получить все типы
    /// затем надо выбрать из полученных если выбрал потвердить то что был добавлен
    /// если такого типа нет добавить свой
    /// и затем уже потвердить добавленное устройство
    @ObservedObject var equipmentObserved = EquipmentObservable()
    @State var serialNumber: String
    private let picker = EquipmentTypePicker()
    
    var body: some View {
        VStack {
            HStack {
                picker
            }
            HStack {
                Text("Серийный номер: ")
                Text(self.serialNumber)
            }
            VStack {
                
                Button(
                    action: {
                        let equipmentType = picker.getEquipmentType()
                        
                        let equipmentTypeID = equipmentType.createType()
                        
                        equipmentObserved.equipment = EquipmentModel(serialNumber: serialNumber, equipmentTypeID: equipmentTypeID)
                        equipmentObserved.createEquipment()
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    label: {
                        Text("Добавить оборудование")
                    }
                )
            }
        }
    }
    
    func loadData() {
        self.picker.loadData()
    }
}

struct EquipmentTypePicker: View {
    @ObservedObject var equipmentsType: EquipmentsTypeObservable = EquipmentsTypeObservable()
    @State var isAddingType: Bool = false
    @State var selectedTypeIndex: Int = 0
    @State var addedType: EquipmentTypeModel = EquipmentTypeModel(id: "", title: "", description: "")
    
    var body: some View {
        VStack {
            HStack {
                Text("Выберите тип")
                Picker(
                    selection: $selectedTypeIndex.onChange(onIndexChange),
                    label: Text("\(selectedTypeIndex == -1 ? "Добавить тип" : equipmentsType.equipmentsType[selectedTypeIndex].title)"),
                    content: {
                        ForEach(equipmentsType.equipmentsType.indices, id: \.self) {
                            (index: Int) in
                            Text(equipmentsType.equipmentsType[index].title)
                        }
                        Text("Добавить тип").tag(-1)
                    }
                ).pickerStyle(MenuPickerStyle())
            }
            if isAddingType {
                // TODO: check if fields not empty
                VStack {
                    HStack {
                        Text("Название")
                        Spacer()
                        TextField("Введите название", text: self.$addedType.title)
                        Spacer()
                    }
                    HStack {
                        Text("Описание")
                        Spacer()
                        TextField("Введите описание", text: self.$addedType.description)
                    }
                }
            }
        }
    }
    
    func loadData() {
        self.equipmentsType.getEquipmentType()
    }
    
    private func onIndexChange(index: Int) {
        if index == -1 {
            isAddingType = true
        } else {
            isAddingType = false
        }
    }
    
    func getEquipmentType() -> EquipmentTypeObservable {
        let equipmentType = EquipmentTypeObservable()
        
        if self.isAddingType {
            equipmentType.equipmentType = addedType
        } else {
            equipmentType.equipmentType = self.equipmentsType.equipmentsType[selectedTypeIndex]
        }
        
        return equipmentType
    }
}

struct EquipmentAdd_Previews: PreviewProvider {
    static var previews: some View {
        let view = EquipmentAddPage(serialNumber: "example")
        view.loadData()
        return view
    }
}

struct EquipmentTypePicker_Previews: PreviewProvider {
    static var previews: some View {
        let view = EquipmentTypePicker()
        view.loadData()
        return view.environmentObject(EquipmentTypeObservable())
    }
}
