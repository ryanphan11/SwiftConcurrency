//
//  Sendable.swift
//  SwiftConcurrency
//
//  Created by Ryan Phan on 6/15/25.
//

import SwiftUI

actor CurrentUserManager {
    func updateDatabase(userInfo: MyUserInfo) {
        
    }
}
/*
 Sendable
 A thread-safe type whose values can be shared across arbitrary concurrent contexts without introducing a risk of data races.
 */

struct MyUserInfo: Sendable {
    var name: String
}
/*
 Sendable requires Class to be final and class properties to be let not var
 */

final class MyClassUserInfo: Sendable {
    let name: String  // error if use var
    init(name: String) {
        self.name = name
    }
}

class SendableBootCampViewModel: ObservableObject {
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        let info = MyUserInfo(name: "info")
        await manager.updateDatabase(userInfo: info)
    }
}

struct SendableBootCamp: View {
    @StateObject var viewModel = SendableBootCampViewModel()
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    SendableBootCamp()
}
