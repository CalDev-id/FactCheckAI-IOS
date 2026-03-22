//
//  HomeCard.swift
//  CekFakta
//
//  Created by Heical Chandra on 10/12/25.
//

import SwiftUI

struct TopNewsCard: View {
    let news: News
    
    var body: some View {
        ZStack {
            AsyncImageView(urlString: news.evidence_scraped?.first?.featured_image)
                .frame(width: UIScreen.main.bounds.width - 20)
                .frame(height: 260)
                .clipped()

            ZStack{
                Image("newsbg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width - 20, height: 180)
                    .clipped()


                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text((news.classification?.final_label ?? "-").capitalizingFirstLetter)
                            .font(.caption.bold())
                            .foregroundColor(.black)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                            )

                        if let date = news.inserted_at {
                            Text(formatISODate(date))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    HStack{
                        Text(news.claim ?? "-")
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .padding(.trailing, 50)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white)
                    }
                }
                .padding()
                .padding(.top, 55)
            }
            .offset(y: 100)
        }
        .frame(height: 260)
        .frame(maxWidth: UIScreen.main.bounds.width - 20)
    }
}


struct AsyncImageView: View {
    let urlString: String?

    var body: some View {
        if let urlString, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .empty:
                    ProgressView()
                default:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(.gray.opacity(0.4))
                }
            }
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFill()
                .foregroundColor(.gray.opacity(0.4))
        }
    }
}

struct NewsRow: View {
    let news: News

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack{
                    Text((news.classification?.final_label ?? "-").capitalizingFirstLetter)
                        .font(.subheadline)
                        .foregroundColor(news.classification?.final_label == "valid" ? .blue : .red)
                    Text("•")
                        .foregroundColor(.gray)
                    if let date = news.inserted_at {
                        Text(formatISODate(date))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                Text(news.claim ?? "-")
                    .font(.headline)
                    .lineLimit(2)
                    .padding(.trailing, 10)
                Text("7 min read")
                    .font(.caption)
                    .foregroundColor(.gray)

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if let img = news.evidence_scraped?.first?.featured_image,
               let url = URL(string: img) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipped()
                    case .empty:
                        ProgressView()
                            .frame(width: 90, height: 90)
                    default:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .padding(.vertical, 6)
        
    }
}

func formatISODate(_ isoString: String) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    if let date = formatter.date(from: isoString) {
        let out = DateFormatter()
        out.dateFormat = "dd/MM/yyyy"
        return out.string(from: date)
    }

    return isoString
}
