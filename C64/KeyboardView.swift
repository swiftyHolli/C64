//
//  KeyboardView.swift
//  C64
//
//  Created by Holger Becker on 11.02.25.
//

import SwiftUI

struct KeyboardView: View {
    @ObservedObject var keyboard = Keyboard()
    
    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2){
                Button {
                    keyboard.keyPressed(00)
                } label: {
                    Image(systemName: "delete.left")
                }
                
                Button("1") {keyboard.keyPressed(56)}
                Button("2") {keyboard.keyPressed(59)}
                Button("3") {keyboard.keyPressed(08)}
                Button("4") {keyboard.keyPressed(11)}
                Button("5") {keyboard.keyPressed(16)}
                Button("6") {keyboard.keyPressed(19)}
                Button("7") {keyboard.keyPressed(24)}
                Button("8") {keyboard.keyPressed(27)}
                Button("9") {keyboard.keyPressed(32)}
                Button("0") {keyboard.keyPressed(35)}
                Button("+") {keyboard.keyPressed(40)}
                Button("-") {keyboard.keyPressed(43)}
                Button("£") {keyboard.keyPressed(48)}
                
            }
            .buttonStyle(KeyboardButtonStyle())
            HStack(spacing: 2) {
                Button("CTRL") {keyboard.keyPressed(58)}
                Button("Q") {keyboard.keyPressed(62)}
                Button("W") {keyboard.keyPressed(09)}
                Button("E") {keyboard.keyPressed(14)}
                Button("R") {keyboard.keyPressed(17)}
                Button("T") {keyboard.keyPressed(22)}
                Button("Y") {keyboard.keyPressed(25)}
                Button("U") {keyboard.keyPressed(30)}
                Button("I") {keyboard.keyPressed(33)}
                Button("O") {keyboard.keyPressed(38)}
                Button("P") {keyboard.keyPressed(41)}
                Button("@") {keyboard.keyPressed(46)}
                Button("*") {keyboard.keyPressed(49)}
            }
            .buttonStyle(KeyboardButtonStyle())
            
            HStack(spacing: 2) {
                Button("A") {keyboard.keyPressed(10)}
                Button("S") {keyboard.keyPressed(13)}
                Button("D") {keyboard.keyPressed(18)}
                Button("F") {keyboard.keyPressed(21)}
                Button("G") {keyboard.keyPressed(26)}
                Button("H") {keyboard.keyPressed(29)}
                Button("J") {keyboard.keyPressed(34)}
                Button("K") {keyboard.keyPressed(37)}
                Button("L") {keyboard.keyPressed(42)}
                Button(":") {keyboard.keyPressed(45)}
                Button(";") {keyboard.keyPressed(50)}
                Button("=") {keyboard.keyPressed(53)}
                Button("Enter") {keyboard.keyPressed(01)}
                
            }
            HStack(spacing: 2) {
                Button("Z") {keyboard.keyPressed(12)}
                Button("X") {keyboard.keyPressed(23)}
                Button("C") {keyboard.keyPressed(20)}
                Button("V") {keyboard.keyPressed(31)}
                Button("B") {keyboard.keyPressed(28)}
                Button("N") {keyboard.keyPressed(39)}
                Button("M") {keyboard.keyPressed(36)}
                Button(",") {keyboard.keyPressed(47)}
                Button(".") {keyboard.keyPressed(44)}
                Button("/") {keyboard.keyPressed(55)}
            }
            HStack(spacing: 2) {
                Button("STOP") {keyboard.keyPressed(63)}
                    .font(.caption)
                Button {
                    keyboard.keyPressed(15)
                } label: {
                    Image(systemName: "shift.fill")
                }
                
                Button("Space") {keyboard.keyPressed(60)}
                Button {
                    keyboard.keyPressed(52)
                } label: {
                    Image(systemName: "shift.fill")
                }
            }
        }
        .buttonStyle(KeyboardButtonStyle())
    }
}

#Preview {
    KeyboardView()
}
