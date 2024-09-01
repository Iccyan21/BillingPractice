//
//  ContentView.swift
//  BillingPractice
//
//  Created by 水原　樹 on 2024/08/09.
//

//import SwiftUI
//import StoreKit
//
//// 追加
//@MainActor
//class PurchaseManager2: ObservableObject {
//    @Published var isProcessingPayment = false
//    
//    init() {
//        listenForTransactions()
//    }
//    
//    private func listenForTransactions() {
//        Task {
//            for await result in Transaction.updates {
//                switch result {
//                case .verified(let transaction):
//                    // トランザクションが検証された場合の処理
//                    await transaction.finish()
//                    print("Transaction verified for product: \(transaction.productID)")
//                case .unverified(let transaction, let error):
//                    // トランザクションの検証に失敗した場合の処理
//                    await transaction.finish()
//                    print("Transaction unverified: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//    
//    func purchaseProduct(productId: String) {
//        isProcessingPayment = true
//        Task {
//            do {
//                let product = try await Product.products(for: [productId]).first!
//                let result = try await product.purchase()
//                
//                switch result {
//                case .success(let verification):
//                    switch verification {
//                    case .verified(let transaction):
//                        // 購入が成功し、検証が完了した
//                        await transaction.finish()
//                        print("Purchase successful for product: \(productId)")
//                    case .unverified(let transaction, let error):
//                        // 検証に失敗した場合
//                        await transaction.finish()
//                        print("Purchase failed due to verification error: \(error.localizedDescription)")
//                    }
//                case .userCancelled:
//                    // ユーザーが購入をキャンセルした場合
//                    print("User cancelled the purchase.")
//                default:
//                    print("Purchase failed or pending.")
//                }
//            } catch {
//                print("Purchase failed with error: \(error.localizedDescription)")
//            }
//            isProcessingPayment = false
//        }
//    }
//}
//
//struct CafeMenuView: View {
//    @StateObject private var purchaseManager = PurchaseManager()
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Welcome to Iccyan Café")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .foregroundColor(.brown)
//            
//            Text("コーヒーおすすめ！")
//                .font(.title2)
//                .foregroundColor(.gray)
//            // productIdを追加
//            VStack(spacing: 30) {
//                MenuItemView(imageName: "coffee", itemName: "Coffee", price: "¥300", productId: "Coffee", purchaseManager: purchaseManager)
//                MenuItemView(imageName: "latte", itemName: "Café Latte", price: "¥500", productId: "CafeLatte", purchaseManager: purchaseManager)
//                MenuItemView(imageName: "matcha", itemName: "Matcha Latte", price: "¥600", productId: "GreenTeaLatte", purchaseManager: purchaseManager)
//            }
//            .padding(.top, 20)
//        }
//        .padding()
//        .background(Color("Background"))
//        .cornerRadius(20)
//        .shadow(radius: 10)
//        // 追加コード
//        .overlay(
//            // 課金中はインジケータを表示
//            Group {
//                if purchaseManager.isProcessingPayment {
//                    Color.black.opacity(0.4)
//                        .edgesIgnoringSafeArea(.all)
//                    ProgressView("Processing Payment...")
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(10)
//                        .shadow(radius: 10)
//                }
//            }
//        )
//    }
//}
//
//struct MenuItemView: View {
//    var imageName: String
//    var itemName: String
//    var price: String
//    var productId: String
//    @ObservedObject var purchaseManager: PurchaseManager
//    
//    var body: some View {
//        HStack {
//            Image(imageName)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 80, height: 80)
//                .cornerRadius(10)
//                .shadow(radius: 5)
//            
//            VStack(alignment: .leading) {
//                Text(itemName)
//                    .font(.title)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.brown)
//                
//                Text(price)
//                    .font(.title3)
//                    .foregroundColor(.gray)
//            }
//            
//            Spacer()
//            // ボタン追加
//            Button(action: {
//                purchaseManager.purchaseProduct(productId: productId)
//            }) {
//                Text("Buy")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.brown)
//                    .cornerRadius(10)
//                    .shadow(radius: 5)
//            }
//            .disabled(purchaseManager.isProcessingPayment)
//        }
//        .padding()
//        .background(Color("ItemBackground"))
//        .cornerRadius(15)
//        .shadow(radius: 5)
//    }
//}
//
//#Preview {
//    CafeMenuView()
//}
