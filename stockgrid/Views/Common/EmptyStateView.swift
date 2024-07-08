//
//  EmptyStateView.swift
//  stockgrid
//
//  Created by Le Bon B' Bauma on 06/03/2023.
//

import SwiftUI

struct EmptyStateView: View {
    // MARK: - Properties
    let text: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .font(.headline)
                .foregroundColor(Color(UIColor.secondaryLabel))
            Spacer()
        }
        .padding(64)
        .lineLimit(3)
        .multilineTextAlignment(.center)
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(text: "No data available")
    }
}
