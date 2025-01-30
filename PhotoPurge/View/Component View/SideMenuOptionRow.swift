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
        GeometryReader { geometry in
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
            .frame(width: geometry.size.width, alignment: .leading)
            .foregroundStyle(.primary)
            .background(selectedOption == sideMenuOption ? .blue.opacity(0.5) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .frame(height: 60)
    }
}


#Preview {
    SideMenuOptionRow(sideMenuOption: .instruction, selectedOption: .constant(.instruction))
}
