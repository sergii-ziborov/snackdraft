import SwiftUI

struct PurchaseSettingsSection: View {
    @Environment(PurchaseStore.self) private var purchases

    var body: some View {
        Section("Advertising") {
            if purchases.hasRemovedAds {
                Label("Ads removed", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(Palette.mossPressed)
            } else if purchases.purchasesEnabled {
                Button {
                    Task { await purchases.purchase() }
                } label: {
                    HStack {
                        Text("Remove Ads")
                        Spacer()
                        if let product = purchases.removeAdsProduct {
                            Text(product.displayPrice)
                        } else {
                            Text("Unavailable").foregroundStyle(.secondary)
                        }
                    }
                }
                .disabled(purchases.removeAdsProduct == nil || purchases.isPurchasing)
                .accessibilityIdentifier("remove-ads-button")
                Text("One-time purchase. All gameplay stays free.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Label("Ad-free beta", systemImage: "leaf.fill")
                    .foregroundStyle(Palette.mossPressed)
                Text("Enjoy all gameplay for free. This beta has no advertisements or paid upgrades.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if purchases.purchasesEnabled || purchases.hasRemovedAds {
                Button("Restore Purchases") {
                    Task { await purchases.restore() }
                }
                .disabled(purchases.isPurchasing)
                .accessibilityIdentifier("restore-purchases-button")
            }
            if let message = purchases.message {
                Text(message).font(.footnote).foregroundStyle(.secondary)
            }
        }
    }
}
