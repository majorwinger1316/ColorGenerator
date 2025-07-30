//
//  InteractiveCard.swift
//  Color_Generator
//
//  Created by Akshat Dutt Kaushik on 31/07/25.
//

import SwiftUI


struct InteractiveColorCard: View {
    let item: Item
    @State private var isPressed = false
    @State private var isExpanded = false
    @State private var rotationX: Double = 0
    @State private var rotationY: Double = 0
    @State private var showingBack = false
    
    var body: some View {
        ZStack {
            if !isExpanded {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: item.hexCode))
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: 6) {
                            Text(item.hexCode)
                                .foregroundColor(textColor(for: item.hexCode))
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        }
                        .padding()
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .onTapGesture {
                        expandCard()
                    }
                    .onLongPressGesture(minimumDuration: 0.1) {
                        copyToClipboard()
                    } onPressingChanged: { pressing in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = pressing
                        }
                    }
            }
        }
        .fullScreenCover(isPresented: $isExpanded) {
            ExpandedColorView(
                item: item,
                isExpanded: $isExpanded,
                rotationX: $rotationX,
                rotationY: $rotationY,
                showingBack: $showingBack
            )
        }
    }
    
    private func expandCard() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isExpanded = true
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = item.hexCode
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
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
