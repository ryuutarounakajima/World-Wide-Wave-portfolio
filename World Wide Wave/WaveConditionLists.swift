//
//  WaveConditionLists.swift
//  World Wide Wave
//
//  Created by Ryuutarou Nakajima on 2025/11/06.
//

import Foundation

struct WaveOptions {
    static let waveSizes: [(key: String, value: String)] = [
        ("", ""),
        ("go home", "go home"),
        ("Waist-high", "Waist-high"),
        ("belly-high", "belly-high"),
        ("Chest-high", "Chest-high"),
        ("Head-high", "Head-high"),
        ("Overhead", "Overhead"),
        ("Double", "Double"),
        ("Triple over", "Triple over")
    ]
    
    static let waveConditions:  [(key: String, value: String)] = [
        ("", ""), ("Go home", "Go home"), ("Choppy", "Choppy"), ("Mushy", "Mushy"), ("Windy", "windy"), ("Clean", "Clean"), ("Glass", "Glass"), ("Rippable", "Rippable"), ("Barrels", "Barrels"), ("Peaky", "Peaky"), ("Gnarly", "Gnarly"), ("Close out", "Close out")
    ]
    
    static let swells:  [(key: String, value: String)] =  [("", ""), ("N", "N"), ("NNE" , "NNE"), ("NE", "NE"), ("ENE", "ENE"), ("E", "E"), ("ESE", "ESE"), ("SE", "SE"), ("SSE", "SSE"), ("S", "S"), ("SSW", "SSW"), ("SW", "SW"), ("WSW", "WSW"), ("W", "W"), ("WNW", "WNW"), ("NW", "NW") , ("NNW", "NNW")
    ]

    
    static let breaks:  [(key: String, value: String)] = [((""), ("")), ("ShoreBreak", "Shorebreak"), ("Beachbreak", "Beachbreak"), ("Poindbreak", "Pointbreak"), ("Sandbar", "Sandbar"), ("Reef", "Reef")]
    
    static let winds:  [(key: String, value: String)] = [("", ""), ("Offshore", "Offshore"), ("Onshore" , "Onshore"), ("Side off", "Side off"), ("Side on", "Side on"), ("ClossShore", "ClossShore")]
    
    static let tides:  [(key: String, value: String)] = [ ("", ""), ("Spring Tide", "Spring Tide"), ("Moderate Tide", "Moderate Tide"), ("Neap Tide", "Neap Tide"), ("Long Tide", "Long Tide"), ("Young Tide", "Young Tide")
    ]
    
    static let waxes:  [(key: String, value: String)] = [("", ""), ("Cold", "Cold"), ("Cool", "Cool"), ("Warm", "Warm"), ("Tropical", "Tropical")]
    
    
}


