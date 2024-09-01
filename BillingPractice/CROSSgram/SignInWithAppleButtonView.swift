//
//  SignInWithAppleButtonView.swift
//  BillingPractice
//
//  Created by 水原　樹 on 2024/09/01.
//

import SwiftUI
import AuthenticationServices
import FirebaseFirestore

struct SignInWithAppleButtonView: View {
    @Binding var isSignedIn: Bool
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userSession: UserSession  // UserSessionを環境オブジェクトとして追加
    
    var body: some View {
        VStack {
            Text("Sign in with Apple")
                .font(.largeTitle)
                .padding()
            
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        handleAuthorization(authorization)
                        isSignedIn = true // サインインが成功したらisSignedInを更新
                    case .failure(let error):
                        print("Apple SignIn failed: \(error.localizedDescription)")
                    }
                }
            )
            .signInWithAppleButtonStyle(
                colorScheme == .dark ? .white : .black
            )
            .frame(width: 280, height: 60)
            .cornerRadius(10)
        }
        .padding()
    }
    
    func handleAuthorization(_ authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            userSession.setUser(userId: userIdentifier)  // UserSessionにユーザーIDを設定
            saveUserID(userIdentifier: userIdentifier)  // Firebaseに保存
        }
    }
    
    func saveUserID(userIdentifier: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userIdentifier).setData([
            "userid": userIdentifier,
            "plan": "無料"
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written with user ID and default plan!")
            }
        }
    }
}

