//
//  ViewController.swift
//  Bookingstatus
//
//  Created by Venkatesh on 08/12/19.
//  Copyright © 2019 Venkatesh. All rights reserved.
//

import UIKit

struct res: Decodable {
    var PNR: String?
    var Status: String?
}

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet weak var heading: UILabel! {
        didSet {
            heading.text = "ENTER STATUS OF LUGGAGE"
            heading.textColor = .white
        }
    }
    
    
    @IBOutlet weak var pnr: UILabel! {
        didSet {
            pnr.text = "ENTER PNR"
            pnr.textColor = .white
        }
    }
    
    
    @IBOutlet weak var enterPnr: UITextField!
    
    
    @IBOutlet weak var status: UILabel! {
        didSet {
            status.text = "ENTER STATUS"
            status.textColor = .white
        }
    }
    
    
    @IBOutlet weak var enterStatus: UITextField! {
        didSet {
            enterStatus.delegate = self
        }
    }
    
    
    @IBOutlet weak var picker: UIPickerView! {
        didSet {
            picker.dataSource = self
            picker.delegate = self
            picker.backgroundColor = .white
            picker.isHidden = true
        }
    }
    
    
    @IBOutlet weak var submit: UIButton! {
        didSet {
            submit.setTitle("SUBMIT", for: .normal)
            submit.addTarget(self, action: #selector(state), for: .touchUpInside)
        }
    }
    
    
    
    @IBOutlet weak var pickerHeight: NSLayoutConstraint!
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return list.count
        
    }
    
    var list = ["Not yet submitted", "Luggage submitted", "Security Checked", "Passing through belts", "Checked", "Collected"]
    var selected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
       view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        // Do any additional setup after loading the view.
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
            self.view.endEditing(true)
        return list[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == self.picker {
            self.enterStatus.text = self.list[row]
            self.picker.isHidden = true
            selected = row
            pickerHeight.constant = 0
        }
        
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == self.enterStatus {
            self.picker.isHidden = false
            pickerHeight.constant = 100
            //if you dont want the users to se the keyboard type:
            textField.endEditing(true)
        }
        
    }
    
    @objc func state() {
        
        guard let pnr = enterPnr.text else {
            return
        }
        
        let value = list[selected]
        print(value)
        var request = URLRequest(url: URL(string: "http://100.82.192.20:8099/api/LuggageStatusChange?PNR=RIRYSOOA&Status=\(selected)")!)
        request.httpMethod = "POST"
        DispatchQueue.main.async {
            self.showLoader()
        }
        URLSession.shared.dataTask(with: request) {(data, response, error ) in
            DispatchQueue.main.async {
                self.hideLoader()
            }
            guard error == nil else {
                print(error)
                print("returned error")
                return
            }
            
            guard let content = data else {
                print("No data")
                return
            }
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!)
                print(parsedData)
                print(data)
                if let d = data {
                    let str = try JSONDecoder().decode(res.self, from: d)
                    print(str)
                    DispatchQueue.main.async {
                        self.showToast(message: "Success", font: UIFont(name: "HelveticaNeue-UltraLight", size: 20.0)!)
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            }.resume()
        
    }


}

extension UIViewController {
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    func showLoader() {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideLoader() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
