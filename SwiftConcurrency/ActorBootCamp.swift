//
//  Actor.swift
//  SwiftConcurrency
//
//  Created by Ryan Phan on 6/15/25.
//
import SwiftUI

actor MyActorDataManager {
    static let shared = MyActorDataManager()
    var data: [String] = []
    
    public init() {}
    
    func getRandomData() async -> String? {
        data.append(UUID().uuidString)
        return data.randomElement()
    }
}

class MyDataManager {
    static let shared = MyDataManager()
    private init() {}
    var data: [String] = []
    
    // This lock will help to make the Class Thread Safe by not letting everyone access the same data at the same time
    let lock = DispatchQueue(label: "com.MyApp.MyDataManager")
    
    func getRandomData(_ completionHandler: @escaping (_ title: String?) -> ()) {
        
        lock.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
        }
    }
        
}

struct HomeView: View {
//    let manager = MyDataManager.shared
    let manager = MyActorDataManager.shared
    
    @State private var text = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8)
            Text(text)
                .font(.headline)
        }.onReceive(timer) { _ in
            // This is a Class Example of Thread Safe call using Queue from the class itself
//            DispatchQueue.global(qos: .background).async {
//                self.manager.getRandomData { title in
//                    DispatchQueue.main.async {
//                        self.text = title!
//                    }
//                }
//            }
            Task {
                if let data = await self.manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
            
        }
    }
}

struct BrowseView: View {
    let manager = MyActorDataManager.shared
    
    @State private var text = ""
    let timer = Timer.publish(every: 0.5, on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.green.opacity(0.8)
            Text(text)
                .font(.headline)
        }.onReceive(timer) { _ in
            Task {
                if let data = await self.manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        }
    }
}

struct ActorBootCamp: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ActorBootCamp()
}

