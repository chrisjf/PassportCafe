import SwiftUI

struct ProfileView: View {
    @State private var name: String = ""
    @State private var email: String = ""

    private let nameLabel = LocalizedStringResource("Profile.TextField.Name", defaultValue: "Name")
    private let emailLabel = LocalizedStringResource("Profile.TextField.Email", defaultValue: "Email")
    private let favoriteDrinkLabel = LocalizedStringResource("Profile.TextField.FavoriteDrink", defaultValue: "Favorite Drink")

    private let drink: Drink = drinkMenu.last!
    private let selectedSize: DrinkSize = .small

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(nameLabel, text: $name)
                    TextField(emailLabel, text: $email)
                    HStack {
                        Text(favoriteDrinkLabel)
                        Spacer()
                        let sizeAndDrink = AttributedString(localized: "Profile.ItemDetail.SizeAndDrink", defaultValue: "^[\(selectedSize.localized(with: drink)) \(AttributedString(localized: drink.name))](inflect: true)")
                        Text(sizeAndDrink)
                    }
                }
            }
            .navigationTitle(String(localized: "Profile.Header.Title", defaultValue: "Profile"))
            #if os(macOS)
            .formStyle(.grouped)
            #endif
            .frame(maxWidth: 600)
        }
    }
}

#Preview {
    ProfileView()
}
