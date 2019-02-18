//
//  ViewController.swift
//  OmyaoVideo
//
//  Created by Vikas  Chauhan on 18/02/19.
//  Copyright © 2019 Vikas  Chauhan. All rights reserved.
//

import UIKit
import OpenTok

class ViewController: UIViewController
{
    
    // Replace with your OpenTok API key
    var kApiKey = "46270582"
    // Replace with your generated session ID
    var kSessionId = "1_MX40NjI3MDU4Mn5-MTU1MDQ3NDM3NDIzMX5iU1B4QzcyVVJreWh4alJjUlMrc2J2Q0V-fg"
    // Replace with your generated token
    var kToken = "T1==cGFydG5lcl9pZD00NjI3MDU4MiZzaWc9YmFkYmY3YTQwNWQ3NDUwMGI1YTY2YTFkYjI1ZmRiMmM3N2EyYWJiMTpzZXNzaW9uX2lkPTFfTVg0ME5qSTNNRFU0TW41LU1UVTFNRFEzTkRNM05ESXpNWDVpVTFCNFF6Y3lWVkpyZVdoNGFsSmpVbE1yYzJKMlEwVi1mZyZjcmVhdGVfdGltZT0xNTUwNDc1ODEzJm5vbmNlPTAuODEyODE0NTYyMDcyOTQ3NyZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNTUxMDgwNjEwJmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9"

    var session: OTSession?
    var publisher: OTPublisher?
    var subscriber: OTSubscriber?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        connectToAnOpenTokSession()
        
    }
    
    // connect with session
    func connectToAnOpenTokSession()
    {
        session = OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self as! OTSessionDelegate)
        var error: OTError?
        session?.connect(withToken: kToken, error: &error)
        if error != nil {
            print(error!)
        }
    }
    
}

// Protocol
// MARK: - OTSessionDelegate callbacks
extension ViewController: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("The client connected to the OpenTok session.")
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        guard let publisher = OTPublisher(delegate: self as! OTPublisherKitDelegate, settings: settings) else {
            return
        }
        
        var error: OTError?
        session.publish(publisher, error: &error)
        guard error == nil else {
            print(error!)
            return
        }
        
        guard let publisherView = publisher.view else {
            return
        }
        let screenBounds = UIScreen.main.bounds
        publisherView.frame = CGRect(x: screenBounds.width - 150 - 20, y: screenBounds.height - 150 - 20, width: 150, height: 150)
        view.addSubview(publisherView)
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("The client disconnected from the OpenTok session.")
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("The client failed to connect to the OpenTok session: \(error).")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream)
    {
        print("A stream was created in the session.")
        subscriber = OTSubscriber(stream: stream, delegate: self as? OTSubscriberKitDelegate)
        guard let subscriber = subscriber else {
            return
        }
        
        var error: OTError?
        session.subscribe(subscriber, error: &error)
        guard error == nil else {
            print(error!)
            return
        }
        
        guard let subscriberView = subscriber.view else {
            return
        }
        subscriberView.frame = UIScreen.main.bounds
        view.insertSubview(subscriberView, at: 0)
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("A stream was destroyed in the session.")
    }
}

// MARK: - OTPublisherDelegate callbacks
extension ViewController: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("The publisher failed: \(error)")
    }
}

// MARK: - OTSubscriberDelegate callbacks
extension ViewController: OTSubscriberDelegate {
    public func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        print("The subscriber did connect to the stream.")
    }
    
    public func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("The subscriber failed to connect to the stream.")
    }
}


