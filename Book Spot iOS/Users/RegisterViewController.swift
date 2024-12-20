//
//  RegisterViewController.swift
//  Book Spot iOS
//
//  Created by Wilmer Ocampo on 17/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var lastname: UITextField!
    @IBOutlet weak var dni: UITextField!
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func registerAction(_ sender: Any) {
        guard let email = email.text, !email.isEmpty,
              let password = password.text, !password.isEmpty,
              let name = name.text, !name.isEmpty,
              let lastname = lastname.text, !lastname.isEmpty,
              let dni = dni.text, !dni.isEmpty,
              let number = number.text, !number.isEmpty else {
            AlertManager.showErrorAlert(on: self, message: "Todos los campos son obligatorios.")
            return
        }
        AlertManager.showConfirmationAlert(
            on: self,
            title: "Confirmar Registro",
            message: "¿Estás seguro de que deseas registrarte con los siguientes datos?\n\nEmail: \(email)\nNombre: \(name) \(lastname)\nDNI: \(dni)\nNúmero: \(number)",
            confirmButtonTitle: "Confirmar",
            cancelButtonTitle: "Cancelar",
            confirmHandler: { [weak self] in
                self?.registerUser(email: email, password: password, name: name, lastname: lastname, dni: dni, number: number)
            },
            cancelHandler: nil
        )
    }
    
    @IBAction func loginAction(_ sender: Any) {
        NavigationManager.goToLogin(from: self)
    }
}

extension RegisterViewController {
    func registerUser(email: String, password: String, name: String, lastname: String, dni: String, number: String) {
        // Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else {
                return
            }
            if let error = error {
                AlertManager.showErrorAlert(on: self, message: "Error en el registro: \(error.localizedDescription)")
                return
            }
            guard let user = authResult?.user else { return }
            let userData = User(name: name, lastname: lastname, dni: dni, number: number)
            // Firebase Realtime Database
            self.saveUserData(uid: user.uid, userData: userData)
        }
    }
    
    func saveUserData(uid: String, userData: User) {
        let ref = Database.database().reference().child("users").child(uid)
        
        ref.setValue(userData.toDictionary()) { error, _ in
            if let error = error {
                AlertManager.showErrorAlert(on: self, message: "Error al guardar los datos: \(error.localizedDescription)")
                return
            }
            AlertManager.showAlert(on: self, title: "Éxito", message: "Registro exitoso. ¡Bienvenido!", buttonTitle: "OK") {
                NavigationManager.goToHome(from: self)
            }
        }
    }
}
