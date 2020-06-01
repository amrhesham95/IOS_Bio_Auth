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
        context.localizedFallbackTitle = "Use Passcode"
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
                        let evalErro = LAError(_nsError: error as! NSError)
                        switch evalErro.code {
                        case LAError.Code.userCancel:
                            print("User has canceled")
                        case LAError.Code.userFallback:
                            print("fallback")
                        case LAError.Code.authenticationFailed:
                            print("failed")
                        default:
                            print("general error")
                        }
                    }
                }
            }
        }else{
            print("can't evaluate")
            if let err = errorCanEval{
                let evalErro = LAError(_nsError: err as! NSError)
                switch evalErro.code {
                case LAError.Code.biometryNotEnrolled:
                    print("Biometry Not enrolled")
                default:
                    print("general error")
                }
            }
        }
    }

}

