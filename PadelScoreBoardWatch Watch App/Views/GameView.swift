import SwiftUI
import Sharing

struct GameView: View {
    @State var model = Model()
    @Environment(\.undoManager) var undoManager
    
    @State var newGameSheetPresented = false
    
    var body: some View {
        ZStack {
            if let unwrapped = Shared(model.$play), !unwrapped.wrappedValue.isPlayFinished {
                PlayView(
                    play: unwrapped
                )
                .environment(
                    \.undoActions,
                     UndoActions(
                        canUndo: undoManager?.canUndo ?? false,
                        registerUndo: {
                            guard let snapshot = model.play else { return }
                            
                            undoManager?.registerUndo(
                                withTarget: model,
                                handler: { target in
                                    target.$play.withLock {
                                        $0 = snapshot
                                    }
                                }
                            )
                        },
                        onUndoTapped: {
                            undoManager?.undo()
                        }
                     )
                )
            } else {
                ScrollView {
                    VStack {
                        if (model.play?.isPlayFinished) ?? false {
                            Text(model.play?.lhsTeamHasWon ?? "")
                            Divider()
                        }
                        
                        Button("New game") {
                            newGameSheetPresented = true
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $newGameSheetPresented) {
            NewGameSheet(
                onSubmit: { side, maxSets in
                    undoManager?.removeAllActions()
                    newGameSheetPresented = false
                    self.model.$play.withLock {
                        $0 = .init(
                            maxSets: maxSets,
                            serve: side
                        )
                    }
                }
            )
        }
    }
}
