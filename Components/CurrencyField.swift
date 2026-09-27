import SwiftUI

struct CurrencyField: View {

    @Binding var amount: Int

    var placeholder: String = "0"
    var fontSize: CGFloat = 40

    @State private var text = ""

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {

            Text("₹")
                .font(.system(
                    size: fontSize,
                    weight: .bold,
                    design: .rounded
                ))

            TextField(placeholder, text: $text)
                .keyboardType(.numberPad)
                .font(.system(
                    size: fontSize,
                    weight: .bold,
                    design: .rounded
                ))
                .onChange(of: text) { _, newValue in

                    let digits = newValue.filter { $0.isNumber }

                    guard !digits.isEmpty else {
                        text = ""
                        amount = 0
                        return
                    }

                    let value = Int(digits) ?? 0
                    amount = value

                    text = value.formatted(
                        .number.locale(
                            Locale(identifier: "en_IN")
                        )
                    )
                }
        }
        .onChange(of: amount) { _, newValue in

            let digits = text.filter { $0.isNumber }

            guard (Int(digits) ?? 0) != newValue else {
                return
            }

            text = newValue == 0
                ? ""
                : newValue.formatted(
                    .number.locale(
                        Locale(identifier: "en_IN")
                    )
                )
        }
    }
}

#Preview {
    CurrencyField(amount: .constant(2500))
        .padding()
}
