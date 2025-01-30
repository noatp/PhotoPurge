//
//  SideMenu.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/29/25.
//

import SwiftUI

enum SideMenuOptions: String, CaseIterable, Identifiable {
    case instruction
    case redeem
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .instruction:
            "How to"
        case .redeem:
            "Redeem"
        }
        
    }
    
    var systemImageName: String {
        switch self {
        case .instruction:
            return "questionmark.circle"
        case .redeem:
            return "arrowshape.turn.up.right.circle"
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
                        .fill(Color(UIColor.systemBackground).opacity(0.6))
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                isShowingSideMenu.toggle()
                            }
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
//        .animation(.easeInOut, value: isShowingSideMenu)
        .onChange(of: selectedOption) { _, option in
            guard option != nil else { return }
            shouldPresent = true
        }
        .sheet(item: $selectedOption) { option in
            destinationView(for: option)
        }
        
    }
    private func destinationView(for option: SideMenuOptions) -> some View {
        Group {
            switch option {
            case .instruction:
                views.instructionView(shouldShowContinueButton: false)
            case .redeem:
                Text("redeem")
            }
        }
        
    }
}

#Preview {
    SideMenu(isShowingSideMenu: .constant(true))
}

