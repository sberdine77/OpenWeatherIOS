//
//  Forecast.swift
//  OpenWeatherIOS
//
//  Created by Sávio Xavier on 7/21/16.
//  Copyright © 2016 Sávio Xavier. All rights reserved.
//

import UIKit

/*Class that controls the third view (that ones showing the detailed forecast)*/
class Forecast: UIViewController {
    
    var selectedCityForecast = CityForecast()
    var cities = Array<CityForecast>()
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var forecastDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Cast (the minimum and maximum temperatures) from 'Int?' to 'String', to show them in labels later
        let max = String(selectedCityForecast.maximumTemperature!)
        let min = String(selectedCityForecast.minimumTemperature!)
        
        //The next four commands load in labels the city and forecast informations
        cityNameLabel.text = selectedCityForecast.cityName
        maxTemperatureLabel.text = max + "°C"
        minTemperatureLabel.text = min + "°C"
        forecastDescriptionLabel.text = selectedCityForecast.forecast
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goBackToCitiesList" {
            if let destination = segue.destinationViewController as? CitiesList {
                
                /*Sends back the 'cities' array to an array of the same type in 'CitiesList.swift' in
                 order to preserve data. More details, see the comments in 178-185 lines of 
                 'CitiesList.swift'*/
                destination.cities = self.cities
                
            }
        }
    }
    
    /*If the user presses 'Back'*/
    @IBAction func back(sender: UIButton) {
        
        self.performSegueWithIdentifier("goBackToCitiesList", sender: self)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
