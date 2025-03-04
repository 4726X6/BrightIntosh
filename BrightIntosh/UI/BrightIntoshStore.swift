//
//  BrightIntoshStore.swift
//  BrightIntosh
//
//  Created by Niklas Rousset on 06.09.24.
//

import SwiftUI
import OSLog

struct InfoNote: View {
    var infoText: LocalizedStringKey
    var body: some View {
        VStack {
            Label(infoText, systemImage: "info.circle")
        }
        .padding(10)
        .background(Color.brightintoshBlue)
        .clipShape(RoundedRectangle(cornerRadius: 10.0))
        .transition(.opacity)
    }
}

struct BrightIntoshStoreView: View {
    public var showLogo: Bool = true

    private let logger = Logger(
        subsystem: "Settings View",
        category: "Store"
    )

    @State private var showRestartNoteDueToSpinner = false

    var body: some View {
        VStack {
            Spacer()
            if showLogo {
                Image("LogoBorderedHighRes").resizable().scaledToFit().frame(height: 90.0)
            }
            Text("You have access to BrightIntosh.\nEnjoy the brightness!")
                .multilineTextAlignment(.center)
                .font(.title)
            Spacer()
        }
    }

    private func delayNotLoadingRestartNote() async {
        do {
            try await Task.sleep(nanoseconds: 6_000_000_000)
        } catch {
            return
        }
    }
}

#Preview {
    BrightIntoshStoreView()
        .frame(width: 800, height: 600)
}
