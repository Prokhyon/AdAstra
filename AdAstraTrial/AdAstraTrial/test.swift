//
//  test.swift
//  AdAstraTrial
//
//  Created by Loris Thomas on 01.03.2025.
//

import SwiftUI

struct Test: View {
    var symbols: String = "(+4;,CLHQacjÌÜ¶"
    var body: some View {
        Text(symbols)
            .font(.custom("cycles", size: 130))
            .padding()
            .frame(width: 1000)
    }
}

#Preview {
    Test()
}
