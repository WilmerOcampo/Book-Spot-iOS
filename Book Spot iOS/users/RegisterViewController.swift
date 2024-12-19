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
            showError("Todos los campos son obligatorios.")
            return
        }
        
        let alertController = UIAlertController(
            title: "Confirmar Registro",
            message: "¿Estás seguro de que deseas registrarte con los siguientes datos?\n\nEmail: \(email)\nNombre: \(name) \(lastname)\nDNI: \(dni)\nNúmero: \(number)",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Confirmar", style: .default) { [weak self] _ in
            self?.registerUser(email: email, password: password, name: name, lastname: lastname, dni: dni, number: number)
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        self.goToLogin()
    }
}

extension RegisterViewController {
    func registerUser(email: String, password: String, name: String, lastname: String, dni: String, number: String) {
        // Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.showError("Error en el registro: \(error.localizedDescription)")
                return
            }
            guard let user = authResult?.user else { return }
            let userData = User(name: name, lastname: lastname, dni: dni, number: number)
            // Firebase Realtime Database
            self?.saveUserData(uid: user.uid, userData: userData)
        }
    }
    
    func saveUserData(uid: String, userData: User) {
        let ref = Database.database().reference().child("users").child(uid)
        
        ref.setValue(userData.toDictionary()) { error, _ in
            if let error = error {
                self.showError("Error al guardar los datos: \(error.localizedDescription)")
                return
            }
            self.goToHome()
        }
    }
}

extension RegisterViewController {
    func goToLogin(){
        let stoyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = stoyboard.instantiateViewController(withIdentifier: "LoginNavView") as! LoginNavViewController
        view.modalPresentationStyle = .fullScreen
        present(view, animated: true)
    }
    
    func goToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewController(withIdentifier: "HomeView") as! HomeViewController
        view.modalPresentationStyle = .fullScreen
        present(view, animated: true)
    }
}

extension RegisterViewController {
    func showError(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
