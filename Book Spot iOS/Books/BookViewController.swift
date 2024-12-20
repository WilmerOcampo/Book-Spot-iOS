//
//  BookViewController.swift
//  Book Spot iOS
//
//  Created by Wilmer Ocampo on 16/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class BookViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var booksCollectionView: UICollectionView!
    var books: [Book] = []
    let itemRow: CGFloat = 2
    let sectionsInsets = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    
    var categories: [Category] = []
    let itemCategoryRow: CGFloat = 3
    let sectionsCategoryInsets = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        booksCollectionView.dataSource = self
        booksCollectionView.delegate = self
        self.findAllBooks()
        
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.delegate = self
        self.findAllCategories()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollectionView {
            return categories.count
        }
        if collectionView == booksCollectionView {
            return books.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == booksCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath) as! BookCollectionViewCell
            let book = books[indexPath.row]
            cell.imageView.sd_setImage(with: URL(string: book.image), placeholderImage: UIImage(named: "placeholder"))
            cell.titleLabel.text = book.title
            cell.authorLabel.text = book.author
            cell.reserveAction = {
                self.showConfirmationAlert(book: book)
            }
            return cell
        }
        if collectionView == categoriesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCollectionViewCell
            let category = categories[indexPath.row]
            cell.nameLabel.text = category.name
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == booksCollectionView {
            let paddingSpace = sectionsInsets.left + sectionsInsets.right
            let widthFree = collectionView.frame.width - paddingSpace - (itemRow - 1)  * 10
            let widthItem = widthFree / itemRow
            
            return CGSize(width: widthItem, height: 330)
        }
        if collectionView == categoriesCollectionView {
            let paddingSpace = sectionsCategoryInsets.left + sectionsCategoryInsets.right
            let widthFree = collectionView.frame.width - paddingSpace - (itemCategoryRow - 1)  * 10
            let widthItem = widthFree / itemCategoryRow
            
            return CGSize(width: widthItem, height: 50)
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == booksCollectionView {
            return sectionsInsets
        } else if collectionView == categoriesCollectionView {
            return sectionsCategoryInsets
        }
        return UIEdgeInsets.zero
    }
}

extension BookViewController {
    func findAllBooks(){
        let ref = Database.database().reference().child("books")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            var books: [Book] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let bookDict = snapshot.value as? [String: Any] {
                    let bookID = snapshot.key
                    if let book = Book(dict: bookDict, uid: bookID) {
                        books.append(book)
                    }
                }
            }
            
            self.books = books
            self.booksCollectionView.reloadData()
        })
    }
    
    func updateBookStock(book: Book) {
        let ref = Database.database().reference().child("books").child(book.title)
        if book.stock > 0 {
            ref.updateChildValues(["stock": book.stock - 1])
        }
    }
    
    func findAllCategories(){
        let ref = Database.database().reference().child("categories")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            var categories: [Category] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let c = snapshot.value as? [String: Any],
                   let category = Category(dict: c) {
                    categories.append(category)
                }
            }
            self.categories = categories
            self.categoriesCollectionView.reloadData()
        })
    }
    
    func reserveBook(book: Book) {
        guard let userID = UserManager.getCurrentUserID() else {
            AlertManager.showAuthenticationAlert(on: self, message: "Necesitas iniciar sesión para poder reservar", loginAction: {
                NavigationManager.goToLogin(from: self)
            }, cancelAction: {
            })
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let reservationDate = dateFormatter.string(from: Date())
        
        let reservation = Reservation(bookID: book.uid, userID: userID, reservationDate: reservationDate, status: "Pendiente")
        
        let ref = Database.database().reference().child("reservations").childByAutoId()
        
        let reservationData = [
            "bookID": reservation.bookID,
            "userID": reservation.userID,
            "reservationDate": reservation.reservationDate,
            "status": reservation.status
        ]
        
        ref.setValue(reservationData) { error, _ in
            if let error = error {
                AlertManager.showErrorAlert(on: self, message: "Error al guardar la reserva: \(error.localizedDescription)")
                //print()
            } else {
                AlertManager.showSuccessAlert(on: self, message: "Reserva genera exitosamente.")
                self.updateBookStock(book: book)
            }
        }
    }
}

extension BookViewController {
    func showConfirmationAlert(book: Book) {
        AlertManager.showConfirmationAlert(on: self, title: "Confirmación de Reserva", message: "¿Estás seguro de que deseas reservar el libro \"\(book.title)\"?", confirmButtonTitle: "Confirmar", cancelButtonTitle: "Cancelar", confirmHandler: {
            self.reserveBook(book: book)
        })
    }
}
