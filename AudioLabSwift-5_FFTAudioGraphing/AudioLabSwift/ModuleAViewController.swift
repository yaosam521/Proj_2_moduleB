//
//  ModuleAViewController.swift
//  AudioLabSwift
//
//  Created by Sam Yao on 9/25/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import UIKit
import Metal
import AVFoundation

class ModuleAViewController: UIViewController {
    
    //View to show time and fft graphs
    @IBOutlet weak var graphView: UIView!
    
    //Labels to show Frequency
    //@IBOutlet weak var frequencyOneLabel: UILabel!
    //@IBOutlet weak var frequencyTwoLabel: UILabel!
    
    @IBOutlet weak var frequencyOneLabel: UILabel!
    @IBOutlet weak var frequencyTwoLabel: UILabel!
    
    struct AudioConstants{
        static let AUDIO_BUFFER_SIZE = 16384
    }
    
    //Sets up the Audio Model
    let audio = AudioModel(buffer_size: AudioConstants.AUDIO_BUFFER_SIZE)
    
    
    //Sets up the Graph
    lazy var graph:MetalGraph? = {
        return MetalGraph(userView: self.graphView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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

        audio.play()
        
        var results:[Double] = []
        
        // run the loop for updating the graph peridocially
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            self.updateGraph()
            
            results = self.audio.getTwoLoudestFrequencies()
            print(results)
            if !results.contains(0.0) {
                self.frequencyOneLabel.text = String(format: "%.2f Hz",results[0])
                self.frequencyTwoLabel.text = String(format:"%.2f Hz", results[1])
            }
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
    
    /**
        This function is designed to grab the top two loudest frequencies and return them as an array.
     
     My idea was to have this return the top two frequencies and change the labels 'Frequency 1' and 'Frequency 2' respectively.
     
     return: [NSInteger,NSInteger]
     */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
