//
//  ContentView.swift
//  AppClock
//
//  Created by Alejandro Flores on 08-06-25.
//
import SwiftUI

struct ContentView: View {
    @State private var alarms: [Alarm] = []
    @State private var selectedTime = Date()
    @State private var selectedTimeZone: TimeZone = .current
    @State private var selectedRepeatOption: RepeatOption = .none
    @State private var editingAlarm: Alarm?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Configurar Alarma")) {
                    DatePicker("Selecciona hora", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .environment(\.calendar, Calendar(identifier: .gregorian))
                        .environment(\.timeZone, selectedTimeZone)
                        .environment(\.locale, Locale(identifier: "en_GB"))

                    Picker("Zona Horaria", selection: $selectedTimeZone) {
                        ForEach(cityTimeZones, id: \.identifier) { tz in
                            Text(tz.identifier.components(separatedBy: "/").last ?? tz.identifier).tag(tz)
                        }
                    }

                    Picker("Repetir", selection: $selectedRepeatOption) {
                        ForEach(RepeatOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }

                    HStack {
                        Text("Hora local:")
                        Spacer()
                        Text(localPreviewTimeString)
                            .foregroundColor(.gray)
                    }

                    Button(editingAlarm == nil ? "Agregar Alarma" : "Guardar Cambios") {
                        if let existing = editingAlarm,
                           let index = alarms.firstIndex(where: { $0.id == existing.id }) {
                            let updated = Alarm(id: existing.id, time: selectedTime, timeZone: selectedTimeZone, repeatOption: selectedRepeatOption)
                            alarms[index] = updated
                            AlarmManager.shared.cancelAlarm(id: updated.id)
                            AlarmManager.shared.scheduleAlarm(alarm: updated)
                            editingAlarm = nil
                        } else {
                            let newAlarm = Alarm(id: UUID(), time: selectedTime, timeZone: selectedTimeZone, repeatOption: selectedRepeatOption)
                            alarms.append(newAlarm)
                            AlarmManager.shared.scheduleAlarm(alarm: newAlarm)
                        }
                    }
                } 

                Section(header: Text("Alarmas Programadas")) {
                    ForEach(alarms) { alarm in
                        VStack(alignment: .leading) {
                            Text("Hora en \(alarm.timeZone.identifier): \(formattedTime(alarm.time, in: alarm.timeZone))")
                            Text("Hora local: \(formattedTimeInLocal(from: alarm.time, fromTimeZone: alarm.timeZone))")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("Repetir: \(alarm.repeatOption.rawValue)")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                confirmDelete(alarm: alarm)
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }

                            Button {
                                editAlarm(alarm)
                            } label: {
                                Label("Editar", systemImage: "pencil")
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "alarm")
                        Text("Alarma Mundial")
                            .font(.headline)
                    }
                }
            }
        }
    }

    var cityTimeZones: [TimeZone] {
        TimeZone.knownTimeZoneIdentifiers
            .compactMap { TimeZone(identifier: $0) }
            .filter { $0.identifier.contains("/") }
            .sorted { $0.identifier < $1.identifier }
    }

    var localPreviewTimeString: String {
        let calendar = Calendar(identifier: .gregorian)
        var destCalendar = calendar
        destCalendar.timeZone = selectedTimeZone

        let now = Date()
        let timeComponents = destCalendar.dateComponents([.hour, .minute], from: selectedTime)
        let destinationComponents = DateComponents(
            year: calendar.component(.year, from: now),
            month: calendar.component(.month, from: now),
            day: calendar.component(.day, from: now),
            hour: timeComponents.hour,
            minute: timeComponents.minute
        )

        guard let destinationDate = destCalendar.date(from: destinationComponents) else { return "?" }

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter.string(from: destinationDate)
    }

    func formattedTime(_ date: Date, in timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = timeZone
        return formatter.string(from: date)
    }

    func formattedTimeInLocal(from date: Date, fromTimeZone: TimeZone) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = fromTimeZone

        let components = calendar.dateComponents([.hour, .minute], from: date)
        let now = Date()
        let dateInSourceTZ = calendar.date(from: DateComponents(
            year: calendar.component(.year, from: now),
            month: calendar.component(.month, from: now),
            day: calendar.component(.day, from: now),
            hour: components.hour,
            minute: components.minute
        )) ?? date

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter.string(from: dateInSourceTZ)
    }

    func editAlarm(_ alarm: Alarm) {
        selectedTime = alarm.time
        selectedTimeZone = alarm.timeZone
        selectedRepeatOption = alarm.repeatOption
        editingAlarm = alarm
    }

    func confirmDelete(alarm: Alarm) {
        AlarmManager.shared.cancelAlarm(id: alarm.id)
        alarms.removeAll { $0.id == alarm.id }
    }
}


#Preview {
    ContentView()
}
