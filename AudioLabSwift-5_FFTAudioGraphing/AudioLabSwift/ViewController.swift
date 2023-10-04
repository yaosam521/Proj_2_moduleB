//
//  ViewController.swift
//  AudioLabSwift
//
//  Created by Eric Larson 
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import UIKit
import Metal
import AVFoundation


class ViewController: UIViewController {

    @IBOutlet weak var decibelLabel: UILabel!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var gestureLabel: UILabel!
    
    struct AudioConstants{
        static let AUDIO_BUFFER_SIZE = 1024*4
    }
    
    // setup audio model
    let audio = AudioModel(buffer_size: AudioConstants.AUDIO_BUFFER_SIZE)
    lazy var graph:MetalGraph? = {
        return MetalGraph(userView: self.userView)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Loaded!")
        
        if let graph = self.graph{
            graph.setBackgroundColor(r: 0, g: 0, b: 0, a: 1)
            
            // add in graphs for display
            // note that we need to normalize the scale of this graph
            // becasue the fft is returned in dB which has very large negative values and some large positive values
            graph.addGraph(withName: "fft",
                            shouldNormalizeForFFT: true,
                            numPointsInGraph: AudioConstants.AUDIO_BUFFER_SIZE/2)
            
            graph.addGraph(withName: "time",
                numPointsInGraph: AudioConstants.AUDIO_BUFFER_SIZE)
            
            graph.makeGrids() // add grids to graph
        }
        
        // start up the audio model here, querying microphone
        audio.startMicrophoneProcessing(withFps: 20) // preferred number of FFT calculations per second
        audio.startProcessingSinewaveForPlayback(withFreq: 15000) // playing audio with sineWave

        audio.play()
        
        // run the loop for updating the graph peridocially
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            self.updateGraph()
            self.decibelLabel.text = "Decibels: \(self.audio.getLoudestMagnitude()) dB"
            //TODO - Change this
            self.gestureLabel.text = "Bruh"
        }
       
    }
    
    //To pause when leaving screen
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated);
            audio.pause();
            
        //audio.pause();
    }
    
    
    // periodically, update the graph with refreshed FFT Data
    func updateGraph(){
        
        if let graph = self.graph{
            graph.updateGraph(
                data: self.audio.getFFTData(),
                forKey: "fft"
            )
            
            graph.updateGraph(
                data: self.audio.getTimeData(),
                forKey: "time"
            )
        }
        
    }
    
    @IBOutlet weak var frequencyLabel: UILabel!
    
    // Plays a settable via a slider inaudible tone to the speakers (15-20kHz)
    @IBAction func changeFrequency(_ sender: UISlider) {
        self.audio.sineFrequency = sender.value
        frequencyLabel.text = "Frequency: \(sender.value) Hz"
    }
    
}
