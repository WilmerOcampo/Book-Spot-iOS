//
//  ProfileViewController.swift
//  Book Spot iOS
//
//  Created by Wilmer Ocampo on 17/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dniLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser {
            emailLabel.text = user.email
            fetchUserData(userID: user.uid)
        } else {
            showAuthenticationAlert()
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Cerrar sesión",
                                                message: "¿Estás seguro de que deseas cerrar sesión?",
                                                preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Sí", style: .destructive) { _ in
            self.performLogout()
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Get User Data
    func fetchUserData(userID: String) {
        let ref = Database.database().reference().child("users").child(userID)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let userData = snapshot.value as? [String: Any] else {
                self.showError("No se pudo obtener los datos del usuario.")
                return
            }
            
            if let name = userData["name"] as? String,
               let dni = userData["dni"] as? String,
               let lastname = userData["lastname"] as? String,
               let number = userData["number"] as? String {
                // Asignar los valores a las etiquetas
                self.nameLabel.text = name + " " + lastname
                self.dniLabel.text = dni
                self.numberLabel.text = number
            }
        }
    }
    
    func showAuthenticationAlert() {
        let alertController = UIAlertController(title: "No autenticado",
                                                message: "No estás autenticado. ¿Quieres iniciar sesión?",
                                                preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
            NavigationManager.goToLogin(from: self)
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            NavigationManager.goToHome(from: self)
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Realizar el logout
    func performLogout() {
        do {
            try Auth.auth().signOut()
            NavigationManager.goToHome(from: self)
        } catch let signOutError as NSError {
            self.showError("Error al cerrar sesión: \(signOutError.localizedDescription)")
        }
    }
}

extension ProfileViewController {
    func showError(_ message: String) {
        AlertManager.showErrorAlert(on: self, message: message)
    }
}
