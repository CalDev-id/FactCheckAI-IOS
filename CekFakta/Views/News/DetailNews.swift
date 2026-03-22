import SwiftUI

struct DetailNews: View {
    let newsId: String
    @StateObject private var vm = DetailNewsViewModel()
    @EnvironmentObject private var router: Router
    @State private var expandEvidence: Bool = false
    
    var body: some View {
        ScrollView {
            if vm.isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let error = vm.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else if let news = vm.news {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Button(action: {
                            router.navigateBack()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                                .padding(8)
                        }

                        
                        Spacer()
                        
                        Button(action: {
                        }) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                                .padding(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    if let img = news.evidence_scraped?.first?.featured_image,
                       let url = URL(string: img) {
                        ZStack(alignment: .bottomLeading){
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 220)
                            .frame(width: UIScreen.main.bounds.width)
                            .clipped()
                            
                            Text(news.classification?.final_label?.capitalized ?? "-")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 15)
                                .background(
                                    news.classification?.final_label?.lowercased() == "valid"
                                    ? Color.blue
                                    : Color.redPrimary
                                )
                                .cornerRadius(5)


                        }
                        .padding(.bottom, 20)
                    }
                    VStack (alignment: .leading){
                        HStack{
                            Image("info")
                                .resizable()
                                .frame(width: 45, height: 45)
                                .shadow(radius: 2)
                            Text("Reason why this news fake or not")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.black)
                        }
                        .padding()
                        .background(Color.greyDetail)
                        .cornerRadius(5)
                        .shadow(radius: 2)
                        
                        Text(news.claim ?? "-")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.vertical, 10)
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: news.author?.avatar_url ?? "")) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 40, height: 40)

                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())

                                case .failure:
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.gray)

                                @unknown default:
                                    EmptyView()
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(news.author?.name ?? "Unknown Author")
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                if let date = news.inserted_at {
                                    Text(formatISODate(date))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }

                        .padding(.bottom, 10)
                        
                        Divider()
                        
                        ExpandableText(
                            text: news.explanation ?? "-",
                            lineLimit: 15 // tampilkan hanya 3 baris pertama
                        )
                        .padding(.bottom, 10)
                        
                        Divider()
                        //evidence
                        if let evidences = news.evidence_scraped, !evidences.isEmpty {

                            SectionCard(title: "Bukti Tambahan (Evidence)") {

                                let evidence = evidences[0]
                                let fullContent = evidence.content ?? "Tidak ada konten"
                                let preview = String(fullContent.prefix(200))

                                VStack(alignment: .leading, spacing: 12) {

                                    // Image
                                    if let imageUrl = evidence.featured_image,
                                       let url = URL(string: imageUrl) {

                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(width: 330, height: 180)
                                                    .background(Color.gray.opacity(0.1))
                                                    .cornerRadius(12)

                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 330, height: 180)
                                                    .clipped()
                                                    .cornerRadius(12)

                                            case .failure:
                                                Color.gray.opacity(0.2)
                                                    .frame(width: 330, height: 180)
                                                    .overlay(Text("Gagal memuat gambar"))
                                                    .cornerRadius(12)

                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    }

                                    // Judul
                                    if let judul = evidence.judul {
                                        Text(judul)
                                            .font(.subheadline)
                                            .bold()
                                    }

                                    // Sumber & tanggal
                                    HStack(spacing: 10) {
                                        if let sumber = evidence.sumber {
                                            Text(sumber)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        if let tanggal = evidence.tanggal {
                                            Text(tanggal)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }

                                    // Content
                                    Text(expandEvidence
                                         ? fullContent
                                         : preview + (fullContent.count > 200 ? "…" : "")
                                    )
                                    .font(.body)
                                    .foregroundColor(.primary)

                                    Button {
                                        withAnimation {
                                            expandEvidence.toggle()
                                        }
                                    } label: {
                                        Text(expandEvidence ? "Lihat lebih sedikit ▲" : "Lihat selengkapnya ▼")
                                            .font(.callout)
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.vertical, 6)
                                }
                            }
                            .padding(.vertical, 10)
                        }


                        //bukti pendukung
                        if let links = news.evidence_links {
                            SectionCard(title: "Sumber Pendukung") {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(links, id: \.self) { link in
                                        Link(destination: URL(string: link)!) {
                                            HStack {
                                                Image(systemName: "link")
                                                Text(link)
                                                    .foregroundColor(.blue)
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                }
                .padding()
                
            }
        }
        .task {
            await vm.fetchDetail(newsId: newsId)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        
        
    }}

extension String {
    var capitalizingFirstLetter: String {
        guard let first = self.first else { return self }
        return first.uppercased() + self.dropFirst()
    }
}

struct ExpandableText: View {
    let text: String
    let lineLimit: Int
    
    @State private var expanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(.init(text.replacingOccurrences(of: "\\n", with: "\n")))
                .font(.body)
                .multilineTextAlignment(.leading)
                .lineLimit(expanded ? nil : lineLimit) // <-- batasi jumlah baris
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)
            
            Button(action: {
                withAnimation {
                    expanded.toggle()
                }
            }) {
                Text(expanded ? "Lihat lebih sedikit ▲" : "Lihat selengkapnya ▼")
                    .font(.callout)
                    .foregroundColor(.blue)
            }
        }
    }
}
