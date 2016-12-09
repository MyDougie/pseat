//
//  loginView.swift
//  pseat3
//
//  Created by 최리아 on 10/26/16.
//  Copyright © 2016  UNO. All rights reserved.
//

import UIKit

class loginView: UIViewController {
    
   
    @IBOutlet weak var idField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func gotomap(sender: UIButton) {
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        prefs.setInteger(2, forKey: "ISLOGGED")
        prefs.synchronize()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
   
    @IBAction func signintapped(sender: UIButton) {
        
        let id:NSString = idField.text!
        let password:NSString = passwordField.text!
        sender.layer.cornerRadius=5
        sender.layer.borderWidth=1
        sender.layer.borderColor=UIColor.blackColor().CGColor
        
        if ( id.isEqualToString("") || password.isEqualToString("") ) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "로그인 실패"
            alertView.message = "빈칸을 채워주세요"
            alertView.delegate = self
            alertView.addButtonWithTitle("확인")
            alertView.show()
        } else {
            
            do {

                let post:NSString = "id=\(id)&password=\(password)"
                
                NSLog("PostData: %@",post);
                
                let url:NSURL = NSURL(string:"http://220.67.128.35:8080/login.php")!
                
                let postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
                
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
                        
                        let jsonData:NSDictionary = try NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                        
                        
                        let success:NSInteger = jsonData.valueForKey("success") as! NSInteger
                        
                        //[jsonData[@"success"] integerValue];
                        
                        NSLog("Success: %ld", success);
                        
                        if(success == 1)
                        {
                            NSLog("로그인 성공");
                            
                            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                            prefs.setObject(id, forKey: "ID")
                            prefs.setInteger(1, forKey: "ISLOGGED")
                        
                            prefs.synchronize()
                            
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            var error_msg:NSString
                            
                            if jsonData["error_message"] as? NSString != nil {
                                error_msg = jsonData["error_message"] as! NSString
                            } else {
                                error_msg = "Unknown Error"
                            }
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "로그인 실패"
                            alertView.message = error_msg as String
                            alertView.delegate = self
                            alertView.addButtonWithTitle("확인")
                            alertView.show()
                            
                        }
                        
                    } else {
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "로그인 실패"
                        alertView.message = "Connection Failed"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("확인")
                        alertView.show()
                    }
                } else {
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "로그인 실패"
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
                alertView.title = "로그인 실패"
                alertView.message = "서버 에러"
                alertView.delegate = self
                alertView.addButtonWithTitle("확인")
                alertView.show()
            }
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
}

