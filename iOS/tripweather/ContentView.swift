import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingItem: WeatherEntry?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.items) { item in
                    Button {
                        editingItem = item
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(item.tripName)")
                                .font(Theme.headingFont)
                                .foregroundStyle(Theme.ink)
                            Text("\(item.date)")
                                .font(Theme.captionFont)
                                .foregroundStyle(Theme.secondaryInk)
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityIdentifier("itemRow_\(item.id)")
                }
                .onDelete { offsets in
                    store.delete(at: offsets)
                }
                .listRowBackground(Theme.cardBackground)
            }
            .scrollContentBackground(.hidden)
            .themedBackground()
            .navigationTitle("Trip Weather Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryEditorView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                EntryEditorView(mode: .edit(item))
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

enum EditorMode: Identifiable, Equatable {
    case add
    case edit(WeatherEntry)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id.uuidString
        }
    }
}

struct EntryEditorView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let mode: EditorMode

    @State private var draftTripname: String = ""
    @State private var draftDate: Date = Date()
    @State private var draftCondition: String = ""
    @State private var draftHightemp: Int = 0
    @State private var draftLowtemp: Int = 0
    @State private var draftNotes: String = ""

    init(mode: EditorMode) {
        self.mode = mode
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("WeatherEntry Details") {
                TextField("Tripname", text: $draftTripname)
                    .accessibilityIdentifier("field_tripName")
                DatePicker("Date", selection: $draftDate, displayedComponents: .date)
                    .accessibilityIdentifier("field_date")
                TextField("Condition", text: $draftCondition)
                    .accessibilityIdentifier("field_condition")
                Stepper("Hightemp: \(draftHightemp)", value: $draftHightemp, in: 0...9999)
                    .accessibilityIdentifier("field_highTemp")
                Stepper("Lowtemp: \(draftLowtemp)", value: $draftLowtemp, in: 0...9999)
                    .accessibilityIdentifier("field_lowTemp")
                TextField("Notes", text: $draftNotes)
                    .accessibilityIdentifier("field_notes")
                }

                if case .edit(let item) = mode {
                    Section {
                        Button("Delete", role: .destructive) {
                            store.delete(item)
                            dismiss()
                        }
                        .accessibilityIdentifier("deleteButton")
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .themedBackground()
            .scrollContentBackground(.hidden)
            .navigationTitle(isEditing ? "Edit" : "New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onAppear { loadIfEditing() }
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func loadIfEditing() {
        if case .edit(let item) = mode {
        draftTripname = item.tripName
        draftDate = item.date
        draftCondition = item.condition
        draftHightemp = item.highTemp
        draftLowtemp = item.lowTemp
        draftNotes = item.notes
        } else {
        draftTripname = ""
        draftDate = Date()
        draftCondition = ""
        draftHightemp = 0
        draftLowtemp = 0
        draftNotes = ""
        }
    }

    private func save() {
        switch mode {
        case .add:
            store.add(WeatherEntry(tripName: draftTripname, date: draftDate, condition: draftCondition, highTemp: draftHightemp, lowTemp: draftLowtemp, notes: draftNotes))
        case .edit(let item):
            var updated = item
            updated.tripName = draftTripname
            updated.date = draftDate
            updated.condition = draftCondition
            updated.highTemp = draftHightemp
            updated.lowTemp = draftLowtemp
            updated.notes = draftNotes
            store.update(updated)
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
