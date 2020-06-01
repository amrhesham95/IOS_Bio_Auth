//
//  ViewController.swift
//  BioAuth
//
//  Created by Amr Hesham on 5/31/20.
//  Copyright © 2020 Amr Hesham. All rights reserved.
//

import UIKit
import LocalAuthentication
class ViewController: UIViewController {
    var context = LAContext()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        context.localizedCancelTitle = "End Session"
        context.localizedFallbackTitle = "Fallback!"
        context.localizedReason = "The app needs your authentaction."
        
        // if the user has unlocked the device using touch ID already .. my app can ignore authenticating him again for some duration .. use the following property to set this duration
        context.touchIDAuthenticationAllowableReuseDuration = LATouchIDAuthenticationMaximumAllowableReuseDuration
        evaluatePolicy()
    }

    func evaluatePolicy(){
        var errorCanEval:NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &errorCanEval) {
            
            switch context.biometryType {
            case .faceID:
                print("we are going to use face id")
            case .touchID:
                print("we are going to use touch id")
            case .none:
                print("none.")
           
            @unknown default:
                print("unknown")
            }
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "can't recognize the face") { (success, error) in
                if (success){
                    print("evaluted successfully")
                }else{
                    if let err = error{
                        let evalErro = LAError(_nsError: err as NSError)
                        switch evalErro.code {
                        case LAError.Code.userCancel:
                            print("User has canceled")
                        case LAError.Code.appCancel:
                            // when the time of the authentication context runs out
                            print("Time out")
                        case LAError.Code.userFallback:
                            print("fallback")
                            self.promptForCode()
                        case LAError.Code.authenticationFailed:
                            print("failed")
                        default:
                            print("general error")
                        }
                    }
                }
               
            }
//            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { (t) in
//                               self.context.invalidate()
//                           }
        }else{
            print("can't evaluate")
            if let err = errorCanEval{
                let evalErro = LAError(_nsError: err as! NSError)
                switch evalErro.code {
                case LAError.Code.biometryNotEnrolled:
                    print("Biometry Not enrolled")
                    // simulate if face id not enrolled scenario so pop appears to make the user enroll in face id
                    sendToSettings()
                default:
                    print("general error")
                }
            }
        }
    }
    func promptForCode(){
        DispatchQueue.main.async {
            
        
            let ac = UIAlertController(title: "Enter code", message: "Enter user code", preferredStyle: .alert)
            
            ac.addTextField { (tf) in
                tf.placeholder = "Enter user code here"
                tf.keyboardType = .numberPad
                // to disable copying the text
                tf.isSecureTextEntry = true
            }
            
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                print(ac.textFields?.first?.text ?? "no value")
            }))
            
                self.present(ac, animated: true, completion: nil)
                
        }
    }
    
func sendToSettings(){
    DispatchQueue.main.async {
        
    
        let ac = UIAlertController(title: "Bio enrollment", message: "Would you like to enroll now?", preferredStyle: .alert)
        
       
        
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        
        ac.addAction(UIAlertAction(title: "NO", style: .default, handler:nil))
        
        
            self.present(ac, animated: true, completion: nil)
            
    }
}
}

