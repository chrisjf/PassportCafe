import Foundation

struct Drink: Identifiable {
    let id = UUID()
    let title: LocalizedStringResource
    let name: LocalizedStringResource
    let imageName: String
    let price: Decimal
}

enum DrinkSize: CaseIterable, Identifiable {
    case small, medium, large

    var id: Self {
        self
    }

    func localized(with drink: Drink) -> AttributedString {
        let name = String(localized: drink.name)
        var options = AttributedString.LocalizationOptions()
        options.concepts = [.localizedPhrase(name)]

        var size: AttributedString
        switch self {
        case .small:
            size = AttributedString(localized: "Menu.ItemDetail.SizeSmall", defaultValue: "small", options: options)
        case .medium:
            size = AttributedString(localized: "Menu.ItemDetail.SizeMedium", defaultValue: "medium", options: options)
        case .large:
            size = AttributedString(localized: "Menu.ItemDetail.SizeLarge", defaultValue: "large", options: options)
        }

        let drinkName = AttributedString(localized: drink.name)
        if let morphology = drinkName.morphology {
            size.inflect = InflectionRule(morphology: morphology)
            return size.inflected()
        }
        return size
    }
}

let drinkMenu: [Drink] = [
    Drink(title: LocalizedStringResource("Menu.ItemDetail.LemonadeTitle", defaultValue: "Lemonade"),
          name: LocalizedStringResource("Menu.ItemDetail.LemonadeName", defaultValue: "lemonade"),
          imageName: "Brasilianische_Limonade",
          price: 2.75),
    Drink(title: LocalizedStringResource("Menu.ItemDetail.LatteTitle", defaultValue: "Latte"),
          name: LocalizedStringResource("Menu.ItemDetail.LatteName", defaultValue: "latte"),
          imageName: "Latte_art",
          price: 4.50),
    Drink(title: LocalizedStringResource("Menu.ItemDetail.CappuccinoTitle", defaultValue: "Cappuccino"),
          name: LocalizedStringResource("Menu.ItemDetail.CappuccinoName", defaultValue: "cappuccino"),
          imageName: "Cappuccino",
          price: 4.50),
    Drink(title: LocalizedStringResource("Menu.ItemDetail.MochaTitle", defaultValue: "Mocha"),
          name: LocalizedStringResource("Menu.ItemDetail.Mocha.Name", defaultValue: "mocha"),
          imageName: "Mocha_Coffee",
          price: 5.00),
    Drink(title: LocalizedStringResource("Menu.ItemDetail.FlatWhiteTitle", defaultValue: "Flat White"),
          name: LocalizedStringResource("Menu.ItemDetail.FlatWhiteName", defaultValue: "flat white"),
          imageName: "Flat_White",
          price: 4.75),
    Drink(title: LocalizedStringResource("Menu.ItemDetail.MilkshakeTitle", defaultValue: "Coffee Milkshake"),
          name: LocalizedStringResource("Menu.ItemDetail.MilkshakeName", defaultValue: "milkshake"),
          imageName: "Shake",
          price: 6.50),
    Drink(title: LocalizedStringResource("Menu.ItemDetail.AmericanoTitle", defaultValue: "Americano"),
          name: LocalizedStringResource("Menu.ItemDetail.AmericanoName", defaultValue: "americano"),
          imageName: "Americano",
          price: 3.50),
    Drink(title: LocalizedStringResource("Menu.ItemDetail.CortadoTitle", defaultValue: "Cortado"),
          name: LocalizedStringResource("Menu.ItemDetail.CortadoName", defaultValue: "cortado"),
          imageName: "Café_cortado",
          price: 4.00),
    Drink(title: LocalizedStringResource("Menu.ItemDetail.HorchataTitle", defaultValue: "Rice Horchata"),
          name: LocalizedStringResource("Menu.ItemDetail.HorchataName", defaultValue: "horchata"),
          imageName: "Horchata_de_arroz",
          price: 2.75),
    Drink(title: LocalizedStringResource("Menu.ItemDetail.ShavedIceTitle", defaultValue: "Snow Cone"),
          name: LocalizedStringResource("Menu.ItemDetail.ShavedIceName", defaultValue: "snow cone"),
          imageName: "Shave_Ice_Surprise",
          price: 5.75)
]
