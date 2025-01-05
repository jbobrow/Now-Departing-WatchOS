//
//  ContentView.swift
//  Now Departing Watch App
//
//  Created by Jonathan Bobrow on 12/29/24.
//

import SwiftUI
import Combine

// Models
struct SubwayLine: Identifiable, Equatable {
    let id: String
    let label: String
    let bg_color: Color
    let fg_color: Color
}

struct Station: Identifiable, Decodable, Equatable {
    let id: String = UUID().uuidString // Automatically generated unique ID
    let display: String
    let name: String

    private enum CodingKeys: String, CodingKey {
        case display
        case name
    }
}

struct APIResponse: Decodable {
    let data: [StationData]
}

struct StationData: Decodable {
    let name: String
    let N: [Train]
    let S: [Train]
}

struct Train: Decodable {
    let route: String
    let time: String
}

struct TrainData: Decodable {
    let station: String
    let arrivalTimes: [Int]
    
    private enum CodingKeys: String, CodingKey {
        case station
        case arrivalTimes = "times" // Adjust if the API uses a different key
    }
}

// Main App Views
struct ContentView: View {
    @EnvironmentObject var stationDataManager: StationDataManager
    @State private var selectedLine: SubwayLine?
    @State private var selectedStation: Station?
    @State private var selectedTerminal: Station?
    @State private var navigationPath = NavigationPath()
    
    let lines = [
        SubwayLine(id: "1", label: "1", bg_color: Color(red: 0.92, green: 0.22, blue: 0.21), fg_color: .white),
        SubwayLine(id: "2", label: "2", bg_color: Color(red: 0.92, green: 0.22, blue: 0.21), fg_color: .white),
        SubwayLine(id: "3", label: "3", bg_color: Color(red: 0.92, green: 0.22, blue: 0.21), fg_color: .white),
        SubwayLine(id: "X", label: "X", bg_color: Color(red: 0.0, green: 0.0, blue: 0.0), fg_color: .black),
        SubwayLine(id: "4", label: "4", bg_color: Color(red: 0.07, green: 0.57, blue: 0.25), fg_color: .white),
        SubwayLine(id: "5", label: "5", bg_color: Color(red: 0.07, green: 0.57, blue: 0.25), fg_color: .white),
        SubwayLine(id: "6", label: "6", bg_color: Color(red: 0.07, green: 0.57, blue: 0.25), fg_color: .white),
        SubwayLine(id: "7", label: "7", bg_color: Color(red: 0.72, green: 0.23, blue: 0.67), fg_color: .white),
        SubwayLine(id: "A", label: "A", bg_color: Color(red: 0.03, green: 0.24, blue: 0.64), fg_color: .white),
        SubwayLine(id: "C", label: "C", bg_color: Color(red: 0.03, green: 0.24, blue: 0.64), fg_color: .white),
        SubwayLine(id: "E", label: "E", bg_color: Color(red: 0.03, green: 0.24, blue: 0.64), fg_color: .white),
        SubwayLine(id: "G", label: "G", bg_color: Color(red: 0.44, green: 0.74, blue: 0.30), fg_color: .white),
        SubwayLine(id: "B", label: "B", bg_color: Color(red: 0.98, green: 0.39, blue: 0.17), fg_color: .white),
        SubwayLine(id: "D", label: "D", bg_color: Color(red: 0.98, green: 0.39, blue: 0.17), fg_color: .white),
        SubwayLine(id: "F", label: "F", bg_color: Color(red: 0.98, green: 0.39, blue: 0.17), fg_color: .white),
        SubwayLine(id: "M", label: "M", bg_color: Color(red: 0.98, green: 0.39, blue: 0.17), fg_color: .white),
        SubwayLine(id: "N", label: "N", bg_color: Color(red: 0.98, green: 0.80, blue: 0.19), fg_color: .black),
        SubwayLine(id: "Q", label: "Q", bg_color: Color(red: 0.98, green: 0.80, blue: 0.19), fg_color: .black),
        SubwayLine(id: "R", label: "R", bg_color: Color(red: 0.98, green: 0.80, blue: 0.19), fg_color: .black),
        SubwayLine(id: "W", label: "W", bg_color: Color(red: 0.98, green: 0.80, blue: 0.19), fg_color: .black),
        SubwayLine(id: "J", label: "J", bg_color: Color(red: 0.60, green: 0.40, blue: 0.22), fg_color: .white),
        SubwayLine(id: "Z", label: "Z", bg_color: Color(red: 0.60, green: 0.40, blue: 0.22), fg_color: .white),
        SubwayLine(id: "L", label: "L", bg_color: Color(red: 0.65, green: 0.66, blue: 0.67), fg_color: .white)
    ]
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            LineSelectionView(lines: lines) { line in
                selectedLine = line
                DispatchQueue.main.async {
                    navigationPath.append("stations")
                }
            }
            .navigationDestination(for: String.self) { route in
                switch route {
                case "stations":
                    if let line = selectedLine,
                       let stations = stationDataManager.stationsByLine[line.id] {
                        StationSelectionView(line: line, onSelect: { station in
                            selectedStation = station
                            DispatchQueue.main.async {
                                navigationPath.append("terminals")
                            }
                        })
                    } else {
                        Text("No stations available for this line.")
                    }
                case "terminals":
                    if let line = selectedLine,
                       let stations = stationDataManager.stationsByLine[line.id] {
                        TerminalSelectionView(line: line, stations: stations, onSelect: { terminal in
                            selectedTerminal = terminal
                            DispatchQueue.main.async {
                                navigationPath.append("times")
                            }
                        })
                    } else {
                        Text("No terminals available for this line.")
                    }
                case "times":
                    if let line = selectedLine,
                        let station = selectedStation,
                        let terminal = selectedTerminal,
                        let stations = stationDataManager.stationsByLine[line.id] {
                        let viewModel = TimesViewModel()  // Create the view model
                        // Pass the terminal's direction (either "N" or "S") based on selectedTerminal
                        let terminalDirection = terminal == stations.first ? "N" : "S"
                        TimesView(viewModel: viewModel, line: line, station: station, direction: terminalDirection)  // Pass it to the view
                    } else {
                        Text("No data available.")
                    }
                default:
                    EmptyView()
                }
            }
            .onChange(of: selectedLine) { newValue in
                print("Selected Line changed to: \(newValue?.id ?? "nil")")
            }
            .onChange(of: selectedStation) { newValue in
                print("Selected Station changed to: \(newValue?.display ?? "nil")")
            }
            .onChange(of: selectedTerminal) { newValue in
                print("Selected Terminal changed to: \(newValue?.display ?? "nil")")
            }
        }
    }
}

// Line Selection View
struct LineSelectionView: View {
    let lines: [SubwayLine]
    let onSelect: (SubwayLine) -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(lines) { line in
                    Button(action: { onSelect(line) }) {
                        Text(line.label)
                            .font(.custom("HelveticaNeue-Bold", size: 26))
                            .foregroundColor(line.fg_color)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(line.bg_color))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
}

struct StationSelectionView: View {
    let line: SubwayLine
    let onSelect: (Station) -> Void

    @EnvironmentObject var dataManager: StationDataManager

    var body: some View {
        if let stations = dataManager.stationsByLine[line.id] {
            List(stations) { station in
                Button(action: { onSelect(station) }) {
                    Text(station.display)
                        .foregroundColor(.white)
                }
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    HStack {
                        Text(line.label)
                            .font(.custom("HelveticaNeue-Bold", size: 26))
                            .foregroundColor(line.fg_color)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(line.bg_color))
                        Text("Select a station")
                            .font(.custom("HelveticaNeue-Bold", size: 18))
                    }
                }
            }
        } else {
            VStack {
                Text("No stations available")
                    .font(.custom("HelveticaNeue-Bold", size: 14))
                    .foregroundColor(.gray)
                Text(line.label)
                    .font(.custom("HelveticaNeue-Bold", size: 26))
                    .foregroundColor(line.fg_color)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(line.bg_color))
            }
        }
    }
}

// Terminal Selection View
struct TerminalSelectionView: View {
    let line: SubwayLine
    let stations: [Station]
    let onSelect: (Station) -> Void
    
    var terminals: [Station] {
        guard stations.count > 1 else { return stations }
        return [stations.first!, stations.last!]
    }
    
    var body: some View {
        List(terminals) { terminal in
            Button(action: { onSelect(terminal) }) {
                Text(terminal.display)
                    .foregroundColor(.white)
            }
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                HStack {
                    Text(line.label)
                        .font(.custom("HelveticaNeue-Bold", size: 26))
                        .foregroundColor(line.fg_color)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(line.bg_color))
                    Text("Select terminal station")
                        .font(.custom("HelveticaNeue-Bold", size: 18))
                }
            }
        }
    }
}

// Times View
struct TimesView: View {
    @ObservedObject var viewModel: TimesViewModel
    let line: SubwayLine
    let station: Station
    let direction: String
    
    var body: some View {
        VStack(spacing: 0) {
            Text(line.label)
                .font(.custom("HelveticaNeue-Bold", size: 60))
                .foregroundColor(line.fg_color)
                .frame(width: 100, height: 100)
                .background(Circle().fill(line.bg_color))
            
            if viewModel.loading {
                Text("Loading...")
                    .font(.custom("HelveticaNeue-Bold", size: 20))
                    .foregroundColor(.gray)
            } else if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .font(.custom("HelveticaNeue-Bold", size: 14))
                    .foregroundColor(.red)
            } else {
                let nextTrains = viewModel.nextTrains;
                if !nextTrains.isEmpty {
                    // Check if the first train is departing (0 minutes)
                    let firstTrainText = nextTrains[0] == 0 ? "Departing" : "\(nextTrains[0]) min"
                    let firstTrainTextSize: CGFloat = nextTrains[0] == 0 ? 28 : 36

                    Text(firstTrainText)
                        .font(.custom("HelveticaNeue-Bold", size: firstTrainTextSize))
                        .foregroundColor(.white)
                
                    Text(nextTrains.dropFirst()
                        .map { "\($0) min" }
                        .joined(separator: ", "))
                        .font(.custom("HelveticaNeue-Bold", size: 14))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                } else {
                    Text("No arrival times available")
                        .font(.custom("HelveticaNeue-Bold", size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            Text(station.name)
                .font(.custom("HelveticaNeue-Medium", size: 20))
                .foregroundColor(.white)
                .padding(.top)
        }
        .padding()
        .onAppear {
            viewModel.startFetchingTimes(for: line, station: station, direction: direction)
            print("Selected Direction: \(direction)")
        }
        .onDisappear {
            viewModel.stopFetchingTimes()
        }
    }
}
