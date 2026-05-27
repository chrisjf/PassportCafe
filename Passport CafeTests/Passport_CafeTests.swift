import Foundation
@testable import Passport_Cafe
import Testing

@Suite(.serialized)
@MainActor
struct Passport_CafeTests {

    // MARK: - String Catalog

    @Test func feminineNounSpecifiedInStringCatalogMarkdown() async throws {
        let drink = try #require(drinkMenu.last)
        let selectedSize = DrinkSize.small
        let locale = Locale(identifier: "es")
        let key = String.LocalizationValue(drink.name.key)
        let drinkName = AttributedString(localized: key, locale: locale)
        let size = selectedSize.localized(with: drink, locale: locale)

        let result = AttributedString(localized: "Profile.ItemDetail.SizeAndDrink", defaultValue: "\(size) \(drinkName)", locale: locale)

        let resultString = String(result.characters)
        #expect(resultString == "raspadilla chica", "testStringCatalogMarkdownMorphology: Got '\(resultString)'")
    }

    @Test func feminineNounSpecifiedInStringCatalogAndInflectWithMorphology() async throws {
        let drink = try #require(drinkMenu.last)
        let locale = Locale(identifier: "es")
        let key = String.LocalizationValue(drink.name.key)
        let drinkName = AttributedString(localized: key, locale: locale)

        let morphology = try #require(drinkName.morphology, "Expected drinkName to contain morphology metadata")
        #expect(morphology.grammaticalGender == .feminine, "Expected feminine morphology for raspadilla")
        var size = AttributedString(localized: "Menu.ItemDetail.SizeSmall", locale: locale)
        size.inflect = InflectionRule(morphology: morphology)

        let resultSize = size.inflected()
        #expect(String(resultSize.characters) == "chica", "Expected inflected size to be 'chica'")

        let resultString = AttributedString(localized: "Profile.ItemDetail.SizeAndDrink", defaultValue: "\(resultSize) \(drinkName)", locale: locale)
        #expect(String(resultString.characters) == "raspadilla chica", "Expected combined result to be 'raspadilla chica'")
    }

    // MARK: - Agree With Concept

    /// The LLM said: Empirically, the programmatic `size.agreementConcept = N` setter does NOT hook into the concept-resolution pass during `.inflected()` — only the markdown `^[chico](agreeWithConcept: N)` form does. So for a known-by-the-system feminine noun like "horchata", use the markdown attribute — the engine then looks up the `.localizedPhrase` concept against its built-in dictionary.
    @Test func knownFeminineNounExplicitlyInCode() async throws {
        let locale = Locale(identifier: "es")
        let drink = AttributedString(localized: "TestMenu.ItemDetail.HorchataName", defaultValue: "horchata", locale: locale)

        let name = String(drink.characters)
        var options = AttributedString.LocalizationOptions()
        options.concepts = [.localizedPhrase(name)]

        var size = AttributedString(localized: "TestMenu.ItemDetail.SizeSmall", defaultValue: "chico", options: options, locale: locale)
        size.agreementConcept = 0 // doesn't work
        let selectedSize = size.inflected()

        let result = AttributedString(localized: "TestMenu.ItemDetail.SizeAndDrink", defaultValue: "\(drink) \(selectedSize)", locale: locale)

        let resultString = String(result.characters)
        withKnownIssue("Apparently `.agreementConcept = 0` in code won't work") {
            #expect(resultString == "horchata chica", "Expected 'horchata chica', but got '\(resultString)'")
        }
    }

    @Test func knownFeminineNounExplicitlyInMarkdown() async throws {
        let locale = Locale(identifier: "es")
        let drink = AttributedString(localized: "TestMenu.ItemDetail.HorchataName", defaultValue: "horchata", locale: locale)

        let name = String(drink.characters)
        var options = AttributedString.LocalizationOptions()
        options.concepts = [.localizedPhrase(name)]

        let size = AttributedString(localized: "TestMenu.ItemDetail.SizeSmall", defaultValue: "^[chico](agreeWithConcept: 1)", options: options, locale: locale).inflected()

        let result = AttributedString(localized: "TestMenu.ItemDetail.SizeAndDrink", defaultValue: "\(drink) \(size)", locale: locale)

        let resultString = String(result.characters)
        #expect(resultString == "horchata chica", "Expected 'horchata chica', but got '\(resultString)'")
    }

    /// The Automatic Grammar Agreement engine does not know that "malteada" should be feminine, so let's explicitly set it
    @Test func unknownFeminineNounExplicitlyInCode() async throws {
        let locale = Locale(identifier: "es")

        var drink = AttributedString(localized: "TestMenu.ItemDetail.MilkshakeName", defaultValue: "malteada", locale: locale)
        var morphologyNoun = Morphology()
        morphologyNoun.partOfSpeech = .noun
        morphologyNoun.grammaticalGender = .feminine
        drink.morphology = morphologyNoun

        let name = String(drink.characters)
        var options = AttributedString.LocalizationOptions()
        options.concepts = [.localizedPhrase(name)]

        var size = AttributedString(localized: "TestMenu.ItemDetail.SizeSmall", defaultValue: "chico", options: options, locale: locale)
//        size.agreementConcept = 0 // The LLM said: The code that sets `size.agreementConcept = 0` "works" only because the next line, `size.inflect = InflectionRule(morphology:)`, does the real inflection; the agreementConcept line is dead in that path.
        if let morphology = drink.morphology {
            size.inflect = InflectionRule(morphology: morphology)
            size = size.inflected()
        }

        let result = AttributedString(localized: "TestMenu.ItemDetail.SizeAndDrink", defaultValue: "\(drink) \(size)", locale: locale)

        let resultString = String(result.characters)
        #expect(resultString == "malteada chica", "Expected 'malteada chica', but got '\(resultString)'")
    }

    /// The Automatic Grammar Agreement engine does not know that "malteada" should be feminine, so let's explicitly set it with the Markdown attribute syntax
    @Test func unknownFeminineNounExplicitlyInMarkdown() async throws {
        let locale = Locale(identifier: "es")

        let drink = AttributedString(localized: "TestMenu.ItemDetail.MilkshakeName", defaultValue: "^[malteada](morphology: { partOfSpeech: 'noun', grammaticalGender: 'feminine' })", locale: locale)

        let name = String(drink.characters)
        var options = AttributedString.LocalizationOptions()
        options.concepts = [.localizedPhrase(name)]

        var size = AttributedString(localized: "TestMenu.ItemDetail.SizeSmall", defaultValue: "^[chico](agreeWithConcept: 1)", options: options, locale: locale)

        if let morphology = drink.morphology {
            size.inflect = InflectionRule(morphology: morphology)
            size = size.inflected()
        }

        let result = AttributedString(localized: "TestMenu.ItemDetail.SizeAndDrink", defaultValue: "\(drink) \(size)", locale: locale)

        let resultString = String(result.characters)
        #expect(resultString == "malteada chica", "Expected 'malteada chica', but got '\(resultString)'")
    }

    @Test func knownFeminineNounSingularAndPlural() async throws {
        let locale = Locale(identifier: "es")
        let drink = LocalizedStringResource("TestMenu.ItemDetail.LemonadeName", defaultValue: "limonada", locale: locale)

        let name = String(localized: drink)
        var options = AttributedString.LocalizationOptions()
        options.concepts = [.localizedPhrase(name)]

        let size = AttributedString(localized: "TestMenu.ItemDetail.SizeSmall", defaultValue: "^[chico](agreeWithConcept: 1)", options: options, locale: locale)

        for count in [1, 3] {
            let result = AttributedString(localized: "TestMenu.ItemDetail.AddToCartButton", defaultValue: "Agregar ^[\(count) \(drink) \(size)](inflect: true)", options: options, locale: locale)

            let resultString = String(result.inflected().characters)
            if count == 1 {
                #expect(resultString == "Agregar 1 limonada chica")
            }
            if count == 3 {
                #expect(resultString == "Agregar 3 limonadas chicas")
            }
        }
    }

    /// Sadly I believe the following is not possible with the current Automatic Grammar Agreement system.
    /// Setup: one noun string, which the system doesn't know it's gender or plural, but we can specify it's gender and plural (in code or with Markdown attribute syntax)…
    /// Desired Result: so the string can be inflected correctly for both singular and plural with the proper gender
    @Test func unknownFeminineNounSingularAndPlural() async throws {
        _ = LocalizedStringResource("TestMenu.ItemDetail.MilkshakeName", defaultValue: "malteada", locale: Locale(identifier: "es"))

//         …

//        if count == 1 {
//            #expect(resolvedString == "Agregar 1 malteada chica")
//        }
//        if count == 3 {
//            #expect(resolvedString == "Agregar 3 malteadas chicas")
//        }
    }

    // MARK: - Agree With Agreement

    /// A simple test to test out agreeWithArgument which wasn't used in the production app code
    @Test func agreeWithArgumentKnownNoun() async throws {
        let drink = AttributedString(localized: "TestMenu.ItemDetail.LemonadeName", defaultValue: "limonada")
        let ingredient = String(localized: "TestMenu.ItemDetail.IngredientLemon", defaultValue: "limón fresco")

        let localizedString = AttributedString(
            localized: "TestMenu.ItemDetail.IngredientsDescription",
            defaultValue: "^[Nuestro \(drink)](inflect: true) está ^[hecho](agreeWithArgument: 1) con \(ingredient).",
            locale: Locale(identifier: "es")
        )
        let inflected = localizedString.inflected()

        let result = String(inflected.characters)
        print("🔎 Result: \(result)")
        #expect(result == "Nuestra limonada está hecha con limón fresco.")
    }

    /// The LLM said: Group `^[… \(drink)](inflect: true)` only inflects siblings (e.g. "Nuestro") when the engine can look up the noun in its built-in dictionary — which works for "limonada" but fails for an unfamiliar word like "malteada", even when `.morphology` is set explicitly on the argument. The fix is to reference the argument directly with `agreeWithArgument: 1`, which reads morphology off the interpolated `AttributedString` and works for unknown nouns.
    @Test func agreeWithArgumentUnknownFeminineNounInCode() async throws {
        var drink = AttributedString(localized: "TestMenu.ItemDetail.MilkshakeName", defaultValue: "malteada")
        var morphology = Morphology()
        morphology.partOfSpeech = .noun
        morphology.grammaticalGender = .feminine
        drink.morphology = morphology

        let ingredient = String(localized: "TestMenu.ItemDetail.IngredientMalt", defaultValue: "malta auténtica")

        let localizedString = AttributedString(
            localized: "TestMenu.ItemDetail.IngredientsDescription",
            defaultValue: "^[Nuestro](agreeWithArgument: 1) \(drink) está ^[hecho](agreeWithArgument: 1) con \(ingredient).",
            locale: Locale(identifier: "es")
        )

        let result = String(localizedString.inflected().characters)
        #expect(result == "Nuestra malteada está hecha con malta auténtica.")
    }

    @Test func agreeWithArgumentUnknownFeminineNounInMarkdown() async throws {
        let drink = AttributedString(localized: "TestMenu.ItemDetail.MilkshakeName", defaultValue: "^[malteada](morphology: { partOfSpeech: 'noun', grammaticalGender: 'feminine' })")
        let ingredient = String(localized: "TestMenu.ItemDetail.IngredientMalt", defaultValue: "malta auténtica")

        let localizedString = AttributedString(
            localized: "TestMenu.ItemDetail.IngredientsDescription",
            defaultValue: "^[Nuestro](agreeWithArgument: 1) \(drink) está ^[hecho](agreeWithArgument: 1) con \(ingredient).",
            locale: Locale(identifier: "es")
        )

        let result = String(localizedString.inflected().characters)
        #expect(result == "Nuestra malteada está hecha con malta auténtica.")
    }

    /// Testing without `^[…(inflect: true)` for the regular known noun case
    @Test func agreeWithArgumentKnownNounWithoutInflectTrue() async throws {
        let drink = AttributedString(localized: "TestMenu.ItemDetail.LemonadeName", defaultValue: "limonada")
        let ingredient = String(localized: "TestMenu.ItemDetail.IngredientLemon", defaultValue: "limón fresco")

        let localizedString = AttributedString(
            localized: "TestMenu.ItemDetail.IngredientsDescription",
            defaultValue: "^[Nuestro](agreeWithArgument: 1) \(drink) está ^[hecho](agreeWithArgument: 1) con \(ingredient).",
            locale: Locale(identifier: "es")
        )
        let inflected = localizedString.inflected()

        let result = String(inflected.characters)
        #expect(result == "Nuestra limonada está hecha con limón fresco.")
    }

    // MARK: - Term of Address

    @Test func termOfAddressSheFavouritedCappuccino() async throws {
        let usersPreferredTermOfAddress: TermOfAddress = .feminine

        var options = AttributedString.LocalizationOptions()
        options.concepts = [.termsOfAddress([usersPreferredTermOfAddress])]

        let localizedString = AttributedString(
            localized: "^[Él](referentConcept: 1) marcó cappuccino como favorito.",
            options: options,
            locale: Locale(identifier: "es_ES")
        )

        let result = String(localizedString.characters)
        #expect(result == "Ella marcó cappuccino como favorito.", "Got '\(result)'")
    }
}

private extension DrinkSize {
    func localized(with drink: Drink, bundle: Bundle = .main, locale: Locale? = nil) -> AttributedString {
        // let name = String(localized: drink.name) // normally this would do, but the unit tests have custom bundle/locales, so the LocalizationValue workaround is needed:
        let key = String.LocalizationValue(drink.name.key)
        let name = String(localized: key, bundle: bundle, locale: locale ?? .current)

        var options = AttributedString.LocalizationOptions()
        options.concepts = [.localizedPhrase(name)]

        var size: AttributedString
        switch self {
        case .small:
            size = AttributedString(localized: "Menu.ItemDetail.SizeSmall", defaultValue: "small", options: options, bundle: bundle, locale: locale)
        case .medium:
            size = AttributedString(localized: "Menu.ItemDetail.SizeMedium", defaultValue: "medium", options: options, bundle: bundle, locale: locale)
        case .large:
            size = AttributedString(localized: "Menu.ItemDetail.SizeLarge", defaultValue: "large", options: options, bundle: bundle, locale: locale)
        }

        let drinkName = AttributedString(localized: key, bundle: bundle, locale: locale)
        if let morphology = drinkName.morphology {
            size.inflect = InflectionRule(morphology: morphology)
            return size.inflected()
        }
        return size
    }
}
