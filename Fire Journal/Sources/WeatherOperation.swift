//
//  WeatherOperation.swift
//  DashboardTest
//
//  Created by DuRand Jones on 2/7/20.
//  Copyright © 2020 inSky LE. All rights reserved.
//

import Foundation

class WeatherOperation: FJOperation, URLSessionDelegate {
    let nc = NotificationCenter.default
    var date: Date
    var thread:Thread!
    let userDefaults = UserDefaults.standard
    let openWeatherCreds: String = "d062fecfe5654703ecb4090e8ada0673"
    let openWeatherURL: String = "api.openweathermap.org/data/2.5/forecast?zip=92262,us"
    
    var openWeatherDict = [String:Any]()
    var openWeatherCustomDict = [String: String]()
    var sessionFailureCount:Int = 0
    var latitude = "33.8414"
    var longitude = "-116.5347"
    var degrees = ""
    var speed = ""
    var humidity = ""
    var temp = ""
       
    init(_ date: Date, latitude: Double = 34.052240 , longitude: Double = -118.243340 ) {
        self.date = date
        self.latitude = String(latitude)
        self.longitude = String(longitude)
           super.init()
       }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        executing(true)
        
        let session = URLSession(configuration:.default,delegate:nil,delegateQueue:.main)
        
//       let url=URL(string:"https://api.openweathermap.org/data/2.5/weather?units=imperial&lang=en&lat=\(latitude)&lon=\(longitude)&APPID=d062fecfe5654703ecb4090e8ada0673")
//        MARK: - WEATHER STACK API KEY: 4def59c3b13c1df6184dd21703293b9d
//        http://api.weatherstack.com/current?access_key=4def59c3b13c1df6184dd21703293b9d&query=New York
//        http://api.weatherstack.com/current?access_key=4def59c3b13c1df6184dd21703293b9d&query=34.052240,-118.243340&units=f
        
        let wealtherStackUrl = URL(string: "http://api.weatherstack.com/current?access_key=4def59c3b13c1df6184dd21703293b9d&query=\(latitude),\(longitude)&units=f")
//         let url=URL(string:"https://api.openweathermap.org/data/2.5/forecast?units=imperial&lang=en&lat=\(latitude)&lon=\(longitude)&APPID=d062fecfe5654703ecb4090e8ada0673")
        
        let request = URLRequest.init(url: wealtherStackUrl!)
        
           // *** 3 ***
        let dataTask = session.dataTask(with: request) { data, response, error in
            
             if let error = error {
               print("Error:\n\(error)")
             } else {
              
//                print("Raw data:\n\(String(describing: response))\n")
                do {
               
                    let weather = try JSONSerialization.jsonObject(
                        with: data!, options: .mutableContainers) as! [String: AnyObject]
                   print("this weather \(weather)")
                    
                    let list = weather["current"] as? [String: AnyObject]
                    print(list ?? "this")

                    guard let lister = list else { return }
                    for (key, value) in lister {
                        let v = value
                        let k = key
                        if k == "humidity" {
                            let h: Int64 = v as? Int64 ?? 0
                            self.humidity = String(h)
                        }
                        if k == "wind_speed" {
                            let w: Int64 = v as? Int64 ?? 0
                            self.speed = String(w)
                        }
                        if k == "wind_dir" {
                            let d: Int64 = v as? Int64 ?? 0
                            let de: String = String(d)
                            if let direc = Double(de) {
                                self.degrees = Direction(direc).rawValue.uppercased()
                            }
                        }
                        if k == "temperature" {
                            let t: Int64 = v as? Int64 ?? 0
                            self.temp = String(t)
                        }
                        print("here is k \(k)")
                    }
                    print("\\here")
                    self.temp = "\(self.temp)°"
                    self.humidity = "\(self.humidity)%"
                    let wind = "\(self.degrees) \(self.speed) mph"
                    print("here is the temp: \(self.temp)\nhere is humidity: \(self.humidity)\nhere is the wind: \(self.speed) \(self.degrees)")
                    self.userDefaults.set(self.temp, forKey: FJkTEMPERATURE)
                    self.userDefaults.set(self.humidity, forKey: FJkHUMIDITY)
                    self.userDefaults.set(wind, forKey: FJkWINDSPEEDDIRECTION)
                    self.userDefaults.set(Date(),forKey: FJkOPENWEATHER_DATETIME)
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue:FJkWEATHERHASBEENUPDATED), object: nil, userInfo:[FJkTEMPERATURE:self.temp,FJkHUMIDITY:self.humidity,FJkWINDSPEEDDIRECTION:wind])

                    }


                    


                    
                    }
                    catch let jsonError as NSError {
                      // An error occurred while trying to convert the data into a Swift dictionary.
                      print("JSON error description: \(jsonError.description)")
                    }
//               let dataString = String(data: data!, encoding: NSUTF8StringEncoding)
//               print("Human-readable data:\n\(dataString!)")
             }
           }
        
           // *** 6 ***
           dataTask.resume()
        
        guard isCancelled == false else {
            finish(true)
            return
        }
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            print("did we get a challenge \(challenge)")
    //        if sessionFailureCount == 0 {
                let cred = URLCredential.init(user: "djones@rcomcreative.com", password: "d062fecfe5654703ecb4090e8ada0673", persistence: .forSession)
                print(cred)
                completionHandler(URLSession.AuthChallengeDisposition.useCredential, cred)
    //        }
            sessionFailureCount += 1
        }
    
}
