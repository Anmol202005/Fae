import SwiftUI

struct SwipeButton: View {
    let title: String
    let action: () -> Void

    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let buttonWidth = geometry.size.width
            let handleWidth: CGFloat = 58
            let horizontalPadding: CGFloat = 5
            let maxOffset = buttonWidth - handleWidth - (horizontalPadding * 2)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.blue)

                RoundedRectangle(cornerRadius: 30)
                    .fill(.white.opacity(0.15))
                    .frame(width: offset + handleWidth + horizontalPadding)

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)

                HStack(spacing: 0) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.blue)
                }
                .frame(width: handleWidth, height: 50)
                .background(.white)
                .clipShape(Capsule())
                .offset(x: offset + horizontalPadding)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = min(
                                max(0, value.translation.width),
                                maxOffset
                            )
                        }
                        .onEnded { _ in
                            if offset >= maxOffset * 0.8 {
                                withAnimation(.spring(response: 0.25)) {
                                    offset = maxOffset
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    action()

                                    withAnimation(.spring) {
                                        offset = 0
                                    }
                                }
                            } else {
                                withAnimation(.spring) {
                                    offset = 0
                                }
                            }
                        }
                )
            }
        }
        .frame(height: 60)
    }
}

#Preview {
    SwipeButton(title: "Swipe to add expense") {
        print("Added")
    }
    .padding()
}
