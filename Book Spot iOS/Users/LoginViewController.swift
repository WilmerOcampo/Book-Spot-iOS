//
//  LoginViewController.swift
//  Book Spot iOS
//
//  Created by Wilmer Ocampo on 17/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentUser = Auth.auth().currentUser {
            NavigationManager.goToHome(from: self)
        }
    }
    
    @IBAction func loginAction(_ sender: Any) {
        // Validar campos
        guard let emailText = email.text, !emailText.isEmpty,
              let passwordText = password.text, !passwordText.isEmpty else {
            showError("Por favor, ingresa tu correo electrónico y contraseña.")
            return
        }
        loginUser(email: emailText, password: passwordText)
    }
    
    // Login: Firebase Auth
    func loginUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                self.showError("Error de inicio de sesión: \(error.localizedDescription)")
                return
            }
            if let user = result?.user {
                self.fetchUserData(userID: user.uid)
            }
        }
    }
    
    // Obtener los datos del usuario
    func fetchUserData(userID: String) {
        let ref = Database.database().reference().child("users").child(userID)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let userData = snapshot.value as? [String: Any] else {
                self.showError("No se pudo obtener los datos del usuario.")
                return
            }
            if let name = userData["name"] as? String {
                self.showWelcomeAlert(userName: name)
            }
        }
    }
}

extension LoginViewController {
    func showError(_ message: String) {
        AlertManager.showErrorAlert(on: self, message: message)
    }
    
    func showWelcomeAlert(userName: String) {
        AlertManager.showAlert(on: self, title: "¡Bienvenido!", message: "¡Hola, \(userName)! Has iniciado sesión con éxito.", buttonTitle: "OK") {
            NavigationManager.goToHome(from: self)
        }
    }
}
