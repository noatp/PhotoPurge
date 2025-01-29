//
//  SideMenuOptionRow.swift
//  PhotoPurger
//
//  Created by Toan Pham on 1/29/25.
//

import SwiftUI

struct SideMenuOptionRow: View {
    private let sideMenuOption: SideMenuOptions
    @Binding var selectedOption: SideMenuOptions?
    
    init(sideMenuOption: SideMenuOptions,
         selectedOption: Binding<SideMenuOptions?>
    ) {
        self.sideMenuOption = sideMenuOption
        _selectedOption = selectedOption
    }
    
    var body: some View {
        Button {
            selectedOption = sideMenuOption
        } label: {
            HStack {
                Image(systemName: sideMenuOption.systemImageName)
                    .imageScale(.large)
                Text(sideMenuOption.title)
                    .font(.headline)
            }
        }
        .padding()
        .foregroundStyle(selectedOption == sideMenuOption ? .blue : .primary)
        .background(selectedOption == sideMenuOption ? .blue.opacity(0.1) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}


#Preview {
    SideMenuOptionRow(sideMenuOption: .instruction, selectedOption: .constant(.instruction))
}
