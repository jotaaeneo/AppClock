//
//  Models.swift
//  AppClock
//
//  Created by Alejandro Flores on 08-06-25.
//

import Foundation

struct Alarm: Identifiable, Equatable {
    let id: UUID
    var time: Date
    var timeZone: TimeZone
    var repeatOption: RepeatOption 
}

