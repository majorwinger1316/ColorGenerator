//
//  ContentView.swift
//  Color_Generator
//
//  Created by Akshat Dutt Kaushik on 30/07/25.
//

import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) private var savedColors: [Item]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var isAnimating = false
    @State private var currentAnimationColor = ""
    @State private var animationScale: CGFloat = 0.3
    @State private var animationOpacity: Double = 0
    @State private var backgroundBlur: CGFloat = 0
    @State private var showDetails = false
    @State private var glowIntensity: Double = 0
    @State private var isAddingNewCard = false
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showNetworkAlert = false
    @State private var networkAlertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                
                VStack(spacing: 24) {

                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            if isAddingNewCard {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.clear)
                                    .frame(height: 200)
                                    .opacity(0)
                            }
                            
                            ForEach(savedColors) { item in
                                InteractiveColorCard(item: item)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 80)
                    }
                }
                .blur(radius: backgroundBlur)
                .navigationTitle("HexRang")
                .navigationBarTitleDisplayMode(.large)
                
                if !NetworkMonitor.shared.isConnected {
                    VStack {
                        HStack(spacing: 12) {
                            Image(systemName: "wifi.slash")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("No Internet Connection")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("Colors will be saved locally and synced when online")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .background(
                            Capsule()
                                .fill(Color.red)
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .transition(.move(edge: .top))
                        .onTapGesture {
                            networkAlertMessage = """
                            You're currently offline. Here's what you should know:
                            
                            • New colors will be saved locally
                            • All changes will sync automatically when back online
                            • You can still view and copy your saved colors
                            """
                            showNetworkAlert = true
                        }
                        
                        Spacer()
                    }
                    .alert("Offline Mode", isPresented: $showNetworkAlert) {
                        Button("Got It", role: .cancel) { }
                    } message: {
                        Text(networkAlertMessage)
                    }
                }
                
                VStack {
                    Spacer()
                    Button(action: generateColorWithAnimation) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color.primary)
                            Text("New Color")
                                .font(.headline)
                                .foregroundStyle(Color.primary)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            ZStack {
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .background(
                                        Color.white.opacity(0.2)
                                            .blur(radius: 10)
                                    )
                                    .cornerRadius(20)
                                
                                Rectangle()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.6),
                                                Color.white.opacity(0.1),
                                                Color.clear
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.5
                                    )
                                    .cornerRadius(20)
                            }
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                .blur(radius: 1)
                        )
                    }
                    .scaleEffect(isAnimating ? 0.96 : 1.0)
                    .disabled(isAnimating)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
                
                if isAnimating {
                    Rectangle()
                        .fill(.black.opacity(0.8))
                        .ignoresSafeArea()
                        .opacity(animationOpacity)
                    
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: currentAnimationColor).opacity(0.2))
                                .frame(width: 260, height: 320)
                                .blur(radius: 20)
                                .scaleEffect(1.1)
                                .opacity(glowIntensity * 0.6)
                            
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: currentAnimationColor))
                                .frame(width: 240, height: 300)
                                .scaleEffect(animationScale)
                                .overlay(
                                    VStack(spacing: 12) {
                                        if showDetails {
                                            Text("New Color")
                                                .font(.title3)
                                                .fontWeight(.medium)
                                                .foregroundColor(textColor(for: currentAnimationColor))
                                            
                                            Text(currentAnimationColor)
                                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                                .foregroundColor(textColor(for: currentAnimationColor))
                                        }
                                    }
                                    .opacity(showDetails ? 1 : 0)
                                )
                                .shadow(color: Color(hex: currentAnimationColor).opacity(0.3), radius: 20, x: 0, y: 8)
                        }
                    }
                    .animation(.spring(), value: NetworkMonitor.shared.isConnected)
                    .alert("Sync Status", isPresented: $showNetworkAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(networkAlertMessage)
                    }
                    .opacity(animationOpacity)
                }
            }
        }
        .onAppear {
                initializeSync()
        }
    }
    
    private func generateColorWithAnimation() {
        let hex = generateAppleStyleColor()
        currentAnimationColor = hex
        
        withAnimation(.easeOut(duration: 0.5)) {
            isAnimating = true
            animationOpacity = 1.0
            backgroundBlur = 15
        }
        
        withAnimation(.spring(response: 0.9, dampingFraction: 0.7).delay(0.1)) {
            animationScale = 1.0
            glowIntensity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeInOut(duration: 0.4)) {
                showDetails = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeOut(duration: 0.3)) {
                showDetails = false
            }
            
            withAnimation(.spring(response: 1.2, dampingFraction: 0.9).delay(0.2)) {
                animationScale = 0.05
                glowIntensity = 0
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                animationOpacity = 0
                backgroundBlur = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.spring()) {
                isAddingNewCard = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            let newItem = Item(hexCode: hex)
            modelContext.insert(newItem)
            
            SyncManager.shared.syncItem(newItem, context: modelContext) { status in
                switch status {
                case .success(let message):
                    self.networkAlertMessage = message
                    self.showNetworkAlert = true
                    
                case .failure(let error):
                    self.networkAlertMessage = "Sync failed: \(error.localizedDescription)"
                    self.showNetworkAlert = true
                    
                case .offlineSavedLocally:
                    self.networkAlertMessage = "Saved locally - will sync when online"
                    self.showNetworkAlert = true
                }
            }
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isAddingNewCard = false
            }
            
            let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
            impactFeedback.impactOccurred()
            
            isAnimating = false
            animationScale = 0.3
            animationOpacity = 0
            backgroundBlur = 0
            showDetails = false
            glowIntensity = 0
        }
        
        
    }
    
    private func generateAppleStyleColor() -> String {
        let hue = Double.random(in: 0...360)
        let saturation = Double.random(in: 0.4...0.85)
        let brightness = Double.random(in: 0.5...0.9)
        
        let color = UIColor(hue: hue/360, saturation: saturation, brightness: brightness, alpha: 1.0)
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let redInt = Int(red * 255)
        let greenInt = Int(green * 255)
        let blueInt = Int(blue * 255)
        
        return String(format: "#%02X%02X%02X", redInt, greenInt, blueInt)
    }
    
    private func textColor(for hexColor: String) -> Color {
        let color = UIColor(Color(hex: hexColor))
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        
        return luminance > 0.6 ? .black : .white
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

extension ContentView {
    private func setupSyncObserver() {
        NetworkMonitor.shared.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { isConnected in
                print("Network status changed: \(isConnected ? "Connected" : "Disconnected")")
            }
            .store(in: &cancellables)
    }
    
    private func syncPendingItems() {
        let unsyncedItems = savedColors.filter { !$0.isSynced }
        
        if !unsyncedItems.isEmpty && NetworkMonitor.shared.isConnected {
            FirebaseService.shared.syncAllUnsyncedItems(items: unsyncedItems)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            print("Batch sync failed: \(error.localizedDescription)")
                        }
                    },
                    receiveValue: { _ in
                        unsyncedItems.forEach { $0.isSynced = true }
                        try? modelContext.save()
                    }
                )
                .store(in: &cancellables)
        }
    }

    private func initializeSync() {
        setupSyncObserver()
        syncPendingItems()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
