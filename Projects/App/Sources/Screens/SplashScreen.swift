//
//  SplashScreen.swift
//  democracyaction
//
//  Created by SwiftUI Migration
//

import SwiftUI

struct SplashScreen: View {
    @Binding var isDone: Bool
    @State private var loadingMessage = "Loading..."
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            Color(red: 0.2, green: 0.4, blue: 0.8) // Brand color
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)

                Text(loadingMessage)
                    .foregroundColor(.white)
                    .font(.headline)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("Retry") {
                Task {
                    await performInitialization()
                }
            }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            Task {
                await performInitialization()
            }
        }
    }

    private func performInitialization() async {
        do {
            loadingMessage = "Initializing..."
            
            // Initialize app (launch count, etc.)
            try await AppInitializer.initialize()

            loadingMessage = "Ready!"
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            await MainActor.run {
                withAnimation {
                    isDone = true
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    SplashScreen(isDone: .constant(false))
}
