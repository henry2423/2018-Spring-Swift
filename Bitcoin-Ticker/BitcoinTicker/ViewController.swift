//
//  ViewController.swift
//  BitcoinTicker
//
//  Created by Angela Yu on 23/01/2016.
//  Copyright © 2016 London App Brewery. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    var finalURL = ""
    let currencySymbols = ["$", "R$", "$", "¥", "€", "£", "$", "Rp", "₪", "₹", "¥", "$", "kr", "$", "zł", "lei", "₽", "kr", "$", "$", "R"]
    var currencySelected: String = ""
    
    //Pre-setup IBOutlets
    @IBOutlet weak var bitcoinPriceLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
    }

    
    //3 UIPickerView delegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyArray[row]
    }
    
    //didselected the picker
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        finalURL = baseURL + currencyArray[row]     //set the API for that currency
        currencySelected = currencySymbols[row]     //set the Currency Symbol
        getCurrencyValue(url: finalURL)
    }

    
//    
//    //MARK: - Networking
//    /***************************************************************/
    
    func getCurrencyValue(url: String) {
        
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                    //print("Sucess! Got the weather data")
                    let bitcionDataJSON : JSON = JSON(response.result.value!)
                    self.updateBitcoionData(json: bitcionDataJSON)
                    
            } else {
                    print("Error: \(String(describing: response.result.error))")
                    self.bitcoinPriceLabel.text = "Connection Issues"
            }
        }

    }

    
//    //MARK: - JSON Parsing
//    /***************************************************************/
    
    func updateBitcoionData(json : JSON) {
        
        if let tempResult = json["ask"].double {
            bitcoinPriceLabel.text = "\(currencySelected)\(round(tempResult) - 273.15)"
        } else {
            self.bitcoinPriceLabel.text = "Price Unavailable"
        }
        
    }
    




}

