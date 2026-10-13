import Foundation
import Observation
import StoreKit

@MainActor
@Observable
final class PurchaseStore {
    static let removeAdsProductID = "com.sergiiziborov.snackdraft.removeads"

    private(set) var removeAdsProduct: Product?
    private(set) var hasRemovedAds = false
    private(set) var isLoading = false
    private(set) var isPurchasing = false
    private(set) var didCheckEntitlements = false
    var message: String?

    // Enable only in a release that actually displays advertisements.
    let purchasesEnabled: Bool
    @ObservationIgnored nonisolated(unsafe) private var updatesTask: Task<Void, Never>?

    init(purchasesEnabled: Bool = false) {
        self.purchasesEnabled = purchasesEnabled
    }

    deinit {
        updatesTask?.cancel()
    }

    func start() async {
        guard purchasesEnabled else {
            didCheckEntitlements = true
            return
        }
        guard updatesTask == nil else { return }
        updatesTask = Task { [weak self] in
            for await result in StoreKit.Transaction.updates {
                guard let self else { return }
                guard case .verified(let transaction) = result,
                      transaction.productID == Self.removeAdsProductID else { continue }
                await self.refreshEntitlements()
                await transaction.finish()
            }
        }
        await refreshEntitlements()
        if purchasesEnabled { await loadProduct() }
    }

    func loadProduct() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            removeAdsProduct = try await Product.products(for: [Self.removeAdsProductID]).first
            if removeAdsProduct == nil {
                message = "The upgrade is unavailable right now. Please try again later."
            }
        } catch {
            message = "Could not connect to the App Store. Please try again later."
        }
    }

    func refreshEntitlements() async {
        var entitled = false
        for await result in StoreKit.Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  transaction.productID == Self.removeAdsProductID,
                  transaction.revocationDate == nil else { continue }
            entitled = true
        }
        hasRemovedAds = entitled
        didCheckEntitlements = true
    }

    func purchase() async {
        guard purchasesEnabled, !isPurchasing, !hasRemovedAds else { return }
        guard let product = removeAdsProduct else {
            await loadProduct()
            return
        }
        message = nil
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            switch try await product.purchase() {
            case .success(let result):
                guard case .verified(let transaction) = result else {
                    message = "The App Store could not verify this purchase. Please try Restore Purchases."
                    return
                }
                await refreshEntitlements()
                await transaction.finish()
            case .pending:
                message = "Your purchase is awaiting approval. Ads will be removed after the App Store confirms it."
            case .userCancelled:
                break
            @unknown default:
                message = "The purchase did not complete. Please try again later."
            }
        } catch {
            message = "The purchase did not complete. Please try again later."
        }
    }

    func restore() async {
        guard !isPurchasing else { return }
        message = nil
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            message = hasRemovedAds ? "Your ad-free upgrade has been restored." : "No ad-free purchase was found for this Apple Account."
        } catch {
            message = "Could not restore purchases. Please try again later."
        }
    }
}
