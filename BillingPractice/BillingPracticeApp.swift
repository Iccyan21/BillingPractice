//
//  BillingPracticeApp.swift
//  BillingPractice
//
//  Created by 水原　樹 on 2024/08/09.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}



@main
struct BillingPracticeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isSignedIn = false
    @StateObject private var userSession = UserSession()
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if isSignedIn {
                    BillingView() // サインイン成功後はBillingViewに遷移
                        .environmentObject(userSession)
                } else {
                    SignInWithAppleButtonView(isSignedIn: $isSignedIn)
                        .environmentObject(userSession) 
                }
            }
        }
    }
}
