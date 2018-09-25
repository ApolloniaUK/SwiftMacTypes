//
//  AUOutputBL.swift
//  PlaySequenceSwift
//
//  Created by C.W. Betts on 2/6/18.
//

import Foundation
import AudioToolbox

public class AUOutputBL {
	public private(set) var format: AudioStreamBasicDescription
	var bufferMemory: UnsafeMutableRawPointer? = nil
	var bufferList: UnsafeMutableAudioBufferListPointer
	var bufferCount: Int
	var bufferSize: Int
	public private(set) var frames: UInt32
	
	public init(streamDescription inDesc: AudioStreamBasicDescription, frameCount inDefaultNumFrames: UInt32 = 512) {
		format = inDesc
		bufferSize = 0
		bufferCount = format.isInterleaved ? 1 : Int(format.mChannelsPerFrame)
		frames = inDefaultNumFrames
		let mem1 = malloc(MemoryLayout<AudioBufferList>.alignment + bufferCount * MemoryLayout<AudioBuffer>.alignment).assumingMemoryBound(to: AudioBufferList.self)
		bufferList = UnsafeMutableAudioBufferListPointer(mem1)
	}
	
	/// You only need to call this if you want to allocate a buffer list.
	/// If you want an empty buffer list, just call `prepare()`.
	/// If you want to dispose previously allocted memory, pass in `0`,
	/// then you either have an empty buffer list, or you can re-allocate.
	/// Memory is kept around if an allocation request is less than what is currently allocated.
	public func allocate(frames inNumFrames: UInt32) {
		if inNumFrames != 0 {
			var nBytes = format.framesToBytes(inNumFrames)
			
			guard nBytes > allocatedBytes else {
				return
			}
			
			// align successive buffers for Altivec and to take alternating
			// cache line hits by spacing them by odd multiples of 16
			if bufferCount > 1 {
				nBytes = (nBytes + (0x10 - (nBytes & 0xF))) | 0x10
			}
			
			bufferSize = Int(nBytes)
			
			let memorySize = bufferSize * bufferCount
			let newMemory = malloc(memorySize)
			memset(newMemory, 0, memorySize)	// make buffer "hot"
			
			let oldMemory = bufferMemory
			bufferMemory = newMemory
			free(oldMemory)
			
			frames = inNumFrames
		} else {
			if let mBufferMemory = bufferMemory {
				free(mBufferMemory)
				self.bufferMemory = nil
			}
			bufferSize = 0
			frames = 0
		}
	}
	
	public func prepare() throws {
		try prepare(frames: frames)
	}
	
	/// this version can throw if this is an allocted ABL and `inNumFrames` is `> allocatedFrames`
	/// you can set the bool to true if you want a `nil` buffer list even if allocated
	/// `inNumFrames` must be a valid number (will throw if inNumFrames is 0)
	public func prepare(frames inNumFrames: UInt32, wantNullBufferIfAllocated inWantNullBufferIfAllocated: Bool = false) throws {
		let channelsPerBuffer = format.isInterleaved ? format.mChannelsPerFrame : 1
		
		if bufferMemory == nil || inWantNullBufferIfAllocated {
			bufferList.count = bufferCount
			for i in 0 ..< bufferCount {
				bufferList[i].mNumberChannels = channelsPerBuffer
				bufferList[i].mDataByteSize = format.framesToBytes(inNumFrames)
				bufferList[i].mData = nil
			}
		} else {
			let nBytes = format.framesToBytes(inNumFrames)
			if (Int(nBytes) * bufferCount) > allocatedBytes {
				throw SAACoreAudioError(.tooManyFramesToProcess)
			}
			bufferList.count = bufferCount
			var p = bufferMemory!
			
			for i in 0 ..< bufferCount {
				bufferList[i].mNumberChannels = channelsPerBuffer
				bufferList[i].mDataByteSize = nBytes
				bufferList[i].mData = p
				p += bufferSize
			}
		}
	}
	
	public var ABL: UnsafeMutablePointer<AudioBufferList> {
		return bufferList.unsafeMutablePointer
	}
	
	private var allocatedBytes: Int {
		return bufferSize * bufferCount
	}
	
	deinit {
		free(bufferList.unsafeMutablePointer)
		if let bufferMemory = bufferMemory {
			free(bufferMemory)
		}
	}
}