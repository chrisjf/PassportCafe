import SwiftUI

struct DrinkDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let drink: Drink
    var presentationStyle: PresentationStyle = .detailPane

    @State private var quantity: Int = 1
    @State private var selectedSize: DrinkSize = .medium
    @State private var isAdded = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PhotoView(drink: drink)
                TitlePriceView(drink: drink)
                Divider()
                sizeSelection
                QuantitySelectionView(quantity: $quantity)
                Divider()
                subtotalView
                Spacer()
                addToCartButton
            }
            .padding(24)
        }
        .toolbar {
            #if os(iOS)
            if presentationStyle == .sheet {
                ToolbarItem(placement: .navigation) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            #endif
        }
    }

    enum PresentationStyle {
        case detailPane
        case sheet
    }

    private var sizeSelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringResource("Menu.ItemDetail.SizeLabel", defaultValue: "Size"))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                ForEach(DrinkSize.allCases) { size in
                    Button(action: { selectedSize = size }) {
                        VStack(spacing: 4) {
                            Image(systemName: sizeIcon(for: size))
                                .font(.title3)
                            Text(size.localized(with: drink))
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .background(selectedSize == size ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.1))
                        .foregroundStyle(selectedSize == size ? Color.accentColor : Color.primary)
                        .clipShape(ContainerRelativeShape())
                        .overlay(
                            ContainerRelativeShape()
                                .strokeBorder(selectedSize == size ? Color.accentColor : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .containerShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var subtotalView: some View {
        HStack {
            Text(String(localized: "Menu.ItemDetail.PriceSubtotal", defaultValue: "Subtotal"))
                .font(.headline)
            Spacer()
            Text(drink.price * Decimal(quantity), format: .currency(code: "EUR"))
                .font(.title3)
                .fontWeight(.bold)
        }
    }

    private var addToCartButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                isAdded = true
            }
        }) {
            HStack(spacing: 8) {
                if isAdded {
                    Image(systemName: "checkmark.circle.fill")
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                } else {
                    let size = selectedSize.localized(with: drink)

                    // Solution 1: works
                    // Text("Add ^[\(quantity) \(size) \(drink.name)](inflect: true)")

                    // Solution 2: works
                    // Text(.menuButtonAddToCart(count: quantity, size: String(size.characters[...]), drink: String(localized: drink.name))) // characters[...] https://forums.swift.org/t/attributedstring-to-string/61667/2

                    // Solution 3: doesn't work, shows "Add ^[2 large latte](inflect: true)" on button
                    // let addToCart = String(localized: "Menu.ItemDetail.AddToCartButton", defaultValue: "Add ^[\(quantity) \(size) \(drink.name)](inflect: true)")
                    // Text(addToCart)

                    // Solution 4: works
                    // let addToCart = LocalizedStringResource("Menu.ItemDetail.AddToCartButton", defaultValue: "Add ^[\(quantity) \(size) \(drink.name)](inflect: true)")
                    // Text(addToCart)

                    // Solution 5: works
                    let addToCart = AttributedString(localized: "Menu.ItemDetail.AddToCartButton", defaultValue: "Add ^[\(quantity) \(size) \(drink.name)](inflect: true)")
                    Text(addToCart)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
        .tint(isAdded ? .green : .accentColor)
        .font(.headline.weight(.semibold))
        .disabled(isAdded)
        .task(id: isAdded) {
            guard isAdded else { return }
            try? await Task.sleep(for: .seconds(1.2))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.2)) {
                isAdded = false
            }
            if presentationStyle == .sheet {
                dismiss()
            }
        }
    }

    private func sizeIcon(for size: DrinkSize) -> String {
        switch size {
        case .small: return "cup.and.saucer"
        case .medium: return "cup.and.saucer.fill"
        case .large: return "mug.fill"
        }
    }
}

private struct PhotoView: View {
    let drink: Drink

    var body: some View {
        Image(drink.imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 220)
            .clipped()
            .clipShape(ContainerRelativeShape())
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            .overlay(
                ContainerRelativeShape()
                    .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
            )
            .containerShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct TitlePriceView: View {
    let drink: Drink

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(drink.title)
                .font(.title2)
                .fontWeight(.bold)

            Text(drink.price, format: .currency(code: "EUR"))
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}

private struct QuantitySelectionView: View {
    @Binding var quantity: Int

    var body: some View {
        HStack(spacing: 12) {
            Text(LocalizedStringResource("Menu.ItemDetail.Quantity", defaultValue: "Quantity"))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Spacer()

            Text(String(quantity))
                .font(.body)

            Stepper(value: $quantity, in: 1 ... 10) {
                EmptyView()
            }
            .labelsHidden()
        }
    }
}

#Preview {
    DrinkDetailView(drink: drinkMenu.first!)
}
