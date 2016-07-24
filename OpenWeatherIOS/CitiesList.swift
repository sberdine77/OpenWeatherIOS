//
//  CitiesList.swift
//  OpenWeatherIOS
//
//  Created by Sávio Xavier on 7/21/16.
//  Copyright © 2016 Sávio Xavier. All rights reserved.
//

import UIKit
import MapKit

/*Class that controls the second view (ones that show the list of nearby cities)*/
class CitiesList: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var cities = Array<CityForecast>() //Array of instances of the object 'CityForecast' that recives the forecast of each city from the JSON file
    var coordinate: CLLocationCoordinate2D! //Recives the choosen coordinate from the previous view
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var failureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tCell")
        
        /*In 'prepareForSegue' of 'ViewController.swift', I guarantee that 'CitiesList' is only called if
         'ViewController.coordinate' isn't 'nil'. Then I pass this to 'CitiesList.coordinate'. So, the only
         way 'CitiesList.coordinate' is 'nil', is when the user presses the button 'Back' in
         'Forecast.swift'. In this case, we don't need to download and process the JSON file again.
         (But we need to preserve the tableView ('cities') data. I handle that in both 'prepareForSegue'
         of 'CitiesList.swift' and 'prepareForSegue' of 'Forecast.swift')*/
        if coordinate != nil{
            
            downloadJSON()
            
        }
        
        self.tableView.reloadData()
        
    }
    
    /*Function reponsible for download and deserialize the JSON file*/
    func downloadJSON() {
        
        let lat = String(format: "%f", coordinate.latitude)
        let long = String(format: "%f", coordinate.longitude)
        
        //Concatenates 'lat' and 'long' with Preset strings to form the complete url
        let url = "http://api.openweathermap.org/data/2.5/find?lat=" + lat + "&lon=" + long + "&units=metric&cnt=15&appid=ae61071273b1b96b6063d531b2122659"
    
        let requestURL: NSURL = NSURL(string: url)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        
        //Creates a task with 'session' to execute (with the url request) the download and deserialization of the JSON
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) { //If the request was successfull
                print("Everyone is fine, file downloaded successfully.")
                
                do{
                    
                    //Try to deserialize the JSON, if it don't succeed, jumps to 'catch'
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    /*The following lines guarantee that every data important to this app in the JSON file,
                     are stored in appropriate variables*/
                    if let places = json["list"] as? [[String: AnyObject]] {
                        
                        for city in places {
                            
                            if let name = city["name"] as? String {
                                
                                if let tempMin = city["main"]?["temp_min"] as? Int {
                                    
                                    if let tempMax = city["main"]?["temp_max"] as? Int {
                                        
                                        if let weather = city["weather"] as? [[String: AnyObject]] {
                                            
                                            if let forecast = weather[0]["description"] as? String{
                                                
                                                /*Declares a temporary instance of the object 'CityForecast'
                                                  and store in its variables the important data 
                                                 deserialized above*/
                                                var currentCity = CityForecast()
                                                currentCity.cityName = name
                                                currentCity.minimumTemperature = tempMin
                                                currentCity.maximumTemperature = tempMax
                                                currentCity.forecast = forecast
                                                
                                                /*Append the new elemment (instance of CityForecast), to the
                                                 'cities' array*/
                                                self.cities.append(currentCity)
                                                
                                                /*Asynchronously update the table view with the new data*/
                                                dispatch_async(dispatch_get_main_queue(), {
                                                    self.tableView.reloadData()})
                                                
                                            }
                                            
                                            
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                        
                        
                    }
                    
                }catch {
                    //Error handling of JSON deserialization
                    
                    print("Error with Json: \(error)")
                    self.failureLabel.alpha = 1 //Show the error message
                    
                    /*The 'sleep(X)' is because we don't want the user interacting with the UI while the error message is shown
                     In a app with necessary uninterrupted UI interaction, I recommend:
                     
                     let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), XX * Int64(NSEC_PER_SEC))
                     dispatch_after(time, dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("goBackToMap", sender: self)
                     }
                     
                     Where 'XX' is the delay time in seconds during which the message will be shown
                    */
                    
                    sleep(3)
                    self.performSegueWithIdentifier("goBackToMap", sender: self)
                    
                }
                
            }else{ //If the request wasn't successfull
                
                //Error handling of JSON download
                
                if ((statusCode == 500) || (statusCode == 501) || (statusCode == 502) || (statusCode == 503) || (statusCode == 504) || (statusCode == 507)){
                    
                    self.failureLabel.alpha = 1 //Show the error message
                    
                    /*The 'sleep(X)' is because we don't want the user interacting with the UI while the error message is shown
                     In a app with necessary uninterrupted UI interaction, I recommend:
                     
                     let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), XX * Int64(NSEC_PER_SEC))
                     dispatch_after(time, dispatch_get_main_queue()) {
                     self.performSegueWithIdentifier("goBackToMap", sender: self)
                     }
                     
                     Where 'XX' is the delay time in seconds during which the message will be shown
                     */
                    
                    sleep(3)
                    self.performSegueWithIdentifier("goBackToMap", sender: self)
                    
                }
            }
        }
        
        task.resume()
        
    }
    
    /*Defines the number of rows in the tableView as the number of elemments in 'cities'*/
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cities.count
    }
    
    /*Defines the displayed text in each cell as the field 'cityName' in each elemment of 'cities'*/
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("tCell")! as UITableViewCell
        
        let itemTable : CityForecast = self.cities[indexPath.row]
        
        cell.textLabel?.text = itemTable.cityName
        
        return cell
    }
    
    /*Perform the 'goToForecast' segue when a row is selected*/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        _ = tableView.indexPathForSelectedRow!
        if let _ = tableView.cellForRowAtIndexPath(indexPath) {
            self.performSegueWithIdentifier("goToForecast", sender: self)
        }
        
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToForecast" {
            if let destination = segue.destinationViewController as? Forecast {
                
                //The next two commands define 'cell' as the selected elemment of 'cities'
                let path = tableView.indexPathForSelectedRow?.row
                let cell = cities[path!]
                
                /*The following commands send the fields in 'cell' to the respective fields in
                 'selectedCityForecast', which is a variable (the same type of 'cell') of 'Forecast.swift'*/
                destination.selectedCityForecast.cityName = cell.cityName
                destination.selectedCityForecast.forecast = cell.forecast
                destination.selectedCityForecast.maximumTemperature = cell.maximumTemperature
                destination.selectedCityForecast.minimumTemperature = cell.minimumTemperature
                
                /*The next command sends the 'cities' array to the next view (Forecast). Doing this, we
                 preserve the data, sending back this array in 'prepareForSegue' of 'Forecast.swift', when 
                 the user presses 'Back'. A better technique to bigger apps would be to save the array in a
                 XML or JSON file, and load it only when the user presses 'Back' from 
                 'Forecast.swift' (preserving then, the data). I choose the first option, because it's less 
                 costly for performance and there is no risk of data loss, considering there is only one
                 more screen on the flow. If there are more sreens on this flow branch, I recommend the
                 second technique.*/
                destination.cities = self.cities
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}