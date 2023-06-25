//
//  ContentView.swift
//  Drawing
//
//  Created by Joseph Langat on 19/06/2023.
//

import SwiftUI

struct Trapezoid: Shape {
    var insetAmount: Double
    
    var animatableData: Double {
        get { insetAmount }
        set { insetAmount = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))

        return path
   }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}

struct Arc: InsettableShape {
    let startAgle: Angle
    let endAngle: Angle
    let clockwise: Bool
    var insetAmount = 0.0
    
    func path(in rect: CGRect) -> Path {
        let rotationAdjustment = Angle.degrees(90)
        let modifiedStart = startAgle - rotationAdjustment
        let modifiedEnd = endAngle - rotationAdjustment
        
        var path = Path()
        
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2 - insetAmount, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)
        
        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
    
}

struct Flower: Shape {
    // How much to move this petal away from the center
    var petalOffset: Double = -20

    // How wide to make each petal
    var petalWidth: Double = 100

    func path(in rect: CGRect) -> Path {
        // The path that will hold all petals
        var path = Path()

        // Count from 0 up to pi * 2, moving up pi / 8 each time
        for number in stride(from: 0, to: Double.pi * 2, by: Double.pi / 8) {
            // rotate the petal by the current value of our loop
            let rotation = CGAffineTransform(rotationAngle: number)

            // move the petal to be at the center of our view
            let position = rotation.concatenating(CGAffineTransform(translationX: rect.width / 2, y: rect.height / 2))

            // create a path for this petal using our properties plus a fixed Y and height
            let originalPetal = Path(ellipseIn: CGRect(x: petalOffset, y: 0, width: petalWidth, height: rect.width / 2))

            // apply our rotation/position transformation to the petal
            let rotatedPetal = originalPetal.applying(position)

            // add it to our main path
            path.addPath(rotatedPetal)
        }

        // now send the main path back
        return path
    }
}

struct ColorCyclingCircle: View {
    var amount = 0.0
    var steps = 100

    var body: some View {
        ZStack {
            ForEach(0..<steps) { value in
                Circle()
                    .inset(by: Double(value))
//                    .strokeBorder(color(for: value, brightness: 1), lineWidth: 2)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color(for: value, brightness: 1),
                                color(for: value, brightness: 0.5)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
            }
        }
        .drawingGroup()
    }

    func color(for value: Int, brightness: Double) -> Color {
        var targetHue = Double(value) / Double(steps) + amount

        if targetHue > 1 {
            targetHue -= 1
        }

        return Color(hue: targetHue, saturation: 1, brightness: brightness)
    }
}

struct ContentView: View {
    @State private var petalOffset = -20.0
    @State private var petalWidth = 100.0
    @State private var colorCycle = 0.0
    @State private var amount = 0.0
    @State private var insetAmount = 50.0
    
    var body: some View {
        ScrollView {
            VStack {
                
                Path { path in
                    path.move(to: CGPoint(x: 200, y: 100))
                    path.addLine(to: CGPoint(x: 100, y: 300))
                    path.addLine(to: CGPoint(x: 300, y: 300))
                    path.addLine(to: CGPoint(x: 200, y: 100))
                    path.closeSubpath()
                }
                .stroke(.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                
                Triangle()
                //            .fill(.red)
                    .stroke(.red, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .frame(width: 300, height: 300)
                
                Arc(startAgle: .degrees(0), endAngle: .degrees(110), clockwise: true)
                    .stroke(.green, lineWidth: 10)
                    .frame(width:300, height: 300)
                Circle()
                    .stroke(.orange, lineWidth: 40)
                Arc(startAgle: .degrees(-90), endAngle: .degrees(90), clockwise: true)
                    .strokeBorder(.brown, lineWidth: 40)
                VStack {
                    Flower(petalOffset: petalOffset, petalWidth: petalWidth)
//                        .stroke(.purple, lineWidth: 1)
                        .fill(.pink, style: FillStyle(eoFill: true))
                    Text("Offset")
                    Slider(value: $petalOffset, in: -40...40)
                        .padding([.horizontal, .bottom])
                    Text("Width")
                    Slider(value: $petalWidth, in: 0...100)
                        .padding(.horizontal)
                }
                Text("Whats Up Africa")
                    .font(.title)
                    .frame(width: 300, height: 300)
//                    .background(.red)
//                    .border(.red, width: 30)
//                    .background(Image("Example"))
                
                /*Image as border won't work unless the image is the exact right size, you have very little control over how it should look.
                 
*/
//                    .border(Image("Example"), width:30)
//                    .border(ImagePaint(image: Image("Example"), scale: 0.2), width: 30)
                    .border(ImagePaint(image: Image("Example"), sourceRect: CGRect(x: 0, y: 0.25, width: 1, height: 0.5), scale: 0.1), width: 30)
                Capsule()
                    .strokeBorder(ImagePaint(image: Image ("Example"), scale: 0.1), lineWidth: 20)
                    .frame(width: 300, height: 200)
                
                VStack {
                    ColorCyclingCircle(amount: colorCycle)
                        .frame(width: 300, height: 300)
                    Slider(value: $colorCycle)
                }
                /*
                ZStack {
                    Image("Example")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .saturation(amount)
                        .blur(radius: (1 - amount) * 20)
                        .colorMultiply(.red)
                    Slider(value: $amount)
                        .padding()
//                    Rectangle()
//                        .fill(.red)
//                        .blendMode(.multiply)
                }
                .frame(width: 300, height: 300)
                .background(.black)
//                .clipped()
                */
                /*
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color(red: 1, green: 0, blue: 0))
                            .frame(width: 200 * amount)
                            .offset(x: -50, y: -80)
                            .blendMode(.screen)
                        Circle()
                            .fill(Color(red: 0, green: 1, blue: 0))
                            .frame().frame(width: 200 * amount)
                            .offset(x: 50, y: -80)
                            .blendMode(.screen)
                        Circle()
                            .fill(Color(red: 0, green: 0, blue: 1))
                            .frame().frame(width: 200 * amount)
                            .blendMode(.screen)
                    }
                    .frame(width: 300, height: 300)
                    
                    Slider(value: $amount)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
                .ignoresSafeArea()
                */
                Trapezoid(insetAmount: insetAmount)
                    .frame(width: 200, height: 100)
                    .onTapGesture {
                        withAnimation{
                            insetAmount = Double.random(in: 10...90)
                        }
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
