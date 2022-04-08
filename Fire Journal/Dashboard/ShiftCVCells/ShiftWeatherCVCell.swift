//
//  ShiftWeatherCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/23/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

class ShiftWeatherCVCell: UICollectionViewCell {
    
    let nc = NotificationCenter.default
    let userDefaults = UserDefaults.standard
    
    private var temp: String = ""
    var theTemp: String = "" {
        didSet {
            self.temp = self.theTemp
        }
    }
    private var humidity: String = ""
    var theHumidity: String = "" {
        didSet {
            self.humidity = self.theHumidity
        }
    }
    private var wind: String = ""
    var theWind: String = "" {
        didSet {
            self.wind = self.theWind
        }
    }
    
    let theBackgroundView = UIView()
    
    let titleIconIV = UIImageView()
    let titleL = UILabel()
    
    let temperatureL = UILabel()
    let humidityL = UILabel()
    let windL = UILabel()
    
    let temperature2L = UILabel()
    let humidity2L = UILabel()
    let wind2L = UILabel()
    var theBorderColor: UIColor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}

extension ShiftWeatherCVCell {
    
    func configure() {
        nc.addObserver(self, selector:#selector(getOpenWeather(nc:)),name:NSNotification.Name(rawValue: FJkOPENWEATHER_UPDATENow), object: nil)
        if let t = self.userDefaults.string(forKey: FJkTEMPERATURE) {
            theTemp = t
        }
        if let h = self.userDefaults.string(forKey: FJkHUMIDITY) {
            theHumidity = h
        }
        if let w = self.userDefaults.string(forKey: FJkWINDSPEEDDIRECTION) {
            theWind = w
        }
        configureObjects()
        configureImageAndLabels()
        configureNSLayouts()
    }
    
    @objc func getOpenWeather(nc: Notification) {
        if let userInfo = nc.userInfo as! [String: Any]? {
            if let t = userInfo["FJkTEMPERATURE"] as? String {
                theTemp = t
            }
            if let h = userInfo["FJkHUMIDITY"] as? String {
                theHumidity = h
            }
            if let w = userInfo["FJkWINDSPEEDDIRECTION"] as? String {
                theWind = w
            }
        }
    }
    
    func configureObjects() {
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        titleIconIV.translatesAutoresizingMaskIntoConstraints = false
        titleL.translatesAutoresizingMaskIntoConstraints = false
        temperatureL.translatesAutoresizingMaskIntoConstraints = false
        humidityL.translatesAutoresizingMaskIntoConstraints = false
        windL.translatesAutoresizingMaskIntoConstraints = false
        temperature2L.translatesAutoresizingMaskIntoConstraints = false
        humidity2L.translatesAutoresizingMaskIntoConstraints = false
        wind2L.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(theBackgroundView)
        contentView.addSubview(titleIconIV)
        contentView.addSubview(titleL)
        contentView.addSubview(humidityL)
        contentView.addSubview(temperatureL)
        contentView.addSubview(windL)
        contentView.addSubview(humidity2L)
        contentView.addSubview(temperature2L)
        contentView.addSubview(wind2L)
        
    }
    
    func configureImageAndLabels() {
        
        theBorderColor = UIColor(named: "FJBlueColor")
        theBackgroundView.layer.cornerRadius = 8
        theBackgroundView.layer.borderWidth = 1
        theBackgroundView.layer.borderColor = theBorderColor.cgColor
        
        let weatherImage = UIImage(named: "weather")
        if weatherImage != nil {
            titleIconIV.image = weatherImage
        }
        
        titleL.textAlignment = .left
        titleL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        titleL.textColor = .label
        titleL.adjustsFontForContentSizeCategory = false
        titleL.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleL.numberOfLines = 0
        titleL.text = """
Current
Weather
"""
        
        temperatureL.textAlignment = .left
        temperatureL.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 300))
        temperatureL.textColor = .label
        temperatureL.adjustsFontForContentSizeCategory = false
        temperatureL.text = "Temperature"
        
        humidityL.textAlignment = .left
        humidityL.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 300))
        humidityL.textColor = .label
        humidityL.adjustsFontForContentSizeCategory = false
        humidityL.text = "Humidity"
        
        windL.textAlignment = .left
        windL.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 300))
        windL.textColor = .label
        windL.adjustsFontForContentSizeCategory = false
        windL.text = "Wind"
        
        temperature2L.textAlignment = .left
        temperature2L.font = .systemFont(ofSize: 16)
        temperature2L.textColor = .label
        temperature2L.adjustsFontForContentSizeCategory = false
        temperature2L.text = self.temp
        
        humidity2L.textAlignment = .left
        humidity2L.font = .systemFont(ofSize: 16)
        humidity2L.textColor = .label
        humidity2L.adjustsFontForContentSizeCategory = false
        humidity2L.text = self.humidity
        
        wind2L.textAlignment = .left
        wind2L.font = .systemFont(ofSize: 16)
        wind2L.textColor = .label
        wind2L.adjustsFontForContentSizeCategory = false
        wind2L.text = self.wind
        
    }
    
    func configureNSLayouts() {
        
        if Device.IS_IPHONE {
            
            NSLayoutConstraint.activate([
                
            theBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            theBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            theBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            theBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleIconIV.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 20),
            titleIconIV.topAnchor.constraint(equalTo: theBackgroundView.topAnchor, constant: 20),
            titleIconIV.heightAnchor.constraint(equalToConstant: 65),
            titleIconIV.widthAnchor.constraint(equalToConstant: 65),
            
            titleL.centerYAnchor.constraint(equalTo: titleIconIV.centerYAnchor),
            titleL.heightAnchor.constraint(equalToConstant: 65),
            titleL.leadingAnchor.constraint(equalTo: titleIconIV.trailingAnchor, constant: 15),
            titleL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
            temperatureL.leadingAnchor.constraint(equalTo: titleIconIV.leadingAnchor),
            temperatureL.topAnchor.constraint(equalTo: titleL.bottomAnchor, constant: 10),
            temperatureL.widthAnchor.constraint(equalToConstant: 200),
            temperatureL.heightAnchor.constraint(equalToConstant: 30),
            
            temperature2L.leadingAnchor.constraint(equalTo: temperatureL.trailingAnchor,constant: 15),
            temperature2L.topAnchor.constraint(equalTo: temperatureL.topAnchor),
            temperature2L.heightAnchor.constraint(equalToConstant: 30),
            temperature2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
            humidityL.leadingAnchor.constraint(equalTo: titleIconIV.leadingAnchor),
            humidityL.topAnchor.constraint(equalTo: temperatureL.bottomAnchor, constant: 10),
            humidityL.widthAnchor.constraint(equalToConstant: 200),
            humidityL.heightAnchor.constraint(equalToConstant: 30),
            
            humidity2L.leadingAnchor.constraint(equalTo: humidityL.trailingAnchor,constant: 15),
            humidity2L.topAnchor.constraint(equalTo: humidityL.topAnchor),
            humidity2L.heightAnchor.constraint(equalToConstant: 30),
            humidity2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
            windL.leadingAnchor.constraint(equalTo: titleIconIV.leadingAnchor),
            windL.topAnchor.constraint(equalTo: humidityL.bottomAnchor, constant: 10),
            windL.widthAnchor.constraint(equalToConstant: 200),
            windL.heightAnchor.constraint(equalToConstant: 30),
            
            wind2L.leadingAnchor.constraint(equalTo: windL.trailingAnchor,constant: 15),
            wind2L.topAnchor.constraint(equalTo: windL.topAnchor),
            wind2L.heightAnchor.constraint(equalToConstant: 30),
            wind2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
            ])
        } else {
        
        NSLayoutConstraint.activate([
            
        theBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        theBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        theBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
        theBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        
        titleIconIV.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 20),
        titleIconIV.topAnchor.constraint(equalTo: theBackgroundView.topAnchor, constant: 20),
        titleIconIV.heightAnchor.constraint(equalToConstant: 65),
        titleIconIV.widthAnchor.constraint(equalToConstant: 65),
        
        titleL.centerYAnchor.constraint(equalTo: titleIconIV.centerYAnchor),
        titleL.heightAnchor.constraint(equalToConstant: 65),
        titleL.leadingAnchor.constraint(equalTo: titleIconIV.trailingAnchor, constant: 15),
        titleL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
        
        temperatureL.leadingAnchor.constraint(equalTo: titleIconIV.leadingAnchor),
        temperatureL.topAnchor.constraint(equalTo: titleL.bottomAnchor, constant: 10),
        temperatureL.widthAnchor.constraint(equalToConstant: 250),
        temperatureL.heightAnchor.constraint(equalToConstant: 30),
        
        temperature2L.leadingAnchor.constraint(equalTo: temperatureL.trailingAnchor,constant: 15),
        temperature2L.topAnchor.constraint(equalTo: temperatureL.topAnchor),
        temperature2L.heightAnchor.constraint(equalToConstant: 30),
        temperature2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
        
        humidityL.leadingAnchor.constraint(equalTo: titleIconIV.leadingAnchor),
        humidityL.topAnchor.constraint(equalTo: temperatureL.bottomAnchor, constant: 10),
        humidityL.widthAnchor.constraint(equalToConstant: 250),
        humidityL.heightAnchor.constraint(equalToConstant: 30),
        
        humidity2L.leadingAnchor.constraint(equalTo: humidityL.trailingAnchor,constant: 15),
        humidity2L.topAnchor.constraint(equalTo: humidityL.topAnchor),
        humidity2L.heightAnchor.constraint(equalToConstant: 30),
        humidity2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
        
        windL.leadingAnchor.constraint(equalTo: titleIconIV.leadingAnchor),
        windL.topAnchor.constraint(equalTo: humidityL.bottomAnchor, constant: 10),
        windL.widthAnchor.constraint(equalToConstant: 250),
        windL.heightAnchor.constraint(equalToConstant: 30),
        
        wind2L.leadingAnchor.constraint(equalTo: windL.trailingAnchor,constant: 15),
        wind2L.topAnchor.constraint(equalTo: windL.topAnchor),
        wind2L.heightAnchor.constraint(equalToConstant: 30),
        wind2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
        
        ])
        }
    }
    
}
