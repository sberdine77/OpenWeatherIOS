//
//  CityForecast.swift
//  OpenWeatherIOS
//
//  Created by Sávio Xavier on 7/21/16.
//  Copyright © 2016 Sávio Xavier. All rights reserved.
//

import Foundation

/*Class that define the characteristics (fields) of the object 'CityForecast'*/
class CityForecast: NSObject{
    
    var cityName: String?
    var maximumTemperature: Int?
    var minimumTemperature: Int?
    var forecast: String?
    
}