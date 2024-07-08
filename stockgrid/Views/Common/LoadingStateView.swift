//
//  LoadingStateView.swift
//  stockgrid
//
//  Created by Le Bon B' Bauma on 06/03/2023.
//

import SwiftUI

struct LoadingStateView: View {
    var body: some View {
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
            Spacer()
        }
    }
}

struct LoadingStateView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingStateView()
    }
}
