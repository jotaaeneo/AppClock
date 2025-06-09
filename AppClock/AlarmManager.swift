//
//  AlarmManager.swift
//  AppClock
//
//  Created by Alejandro Flores on 08-06-25.
//

import Foundation
import UserNotifications

class AlarmManager {
    static let shared = AlarmManager()
    
    private init() {}
    
    func scheduleAlarm(alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "Alarma"
        content.body = "Son las \(formattedTime(alarm.time, in: alarm.timeZone)) en \(alarm.timeZone.identifier)"
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
        dateComponents.timeZone = alarm.timeZone

        let trigger: UNNotificationTrigger

        switch alarm.repeatOption {
        case .none:
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        case .daily:
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        case .weekly:
            dateComponents.weekday = Calendar.current.component(.weekday, from: Date())
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        case .monthly:
            dateComponents.day = Calendar.current.component(.day, from: Date())
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        }

        let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error al programar alarma: \(error.localizedDescription)")
            }
        }
    }

    func cancelAlarm(id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }

    private func formattedTime(_ date: Date, in timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = timeZone 
        return formatter.string(from: date)
    }
}




