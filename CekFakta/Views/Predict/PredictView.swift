//import SwiftUI
//
//struct PredictOption: Identifiable {
//    let id = UUID()
//    let title: String
//    let destination: Router.Destination
//}
//
//struct PredictView: View {
//    @EnvironmentObject private var router: Router
//
//    private let options: [PredictOption] = [
//        PredictOption(title: "Claim Only",  destination: .predictWithNews),
//        PredictOption(title: "Claim + Evidence", destination: .predictWithClaim),
////        PredictOption(title: "Link",  destination: .predictWithLink)
//    ]
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Choose Prediction Method")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .padding(.top, 20)
//                .frame(maxWidth: .infinity, alignment: .leading)
//
//            ForEach(options) { option in
//                Button {
//                    router.navigate(to: option.destination)
//                } label: {
//                    PredictCard(predict: option.title)
//                }
//                .buttonStyle(.plain)
//            }
//
//            Spacer()
//        }
//        .padding(.horizontal, 20)
//        .background(Color(.systemGroupedBackground))
//    }
//}
//
//#Preview {
//    PredictView()
//}
//
//struct PredictCard: View {
//    let predict: String
//    
//    var body: some View {
//        HStack(spacing: 15) {
//            
//            // MARK: Icon sesuai nama titel
//            Image(systemName: iconName(for: predict))
//                .font(.system(size: 28, weight: .bold))
//                .foregroundColor(.white)
//                .padding(14)
//                .background(
//                    LinearGradient(colors: [Color.redPrimary, Color.redPrimary.opacity(0.8)],
//                                   startPoint: .topLeading,
//                                   endPoint: .bottomTrailing)
//                )
//                .clipShape(RoundedRectangle(cornerRadius: 18))
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(predict)
//                    .font(.headline)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.primary)
//
//                Text(subtitle(for: predict))
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            
//            Spacer()
//            
//            Image(systemName: "chevron.right")
//                .font(.system(size: 16, weight: .bold))
//                .foregroundColor(.redPrimary)
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(Color.white)
//                .shadow(
//                    color: Color.black.opacity(0.08),
//                    radius: 8,
//                    x: 0, y: 4
//                )
//        )
//    }
//}
//
//extension PredictCard {
//    // MARK: Subtitle otomatis
//    func subtitle(for title: String) -> String {
//        switch title {
//        case "News": return "Paste news article to analyze"
//        case "Claim": return "Check the truth of a specific claim"
//        case "Link": return "Verify content from a website link"
//        default: return "Prediction method"
//        }
//    }
//    
//    // MARK: Icon otomatis
//    func iconName(for title: String) -> String {
//        switch title {
//        case "News": return "newspaper.fill"
//        case "Claim": return "quote.bubble.fill"
//        case "Link": return "link.circle.fill"
//        default: return "questionmark.circle"
//        }
//    }
//}

import SwiftUI

struct PredictView: View {
    var body: some View {
        PredictWithClaim()
    }
}

#Preview {
    PredictView()
}
