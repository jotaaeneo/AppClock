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

        var calendar = Calendar.current
        calendar.timeZone = alarm.timeZone
        var dateComponents = calendar.dateComponents([.hour, .minute], from: alarm.time)
        dateComponents.timeZone = alarm.timeZone

        let trigger: UNNotificationTrigger

        switch alarm.repeatOption {
        case .none:
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        case .daily:
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        case .weekly:
            // Determine weekday in the alarm's timezone so weekly repeats match that zone
            dateComponents.weekday = calendar.component(.weekday, from: alarm.time)
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        case .monthly:
            // Determine day of the month using the alarm's timezone for monthly repeats
            dateComponents.day = calendar.component(.day, from: alarm.time)
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




