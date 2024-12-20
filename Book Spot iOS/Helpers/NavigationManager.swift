//
//  NavigationManager.swift
//  Book Spot iOS
//
//  Created by Wilmer Ocampo on 19/12/24.
//

import UIKit

class NavigationManager {
    
    // Función para navegar al Login
    static func goToLogin(from viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginNavView") as? LoginNavViewController {
            loginViewController.modalPresentationStyle = .fullScreen
            viewController.present(loginViewController, animated: true, completion: nil)
        }
    }
    
    // Función para navegar al Home
    static func goToHome(from viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeView") as? HomeViewController {
            homeViewController.modalPresentationStyle = .fullScreen
            viewController.present(homeViewController, animated: true, completion: nil)
        }
    }
}
