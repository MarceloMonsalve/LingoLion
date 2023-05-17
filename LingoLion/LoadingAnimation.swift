//
//  LoadingAnimation.swift
//  LingoLion
//
//  Created by Marcelo Monsalve on 5/16/23.
//

import SwiftUI

struct LoadingAnimation: View {
    @State private var rotation: Double = 360
    var color: Color
    var body: some View {
        VStack {
            Circle()
                .trim(from: 1/2, to: 1)
                .stroke(lineWidth: 7)
                .frame(width:30)
                .rotationEffect(.degrees(self.rotation))
                .onAppear {
                    if self.rotation == 0 {self.rotation = 360} else {self.rotation = 0}
                }
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotation)
                .foregroundColor(color)
        }
        
    }
}

struct LoadingAnimation_Previews: PreviewProvider {
    static var previews: some View {
        LoadingAnimation(color: Color.blue)
    }
}
