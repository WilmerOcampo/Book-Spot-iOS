//
//  AlertManager.swift
//  Book Spot iOS
//
//  Created by Wilmer Ocampo on 19/12/24.
//

import UIKit

class AlertManager {
    
    // Alert con un solo botón
    static func showAlert(on viewController: UIViewController, title: String, message: String, buttonTitle: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default) { _ in
            completion?()
        }
        alertController.addAction(action)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    // Confirmation alert
    static func showConfirmationAlert(on viewController: UIViewController, title: String, message: String, confirmButtonTitle: String, cancelButtonTitle: String, confirmHandler: @escaping () -> Void, cancelHandler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmButtonTitle, style: .default) { _ in
            confirmHandler()
        }
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
            cancelHandler?()
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    // Success alert
    static func showSuccessAlert(on viewController: UIViewController, message: String) {
        showAlert(on: viewController, title: "Éxito", message: message, buttonTitle: "OK")
    }
    
    // Error alert
    static func showErrorAlert(on viewController: UIViewController, message: String) {
        showAlert(on: viewController, title: "Error", message: message, buttonTitle: "OK")
    }
    
    // Mostrar alerta de autenticación
    static func showAuthenticationAlert(on viewController: UIViewController, message: String, loginAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        let alertController = UIAlertController(title: "No autenticado", message: message, preferredStyle: .alert)
        let loginActionAlert = UIAlertAction(title: "OK", style: .default) { _ in
            loginAction()
        }
        let cancelActionAlert = UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            cancelAction()
        }
        alertController.addAction(loginActionAlert)
        alertController.addAction(cancelActionAlert)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
