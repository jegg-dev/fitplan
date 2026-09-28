import SwiftUI

enum AppTheme {
    static let accent = Color(red: 0.22, green: 0.48, blue: 0.95)
    static let strength = Color(red: 0.55, green: 0.32, blue: 0.93)
    static let cardio = Color(red: 0.95, green: 0.34, blue: 0.26)
    static let background = Color(uiColor: .systemGroupedBackground)
}

struct RoundIcon: View {
    let systemName: String
    let color: Color

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: 38, height: 38)
            .background(color.opacity(0.13), in: Circle())
    }
}

