
import SwiftUI
import Sharing

struct MoreMenuView: View {
    @Environment(\.undoActions) var undoActions
    @Environment(\.dismiss) var dismiss
    @Shared var play: Play
    
    var body: some View {
        List {
            Button("Restart", systemImage: "arrow.trianglehead.counterclockwise") {
                undoActions.registerUndo()
                $play.withLock {
                    $0.restart()
                }
                dismiss()
            }
        }
    }
}
