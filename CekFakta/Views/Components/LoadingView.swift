//
//  LoadingView.swift
//  CekFakta
//
//  Created by Heical Chandra on 11/12/25.
//

import SwiftUI

struct InfoCard: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var start: CGFloat = 0.0
    @State private var end: CGFloat = 0.2
    @State private var progress: CGFloat = 0.0
    let duration: Double = 50.0
    
    let cards: [InfoCard] = [
        InfoCard(
            title: "The More You Know",
            content: "Many fake news use altered or photoshopped images"
        ),
        InfoCard(
            title: "Be Critical",
            content: "Always verify information using multiple trusted sources"
        )
    ]

    
    var body: some View {
        VStack(alignment: .center){
            Spacer()
            Image("loading")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .overlay(
                    GeometryReader { geo in
                        let size = geo.size.width
                        
                        RoundedRectangle(cornerRadius: 0)
                            .trim(from: start, to: end)
                            .stroke(
                                Color.redPrimary,
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: size * 0.85, height: size * 0.85)
                            .rotationEffect(.degrees(45))
                            .position(x: size / 2, y: size / 2)
                            .scaleEffect(0.85)
                    }
                )
                
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        start = 1
                        end = start + 0.2
                    }
                }
            Text("Scanning Article...")
                .font(.headline)
                .padding(.top,10)
            Text("Currently scanning and reviewing this article.\nPlease wait a minute for the result.")
                .multilineTextAlignment(.center)
                .fontWeight(.light)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            VStack(spacing: 16) {

                GeometryReader { geo in
                    let width = geo.size.width

                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))

                        Rectangle()
                            .fill(Color.redPrimary)
                            .frame(width: width * progress)
                    }
                    .cornerRadius(6)
                }
                .frame(height: 12)
                .frame(width: 250)

                Text("\(Int(progress * 100))%")
                    .font(.headline)
            }
            .onAppear {
                startLoading()
            }
        
            Spacer()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(cards) { card in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.redPrimary)
                                .font(.title3)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(card.title)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.redPrimary)

                                Text(card.content)
                                    .lineLimit(2)
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(12)
                        .frame(width: 240, height: 80, alignment: .topLeading)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                        )
                    }
                }
                .padding(.leading, 20)
                .padding(.bottom, 50)
                .padding(.top, 80)
            }
        }
        .background(.white)
    }
    func startLoading() {
        let steps = 1000
        let interval = duration / Double(steps)

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if progress >= 1.0 {
                timer.invalidate()
            } else {
                progress += 1.0 / CGFloat(steps)
            }
        }
    }
}



//#Preview {
//    LoadingView()
//}

#Preview {
    LoadingView()
}
