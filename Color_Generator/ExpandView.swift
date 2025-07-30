//
//  ExpandView.swift
//  Color_Generator
//
//  Created by Akshat Dutt Kaushik on 31/07/25.
//

import SwiftUI

struct ExpandedColorView: View {
    let item: Item
    @Binding var isExpanded: Bool
    @Binding var rotationX: Double
    @Binding var rotationY: Double
    @Binding var showingBack: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(.black)
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                isExpanded = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                                .background(.ultraThinMaterial, in: Circle())
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(hex: item.hexCode).opacity(0.2))
                            .frame(width: 260, height: 320)
                            .overlay(
                                VStack(spacing: 16) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("Created")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Text(formatFullTime(item.timestamp))
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                }
                            )
                            .rotation3DEffect(
                                .degrees(rotationY + 180),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .opacity(showingBack ? 1 : 0)
                        
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(hex: item.hexCode))
                            .frame(width: 260, height: 320)
                            .overlay(
                                VStack(spacing: 16) {
                                    Text(item.hexCode)
                                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                                        .foregroundColor(textColor(for: item.hexCode))
                                    
                                    Text("Tap to flip")
                                        .font(.caption)
                                        .foregroundColor(textColor(for: item.hexCode).opacity(0.7))
                                }
                            )
                            .rotation3DEffect(
                                .degrees(rotationY),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .opacity(showingBack ? 0 : 1)
                    }
                    .rotation3DEffect(
                        .degrees(rotationX),
                        axis: (x: 1, y: 0, z: 0)
                    )
                    .shadow(color: Color(hex: item.hexCode).opacity(0.4), radius: 30, x: 0, y: 15)
                    .onTapGesture {
                        flipCard()
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                rotationY = Double(value.translation.width / 5)
                                rotationX = Double(-value.translation.height / 5)
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                                    rotationX = 0
                                    rotationY = showingBack ? 180 : 0
                                }
                            }
                    )
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            UIPasteboard.general.string = item.hexCode
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        }) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("Copy")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(.ultraThinMaterial, in: Capsule())
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
    }
    
    private func flipCard() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            rotationY += 180
            showingBack.toggle()
        }
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
    
    private func formatFullTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
