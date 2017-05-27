//
//  VoxeetManager.swift
//  Atlas Messenger
//
//  Created by Daniel Maness on 4/11/17.
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

import Foundation
import LayerKit
import VoxeetSDK
import VoxeetConferenceKit

@objc public class ConferenceParticipant: NSObject {
    public let id: String
    public var name: String
    public var avatarURL: URL?
    
    public init(id: String, name: String, avatarURL: URL?) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
    }
}

@objc public class VoxeetManagerDelegate: NSObject {
    
}

@objc public class VoxeetManager: NSObject {
    
    public static func initializeVoxeetConferenceKit(consumerKey: String, consumerSecret: String) {
        VoxeetConferenceKit.shared.initialize(consumerKey: consumerKey, consumerSecret: consumerSecret);
        VoxeetConferenceKit.shared.appearMaximized = false
    }
    
    public static func openSession(identity: LYRIdentity) {
        let name = identity.firstName ?? identity.displayName ?? ""
        let voxeetParticipant = VoxeetParticipant(id: identity.userID, name: name, avatarURL: identity.avatarImageURL)
        VoxeetConferenceKit.shared.openSession(participant: voxeetParticipant)
    }
    
    public static func createConference(completion: @escaping (_ conferenceID: String?) -> Void) {
        VoxeetSDK.shared.conference.create(parameters: nil, success: { (confId, confAlias) in
            print("voxeet conference created")
            completion(confId)
        }) { (error) in
            print("failed to created voxeet conference\(error)")
            completion(nil)
        }
    }
    
    public static func startConference(conferenceID: String, authenticatedUser: LYRIdentity, participants: Set<LYRIdentity>, success successCompletion: ((Any) -> Swift.Void)?, fail failCompletion: ((Any) -> Swift.Void)?) {
        var voxeetParticipants: [VoxeetParticipant] = [VoxeetParticipant]()
        for participant in participants {
            let name = participant.firstName ?? participant.displayName
            voxeetParticipants.append(VoxeetParticipant(id: participant.userID, name: name!, avatarURL: participant.avatarImageURL))
        }
        
        let name = authenticatedUser.firstName ?? authenticatedUser.displayName ?? ""
        let participant = VoxeetParticipant(id: authenticatedUser.userID, name: name, avatarURL: authenticatedUser.avatarImageURL)
        VoxeetConferenceKit.shared.updateSession(participant: participant)
        
        VoxeetConferenceKit.shared.initializeConference(id: conferenceID, participants: voxeetParticipants)
        VoxeetConferenceKit.shared.startConference(sendInvitation: false, success: { (confID) in
            successCompletion!(confID)
        }) { (error) in
            print("Failed to start Voxeet conferenceID = \(conferenceID) with error \(error)")
            failCompletion!(error)
        }
    }
    
    public static func stopConference(conferenceID: String) {
        VoxeetConferenceKit.shared.stopConference()
    }
    
    public static func status(conferenceID confID: String, success successCompletion: ((Any) -> Swift.Void)?) {
        VoxeetSDK.shared.conference.status(conferenceID: confID, success: { (json) in
            successCompletion!(json)
        }) { (error) in
            //failCompletion?(error)
        }
    }
    
    public static func history(conferenceID confID: String, success successCompletion: ((Any) -> Swift.Void)?) {
        VoxeetSDK.shared.conference.history(conferenceID: confID, success: { (json) in
            successCompletion!(json)
        }) { (error) in
            if error != nil {
//                failCompletion?(error)
            }
        }
    }
}
