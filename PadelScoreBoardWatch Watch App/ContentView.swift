//
//  ContentView.swift
//  PadelScoreBoardWatch Watch App
//
//  Created by Teodor Ivanov on 4.04.26.
//

import SwiftUI
import Sharing

extension SharedKey where Self == FileStorageKey<Play?> {
    static var currentPlay: Self {
        let url = URL.documentsDirectory.appending(path: "current_play.json")
        print("💬 ", url)
        return fileStorage(url)
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            GameView()
        }
    }
}

@Observable
final class Model {
    @ObservationIgnored
    @Shared(.currentPlay) var play
    
    init() {}
}

struct UndoActions: EnvironmentKey {
    static var defaultValue = UndoActions(
        canUndo: false,
        registerUndo: { fatalError() },
        onUndoTapped: { fatalError() }
    )
    
    let canUndo: Bool
    let registerUndo: () -> Void
    let onUndoTapped: () -> Void
}

extension EnvironmentValues {
    @Entry var undoActions = UndoActions.defaultValue
}

extension Play.MaxSets {
    var stride: Int {
        get { rawValue }
        set { self = Play.MaxSets(rawValue: newValue) ?? .three }
    }
}

private struct IdentityButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

#Preview {
    ContentView()
}
