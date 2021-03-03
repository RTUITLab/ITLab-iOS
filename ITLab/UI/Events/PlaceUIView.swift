//
//  PlaceView.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 06.11.2020.
//

import SwiftUI

struct PlaceUIView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let place: PlaceView
    let indexPlace: Int
    @State var salary: PlaceSalaryView?

    @State private var isUsers: Bool = false
    @State private var isEquipment: Bool = false
    @State private var isEnableButton: Bool = false
    @State private var isExpanded: Bool = false

    @State private var showingActionSheet: Bool = false
    @State private var actionSheetButtons: [ActionSheet.Button] = []

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                VStack{
                    Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .opacity(0.5)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .animation(.spring())
                }
                        .padding(.trailing, 10)

                VStack(alignment: .leading) {
                    Text("Место #\(indexPlace)")
                            .fontWeight(.bold)
                            .padding(.bottom, 1)

                    HStack(alignment: .center) {
                        Image(systemName: "person.2.fill")
                                .font(.callout)
                                .foregroundColor(.gray)
                                .opacity(0.5)
                        Text(declinationOfNumberOfParticipants())
                                .font(.callout)
                                .foregroundColor(Color.gray)
                    }

                    if let salary = self.salary {
                        HStack(alignment: .center) {
                            Image(systemName: "creditcard.fill")
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                    .opacity(0.5)
                            Text("\(salary.count!) \u{20BD}")
                                    .font(.callout)
                                    .foregroundColor(Color.gray)
                        }
                                .padding(.top, 1.0)
                    }
                }

                Spacer()


                Button(action: {
                    self.showingActionSheet = true
                }, label: {
                    Text("Подать заявку")
                })
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(self.isEnableButton)
            }
                    . onTapGesture(){
                        isExpanded.toggle()
                    }
                    .actionSheet(isPresented: $showingActionSheet) {
                        ActionSheet(title: Text("Подать заявку"), message: Text("Выберите степень участия"), buttons: self.actionSheetButtons)
                    }
            if isExpanded
            {
                VStack(alignment: .leading) {

                    Divider()

                    if isUsers {

                        VStack(alignment: .leading) {

                            if let participants = place.participants {
                                ForEach(participants, id: \.user!._id) { participant in
                                    UserPlace(user: participant, userType: .participants)
                                }
                            }

                            if let invited = place.invited {
                                ForEach(invited, id: \.user!._id) { invite in
                                    UserPlace(user: invite, userType: .invited)
                                }
                            }

                            if let wishers = place.wishers {
                                ForEach(wishers, id: \.user!._id) { wisher in
                                    UserPlace(user: wisher, userType: .wishers)
                                }
                            }


                        }
                    } else {
                        Text("Нет участников").padding(.top, 2)
                    }
                }
                        .padding(.horizontal, 20.0)
                        .padding(.vertical, 10.0)
                        .transition(AnyTransition.slide.animation(.linear(duration: 0.3)))
            }
        }
                .onAppear() {

                    var usersCount = 0

                    var isParticipant = false, isWisher = false, isInvite = false


                    if let participants = place.participants {
                        usersCount += participants.count
                        isParticipant = participants.contains(where: { (user) -> Bool in
                            return user.user!._id == OAuthITLab.shared.getUserInfo()!.userId
                        })
                    }

                    if let wishers = place.wishers {
                        usersCount += wishers.count
                        isWisher = wishers.contains(where: { (user) -> Bool in
                            return user.user!._id == OAuthITLab.shared.getUserInfo()!.userId
                        })
                    }

                    if let invited = place.invited {
                        usersCount += invited.count
                        isInvite = invited.contains(where: { (user) -> Bool in
                            return user.user!._id == OAuthITLab.shared.getUserInfo()!.userId
                        })
                    }

                    self.isEnableButton = isParticipant || isWisher || isInvite
                    self.isUsers = usersCount != 0
                    self.isEquipment = place.equipment?.count ?? 0 != 0

                    var kek: [ActionSheet.Button] = []
                    for i in EventRole.data {
                        kek.append(.default(Text(i.title ?? "nil")) {
                            registrationEvent(event: i._id!)
                        })
                    }
                    kek.append(.cancel(Text("Отмена")))

                    self.actionSheetButtons = kek
                }

    }

    func registrationEvent(event id: UUID) {
        EventAPI.apiEventWishPlaceIdRoleIdPost(placeId: place._id!, roleId: id) { (_, error) in
            
            if let error = error {
                print(error)
                AlertError.shared.callAlert(message: error.localizedDescription)
                return
            }
            
            self.presentationMode.wrappedValue.dismiss()

        }
    }

    func declinationOfNumberOfParticipants() -> String {

        return "\(place.participants!.count + place.wishers!.count + place.invited!.count)/\(place.targetParticipantsCount!)"
    }

    private struct UserPlace: View {
        enum UserType {
            case participants
            case wishers
            case invited
        }

        let user: UserAndEventRole
        let userType: UserType

        var body: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {

                    VStack{
                        switch userType {
                        case .participants:
                            Image(systemName: "person.fill")
                                    .foregroundColor(.green)
                        case .invited:
                            Image(systemName: "person.fill")
                                    .foregroundColor(.orange)
                        case .wishers:
                            Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                                    .opacity(0.5)
                        }
                    }
                            .padding(.trailing, 5)

                    Text("\(user.user!.lastName ?? "") \(user.user!.firstName ?? "")")
                            .font(.callout)
                            .bold()

                    Text("—")
                            .font(.callout)

                    Text(user.eventRole!.title!.lowercased())
                            .font(.callout)
                }
            }
                    .padding(1.0)

        }
    }

    private struct EquipmentPlace: View {
        let equipment: EquipmentView

        var body: some View {
            VStack(alignment: .leading) {

                Text("\(equipment.equipmentType!.title!)")
                        .font(.footnote)
                        .bold()
                        .lineLimit(2)

                Text(equipment.serialNumber!)
                        .font(.caption)

            }
                    .padding(5.0)
        }
    }
}
