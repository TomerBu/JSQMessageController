//
//  EmailViewController.swift
//  ChitChat
//
//  Created by Tomer Buzaglo on 07/09/2017.
//  Copyright © 2017 iTomerBu. All rights reserved.
//

import UIKit
import FirebaseAuth

class EmailViewController: UIViewController {
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var rocketImage: UIImageView!
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    
    
    enum LoginOrSign {
        case SignIn
        case CrateUser
    }
    
    
    @IBAction func signIn(_ sender: UIButton) {
        logOrSign(choice: .SignIn)
    }
    
    @IBAction func create(_ sender: UIButton) {
        logOrSign(choice: .CrateUser)
    }

    func logOrSign(choice: LoginOrSign){
        let e =  email.text ?? ""
        let pass =  password.text ?? ""
        if e.characters.count < 6 || pass.characters.count < 6{
            showError(message: "Password And Email must contain at least 6 characters"); return
        }
        showProgress()
        
        let callback:AuthResultCallback = { (user, error) in
            if let error = error{
                self.showError(message: error.localizedDescription)
                return
            }
            if let user = user{
                print(user)
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        
        if choice == .CrateUser{
            Auth.auth().createUser(withEmail: e, password: pass, completion: callback)
        }else if choice == .SignIn{
            Auth.auth().signIn(withEmail: e, password: pass, completion: callback)
        }
    }
    
    func showProgress(){
        rocketImage.isHidden = false
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseInOut], animations: {
            self.rocketImage.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.height)
        }, completion: {_ in
            self.rocketImage.transform = CGAffineTransform.identity
            self.rocketImage.isHidden = true
        })
    }
    func hideError(){
        
    }
    func showError(message:String){
        //starting conditions:
        dialogView.transform = CGAffineTransform(translationX: 0, y: +dialogView.frame.height)
        dialogView.isHidden = false
        //set the error messge:
        label.text = message
        label.sizeToFit()
        
        
        //animate:
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 10, options: [], animations: {
            self.dialogView.transform = CGAffineTransform.identity
        }) { (completed) in}
    }
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        let email = self.email.text ?? ""
        showProgress()
        
        Auth.auth().sendPasswordReset(withEmail: email) { (err) in
            if let err = err {
                self.showError(message: err.localizedDescription)
            }else{
                self.showError(message: "Sent You an Email...")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dialogView.layer.cornerRadius = 10
        let width = dialogView.frame.width
        let height = dialogView.frame.height
        let ox = dialogView.frame.origin.x
        let oy = dialogView.frame.origin.y
        dialogView.frame = CGRect(x: ox, y: oy, width: width + 40, height: height)
        dialogView.isHidden = true
        dialogView.center.x = self.view.center.x
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
