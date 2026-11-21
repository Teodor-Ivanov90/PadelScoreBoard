import SwiftUI
import Sharing

struct PlayView: View {
    @State var showMoreMenu = false
    @Shared var play: Play
    @EnvironmentObject var connectivity: ConnectivityManager
    
    @Environment(\.undoActions) var undoActions
    
    var servePosition: some View {
        HStack(spacing: 8) {
            Capsule()
                .glassEffect(.regular.tint(play.servePosition == .lhs ? .white : nil))
                .frame(width: play.servePosition == .lhs ? 24 : 8)
                .frame(width: 24, alignment: .trailing)
            
            Capsule()
                .glassEffect(.regular.tint(play.servePosition == .rhs ? .white : nil))
                .frame(width: play.servePosition == .rhs ? 24 : 8)
                .frame(width: 24, alignment: .leading)
        }
        .frame(height: 8)
        .animation(.smooth, value: play.servePosition)
        .padding(.horizontal, 16)
    }
    
    var body: some View {
        ZStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.cyan.opacity(1),
                        Color.cyan.opacity(0.2),
                        Color.cyan.opacity(0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(play.serve == .lhs ? 0.6 : 0.2)
                
                LinearGradient(
                    colors: [
                        Color.pink.opacity(1),
                        Color.pink.opacity(0.2),
                        Color.pink.opacity(0)
                    ],
                    startPoint: .bottomTrailing,
                    endPoint: .topLeading
                ).opacity(play.serve == .rhs ? 0.6 : 0.2)
            }
            .animation(.smooth, value: play.serve)
            .ignoresSafeArea()
            
            VStack(spacing: 12) {
                
                HStack(spacing: 16) {
                    VStack(spacing: 8) {
                        let lhsShape = UnevenRoundedRectangle(
                            cornerRadii: .init(
                                topLeading: 12,
                                bottomLeading: 48,
                                bottomTrailing: 12,
                                topTrailing: 48
                            ),
                            style: .continuous
                        )
                        
                        Button {
                            undoActions.registerUndo()
                            $play.withLock {
                                $0.lhsTeamScored()
                            }
                            
                            let data = try? JSONEncoder().encode(play)
                            connectivity.sendTextMessage(["score": data ?? Data()])
                        } label: {
                            VStack(spacing: 8) {
                                Text("\(play.lhsScore.sets)")
                                    .fontWeight(.semibold)
                                    .font(.body)
                                    .foregroundStyle(.tertiary)
                                
                                Text("\(play.lhsScore.games)")
                                    .fontWeight(.bold)
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                                
                                Text(play.lhsScore.points.displayValue)
                                    .fontWeight(.black)
                                    .font(.title)
                                    .foregroundStyle(.primary)
                            }
                            .fontWidth(.condensed)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .glassEffect(
                                .regular.interactive().tint(.cyan),
                                in: lhsShape
                            )
                            .colorScheme(.dark)
                        }
                        .buttonStyle(.plain)
                        .contentShape(lhsShape)
                        .tint(.cyan)
                        .background {
                            lhsShape.fill(.cyan)
                                .scaleEffect(1.25, anchor: .bottomTrailing)
                                .blur(radius: 24)
                                .opacity(play.serve == .lhs ? 1 : 0.2)
                                .animation(.smooth, value: play.serve)
                        }
                    }
                    
                    let rhsShape = UnevenRoundedRectangle(
                        cornerRadii: .init(
                            topLeading: 48,
                            bottomLeading: 12,
                            bottomTrailing: 48,
                            topTrailing: 12
                        ),
                        style: .continuous
                    )
                    
                    VStack(spacing: 8) {
                        Button {
                            undoActions.registerUndo()
                            $play.withLock {
                                $0.rhsTeamScored()
                            }
                            
                            let data = try? JSONEncoder().encode(play)
                            connectivity.sendTextMessage(["score": data ?? Data()])
                        } label: {
                            VStack(spacing: 8) {
                                Text("\(play.rhsScore.sets)")
                                    .fontWeight(.semibold)
                                    .font(.body)
                                    .foregroundStyle(.tertiary)
                                
                                Text("\(play.rhsScore.games)")
                                    .fontWeight(.bold)
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                                
                                Text(play.rhsScore.points.displayValue)
                                    .fontWeight(.black)
                                    .font(.title)
                                    .foregroundStyle(.primary)
                            }
                            .fontWidth(.condensed)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .glassEffect(
                                .regular.interactive().tint(.pink),
                                in: rhsShape
                            )
                            .colorScheme(.dark)
                        }
                        .tint(.pink)
                        .background {
                            rhsShape.fill(.pink)
                                .scaleEffect(1.25, anchor: .bottomLeading)
                                .blur(radius: 24)
                                .opacity(play.serve == .rhs ? 1 : 0.2)
                                .animation(.smooth, value: play.serve)
                        }
                    }
                    .buttonStyle(.plain)
                    .contentShape(rhsShape)
                }
                .colorScheme(.light)
                .background(alignment: .bottom) {
                    servePosition
                        .offset(x: 0, y: 20)
                        .animation(.smooth, value: play.serve)
                }
            }
            .padding(.horizontal, 12)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("", systemImage: "arrow.uturn.backward") {
                    undoActions.onUndoTapped()
                    let data = try? JSONEncoder().encode(play)
                    connectivity.sendTextMessage(["score": data ?? Data()])
                }
                .disabled(!undoActions.canUndo)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(), systemImage: "ellipsis") {
                    self.showMoreMenu = true
                }
            }
        }
        .sheet(isPresented: $showMoreMenu) {
            MoreMenuView(play: $play)
        }
    }
}
