import SwiftUI

/// A single flip unit that displays a number and handles the 3D flip animation per the specific "Four Layer" spec.
struct FlipUnit: View {
    let value: String
    
    @State private var oldValue: String = ""
    @State private var newValue: String = ""
    @State private var rotation: Double = 0
    
    init(value: String) {
        self.value = value
    }
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let halfHeight = size.height / 2
            let fontSize = size.height * 0.8
            let cornerRadius = size.height * 0.1 // Responsive corner radius
            
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(white: 0.15))
                
                // MARK: - Layer 1 & 2: Static Backgrounds (New Value)
                VStack(spacing: 0) {
                    HalfCard(text: newValue, type: .top, fontSize: fontSize, cornerRadius: cornerRadius)
                        .frame(height: halfHeight)
                    
                    HalfCard(text: newValue, type: .bottom, fontSize: fontSize, cornerRadius: cornerRadius)
                        .frame(height: halfHeight)
                }
                
                // MARK: - Layer 3: Front-Bottom (Old Value)
                // Visible initially.
                if rotation <= 90 {
                    VStack(spacing: 0) {
                        Spacer().frame(height: halfHeight)
                        HalfCard(text: oldValue, type: .bottom, fontSize: fontSize, cornerRadius: cornerRadius)
                            .frame(height: halfHeight)
                    }
                }
                
                // MARK: - Layer 4: The Flipper
                VStack(spacing: 0) {
                    ZStack {
                        if rotation <= 90 {
                            // 0 -> 90: Old Top
                            HalfCard(text: oldValue, type: .top, fontSize: fontSize, cornerRadius: cornerRadius)
                                .overlay(
                                    Color.black.opacity(rotation / 180.0)
                                )
                                .clipShape(RoundedHalfRect(radius: cornerRadius, type: .top))
                        } else {
                            // 90 -> 180: New Bottom
                            // We need to show the Bottom Card.
                            // But properly oriented for the flip.
                            HalfCard(text: newValue, type: .bottom, fontSize: fontSize, cornerRadius: cornerRadius)
                                .overlay(
                                    Color.black.opacity((180 - rotation) / 180.0)
                                )
                                .clipShape(RoundedHalfRect(radius: cornerRadius, type: .bottom))
                                // Invert content vertically so when rotated 180 it looks right
                                .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
                        }
                    }
                    .frame(height: halfHeight)
                    // The rotation happens around the BOTTOM edge of this Top-Half Frame
                    .rotation3DEffect(
                        .degrees(rotation),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .bottom,
                        perspective: 0.5
                    )
                    
                    Spacer().frame(height: halfHeight)
                }
            }
        }
        .onAppear {
            oldValue = value
            newValue = value
        }
        .onChange(of: value) { newVal in
            let previous = newValue
            oldValue = previous
            newValue = newVal
            rotation = 0
            withAnimation(.interpolatingSpring(stiffness: 170, damping: 15)) {
                rotation = 180
            }
        }
    }
}

// MARK: - Subcomponent: Half Card
struct HalfCard: View {
    let text: String
    let type: HalfType
    let fontSize: CGFloat
    let cornerRadius: CGFloat
    
    enum HalfType { case top, bottom }
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            Color(white: 0.15) // Card Color
                .overlay(
                    Text(text)
                        .font(.system(size: fontSize, weight: .bold))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(.white)
                        .frame(width: w, height: h * 2, alignment: .center)
                        .position(x: w / 2, y: (type == .top ? h : 0) - fontSize * 0.035)
                )
                .clipShape(RoundedHalfRect(radius: cornerRadius, type: type))
                .overlay(
                    // Separator line logic - 使用屏幕底色，营造上下两片分开的效果
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(Color(white: 0.1))
                        .frame(maxHeight: .infinity, alignment: type == .top ? .bottom : .top)
                )
        }
    }
}

struct RoundedHalfRect: Shape {
    var radius: CGFloat
    var type: HalfCard.HalfType
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // top-left, top-right, bottom-right, bottom-left
        let tl = CGPoint(x: rect.minX, y: rect.minY)
        let tr = CGPoint(x: rect.maxX, y: rect.minY)
        let br = CGPoint(x: rect.maxX, y: rect.maxY)
        let bl = CGPoint(x: rect.minX, y: rect.maxY)
        
        if type == .top {
            // Top corners rounded, Bottom square
            path.move(to: CGPoint(x: bl.x, y: bl.y)) // Start Bottom-Left
            path.addLine(to: CGPoint(x: tl.x, y: tl.y + radius)) // Left edge up to curve
            path.addArc(center: CGPoint(x: tl.x + radius, y: tl.y + radius), radius: radius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
            path.addLine(to: CGPoint(x: tr.x - radius, y: tr.y)) // Top edge
            path.addArc(center: CGPoint(x: tr.x - radius, y: tr.y + radius), radius: radius, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
            path.addLine(to: CGPoint(x: br.x, y: br.y)) // Right edge down
            path.closeSubpath() // Bottom edge closed
        } else {
            // Top square, Bottom corners rounded
            path.move(to: CGPoint(x: tl.x, y: tl.y)) // Start Top-Left
            path.addLine(to: CGPoint(x: tr.x, y: tr.y)) // Top edge
            path.addLine(to: CGPoint(x: br.x, y: br.y - radius)) // Right edge down to curve
            path.addArc(center: CGPoint(x: br.x - radius, y: br.y - radius), radius: radius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
            path.addLine(to: CGPoint(x: bl.x + radius, y: bl.y)) // Bottom edge
            path.addArc(center: CGPoint(x: bl.x + radius, y: bl.y - radius), radius: radius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            path.closeSubpath() // Left edge closed
        }
        
        return path
    }
}
