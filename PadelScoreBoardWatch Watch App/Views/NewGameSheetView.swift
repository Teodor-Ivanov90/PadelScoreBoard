
import SwiftUI

struct NewGameSheet: View {
    @State var firstServe: Play.Side?
    @State var maxSets = Play.MaxSets.three
    @State var blueTeamIsOnLeftCourtSide: Bool = true
    
    let onSubmit: (Play.Side, Play.MaxSets) -> Void
    
    var body: some View {
        Form {
            Section("First Serve") {
                VStack {
                    HStack {
                        Button {
                            self.firstServe = .lhs
                        } label: {
                            Image(systemName: "checkmark")
                                .opacity(firstServe == .lhs ? 1 : 0)
                        }
                        .tint(.cyan)
                        
                        Button {
                            self.firstServe = .rhs
                        } label: {
                            Image(systemName: "checkmark")
                                .opacity(firstServe == .rhs ? 1 : 0)
                        }
                        .tint(.pink)
                    }
                    .fontWeight(.bold)
                    .buttonStyle(.glassProminent)
                    
                    Button("🎲") {
                        self.firstServe = Bool.random() ? .lhs : .rhs
                    }
                    .buttonStyle(.glass)
                }
                .listRowBackground(Color.clear)
            }
            
            Section("Max Sets") {
                Stepper(
                    String(maxSets.rawValue),
                    value: $maxSets.stride,
                    in: 3...5,
                    step: 2,
                    onEditingChanged: { _ in
                        
                    }
                )
            }
            
            Button("Confirm") {
                onSubmit(
                    firstServe ?? .lhs,
                    maxSets
                )
            }
            .buttonStyle(.glassProminent)
            .tint(
                firstServe == .lhs ? .cyan : .pink
            )
            .listRowBackground(Color.clear)
            .disabled(firstServe == nil)
        }
    }
}

