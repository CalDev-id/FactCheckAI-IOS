//
//  HomeScreen.swift
//  CekFakta
//
//  Created by Heical Chandra on 24/11/25.
//
import SwiftUI

struct HomeScreen: View {
    @StateObject private var vm = NewsViewModel()
    @EnvironmentObject var auth: AuthManager
    @EnvironmentObject private var router: Router

    let tab = ["All News", "Valid", "Hoaks"]
    @State var selectedIndex = 0

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if vm.isLoading {
                // ProgressView("Loading...")
            } else if let error = vm.errorMessage {
                Text(error).foregroundColor(.red)
            } else {
                VStack {
                    HStack {
                        Image("logo")
                            .resizable()
                            .frame(width: 40, height: 40)

                        Spacer()

                        if let avatar = auth.avatarURL,
                           let url = URL(string: avatar) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: { ProgressView() }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Daily News").fontWeight(.semibold)
                        Text("Feed").fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .font(.system(size: 35))
                    .padding(.top, 20)

                    HStack {
                        ForEach(tab.indices, id: \.self) { index in
                            Button {
                                selectedIndex = index
                            } label: {
                                Text(tab[index])
                                    .foregroundColor(index == selectedIndex ? Color.redPrimary : Color.gray)
                                    .padding(.vertical)
                                    .overlay(
                                        Rectangle()
                                            .fill(index == selectedIndex ? Color.redPrimary : Color.clear)
                                            .frame(height: 2),
                                        alignment: .bottom
                                    )
                                    .padding(.trailing)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, -10)

                    Divider().padding(.top, -9)

                    if let top = filteredNews.last, let _ = top.id {
                        TopNewsCard(news: top)
                            .onTapGesture { router.navigate(to: .detailNews(id: top.id!)) }
                    }

                    Divider()
                        .offset(y: 70)
                        .padding(.horizontal)

                    ForEach(Array(filteredNews.dropLast().reversed())) { item in
                        NewsRow(news: item)
                            .contentShape(Rectangle())
                            .onTapGesture { router.navigate(to: .detailNews(id: item.id!)) }
                            .padding(.horizontal, 20)
                            .offset(y: 70)
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .background(Color(.systemBackground))

        .task { await vm.loadIfNeeded() }

        .refreshable {
            await vm.fetchNews(showLoading: false) // biar gak ngosongin konten pas refresh
        }

    }
}

extension HomeScreen {
    var filteredNews: [News] {
        let filtered: [News]

        switch selectedIndex {
        case 1:
            filtered = vm.newsList.filter {
                $0.classification?.final_label?.lowercased() == "valid"
            }
        case 2:
            filtered = vm.newsList.filter {
                $0.classification?.final_label?.lowercased() == "hoaks"
            }
        default:
            filtered = vm.newsList
        }

        return Array(filtered.prefix(10))
    }}
