//
//  ViewController.swift
//  ChitChat
//
//  Created by Tomer Buzaglo on 07/09/2017.
//  Copyright © 2017 iTomerBu. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class MainViewController: UIViewController {
    
@IBAction func signOut(_ sender: Any) {
    do{
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance().signOut()
    }
    catch let error{
        print(error)
    }
}
    
    var handle: AuthStateDidChangeListenerHandle?
    
    //before the view is loaded:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Add an observer to the auth state of the user.
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user{
                print(user)
            }else{
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let handle = handle{
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

