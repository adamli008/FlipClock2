import SwiftUI

struct FlipClockView: View {
    @ObservedObject var timeModel: TimeModel
    
    var body: some View {
        GeometryReader { geo in
            // Calculate optimal card size based on available space
            // Layout: [H][H] - [M][M] - [S][S]
            // We have 6 cards.
            // Spacing: 
            //   - Between digits in pair: small (e.g. 0.05 * cardWidth)
            //   - Between groups: large (e.g. 0.3 * cardWidth)
            // Aspect Ratio of card: 0.6 (Width / Height)
            
            // Dynamic padding based on width to scale margins with window size
            let padding = geo.size.width * 0.1 // 10% padding on each side
            let availableW = geo.size.width - (padding * 2)
            let availableH = geo.size.height - 60 // Keep reasonable fixed vertical padding or make it proportional too? Let's use fixed safe area feel.
            
            // Equation: 
            // 6 * W + 3 * smallGap + 2 * largeGap = TotalW
            // Let smallGap = 0.05W, largeGap = 0.4W
            // TotalWidth factor = 6 + 3(0.05) + 2(0.3) = 6 + 0.15 + 0.6 = 6.75
            
            // Constrain by Width
            // We use 7.0 as a safe divisor to fit the 6.75 factor
            let wFromWidth = availableW / 6.75 
            
            // Constrain by Height (W = H * 0.6)
            // Reduce height factor to ensure vertical spacing for date
            let wFromHeight = (availableH * 0.75) * 0.6
            
            let cardWidth = min(wFromWidth, wFromHeight)
            let cardHeight = cardWidth / 0.6
            
            let smallSpacing = cardWidth * 0.05
            let largeSpacing = cardWidth * 0.3
            
            ZStack {
                // Background
                Color(white: 0.1).edgesIgnoringSafeArea(.all)
                
                // Clock Digits (Centered)
                HStack(spacing: largeSpacing) {
                    // Hours
                    HStack(spacing: smallSpacing) {
                        FlipUnit(value: String(timeModel.hour.prefix(1)))
                            .frame(width: cardWidth, height: cardHeight)
                        FlipUnit(value: String(timeModel.hour.suffix(1)))
                            .frame(width: cardWidth, height: cardHeight)
                    }
                    
                    // Separator
                    VStack(spacing: cardHeight * 0.2) {
                        Circle().fill(Color(white: 0.3)).frame(width: cardWidth * 0.12, height: cardWidth * 0.12)
                        Circle().fill(Color(white: 0.3)).frame(width: cardWidth * 0.12, height: cardWidth * 0.12)
                    }
                    
                    // Minutes
                    HStack(spacing: smallSpacing) {
                        FlipUnit(value: String(timeModel.minute.prefix(1)))
                            .frame(width: cardWidth, height: cardHeight)
                        FlipUnit(value: String(timeModel.minute.suffix(1)))
                            .frame(width: cardWidth, height: cardHeight)
                    }
                    
                    // Separator
                    VStack(spacing: cardHeight * 0.2) {
                        Circle().fill(Color(white: 0.3)).frame(width: cardWidth * 0.12, height: cardWidth * 0.12)
                        Circle().fill(Color(white: 0.3)).frame(width: cardWidth * 0.12, height: cardWidth * 0.12)
                    }
                    
                    // Seconds
                    HStack(spacing: smallSpacing) {
                        FlipUnit(value: String(timeModel.second.prefix(1)))
                            .frame(width: cardWidth, height: cardHeight)
                        FlipUnit(value: String(timeModel.second.suffix(1)))
                            .frame(width: cardWidth, height: cardHeight)
                    }
                }
                
                // Date Text (Positioned in bottom margin)
                Text(timeModel.dateString)
                    .font(.system(size: cardHeight * 0.12, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(white: 0.4))
                    .position(x: geo.size.width / 2, y: (geo.size.height / 2) + (cardHeight / 2) + ((geo.size.height - cardHeight) / 4))
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
