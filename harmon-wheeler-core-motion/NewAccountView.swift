//
//  NewAccountView.swift
//
//  Created by Parker Harmon on 12/2/24.
//

import SwiftUI
import FirebaseAuth

struct NewAccountView: View {
    @EnvironmentObject var navigator: MyNavigator
    
    @EnvironmentObject var vm: HikingViewModel
    //variables for creating a new account
    @State private var email: String = ""
    @State private var pass: String = ""
    @State private var confirmPass: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack {
            Text("Create New Account").font(.largeTitle)
                .fontWeight(.bold) // Make it bold
                .foregroundColor(.darkOlive)
                .padding()
                .shadow(color: .gray, radius: 2, x: 1, y: 1)
            if errorMessage.count > 0 {
                Text("Create Account Feedback: \(errorMessage)")
            }
            VStack{
                TextField("Email Address", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.darkOlive, lineWidth: 1)
                    )
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                
                SecureField("Password", text: $pass)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.darkOlive, lineWidth: 1)
                    )
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                
                SecureField("Confirm Password", text: $confirmPass)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.darkOlive, lineWidth: 1)
                    )
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
            }.padding()
            HStack {
                Button("Cancel"){
                    navigator.navBack()
                }
                Button("Create Account"){
                    createAccount()
                }.disabled(pass != confirmPass || pass.isEmpty || confirmPass.isEmpty || email.isEmpty)
            }
        }.buttonStyle(.borderedProminent)
        
    }
    
    func createAccount(){
        Auth.auth().createUser(withEmail: email, password: pass) { authResult, error in
               if let error = error {
                   // Handle the error
                   errorMessage = "\(error.localizedDescription)"
                   
               } else {
                   // Navigate to the game screen
                   navigator.navigate(to: .HikingDestination)
               }
           }
    }
}

#Preview {
    NewAccountView()
}
