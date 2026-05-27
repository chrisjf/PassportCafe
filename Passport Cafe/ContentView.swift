import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var selectedDrink: Drink?
    @State private var selectedTab: NavigationTab? = .menu

    var body: some View {
        #if os(macOS)
        splitLayout
        #else
        if horizontalSizeClass == .compact {
            tabLayout
        } else {
            splitLayout
        }
        #endif
    }

    private var tabLayout: some View {
        TabView(selection: $selectedTab) {
            MenuView(selectedDrink: $selectedDrink)
                .tabItem {
                    Label(NavigationTab.menu.title, systemImage: NavigationTab.menu.systemImage)
                }
                .tag(NavigationTab.menu as NavigationTab?)

            ProfileView()
                .tabItem {
                    Label(NavigationTab.profile.title, systemImage: NavigationTab.profile.systemImage)
                }
                .tag(NavigationTab.profile as NavigationTab?)
        }
        .sheet(item: $selectedDrink) { drink in
            NavigationStack {
                DrinkDetailView(drink: drink, presentationStyle: .sheet)
            }
        }
    }

    private var splitLayout: some View {
        NavigationSplitView {
            List(NavigationTab.allCases, id: \.self, selection: $selectedTab) { tab in
                Label(tab.title, systemImage: tab.systemImage)
                    .tag(tab)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 150, ideal: 180, max: 220)
        } content: {
            if selectedTab == .menu {
                MenuView(selectedDrink: $selectedDrink)
                    .navigationSplitViewColumnWidth(min: 160, ideal: 400, max: 500)
            } else {
                #if os(macOS)
                Color.clear
                    .navigationSplitViewColumnWidth(0)
                #else
                EmptyView()
                #endif
            }
        } detail: {
            switch selectedTab {
            case .menu:
                if let selectedDrink {
                    DrinkDetailView(drink: selectedDrink)
                } else {
                    ContentUnavailableView(
                        String(localized: "Menu.ItemDetail.NoDrinkSelectedTitle", defaultValue: "Coffee time?"),
                        systemImage: "cup.and.saucer",
                        description: Text(LocalizedStringResource("Menu.ItemDetail.NoDrinkSelectedDescription", defaultValue: "Select a drink from the menu"))
                    )
                }
            case .profile:
                ProfileView()
            case nil:
                ContentUnavailableView(
                    String(localized: "App.Tab.NoSelectionTitle", defaultValue: "No Selection"),
                    systemImage: "cup.and.saucer",
                    description: Text(LocalizedStringResource("App.Tab.NoSelectionDescription", defaultValue: "Select a category from the sidebar"))
                )
            }
        }
    }
}

enum NavigationTab: Hashable, CaseIterable {
    case menu
    case profile

    var title: String {
        switch self {
        case .menu:
            return String(localized: "App.Tab.Menu", defaultValue: "Menu")
        case .profile:
            return String(localized: "App.Tab.Profile", defaultValue: "Profile")
        }
    }

    var systemImage: String {
        switch self {
        case .menu:
            return "cup.and.saucer.fill"
        case .profile:
            return "person.fill"
        }
    }
}

#Preview {
    ContentView()
}
