//
//  ContentView.swift
//  LiveActivities
//
//  Created by 白数叡司 on 2022/09/26.
//

import SwiftUI
import WidgetKit
import ActivityKit

struct ContentView: View {
    // MARK: Updating Live Activity
    @State var currentID: String = ""
    @State var currentSelection: Status = .received
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker(selection: $currentSelection) {
                    Text("Received")
                        .tag(Status.received)
                    Text("Progress")
                        .tag(Status.progress)
                    Text("Ready")
                        .tag(Status.ready)
                } label: {
                    
                }
                .labelsHidden()
                .pickerStyle(.segmented)

                
                // MARK: Initializing Activity
                Button("Start Activity") {
                    addLiveActivity()
                }
                .padding(.top)
                
                // MARK: Removing Activity
                Button("Remove Activity") {
                    removeActivity()
                }
                .padding(.top)
            }
            .navigationTitle("Live Activities")
            .padding(15)
            .onChange(of: currentSelection) { newValue in
                // Retreiving Current Activity From the List Of Phone Activities
                if let activity = Activity.activities.first(where: { (activity: Activity<OrderAttributes>) in
                    activity.id == currentID
                }) {
                    print("Activity Found")
                    // Since I Need to Show Animation I'm Delaying Action For 2s
                    // For Demo Purpose
                    // In Real Case Scenairo Remove the Delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        var updatedState = activity.contentState
                        updatedState.status = currentSelection
                        Task {
                            await activity.update(using: updatedState)
                        }
                    }
                }
            }
        }
    }
    
    func removeActivity() {
        if let activity = Activity.activities.first(where: { (activity: Activity<OrderAttributes>) in
            activity.id == currentID
        }) {
            Task {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                await activity.end(using: activity.contentState, dismissalPolicy: .immediate)
            }
        }
    }
    
    // Note: We need to add Key in Info.plist file not to indicate "The operation couldn't be completed.(~~~)"
    func addLiveActivity() {
        let orderAttributes = OrderAttributes(orderNumber: 26383, orderItems: "Burger & Milk Shake")
        // Since It Doesn't Requires Any Initial Values
        // If Your Content State Struct Contains Initilaizers Then You Must Pass It Here
        let initialContentState = OrderAttributes.ContentState()
        
        do {
            let activity = try Activity.request(attributes: orderAttributes, contentState: initialContentState, pushType: nil)
            // MARK: Storing CurrentID For Updating Activity
            currentID = activity.id
            print("Activity Added Successfully. id: \(activity.id)")
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
