//
//  BillingView.swift
//  BillingPractice
//
//  Created by 水原　樹 on 2024/08/30.
//

import SwiftUI
import StoreKit
import Firebase

class UserSession: ObservableObject {
    @Published var userId: String?
    
    func setUser(userId: String) {
        DispatchQueue.main.async {
            self.userId = userId
        }
    }
}

struct BillingView: View {
    @StateObject private var purchaseManager = PurchaseManager()
    @EnvironmentObject var userSession: UserSession
    @State private var selectedPlan: String = "無料" // デフォルト値を設定
    @State private var currentPlan: String = "無料" // 現在のプランを保存
    @State private var isLoadingPlan = true // ローディング中の状態を示す
    
    // 各プランの特徴を定義
    let freeFeatures = [
        "発見機能（交流が活発なエリアを閲覧）: 非表示",
        "プロフィールの閲覧: すれ違ったユーザーを一度のみ閲覧可能",
        "すれ違ったユーザーの表示時間: 6時間以内",
        "プロフィールをすれ違いリストの上部に表示: 時系列",
        "通知（すれ違った瞬間にわかる）: オフ",
        "足跡: 非表示",
        "プロフィールの閲覧制限: 30件/日",
        "広告表示: 表示",
        "2Bプラン: 小",
        "マップ上に店舗情報表示: 5万/月"
    ]
    let proFeatures =  [
        "発見機能（交流が活発なエリアを閲覧）: 24時間以内にチェックインしたユーザーを表示",
        "プロフィールの閲覧: 24時間以内であれば何度でも可能",
        "すれ違ったユーザーの表示時間: 24時間以内",
        "プロフィールをすれ違いリストの上部に表示: 24時間以内のアクティビティユーザーを表示",
        "通知（すれ違った瞬間にわかる）: オン",
        "足跡: 24時間以内のアクティビティユーザーを表示",
        "プロフィールの閲覧制限: 100件/日",
        "広告表示: 非表示",
        "2Bプラン: 中",
        "マップ上に店舗情報表示: 10万/月"
    ]
    let premiumFeatures = [
        "発見機能（交流が活発なエリアを閲覧）: 1週間以内にチェックインしたユーザーを表示",
        "プロフィールの閲覧: 1週間以内であれば何度でも可能",
        "すれ違ったユーザーの表示時間: 1週間以内",
        "プロフィールをすれ違いリストの上部に表示: 1週間以内のアクティビティユーザーを表示",
        "通知（すれ違った瞬間にわかる）: 無制限",
        "足跡: 無制限",
        "プロフィールの閲覧制限: 無制限",
        "広告表示: 非表示",
        "2Bプラン: 大",
        "マップ上に店舗情報表示: 20万/月"
    ]
    
    var body: some View {
        VStack {
            Text("Pick Your Plan")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            if isLoadingPlan {
                ProgressView("Loading current plan...")
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        DetailedPlanView(planName: "無料", price: "無料", features: freeFeatures, isSelected: selectedPlan == "無料", currentPlan: currentPlan, onSelect: {
                            selectedPlan = "無料"
                        })
                        DetailedPlanView(planName: "プロ", price: "¥500/週", features: proFeatures, isSelected: selectedPlan == "プロ", currentPlan: currentPlan, onSelect: {
                            selectedPlan = "プロ"
                        })
                        DetailedPlanView(planName: "プレミアム", price: "¥1,000/週", features: premiumFeatures, isSelected: selectedPlan == "プレミアム", isRecommended: true, currentPlan: currentPlan, onSelect: {
                            selectedPlan = "プレミアム"
                        })
                    }
                    .padding()
                }
                
                Button(action: {
                    purchaseSelectedPlan()
                }) {
                    Text("プランに入る！")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedPlan == currentPlan ? Color.gray : Color.purple) // 無効化時はグレー、通常時はパープル
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
                .disabled(selectedPlan == currentPlan) // 選択されたプランが既存のプランと同じならボタンを無効化
            }
        }
        .onAppear {
            loadCurrentPlan()
        }
        .overlay(
            Group {
                if purchaseManager.isProcessingPayment {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView("Processing Payment...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
        )
        .onReceive(purchaseManager.$isProcessingPayment) { isProcessing in
            // 購入処理が完了したらボタン状態を更新
            if !isProcessing {
                currentPlan = selectedPlan // 購入後に現在のプランを更新
            }
        }
    }
    
    func loadCurrentPlan() {
        guard let userId = userSession.userId else {
            print("User ID is not available.")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                if let plan = document.data()?["plan"] as? String {
                    selectedPlan = plan
                    currentPlan = plan  // 現在のプランを保存
                    print("Current plan: \(plan)")
                } else {
                    // ドキュメントが存在しても "plan" フィールドがない場合
                    selectedPlan = "無料"
                    currentPlan = "無料"
                    print("No plan found, defaulting to Free.")
                }
            } else {
                // ドキュメントが存在しない場合やエラーの場合
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                selectedPlan = "無料"
                currentPlan = "無料"
            }
            isLoadingPlan = false
        }
    }
    
    
    func purchaseSelectedPlan() {
        guard let userId = userSession.userId else {
            print("User ID is not available.")
            return
        }
        print("User ID is available: \(userId)")
        
        let productId = productId(for: selectedPlan)
        print("Selected plan: \(selectedPlan), Product ID: \(productId)")
        purchaseManager.purchaseProduct(productId: productId, planName: selectedPlan, userId: userId)
    }
    
    func productId(for plan: String) -> String {
        let id = switch plan {
        case "プロ": "Professional"
        case "プレミアム": "Premium"
        default: "Free"
        }
        print("Product ID for \(plan) is \(id)")
        return id
    }
}


struct DetailedPlanView: View {
    var planName: String
    var price: String
    var features: [String]
    var isSelected: Bool
    var isRecommended: Bool = false
    var currentPlan: String // 現在のプラン
    var onSelect: () -> Void
    
    var body: some View {
        Button(action: {
            onSelect()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(planName)
                        .font(.headline)
                    Spacer()
                    if isRecommended {
                        Text("Recommended！")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.black)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                    }
                }
                Text(price)
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(features, id: \.self) { feature in
                        Text("• \(feature)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        }
    }
}



// PurchaseManager: サブスクリプションの管理クラス
@MainActor
final class PurchaseManager: ObservableObject {
    @Published var isProcessingPayment = false
    
    init() {
        listenForTransactions()
    }
    
    private func listenForTransactions() {
        Task {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    // トランザクションが検証され、問題ないことが確認された場合、完了処理を行います。
                    await transaction.finish()
                    print("Transaction verified and finished for product: \(transaction.productID)")
                case .unverified(let transaction, let error):
                    // トランザクションが未検証、または問題がある場合、エラーをログに記録し、トランザクションを終了します。
                    await transaction.finish()
                    print("Transaction unverified: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func purchaseProduct(productId: String, planName: String, userId: String) {
        isProcessingPayment = true
        Task {
            do {
                // Product.products(for:) で得られるのはProductの配列
                // first! で最初のProductを取得し、強制アンラップします
                guard let product = try await Product.products(for: [productId]).first else {
                    print("No product found for ID: \(productId)")
                    isProcessingPayment = false
                    return
                }
                
                // 購入処理を実行
                let result = try await product.purchase()
                
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        await transaction.finish()
                        print("Purchase successful for product: \(productId)")
                        updateSubscriptionPlan(userId: userId, planName: planName)
                    case .unverified(let transaction, let error):
                        await transaction.finish()
                        print("Purchase failed due to verification error: \(error.localizedDescription)")
                    }
                case .userCancelled:
                    print("User cancelled the purchase.")
                default:
                    print("Purchase failed or pending.")
                }
            } catch {
                print("Purchase failed with error: \(error.localizedDescription)")
            }
            isProcessingPayment = false
        }
    }
    
    
    private func updateSubscriptionPlan(userId: String, planName: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData(["plan": planName], merge: true) { err in
            if let err = err {
                print("Error updating subscription plan: \(err)")
            } else {
                print("Subscription plan updated successfully")
            }
        }
    }
}



#Preview {
    BillingView()
}
