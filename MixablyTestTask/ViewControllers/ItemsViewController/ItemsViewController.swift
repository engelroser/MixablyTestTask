//
//  ItemsViewController.swift
//  MixablyTestTask
//
//  Created by Admin on 1/9/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage
import Koloda

let app_key = "2e62ddd8891acf85928024592885e144"
let token = "557ca5652352412ae9aeeb05b5ff85cfd2dc26e219b381c847311957b0cf8ba0"
let itemslistid = "5873e329fbebe1315df18612"
let cartlistid = "5873e330fef5213aab70b050"
let paidlistid = "5873e3367764a75660a1c53d"

var itemsData = [[String:AnyObject]]()
var cartData = [[String:AnyObject]]()
var paidData = [[String:AnyObject]]()
var imageData:[UIImage] = []
var outImageData:[UIImage] = []

var selectedIndex = 0
var selectedTableIndex = 0

private var numberOfCards: Int = 5

class ItemsViewController: MTTBaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var scrollContentViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var paidTableViewHeightConstrinat: NSLayoutConstraint!
    @IBOutlet weak var itemsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cartViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var paidTableView: UITableView!
    
    @IBOutlet weak var kolodaView: KolodaView!
    
    @IBOutlet weak var checkoutButton: UIButton!
    fileprivate var dataSource: [UIImage] = {
        var array: [UIImage] = []
        for index in 0..<numberOfCards {
            array.append(UIImage(named: "Card_like_\(index + 1)")!)
        }
        
        return array
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.kolodaView.dataSource = self
        self.kolodaView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        checkoutButton.isHidden = true;
        self.fetchItemsData()
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
    
    //MARK: - TABLE DELEGATE AND DATASOURCE
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.itemsTableView {
            return itemsData.count
        } else if tableView == self.paidTableView {
            return paidData.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var simpleTableIdentifier:String = ""
        
        if tableView == self.itemsTableView {
            simpleTableIdentifier = "items_table_cell"
        } else if tableView == self.paidTableView {
            simpleTableIdentifier = "paid_table_cell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: simpleTableIdentifier, for: indexPath)
        if tableView == self.itemsTableView {
            
            
            let imageView = cell.viewWithTag(1001) as? UIImageView
            let titleLbl = cell.viewWithTag(1002) as? UILabel
            let deleteButton = cell.viewWithTag(1003) as? UIButton
            
//            deleteButton?.addTarget(self, action: #selector(deleteItemsButtonTapped(index: indexPath.row)), forControlEvents: .TouchUpInside)
            deleteButton?.addTarget(self, action: #selector(deleteItemsButtonTapped(_:)), for: .touchUpInside)
            selectedTableIndex = indexPath.row
            titleLbl?.text = itemsData[indexPath.row]["name"] as? String
            let tempdata = itemsData[indexPath.row]["attachments"] as! [[String:AnyObject]]
            
            print((tempdata[0]["url"] as? String)! as String)
            let url = URL(string: (tempdata[0]["url"] as? String)! as String)!
            let placeholderImage = UIImage(named: "raptorcop_raptorcop_angel1.png")!
            
            imageView?.af_setImage(withURL: url, placeholderImage: placeholderImage)
            
            return cell
            
        } else if tableView == self.paidTableView {
            
            let imageView = cell.viewWithTag(1004) as? UIImageView
            let titleLbl = cell.viewWithTag(1005) as? UILabel
            let deleteButton = cell.viewWithTag(1006) as? UIButton
            
            deleteButton?.addTarget(self, action: #selector(deletePaidButtonTapped(_:)), for: .touchUpInside)
            selectedTableIndex = indexPath.row
            titleLbl?.text = paidData[indexPath.row]["name"] as? String
            let tempdata = paidData[indexPath.row]["attachments"] as! [[String:AnyObject]]
            
            print((tempdata[0]["url"] as? String)! as String)
            let url = URL(string: (tempdata[0]["url"] as? String)! as String)!
            let placeholderImage = UIImage(named: "raptorcop_raptorcop_angel1.png")!
            
            imageView?.af_setImage(withURL: url, placeholderImage: placeholderImage)
            
            return cell
        }
        
        return cell
    }
    
    func  tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            print("asd")
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let carAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Move to Cart") { (action , indexPath ) -> Void in
            
            print("Cart button pressed")
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud?.labelText = ""
            Alamofire.request("https://api.trello.com/1/cards/\(itemsData[indexPath.row]["id"] as! String)/idList?value=\(cartlistid)&key=\(app_key)&token=\(token)", method: .put)
                .responseJSON { response in
                    print(response.request as Any)  // original URL request
                    print(response.response as Any) // URL response
                    print(response.result.value as Any)   // result of response serialization
                    
                    hud?.hide(true)
                    
                    itemsData.remove(at: indexPath.row)
                    cartData.append(itemsData[indexPath.row])
                    let imageView = self.itemsTableView.cellForRow(at: indexPath)?.viewWithTag(1001) as! UIImageView
                    outImageData.append(imageView.image!)
                    imageData.append(imageView.image!)
                    self.itemsTableView.reloadData()
                    self.kolodaView.reloadData()
            }
            
            
            
            
        }
        
        return [carAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if tableView == self.paidTableView {
            return false
        }
        
        return true
    }
    
    
    //MARK: - FETCH ITEMS FROM TRELLO BOARD
    
    func fetchItemsData() {
        
        cartData = []
        itemsData = []
        paidData = []
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.labelText = ""
        
        Alamofire.request("https://api.trello.com/1/boards/5873e1bb059bf2c755b000f6/cards?attachments=true&attachment_fields=url&fields=name,idList,url&key=\(app_key)&token=\(token)").responseJSON { responseData in
            if((responseData.result.value) != nil) {
                
                hud?.hide(true)
                
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                if let resData1 = swiftyJsonVar.arrayObject {
                    
                    for resData in resData1 as! [[String:AnyObject]] {
                        
                        if resData["idList"] as! String == itemslistid {
                            itemsData.append(resData)
                        } else if resData["idList"] as! String == cartlistid {
                            cartData.append(resData)
                        } else if resData["idList"] as! String == paidlistid {
                            paidData.append(resData)
                        }
                    }
                    
                }
          
                if itemsData.count > 0 {
                    self.itemsTableView.dataSource = self
                    self.itemsTableView.delegate = self
                    self.itemsTableView.reloadData()
                    
                    UIView.animate(withDuration: 0.1,
                                   delay: 0.1,
                                   options: UIViewAnimationOptions.curveEaseIn,
                                   animations: { () -> Void in
                                    self.itemsTableViewHeightConstraint.constant = 120
                                    self.view?.layoutIfNeeded()
                    }, completion: { (finished) -> Void in
                        // ....
                    })
                } else {
                    UIView.animate(withDuration: 0.1,
                                   delay: 0.1,
                                   options: UIViewAnimationOptions.curveEaseIn,
                                   animations: { () -> Void in
                                    self.itemsTableViewHeightConstraint.constant = 0
                                    self.view?.layoutIfNeeded()
                    }, completion: { (finished) -> Void in
                        // ....
                    })
                }
                
                if paidData.count > 0 {
                    self.paidTableView.dataSource = self
                    self.paidTableView.delegate = self
                    self.paidTableView.reloadData()
                    
                    UIView.animate(withDuration: 0.1,
                                   delay: 0.1,
                                   options: UIViewAnimationOptions.curveEaseIn,
                                   animations: { () -> Void in
                                    self.paidTableViewHeightConstrinat.constant = 120
                                    self.view?.layoutIfNeeded()
                    }, completion: { (finished) -> Void in
                        // ....
                    })
                    
                } else {
                    UIView.animate(withDuration: 0.1,
                                   delay: 0.1,
                                   options: UIViewAnimationOptions.curveEaseIn,
                                   animations: { () -> Void in
                                    self.paidTableViewHeightConstrinat.constant = 0
                                    self.view?.layoutIfNeeded()
                    }, completion: { (finished) -> Void in
                        // ....
                    })
                }
                
                if cartData.count > 0 {
                    numberOfCards = cartData.count
                    if (imageData.count > 0){
                        
                    } else {
                        imageData = []
                        outImageData = []
                    }
                    
                    for i in 0..<cartData.count {
                        
                        let tempdata = cartData[i]["attachments"] as! [[String:AnyObject]]
                        
                        print((tempdata[0]["url"] as? String)! as String)
                        let url = URL(string: (tempdata[0]["url"] as? String)! as String)!
                        
                        Alamofire.request(url).responseImage { response in
                            debugPrint(response)
                            
                            print(response.request)
                            print(response.response)
                            debugPrint(response.result)
                            
                            if let image = response.result.value {
                                print("image downloaded: \(image)")
                                
                                if outImageData.count >= cartData.count{
                                    
                                } else {
                                    imageData.append(UIImage (data: response.data!)!)
                                    outImageData.append(UIImage (data: response.data!)!)
                                }
                                
                                
                                self.kolodaView.reloadData()
                            }
                            
                            
                        }
                    }
                    
                    UIView.animate(withDuration: 0.1,
                                   delay: 0.1,
                                   options: UIViewAnimationOptions.curveEaseIn,
                                   animations: { () -> Void in
                                    self.cartViewHeightConstraint.constant = 200
                                    self.view?.layoutIfNeeded()
                    }, completion: { (finished) -> Void in
                        // ....
                    })
                    
                } else {
                    UIView.animate(withDuration: 0.1,
                                   delay: 0.1,
                                   options: UIViewAnimationOptions.curveEaseIn,
                                   animations: { () -> Void in
                                    self.cartViewHeightConstraint.constant = 0
                                    self.view?.layoutIfNeeded()
                    }, completion: { (finished) -> Void in
                        // ....
                    })
                }
                
            }
        }
        
        
    }
    
    
    @IBAction func act_reload(_ sender: Any) {
        self.fetchItemsData()
    }
    
    
    func deleteItemsButtonTapped(_ button: UIButton) {
        
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.labelText = ""
        Alamofire.request("https://api.trello.com/1/cards/\(itemsData[selectedTableIndex]["id"] as! String)?key=\(app_key)&token=\(token)", method: .delete)
            .responseJSON { response in
                print(response.request as Any)  // original URL request
                print(response.response as Any) // URL response
                print(response.result.value as Any)   // result of response serialization
                
                hud?.hide(true)
                
                itemsData.remove(at: selectedTableIndex)
                self.itemsTableView.reloadData()
        }
        
    }
    
    func deletePaidButtonTapped(_ button: UIButton) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.labelText = ""
        Alamofire.request("https://api.trello.com/1/cards/\(paidData[selectedTableIndex]["id"] as! String)?key=\(app_key)&token=\(token)", method: .delete)
            .responseJSON { response in
                print(response.request as Any)  // original URL request
                print(response.response as Any) // URL response
                print(response.result.value as Any)   // result of response serialization
                
                hud?.hide(true)
                
                paidData.remove(at: selectedTableIndex)
                self.paidTableView.reloadData()
        }
        
    }
    
}

// MARK: KolodaViewDelegate

extension ItemsViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        let position = kolodaView.currentCardIndex
        for i in 0...outImageData.count-1 {
            imageData.append(outImageData[i])
        }
        kolodaView.insertCardAtIndexRange(position..<position + outImageData.count, animated: true)
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
//        UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
        self.checkoutButton.isHidden = false;
        selectedIndex = index;
    }
    
}

// MARK: KolodaViewDataSource

extension ItemsViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return imageData.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return UIImageView(image: imageData[Int(index)])
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
}
