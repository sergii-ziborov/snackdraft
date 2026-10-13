import SwiftUI

enum AppDocument: String, Identifiable, CaseIterable {
    case about = "About"
    case privacy = "Privacy"
    case terms = "Terms"
    case support = "Support"

    var id: String { rawValue }
    var title: String {
        switch self {
        case .about: "About Snackdraft"
        case .privacy: "Privacy Policy"
        case .terms: "Terms of Use"
        case .support: "Help & Support"
        }
    }

    var sections: [(heading: String, body: String)] {
        guard let url = Bundle.main.url(forResource: rawValue, withExtension: "md"),
              let source = try? String(contentsOf: url, encoding: .utf8) else {
            return [("Document unavailable", "Contact sergii.ziborov@gmail.com for a copy.")]
        }
        var result: [(heading: String, body: String)] = []
        var heading = ""
        var lines: [String] = []
        for line in source.components(separatedBy: .newlines) {
            if line.hasPrefix("# ") { continue }
            if line.hasPrefix("## ") {
                let body = lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                if !body.isEmpty { result.append((heading, body)) }
                heading = String(line.dropFirst(3))
                lines = []
            } else {
                lines.append(line)
            }
        }
        let body = lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        if !body.isEmpty { result.append((heading, body)) }
        return result
    }
}

struct AppDocumentView: View {
    @Environment(\.dismiss) private var dismiss
    var document: AppDocument

    var body: some View {
        PageShell(title: document.title, onBack: { dismiss() }, backIdentifier: "document-close-button") {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if document == .about {
                        HStack(spacing: 14) {
                            Image("BrandMark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Snackdraft").font(.sdDisplay(24))
                                Text("Version \(AppInfo.version)")
                                    .font(.sdBody(13))
                                    .foregroundStyle(Palette.inkSoft)
                            }
                        }
                    }
                    ForEach(Array(document.sections.enumerated()), id: \.offset) { _, section in
                        VStack(alignment: .leading, spacing: 8) {
                            if !section.heading.isEmpty {
                                Text(section.heading).font(.sdBody(18))
                            }
                            Text(section.body)
                                .font(.system(size: 15, design: .rounded))
                                .lineSpacing(5)
                                .textSelection(.enabled)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    Link("Email support", destination: AppInfo.supportEmailURL)
                        .font(.sdBody(15))
                        .padding(.vertical, 10)
                        .accessibilityIdentifier("support-email-link")
                    Link("Apple Standard EULA", destination: AppInfo.eulaURL)
                        .font(.sdBody(14))
                        .padding(.vertical, 6)
                }
                .foregroundStyle(Palette.ink)
                .padding(24)
                .frame(maxWidth: 680, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .accessibilityIdentifier("app-document-scroll")
        }
    }
}

enum AppInfo {
    static var version: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
    static let supportEmailURL = URL(string: "mailto:sergii.ziborov@gmail.com?subject=Snackdraft%20support")!
    static let eulaURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
}
