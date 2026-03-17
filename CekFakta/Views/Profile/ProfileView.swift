import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var auth: AuthManager
    @EnvironmentObject private var vm: ProfileManager
    @EnvironmentObject private var router: Router
    @State private var showEditProfile = false
    @State private var showDeleteConfirm = false
    @State private var pendingDelete: News? = nil


    var body: some View {
        List {
            HStack {
                Spacer()
                
                Button(role: .destructive) {
                    auth.logout()
                    vm.resetCache()
                } label: {
                    Text("Logout")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            .contentShape(Rectangle())
            .listRowSeparator(.hidden)
            

            if let avatar = auth.avatarURL, let url = URL(string: avatar) {
                HStack {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())

                    VStack(alignment: .leading) {
                        HStack {
                            Text(auth.userName ?? "No Name")
                                .font(.title3)
                                .bold()
                            Image(systemName: "pencil.line")
                                .bold()
                                .font(.system(size: 17))
                        }

                        Text(auth.userEmail ?? "-")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    showEditProfile = true
                }
                .listRowSeparator(.hidden)

            } else {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading) {
                        HStack {
                            Text(auth.userName ?? "No Name")
                                .font(.title3)
                                .bold()
                            Image(systemName: "pencil.line")
                                .bold()
                                .font(.system(size: 17))
                        }

                        Text(auth.userEmail ?? "-")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    showEditProfile = true
                }
                .listRowSeparator(.hidden)
            }



            Divider()
                .listRowSeparator(.hidden)

            VStack(alignment: .leading,) {
                Text("My Posts")
                    .font(.headline)
                    .multilineTextAlignment(.leading)

                if let err = vm.errorMessage {
                    Text(err)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if vm.news.isEmpty {
                    Text("No posts yet")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .listRowSeparator(.hidden)

            if !vm.isLoading && !vm.news.isEmpty {
                ForEach(vm.news, id: \.id) { item in
                    if let id = item.id {
                        NewsRow(news: item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                router.navigate(to: .detailNews(id: id))
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    pendingDelete = item
                                    showDeleteConfirm = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red) // tampil merah tapi tanpa destructive behavior bawaan
                            }



                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            vm.refreshMyNews(force: true)
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
                .environmentObject(auth)
                .environmentObject(vm)
        }
        .confirmationDialog(
            "Delete this post?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let item = pendingDelete {
                    vm.deleteNews(item)     // ✅ delete di sini saja
                }
                pendingDelete = nil
            }
            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
        } message: {
            Text("This action can’t be undone.")
        }


    }
}
