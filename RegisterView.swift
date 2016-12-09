//
//  RegisterView.swift
//  pseat3
//
//  Created by 최리아 on 10/26/16.
//  Copyright © 2016  UNO. All rights reserved.
//

import UIKit

class RegisterView: UIViewController {
    
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var idField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var passwordconfirmField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
    @IBAction func gotologin(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signuptapped(sender: UIButton) {
        
        
        let username:NSString = usernameField.text! as NSString
        let id:NSString = idField.text! as NSString
        let email:NSString = emailField.text! as NSString
        let password:NSString = passwordField.text! as NSString
        let confirm_password:NSString = passwordconfirmField.text! as NSString
        
        if ( username.isEqualToString("") || id.isEqualToString("") || email.isEqualToString("") || password.isEqualToString("")) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "회원가입 실패"
            alertView.message = "빈칸을 채워주세요"
            alertView.delegate = self
            alertView.addButtonWithTitle("확인")
            alertView.show()
        } else if ( !password.isEqual(confirm_password) ) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "회원가입 실패"
            alertView.message = "비밀번호가 일치하지 않습니다."
            alertView.delegate = self
            alertView.addButtonWithTitle("확인")
            alertView.show()
        } else {
            do {
                 
                 
                let post:NSString = "username=\(username)&id=\(id)&email=\(email)&password=\(password)&confirm_password=\(confirm_password)"
                
                NSLog("PostData: %@",post);
                
                let url:NSURL = NSURL(string: "http://220.67.128.35:8080/signup.php")!
                
                let postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!
                
                let postLength:NSString = String( postData.length )
                
                let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                request.HTTPBody = postData
                request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                
                var reponseError: NSError?
                var response: NSURLResponse?
                
                var urlData: NSData?
                do {
                    urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
                } catch let error as NSError {
                    reponseError = error
                    urlData = nil
                }
                
                if ( urlData != nil ) {
                    let res = response as! NSHTTPURLResponse!;
                    
                    NSLog("Response code: %ld", res.statusCode);
                    
                    if (res.statusCode >= 200 && res.statusCode < 300)
                    {
                        let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                        
                        NSLog("Response ==> %@", responseData);
                        
                        //var error: NSError?
                        
                        do {
                            let jsonData:NSDictionary = try NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                            
                            let success:NSInteger = jsonData.valueForKey("success") as! NSInteger
                            // use jsonData
                        
                    
                        
                      
                        
                        //[jsonData[@"success"] integerValue];
                        
                        NSLog("Success: %ld", success);
                        
                        if(success == 1)
                        {
                            NSLog("회원가입 성공");
                        
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            var error_msg:NSString
                            
                            if jsonData["error_message"] as? NSString != nil {
                                error_msg = jsonData["error_message"] as! NSString
                            } else {
                                error_msg = "Unknown Error"
                            }
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "회원가입 실패"
                            alertView.message = error_msg as String
                            alertView.delegate = self
                            alertView.addButtonWithTitle("확인")
                            alertView.show()
                            
                        }
                            
                        } catch {
                            // report error
                        }
                        
                    } else {
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "회원가입 실패"
                        alertView.message = "Connection Failed"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                }  else {
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "회원가입 실패"
                    alertView.message = "Connection Failure"
                    if let error = reponseError {
                        alertView.message = (error.localizedDescription)
                    }
                    alertView.delegate = self
                    alertView.addButtonWithTitle("확인")
                    alertView.show()
                }
            } catch {
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "회원가입 실패"
                alertView.message = "서버 에러"
                alertView.delegate = self
                alertView.addButtonWithTitle("확인")
                alertView.show()
            }
        }
     
    }
    
    
    
}
