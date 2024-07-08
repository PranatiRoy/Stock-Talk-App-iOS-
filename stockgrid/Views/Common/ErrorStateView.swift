//
//  ErrorStateView.swift
//  stockgrid
//
//  Created by Le Bon B' Bauma on 06/03/2023.
//

import SwiftUI

struct ErrorStateView: View {
    // MARK: - Properties
    
    let error: String
    var retryCallBack: (() -> ())? = nil
    
    var body: some View {
        HStack {
            Spacer()
            VStack (spacing: 16) {
                Text(error)
                if let retryCallBack {
                    Button("Retry", action: retryCallBack)
                        .buttonStyle(.borderedProminent)
                }
            }
            Spacer()
        }
        .padding(64)
    }
}

struct ErrorStateView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ErrorStateView(error: "An Error Occured") {}
                .previewDisplayName("With Retry Button")
            ErrorStateView(error: "An Error Occured")
                .previewDisplayName("Without Retry Button")
        }
    }
}
