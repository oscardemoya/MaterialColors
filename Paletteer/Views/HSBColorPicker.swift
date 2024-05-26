//
//  HSBColorPicker.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct HSBColorPicker: View {
    @State var title: String = ""
    @Binding var color: Color
    @State private var showingSheet = false
    @State private var sheetHeight: CGFloat = .zero
    @State private var colorSpace: ColorSpace = .hct
    @State private var squareHeight: CGFloat = .zero
    @State private var hueSliderValue = Self.hueRange.median
    @State private var saturationSliderValue = Self.saturationRange.median
    @State private var brightnessSliderValue = Self.brightnessRange.median
    
    static let hueRange: ClosedRange<Double> = 0...360
    static let saturationRange: ClosedRange<Double> = 0...100
    static let brightnessRange: ClosedRange<Double> = 0...100
    
    func colorCreator() -> some View {
        VStack(spacing: 24) {
            HStack(alignment: .center) {
                Spacer()
                    .frame(width: 32, height: 32)
                Spacer()
                Text(title)
                    .font(.headline)
                Spacer()
                CircularCloseButton {
                    showingSheet = false
                }
                .frame(width: 32, height: 32)
            }
            Picker("Color Space", selection: $colorSpace) {
                ForEach(ColorSpace.allCases) {
                    Text($0.title)
                }
            }
            .pickerStyle(.segmented)
            switch colorSpace {
            case .hct:
                hctColorPicker()
            case .rgb:
                ColorPicker(title, selection: $color, supportsOpacity: false).rounded()
            }
        }
        .padding()
        .readSize { size in
            sheetHeight = size.height
        }
        .presentationDetents([.height(sheetHeight)])
        .presentationDragIndicator(.hidden)
        .onChange(of: showingSheet) {
            if showingSheet {
                setHCTValues()
            }
        }
        .onChange(of: colorSpace) {
            setHCTValues()
        }
        .onChange(of: hueSliderValue) {
            updateColor()
        }
        .onChange(of: saturationSliderValue) {
            updateColor()
        }
        .onChange(of: brightnessSliderValue) {
            updateColor()
        }
    }
    
    var body: some View {
        Button {
            showingSheet.toggle()
        } label: {
            Text(title)
            Spacer()
            rectangle(color: color)
                .frame(width: 30, height: 30)
        }
        .sheet(isPresented: $showingSheet) {
            colorCreator()
        }
    }
    
    func setHCTValues() {
        guard let hct = color.hct else {
            print("Error converting color to HCT.")
            return
        }
        hueSliderValue = hct.hue
        saturationSliderValue = hct.chroma
        brightnessSliderValue = hct.tone
    }
    
    func updateColor() {
        let hctColor = Hct.from(hueSliderValue, saturationSliderValue, brightnessSliderValue)
        color = Color(hctColor: hctColor)
    }
    
    func hctColorPicker() -> some View {
        VStack(spacing: 24) {
            HStack(spacing: 12) {
                rectangle(color: color)
                    .frame(width: squareHeight, height: squareHeight)
                colorValues()
                Spacer()
            }
            Grid(alignment: .leading) {
                GridRow {
                    Text("Hue").frame(alignment: .leading)
                    Slider(value: $hueSliderValue, in: Self.hueRange)
                    HStack {
                        Spacer(minLength: 0)
                        Stepper("\(Int(hueSliderValue))", value: $hueSliderValue, in: Self.hueRange)
                            .fixedSize()
                    }
                    .gridColumnAlignment(.trailing)
                }
                GridRow {
                    Text("Chroma").frame(alignment: .leading)
                    Slider(value: $saturationSliderValue, in: Self.saturationRange)
                    HStack {
                        Spacer(minLength: 0)
                        Stepper("\(Int(saturationSliderValue))", value: $saturationSliderValue, in: Self.saturationRange)
                            .fixedSize()
                    }
                    .gridColumnAlignment(.trailing)
                }
                GridRow {
                    Text("Tone").frame(alignment: .leading)
                    Slider(value: $brightnessSliderValue, in: Self.brightnessRange)
                    HStack {
                        Spacer(minLength: 0)
                        Stepper("\(Int(brightnessSliderValue))", value: $brightnessSliderValue, in: Self.brightnessRange)
                            .fixedSize()
                    }
                    .gridColumnAlignment(.trailing)
                }
            }
        }
    }
    
    func rectangle(color: Color) -> some View {
        Rectangle()
            .fill(color)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.gray.opacity(0.5), lineWidth: 0.5)
            )
    }
    
    func colorValues() -> some View {
        return VStack(alignment: .leading) {
            HStack {
                Text("RGB")
                    .fontWeight(.bold)
                Button {
                    String.pasteboardString = color.hexRGB.uppercased()
                } label: {
                    HStack {
                        Text(color.hexRGB.uppercased())
                        Image(systemName: "square.on.square")
                    }
                    .padding(2)
                }
            }
            HStack {
                Text("HTC")
                    .fontWeight(.bold)
                Button {
                    if let hct = color.hct {
                        String.pasteboardString = hct.label
                    }
                } label: {
                    HStack {
                        if let hct = color.hct {
                            Text(hct.label)
                        }
                        Image(systemName: "square.on.square")
                    }
                    .padding(2)
                }
            }
        }
        .readSize { size in
            squareHeight = size.height
        }
    }
}

#Preview {
    @State var color: Color = .blue
    @State var clipboardColor: Color = .red
    return HCTColorPicker(title: "Title", selectedColor: $color, clipboardColor: $clipboardColor)
}