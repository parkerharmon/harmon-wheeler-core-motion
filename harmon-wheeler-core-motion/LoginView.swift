//
//  LoginView.swift
//  ios1024
//
//  Created by Parker Harmon on 12/2/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var navigator: MyNavigator
    @EnvironmentObject var vm: HikingViewModel
    @State var loginError: String = ""
    
    //variables for loggin in
    @State private var email: String = ""
    @State private var pass: String = ""
    
    var body: some View {
        VStack{
            Text("Hiking App") .font(.largeTitle)
                .fontWeight(.bold) // Make it bold
                .foregroundColor(.darkOlive)
                .padding()
                .shadow(color: .gray, radius: 2, x: 1, y: 1)
        
            if loginError.count > 0 {
                Text("Login Feedback: \(loginError)")
            }
            
            Spacer()
            
            VStack(spacing: 16) {
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
            }
            .padding(20)
            
            HStack{
                Button("Sign In"){
                    checkAuthentication()
                }.disabled(pass.isEmpty || email.isEmpty)
                Button("Sign Up"){
                    navigator.navigate(to: .NewAccountDestination)
                }
            }.padding(20)
            
            Spacer()
        }.buttonStyle(.borderedProminent)
        
    }
    
    func checkAuthentication(){
        Task{
            if await vm.checkUserAcct(user: email, pwd: pass){
                navigator.navigate(to: .HikingDestination)
                loginError = ""
            } else {
                loginError = "Unable to log in"
            }
            
            
        }
    }
}

#Preview {
    LoginView()
}
