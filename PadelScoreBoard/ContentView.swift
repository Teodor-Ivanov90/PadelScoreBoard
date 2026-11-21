import SwiftUI
import Combine
import WatchConnectivity

//struct ContentView: View {
//    
//        @EnvironmentObject var connectivity: ConnectivityManager
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            HStack(spacing: 0) {
//                Text("\(connectivity.play.blueTeamIsOnLeftSide ? connectivity.play.lhsScore.games : connectivity.play.rhsScore.games)")
//                    .foregroundStyle(.white)
//                    .font(.system(size: 70, weight: .bold))
//                    .frame(maxHeight: .infinity)
//                    .background(connectivity.play.blueTeamIsOnLeftSide ? Color.cyan : Color.pink)
//                
//                Text(connectivity.play.blueTeamIsOnLeftSide ? connectivity.play.lhsScore.points.displayValue : connectivity.play.rhsScore.points.displayValue)
//                    .foregroundStyle(.white)
//                    .font(.system(size: 200, weight: .bold))
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(connectivity.play.blueTeamIsOnLeftSide ? Color.cyan : Color.pink)
//                    .contentTransition(.interpolate)
//                    //.animation(.smooth, value: connectivity.play.lhsScore.points)
//                
//                Text(connectivity.play.blueTeamIsOnLeftSide ? connectivity.play.rhsScore.points.displayValue : connectivity.play.lhsScore.points.displayValue)
//                    .foregroundStyle(.white)
//                    .font(.system(size: 200, weight: .bold))
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(connectivity.play.blueTeamIsOnLeftSide ? Color.pink : Color.cyan)
//                
//                Text("\(connectivity.play.blueTeamIsOnLeftSide ? connectivity.play.rhsScore.games : connectivity.play.lhsScore.games)")
//                    .foregroundStyle(.white)
//                    .font(.system(size: 70, weight: .bold))
//                    .frame(maxHeight: .infinity)
//                    .background(connectivity.play.blueTeamIsOnLeftSide ? Color.pink : Color.cyan)
//            }
//            
//            
//        }
//    }
//}

struct ContentView: View {
  struct Row {
    let players: [String]
    let sets: Int
    let games: Int
    let points: String
    let serving: Bool
  }

    var rows: [Row] {
        [
        Row(
          players: ["Teo", "Alex"],
          sets: connectivity.play.lhsScore.sets,
          games: connectivity.play.lhsScore.games,
          points: connectivity.play.lhsScore.points.displayValue,
          serving: connectivity.play.serve == .lhs
        ),
        Row(
          players: ["Mike", "Petar"],
          sets: connectivity.play.rhsScore.sets,
          games: connectivity.play.rhsScore.games,
          points: connectivity.play.rhsScore.points.displayValue,
          serving: connectivity.play.serve == .rhs
        )
      ]
    }
    
    @EnvironmentObject var connectivity: ConnectivityManager

  var body: some View {
    GeometryReader { proxy in
      let spacing = CGFloat(32)
      let columns = CGFloat(5.0)
      let columnWidth = (proxy.size.width - (spacing * 3.0)) / columns

      VStack(spacing: .zero) {
        ForEach(rows.enumerated(), id: \.offset) { (offset, row) in
          HStack(spacing: spacing) {
            VStack(alignment: .trailing) {
              ForEach(row.players.enumerated(), id: \.offset) { (offset, element) in
                Text(element)
                  .textCase(.uppercase)
                  .minimumScaleFactor(0.01)
                  .font(.system(size: 48))
                  .fontWidth(.compressed)
                  .fontWeight(.semibold)
                  .lineLimit(1)
              }
            }
            .frame(width: columnWidth, alignment: .trailing)

            Group {
              Text(String(row.sets))
                .fixedSize()
                .frame(width: columnWidth)
                .fontWidth(.condensed)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
              Text(String(row.games))
                .fixedSize()
                .frame(width: columnWidth)
                .fontWidth(.condensed)
                .fontWeight(.bold)
              Text(String(row.points))
                .fixedSize()
                .frame(width: columnWidth * 2.0)
                .fontWeight(.bold)
                .fontWidth(.expanded)
            }
            .lineLimit(1)
            .font(.system(size: 160))
          }
          .frame(maxHeight: .infinity)
          .background {
            if offset == 0, row.serving {
              Rectangle()
                .fill(
                  LinearGradient(
                    colors: [.cyan.opacity(0.0), .cyan.opacity(0.2), .cyan.opacity(0.5), .cyan],
                    startPoint: .bottomTrailing,
                    endPoint: .topLeading
                  )
                )
                .blur(radius: 48)
            }

            if offset == 1, row.serving {
              Rectangle()
                .fill(
                  LinearGradient(
                    colors: [.pink.opacity(0.0), .pink.opacity(0.2), .pink.opacity(0.5), .pink],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                  )
                )
                .blur(radius: 48)
            }
          }
        }
      }
      .background {
        HStack(spacing: spacing) {
          Text("—")
            .foregroundStyle(.tertiary)
            .frame(width: columnWidth, alignment: .trailing)

          Group {
            Text("SETS")
              .foregroundStyle(.secondary)
              .frame(width: columnWidth)
            Text("GAMES")
              .frame(width: columnWidth)
            Text("POINTS")
              .frame(width: columnWidth * 2.0)
          }
        }
        .font(.system(size: 24, weight: .bold))
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ignoresSafeArea()
    .background()
  }
}

#Preview {
  ContentView()
        .environmentObject(ConnectivityManager.shared)
    .colorScheme(.dark)
}


//#Preview {
//    ContentView()
//}
