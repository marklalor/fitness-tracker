//
//  DataModel.swift
//  FitnessTracker
//
//  Created by Mark Lalor on 4/29/19.
//  Copyright © 2019 Jenny Zhao. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

class WorkoutEntry {
    var exerciseName: String?
    var date: Date?
    var details: String?
    
    init(exerciseName: String?, date: Date?, details: String?) {
        self.exerciseName = exerciseName
        self.date = date
        self.details = details
    }
}

class StrengthTrainingEntry: WorkoutEntry {
    enum WeightUnit: String, CaseIterable {
        case pounds, kilograms
        
        static func fromString(_ label: String) -> WeightUnit? {
            return self.allCases.first{ "\($0)" == label }
        }
    }
    
    var weight: Int?
    var weightUnit: WeightUnit?
    var reps: Int?
    var sets: Int?

    init(exerciseName: String?, date: Date?, weight: Int?, weightUnit: WeightUnit?, reps: Int?, sets: Int?, details: String?) {
        super.init(exerciseName: exerciseName, date: date, details: details)
        self.weight = weight
        self.weightUnit = weightUnit
        self.reps = reps
        self.sets = sets
    }
    
    static func fromDictionary(_ dictionary: [String:Any]) -> StrengthTrainingEntry {
        return StrengthTrainingEntry(
            exerciseName: dictionary["exerciseName"] as? String,
            date: dictionary["date"].map{Date(milliseconds: $0 as! Int)},
            weight: dictionary["weight"] as? Int,
            weightUnit: dictionary.keys.contains("weightUnit") ? StrengthTrainingEntry.WeightUnit.fromString(dictionary["weightUnit"] as! String) : nil,
            reps: dictionary["weight"] as? Int,
            sets: dictionary["sets"] as? Int,
            details: dictionary["details"] as? String)
    }
    
    func toDictionary() -> [String:Any] {
        return ["exerciseName": exerciseName,
                "date": date?.millisecondsSince1970,
                "weight": weight,
                "weightUnit": weightUnit?.rawValue,
                "reps": reps,
                "sets": sets,
                "details": details]
    }
}


class CardioEntry: WorkoutEntry {
    enum DurationUnit: String, CaseIterable {
        case seconds, minutes, hours
        
        static func fromString(_ label: String) -> DurationUnit? {
            return self.allCases.first{ "\($0)" == label }
        }
    }
    
    var duration: Int?
    var durationUnit: DurationUnit?

    init(exerciseName: String?, date: Date?, duration: Int?, durationUnit: DurationUnit?, details: String?) {
        super.init(exerciseName: exerciseName, date: date, details: details)
        self.duration = duration
        self.durationUnit = durationUnit
    }
    
    static func fromDictionary(_ dictionary: [String:Any]) -> CardioEntry {
        return CardioEntry(
            exerciseName: dictionary["exerciseName"] as? String,
            date: dictionary["date"].map{Date(milliseconds: $0 as! Int)},
            duration: dictionary["duration"] as? Int,
            durationUnit: dictionary.keys.contains("durationUnit") ? CardioEntry.DurationUnit.fromString(dictionary["durationUnit"] as! String) : nil,
            details: dictionary["details"] as? String)
    }
    
    func toDictionary() -> [String:Any] {
        return ["exerciseName": exerciseName,
                "date": date?.millisecondsSince1970,
                "duration": duration,
                "durationUnit": durationUnit?.rawValue,
                "details": details]
    }
}

class DataModel {
    var strengthTrainingEntries: [StrengthTrainingEntry]
    var cardioEntries: [CardioEntry]

    init(_ strengthTrainingEntries: [StrengthTrainingEntry], _ cardioEntries: [CardioEntry]) {
        self.strengthTrainingEntries = strengthTrainingEntries
        self.cardioEntries = cardioEntries
    }
    
    public static func fromStorage() -> DataModel {
        let strengthTrainingEntries: [StrengthTrainingEntry] = objectFromJson(jsonString: unpersist(key: "strength")) { (dict: [String : AnyObject]) -> StrengthTrainingEntry in
            StrengthTrainingEntry.fromDictionary(dict)
        }
        
        let cardioEntries: [CardioEntry] = objectFromJson(jsonString: unpersist(key: "cardio")) { (dict: [String : AnyObject]) -> CardioEntry in
            CardioEntry.fromDictionary(dict)
        }
        
        return DataModel(strengthTrainingEntries, cardioEntries)
    }
    
    private static func makeJsonString(from object: [[String:Any]]) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            fatalError("Could not save data.")
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    private static func objectFromJson<T>(jsonString: String, initFunction: ([String:AnyObject]) -> T) -> [T] {
        if let jsonData = jsonString.data(using: String.Encoding.utf8) {
            if let jsonObjects = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String:AnyObject]] {
                return jsonObjects!.map{initFunction($0)}
            }
        }
        
        return []
    }
    
    private static func unpersist(key: String) -> String {
        let defaults = UserDefaults(suiteName: "data")
        return defaults?.string(forKey: key) ?? "[]"
    }
    
    private static func persist(data object: String, key: String) {
        let defaults = UserDefaults(suiteName: "data")
        defaults?.set(object, forKey: key)
    }
    
    func persist() {
        let strengthJsonString = DataModel.makeJsonString(from: self.strengthTrainingEntries.map{$0.toDictionary()})!
        DataModel.persist(data: strengthJsonString, key: "strength")
        
        let cardioJsonString = DataModel.makeJsonString(from: self.cardioEntries.map{$0.toDictionary()})!
        DataModel.persist(data: cardioJsonString, key: "cardio")
    }
}
