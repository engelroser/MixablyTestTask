//
//  CheckOutViewController.swift
//  MixablyTestTask
//
//  Created by Admin on 1/9/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage

class CheckOutViewController: MTTBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print(cartData.count)
        print(selectedIndex)
        
        let imageView = self.view.viewWithTag(1001) as! UIImageView
        let titleLbl = self.view.viewWithTag(1002) as! UILabel
        let index = selectedIndex % cartData.count
        titleLbl.text = cartData[index]["name"] as? String
        
        imageView.image = imageData[selectedIndex]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBOutlet weak var act_delete: UIButton!
    
    @IBAction func act_delete(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func act_pay(_ sender: Any) {
        let index = selectedIndex % cartData.count
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.labelText = ""
        Alamofire.request("https://api.trello.com/1/cards/\(cartData[index]["id"] as! String)/idList?value=\(paidlistid)&key=\(app_key)&token=\(token)", method: .put)
            .responseJSON { response in
                print(response.request as Any)  // original URL request
                print(response.response as Any) // URL response
                print(response.result.value as Any)   // result of response serialization
                
                hud?.hide(true)
                
        }
    
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func act_reload(_ sender: Any) {
        
    }
    
    @IBAction func act_back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
