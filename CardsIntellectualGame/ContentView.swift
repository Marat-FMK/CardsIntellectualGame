//
//  ContentView.swift
//  CardsIntellectualGame
//
//  Created by Marat Fakhrizhanov on 06.12.2024.
//

import SwiftUI
extension View {
       func stacked(at position: Int, in total: Int) -> some View {
           let offset = Double(total - position)
           return self.offset(y: offset * 10)
       }
   }

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    @State private var cards = Array<Card>(repeating: .example, count: 10)
    
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Environment(\.scenePhase) var scenePhase
    @State private var isActive = true
    
        var body: some View {
            ZStack {
                Image(decorative: "background") // Делаем  картинку нечитаемой в VoiceOver
                    .resizable()
                    .ignoresSafeArea()
                VStack {
                    Text("Time: \(timeRemaining)")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(.black.opacity(0.75))
                        .clipShape(.capsule)
                    ZStack {
                        ForEach(0..<cards.count, id: \.self) { index in
                            CardView(card: cards[index]) {
                                withAnimation {
                                    removeCard(at: index)
                                }
                            }
                            .allowsHitTesting(index == cards.count - 1) // Что бы при свайпе реагировала только верхняя карточка
                            .accessibilityHidden(index < cards.count - 1) // Читает Voice только верхнюю карточку
                            .stacked(at: index, in: cards.count) // работает с оффсетами стопки карточек
                            
                        }
                    }
                    .allowsHitTesting(timeRemaining > 0)
                    
                    if cards.isEmpty {
                        Button("Start Again", action: resetCards)
                            .padding()
                            .background(.white)
                            .foregroundStyle(.black)
                            .clipShape(.capsule)
                    }
                    
                }
                if accessibilityDifferentiateWithoutColor {
                    VStack {
                        Spacer()

                        HStack {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                            Spacer()
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                        }
                        .foregroundStyle(.white)
                        .font(.largeTitle)
                        .padding()
                    }
                }
            }
            .onReceive(timer) { time in
                
                guard isActive else { return } // Если фолс - тогда выйди из ф- ии и не вычитай таймер
                
                if timeRemaining > 0 {
                    timeRemaining -= 1
                }
            }
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    if cards.isEmpty == false { // Если не фоновый режим и массив не пустой - то таймер активен и отнимает по одной секунде от времени
                        isActive = true
                    }
                } else {
                    isActive = false // иначе ничего не отнимает
                }
            }
        }
    
 func removeCard(at index: Int) {
        cards.remove(at: index)
     
     if cards.isEmpty {
         isActive = false // не сможем больше отнять секунды таймера
     }
    }
    
 func resetCards() {
        cards = Array<Card>(repeating: .example, count: 10)
        timeRemaining = 100
        isActive = true
    }
}

#Preview {
    ContentView()
}
