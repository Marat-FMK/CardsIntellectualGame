//
//  CardsView.swift
//  CardsIntellectualGame
//
//  Created by Marat Fakhrizhanov on 06.12.2024.
//

import SwiftUI
import Foundation


struct CardView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    
    let card: Card
    @State private var isShowingAnswer = false
    @State private var offset = CGSize.zero
    var removal: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    accessibilityDifferentiateWithoutColor
                        ? .white
                        : .white
                            .opacity(1 - Double(abs(offset.width / 50)))

                )
                .background(
                    accessibilityDifferentiateWithoutColor
                        ? nil
                        : RoundedRectangle(cornerRadius: 25)
                            .fill(offset.width > 0 ? .green : .red)
                )
                .shadow(radius: 10)

            VStack {
                Text(card.prompt)
                    .font(.largeTitle)
                    .foregroundStyle(.black)

                if isShowingAnswer {
                    Text(card.answer)
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
            .multilineTextAlignment(.center) // ПР17 8/13 Обьясняют оффсеты и сдвиги карточки в стопке
        }
        .frame(width: 450, height: 250)
        .rotationEffect(.degrees(offset.width / 5.0)) // меняем угол в зависимости от длинны жеста
        .offset(x: offset.width * 5) // увеличиваем пройденное расстояние , что бы жест был короткий а карточка прошла большое расстояние
        .opacity(2 - Double(abs(offset.width / 50))) // повышаем прозрачность по мере удаления
        // И нам не важно в какую сторону сдивнется в (право - полодительный оффсет) или (влево - отрицательный оффсет будет ) Определяем по оффсету
        // Ставит 2 - что бы оффсет не сразу менял значение опасити , а тоько через определенное расстояние  и картока будет вплоть до 1 оставаться непрозрачной
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if abs(offset.width) > 100 {
                        removal?()
                    } else {
                        offset = .zero
                    }
                }
        )
        .onTapGesture {
            isShowingAnswer.toggle()
        }
    }
}

#Preview {
    CardView(card: .example)
}