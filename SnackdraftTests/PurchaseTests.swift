import XCTest
import StoreKitTest
@testable import Snackdraft

@MainActor
final class PurchaseTests: XCTestCase {
    private func testSession() throws -> SKTestSession {
        guard ProcessInfo.processInfo.environment["SNACKDRAFT_STOREKIT_TESTS"] == "1" else {
            throw XCTSkip("Run the Snackdraft Purchases scheme for StoreKit integration tests.")
        }
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "RemoveAds", withExtension: "storekit"))
        let session = try SKTestSession(contentsOf: url)
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()
        return session
    }

    func testPurchaseRestorationAndRefund() async throws {
        let session = try testSession()
        defer { session.clearTransactions() }

        let store = PurchaseStore(purchasesEnabled: true)
        await store.start()
        let product = try XCTUnwrap(store.removeAdsProduct)
        XCTAssertEqual(product.price, Decimal(string: "1.99"))
        XCTAssertFalse(store.hasRemovedAds)
        XCTAssertTrue(store.didCheckEntitlements)

        await store.purchase()
        XCTAssertTrue(store.hasRemovedAds)
        XCTAssertNil(store.message)

        let relaunchedStore = PurchaseStore(purchasesEnabled: true)
        await relaunchedStore.start()
        XCTAssertTrue(relaunchedStore.hasRemovedAds, "A verified non-consumable must survive a new store instance")
        let transaction = try XCTUnwrap(session.allTransactions().first)
        try session.refundTransaction(identifier: transaction.identifier)
        let deadline = Date().addingTimeInterval(5)
        while store.hasRemovedAds && Date() < deadline {
            try await Task.sleep(for: .milliseconds(50))
        }
        XCTAssertFalse(store.hasRemovedAds, "Refunded upgrades must not keep an ad-free entitlement")
    }

    func testBetaDoesNotOfferOrSellAnUpgrade() async throws {
        let store = PurchaseStore()
        await store.start()
        await store.purchase()
        XCTAssertFalse(store.purchasesEnabled)
        XCTAssertNil(store.removeAdsProduct)
        XCTAssertFalse(store.hasRemovedAds)
    }

    func testLegalDocumentsAreBundledAndReadable() {
        for document in AppDocument.allCases {
            XCTAssertFalse(document.sections.isEmpty, "\(document) must contain readable text")
            XCTAssertFalse(document.sections.contains { $0.heading == "Document unavailable" })
        }
    }
}
