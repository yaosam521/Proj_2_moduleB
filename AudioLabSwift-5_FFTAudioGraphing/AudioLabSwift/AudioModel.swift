//
//  AudioModel.swift
//  AudioLabSwift
//
//  Created by Eric Larson 
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import Foundation
import Accelerate
import AVFoundation

class AudioModel {
    
    // MARK: Properties
    private var BUFFER_SIZE:Int
    // thse properties are for interfaceing with the API
    // the user can access these arrays at any time and plot them if they like
    private var timeData:[Float]
    private var fftData:[Float]

    //A Variable that has the sampling rate
    private var samplingRate:Double

    
    
    // MARK: Public Methods
    init(buffer_size:Int) {
        BUFFER_SIZE = buffer_size
        
        // anything not lazily instatntiated should be allocated here
        timeData = Array.init(repeating: 0.0, count: BUFFER_SIZE)
        fftData = Array.init(repeating: 0.0, count: BUFFER_SIZE/2)
        
        //Immediately store the sampling rate, as it is a constant
        samplingRate = AVAudioSession.sharedInstance().sampleRate
    }
    
    // public function for starting processing of microphone data
    func startMicrophoneProcessing(withFps:Double){
        // setup the microphone to copy to circualr buffer
        if let manager = self.audioManager{
            manager.inputBlock = self.handleMicrophone
            
            // repeat this fps times per second using the timer class
            //   every time this is called, we update the arrays "timeData" and "fftData"
            Timer.scheduledTimer(withTimeInterval: 1.0/withFps, repeats: true) { _ in
                self.runEveryInterval()
            }
            
        }
    }
    
    func getFFTData() -> Array<Float>{
        return self.fftData
    }
    
    func getTimeData() -> Array<Float>{
        return self.timeData
    }

    // You must call this when you want the audio to start being handled by our model
    func play(){
        
        if let manager = self.audioManager{
            manager.play()
        }
    }
    
    /**
     Function that calculates the two loudest frequencies from the microphone.
     
     How it works:
     For loop reads through every magnitude in the FFT Data
     It selects the loudest magnitude, saving the location within the array to calculate the frequency.
     The second loudest magnitude is saved if and only if the iteration is plus or minus 17 from the first magnitude.
     
     17 was calculated from the sampleRate/N equation, as each iteration in the fft array is roughly an increase in 3 Hz. Therefore 17 * 3 = 51
     
     If the combined magnitudes is no louder than 50 db (an arbitrary value), the return array will be set to 0.0
     Otherwise, it returns an array of two elements, both of them frequencies in Hertz.
     */
    func getTwoLoudestFrequencies()->Array<Double>{
        //Static constant for sampling rate over buffer size
        let samplingOverN = self.samplingRate/Double(self.getDataSize())
        
        //Arbitrarily set float values
        var magnitudeOne:Float = -1000
        var magnitudeTwo:Float = -1000
        
        //Frequencies initially set to arbitrary values
        var frequencyOne:Double = -1000
        var frequencyTwo:Double = -10000
        
        //Indices for calculating frequencies. Set to zero initially
        var indexOne:Int = 0
        var indexTwo:Int = 0
        
        /**
         Loop that calculates the two largest frequencies.
         
         Two frequencies, chilling in an FFT Graph, 50 Hz Apart
         */
        for i in 0...self.fftData.count-1{
            if self.fftData[i] > magnitudeOne{
                
                //Update if and only if 'i' is 17 indices away from indexOne
                if (i > indexOne + 17 || i < indexOne - 17){
                    magnitudeTwo = magnitudeOne
                    indexTwo = indexOne
                }
                
                //Update indexOne
                magnitudeOne = self.fftData[i]
                indexOne = i
                
            //Set magnitude of second loudest tone
            }else if self.fftData[i] > magnitudeTwo && (i > indexOne + 17 || i < indexOne - 17){
                magnitudeTwo = self.fftData[i]
                indexTwo = i
            }
        }
        
        //Print statement used for debugging
        print(indexOne)
        print(indexTwo)
        
        //Calculates the first and second frequencies
        frequencyOne = Double(indexOne) * samplingOverN
        frequencyTwo = Double(indexTwo) * samplingOverN
        
        //Return array
        var result:[Double] = []
        
        //If magnitudes are louder than 50 decibels, populate array with frequencies
        //Otherwise, leave them blank
        if magnitudeOne + magnitudeTwo > 50{
            result = [frequencyOne, frequencyTwo]
        }else{
            result = [0.0,0.0]
        }
        
        return result
    }
    
    
    //==========================================
    // MARK: Private Properties
    private lazy var audioManager:Novocaine? = {
        return Novocaine.audioManager()
    }()
    
    private lazy var fftHelper:FFTHelper? = {
        return FFTHelper.init(fftSize: Int32(BUFFER_SIZE))
    }()
    
    
    private lazy var inputBuffer:CircularBuffer? = {
        return CircularBuffer.init(numChannels: Int64(self.audioManager!.numInputChannels),
                                   andBufferSize: Int64(BUFFER_SIZE))
    }()
    
    
    //==========================================
    // MARK: Private Methods
    
    /**
     Private Helper Function that returns size of microphone array.
     Purpose is to make calculation code look less messy
     */
    private func getDataSize() -> Int{
        return self.timeData.count
    }
   
    //==========================================
    // MARK: Model Callback Methods
    private func runEveryInterval(){
        if inputBuffer != nil {
            // copy time data to swift array
            self.inputBuffer!.fetchFreshData(&timeData,
                                             withNumSamples: Int64(BUFFER_SIZE))
            
            // now take FFT
            fftHelper!.performForwardFFT(withData: &timeData,
                                         andCopydBMagnitudeToBuffer: &fftData)
            
            // at this point, we have saved the data to the arrays:
            //   timeData: the raw audio samples
            //   fftData:  the FFT of those same samples
            // the user can now use these variables however they like
            
        }
    }
    
    //==========================================
    // MARK: Audiocard Callbacks
    // in obj-C it was (^InputBlock)(float *data, UInt32 numFrames, UInt32 numChannels)
    // and in swift this translates to:
    private func handleMicrophone (data:Optional<UnsafeMutablePointer<Float>>, numFrames:UInt32, numChannels: UInt32) {
        // copy samples from the microphone into circular buffer
        self.inputBuffer?.addNewFloatData(data, withNumSamples: Int64(numFrames))
    }
    
    //pause function called when leaving view and button
    func pause(){
        if let manager = self.audioManager{
            manager.pause()
            
        }
    }
    
   
    //implemented for audio output as a sine wave //can be user adjusted
    var sineFrequency:Float = 0.0 { // frequency in Hz (changeable by user)
        didSet{
            // if using swift for generating the sine wave: when changed, we need to update our increment
            //phaseIncrement = Float(2*Double.pi*sineFrequency/audioManager!.samplingRate)
            
            // if using objective c: this changes the frequency in the novocain block
            self.audioManager?.sineFrequency = sineFrequency
        }
    }
        func startProcessingSinewaveForPlayback(withFreq:Float=330.0){
            sineFrequency = withFreq
            // Two examples are given that use either objective c or that use swift
            //   the swift code for loop is slightly slower thatn doing this in c,
            //   but the implementations are very similar
            //self.audioManager?.outputBlock = self.handleSpeakerQueryWithSinusoid // swift for loop
            self.audioManager?.setOutputBlockToPlaySineWave(sineFrequency) // c for loop
        }

}
