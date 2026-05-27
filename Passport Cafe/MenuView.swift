import SwiftUI

struct MenuView: View {
    @Binding var selectedDrink: Drink?

    private let columns = [GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 16)]

    init(selectedDrink: Binding<Drink?> = .constant(nil)) {
        self._selectedDrink = selectedDrink
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(drinkMenu) { drink in
                        DrinkCardView(drink: drink) {
                            selectedDrink = drink
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(String(localized: "Menu.Header.Title", defaultValue: "Menu"))
        }
    }
}

struct DrinkCardView: View {
    let drink: Drink
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(drink.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
                    .clipShape(ContainerRelativeShape())

                Text(drink.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(12)
            .aspectRatio(0.75, contentMode: .fill)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.secondary.opacity(isHovered ? 0.15 : 0.1))
            .clipShape(ContainerRelativeShape())
            .containerShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .onHover { hovering in
                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                    isHovered = hovering
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MenuView()
}
