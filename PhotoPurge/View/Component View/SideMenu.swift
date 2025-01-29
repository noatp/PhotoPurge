//
//  SideMenu.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/29/25.
//

import SwiftUI

enum SideMenuOptions: String, CaseIterable {
    case instruction
    case redeem
    
    var title: String {
        rawValue.capitalized
    }
    
    var systemImageName: String {
        switch self {
        case .instruction:
            "questionmark.circle"
        case .redeem:
            "arrowshape.turn.up.right.circle"
        }
    }
}

struct SideMenu: View {
    @Environment(\.viewsFactory) var views
    @Binding var isShowingSideMenu: Bool
    @State private var selectedOption: SideMenuOptions?
    @State private var shouldPresent: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isShowingSideMenu {
                    Rectangle()
                        .opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isShowingSideMenu.toggle()
                        }
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Menu")
                                .font(.title)
                                .bold()
                                .padding()
                            ForEach(SideMenuOptions.allCases, id: \.title) { sideMenuOption in
                                SideMenuOptionRow(sideMenuOption: sideMenuOption, selectedOption: $selectedOption)
                                    .padding(.horizontal)
                            }
                            Spacer()
                        }
                        .frame(width: geometry.size.width * 0.7, height: geometry.size.height, alignment: .leading)
                        .background(Color(UIColor.systemBackground))
                        Spacer()
                    }
                    .transition(.move(edge: .leading))
                }
                
            }
            
        }
        .animation(.easeInOut, value: isShowingSideMenu)
        .onChange(of: selectedOption) { _, option in
            guard option != nil else { return }
            shouldPresent = true
        }
        .sheet(isPresented: $shouldPresent) {
            selectedOption = nil
        } content: {
            switch selectedOption {
            case .instruction:
                views.instructionView()
            case .redeem:
                Text("Redeem")
            case nil:
                Text("nil")
            }
        }
    }
}

#Preview {
    SideMenu(isShowingSideMenu: .constant(true))
}

