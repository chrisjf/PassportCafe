# Passport Café

This is a small sample project to test out **Automatic Grammatical Agreement** (gender/plurals) for localization on Apple's platforms.

I also wanted to test out some more in-depth localization techniques including using `LocalizedStringResource` with default values in the code for easy code readability/searchability, and generated symbols from the String Catalog.

## Solution

The key is the extended attribute Markdown syntax `^[…](inflect: true)` and `^[…](agreeWithConcept: 1)` in the Strings Catalog, and using an `AttributedString` with `InflectionConcept.localizedPhrase(…)` in code.

E.g. "1 large latte" becomes "2 large lattes" so the plural is automatically made in English.

E.g. The Strings Catalog has the Spanish translated strings "limonada" and "chico". So the full string "1 small lemonade" in English automatically becomes "1 limonada chica" in Spanish, which also automatically pluralizes to "2 limonadas chicas".

## Limitations

E.g. "2 medium flat whites" in English should become "2 flat whites medianos". Apple's automatic grammar agreement is not applied in this case and so results in the incorrect translation of "2 flat white mediano".

E.g. "2 small snow cones" in English should become "2 raspadillas chicas" but instead is incorrectly presented to the user as "2 raspadilla chica".

My unsubstantiated guess is that this error is likely because "raspadilla" is a regionalism (Perú) for shaved ice and thus Apple's system does not recognize this word. Thus the system does not know it should be feminine, and therefore it does not work for either gender agreement nor pluralization accordance.

I thought it might be possible to explicitly tell the grammar engine the word's gender, something like: `^[raspadilla](morphology: {partOfSpeech: 'noun', grammaticalGender: 'feminine'})` but unfortunately this does not fully work, even with extracting the morphology from the noun and setting an `InflectionRule` on the adjective with said morphology. The closest I can get with this approach is the grammatically incorrect "2 raspadilla chica", which is slightly better than "2 raspadilla chico" without the morphology workaround.

I spoke with a professional translator, and the suggested general approach to these limitations is to rephrase/paraphrase in the target language to avoid grammar errors.

## Sources

- [Unlock the power of grammatical agreement, WWDC 2023](https://developer.apple.com/videos/play/wwdc2023/10153/)
- [What's new in Foundation, WWDC 2021](https://developer.apple.com/videos/play/wwdc2021/10109/)
- [Automatic Grammar Agreement in Message Formatting, Unicode Technology Workshop 2023](https://www.youtube.com/watch?v=C2e7hYIkqoM)
