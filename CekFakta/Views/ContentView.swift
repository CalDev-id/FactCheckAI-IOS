import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject var auth: AuthManager
    @EnvironmentObject var profile: ProfileManager

    var body: some View {
        TabView(selection: Binding(
            get: { router.selectedTab.rawValue },
            set: { router.selectedTab = Router.Tab(rawValue: $0) ?? .home }
        )) {
            HomeScreen()
                .tag(Router.Tab.home.rawValue)
                .tabItem { Image(systemName: "house"); Text("Home") }

            PredictView()
                .tag(Router.Tab.check.rawValue)
                .tabItem { Image(systemName: "magnifyingglass"); Text("Check") }

//            ChatView()
//                .tag(Router.Tab.chat.rawValue)
//                .tabItem { Image(systemName: "message"); Text("Chat") }

            ProfileView()
                .tag(Router.Tab.profile.rawValue)
                .tabItem { Image(systemName: "person.fill"); Text("Profile") }
        }
        .background(.black)
        .accentColor(.red)
        .task { profile.fetchMyNewsIfNeeded(force: false, isAdmin: auth.isAdmin) }
    }
}


#Preview {
    ContentView()
}
