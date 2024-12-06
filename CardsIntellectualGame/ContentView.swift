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
    
    @State private var cards = [Card]()
    
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Environment(\.scenePhase) var scenePhase
    @State private var isActive = true
    
    @State private var showingEditScreen = false
    
        var body: some View {
            ZStack {
                Image(decorative: "background") // Делаем  картинку нечитаемой в VoiceOver
                    .resizable()
                    .ignoresSafeArea()
                VStack {
                    Text("Time: \(timeRemaining)") // показывает таймер
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
                                    removeCard(at: index) // удаляем карточки с аимацией
                                }
                            }
                            .allowsHitTesting(index == cards.count - 1) // Что бы при свайпе реагировала только верхняя карточка
                            .accessibilityHidden(index < cards.count - 1) // Читает Voice только верхнюю карточку
                            .stacked(at: index, in: cards.count) // работает с оффсетами стопки карточек
                            
                        }
                    }
                    .allowsHitTesting(timeRemaining > 0) // Отключать свайпы по карточкам если их нет
                    
                    if cards.isEmpty {
                        Button("Start Again", action: resetCards)
                            .padding()
                            .background(.white)
                            .foregroundStyle(.black)
                            .clipShape(.capsule)
                    }
                    
                }
                
                
                VStack {
                    HStack {
                        Spacer()

                        Button {
                            showingEditScreen = true // Рисуем кнопку добавления нового вопроса, которая перекинет нас на другой экран 
                        } label: {
                            Image(systemName: "plus.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                        }
                    }

                    Spacer()
                }
                .foregroundStyle(.white)
                .font(.largeTitle)
                .padding()
                
                
                if accessibilityDifferentiateWithoutColor || accessibilityVoiceOverEnabled {
                    VStack {
                        Spacer()

                        HStack {
                            Button {
                                withAnimation {
                                    removeCard(at: cards.count - 1)
                                }
                            } label: {
                                Image(systemName: "xmark.circle")
                                    .padding()
                                    .background(.black.opacity(0.7))
                                    .clipShape(.circle)
                            }
                            .accessibilityLabel("Wrong") // Прочитать как Вронг при Войс овере
                            .accessibilityHint("Mark your answer as being incorrect.")

                            Spacer()

                            Button {
                                withAnimation {
                                    removeCard(at: cards.count - 1)
                                }
                            } label: {
                                Image(systemName: "checkmark.circle")
                                    .padding()
                                    .background(.black.opacity(0.7))
                                    .clipShape(.circle)
                            }
                            .accessibilityLabel("Correct") // Прочитать как ответ правильный Коррект при Войс овере
                            .accessibilityHint("Mark your answer as being correct.")
                        }
                        .foregroundStyle(.white)
                        .font(.largeTitle)
                        .padding()
                    }
                }
            }
            
            .onReceive(timer) { time in // включить таймер
                
                guard isActive else { return } // Если фолс - тогда выйди из ф- ии и не вычитай таймер
                
                if timeRemaining > 0 { // отнимать от начального времени секунду каждую секунду )
                    timeRemaining -= 1
                }
            }
            .onChange(of: scenePhase) {// что делать если ушли в бекграунд - остановить таймер
                if scenePhase == .active {
                    if cards.isEmpty == false { // Если не фоновый режим и массив не пустой - то таймер активен и отнимает по одной секунде от времени
                        isActive = true
                    }
                } else {
                    isActive = false // иначе ничего не отнимает
                }
            }
            .sheet(isPresented: $showingEditScreen, onDismiss: resetCards, content: EditCards.init)
            .onAppear(perform: resetCards)
        }
    
 func removeCard(at index: Int) { // удаляем по индексу карточку - индекс беерем в фор ич переборе
     
     guard index >= 0 else { return }
     
        cards.remove(at: index)
     
     if cards.isEmpty {
         isActive = false // не сможем больше отнять секунды таймера если пустой массив карточек
     }
    }
    
// func resetCards() { // обновляем игру и устанавливаем значения в начальное состояние и запускам таймер
//        cards = Array<Card>(repeating: .example, count: 10)
//        timeRemaining = 100
//        isActive = true
//    }
    
    func resetCards() { // обновляем игру и устанавливаем значения в начальное состояние и запускам таймер
        timeRemaining = 100
        isActive = true
        loadData() // обновлять всегда
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded
            }
        }
    }
    
}

#Preview {
    ContentView()
}
