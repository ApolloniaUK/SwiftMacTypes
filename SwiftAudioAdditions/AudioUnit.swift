//
//  AudioUnit.swift
//  SwiftAdditions
//
//  Created by C.W. Betts on 11/6/14.
//  Copyright (c) 2014 C.W. Betts. All rights reserved.
//

import Foundation
import AudioUnit

public let AudioUnitManufacturer_Apple: OSType = 0x6170706C

public enum AudioComponentType {
	case Output(AUOutput)
	case MusicDevice(AUInstrument)
	case MusicEffect(OSType)
	case FormatConverter(AUConverter)
	case Effect(AUEffect)
	case Mixer(AUMixer)
	case Panner(AUPanner)
	case Generator(AUGenerator)
	case OfflineEffect(AUEffect)
	case MIDIProcessor(OSType)
	case Unknown(AUType: OSType, AUSubtype: OSType)
	
	public init(AUType rawType: OSType, AUSubtype: OSType) {
		switch rawType {
		case AUType.Output.rawValue:
			if let aOut = AUOutput(rawValue: AUSubtype) {
				self = .Output(aOut)
				return
			}
			
		case AUType.MusicDevice.rawValue:
			if let aDevice = AUInstrument(rawValue: AUSubtype) {
				self = .MusicDevice(aDevice)
				return
			}
			
		case AUType.MusicEffect.rawValue:
			self = .MusicEffect(AUSubtype)
			return
			
		case AUType.FormatConverter.rawValue:
			if let aForm = AUConverter(rawValue: AUSubtype) {
				self = .FormatConverter(aForm)
				return
			}
			
		case AUType.Effect.rawValue:
			if let aEffect = AUEffect(rawValue: AUSubtype) {
				self = .Effect(aEffect)
				return
			}
			
		case AUType.Mixer.rawValue:
			if let aMix = AUMixer(rawValue: AUSubtype) {
				self = .Mixer(aMix)
				return
			}
			
		case AUType.Panner.rawValue:
			if let aPann = AUPanner(rawValue: AUSubtype) {
				self = .Panner(aPann)
				return
			}
			
		case AUType.Generator.rawValue:
			if let aGen = AUGenerator(rawValue: AUSubtype) {
				self = .Generator(aGen)
				return
			}
			
		case AUType.OfflineEffect.rawValue:
			if let aEffect = AUEffect(rawValue: AUSubtype) {
				self = .OfflineEffect(aEffect)
				return
			}
			
		case AUType.MIDIProcessor.rawValue:
			self = .MIDIProcessor(AUSubtype)
			return
			
		default:
			break;
		}
		
		
		self = .Unknown(AUType: rawType, AUSubtype: AUSubtype)
	}
	
	public enum AUType: OSType {
		case Output = 0x61756F75
		case MusicDevice = 0x61756D75
		case MusicEffect = 0x61756D66
		case FormatConverter = 0x61756663
		case Effect = 0x61756678
		case Mixer = 0x61756D78
		case Panner = 0x6175706E
		case Generator = 0x6175676E
		case OfflineEffect = 0x61756F6C
		case MIDIProcessor = 0x61756D69
	}
	
	public enum AUOutput: OSType {
		case Generic = 0x67656E72
		case HAL = 0x6168616C
		case Default = 0x64656620
		case System = 0x73797320
		case VoiceProcessingIO = 0x7670696F
	}
	
	public enum AUInstrument: OSType {
		#if os(OSX)
		case DLS = 0x646C7320
		#endif
		case Sampler = 0x73616D70
		case MIDI = 0x6D73796E
	}
	
	public enum AUConverter: OSType {
		case AUConverter = 0x636F6E76
		#if os(OSX)
		case TimePitch = 0x746D7074
		#endif
		#if os(iOS)
		case iPodTime = 0x6970746D
		#endif
		case Varispeed = 0x76617269
		case DeferredRenderer = 0x64656672
		case Splitter = 0x73706C74
		case Merger = 0x6D657267
		case NewTimePitch = 0x6E757470
		case iPodTimeOther = 0x6970746F
	}
	
	public enum AUEffect: OSType {
		case Delay = 0x64656C79
		case LowPassFilter = 0x6C706173
		case HighPassFilter = 0x68706173
		case BandPassFilter = 0x62706173
		case HighShelfFilter = 0x68736866
		case LowShelfFilter = 0x6C736866
		case ParametricEQ = 0x706D6571
		case PeakLimiter = 0x6C6D7472
		case DynamicsProcessor = 0x64636D70
		case SampleDelay = 0x73646C79
		case Distortion = 0x64697374
		case NBandEQ = 0x6E626571
		
		#if os(OSX)
		case GraphicEQ = 0x67726571
		case MultiBandCompressor = 0x6D636D70
		case MatrixReverb = 0x6D726576
		case Pitch = 0x746D7074
		case AUFilter = 0x66696C74
		case NetSend = 0x6E736E64
		case RogerBeep = 0x726F6772
		#elseif os(iOS)
		case Reverb2 = 0x72766232
		case iPodEQ = 0x69706571
		#endif
	}
	
	public enum AUMixer: OSType {
		case MultiChannel = 0x6D636D78
		case Spatial = 0x3364656D
		case Stereo = 0x736D7872
		case Matrix = 0x6D786D78
	}
	
	public enum AUPanner: OSType {
		case SphericalHead = 0x73706872
		case Vector = 0x76626173
		case SoundField = 0x616D6269
		case HRTF = 0x68727466
	}
	
	public enum AUGenerator: OSType {
		case NetReceive = 0x6E726376
		case ScheduledSoundPlayer = 0x7373706C
		case AudioFilePlayer = 0x6166706C
	}
	
	public var types: (AUType: OSType, AUSubtype: OSType) {
		switch self {
		case let .Output(aType):
			return (AUType.Output.rawValue, aType.rawValue)
			
		case let .MusicDevice(aType):
			return (AUType.MusicDevice.rawValue, aType.rawValue)
			
		case let .MusicEffect(aType):
			return (AUType.MusicEffect.rawValue, aType)
			
		case let .FormatConverter(aType):
			return (AUType.FormatConverter.rawValue, aType.rawValue)
			
		case let .Effect(aType):
			return (AUType.Effect.rawValue, aType.rawValue)
			
		case let .Mixer(aType):
			return (AUType.Mixer.rawValue, aType.rawValue)
			
		case let .Panner(aType):
			return (AUType.Panner.rawValue, aType.rawValue)
			
		case let .Generator(aType):
			return (AUType.Generator.rawValue, aType.rawValue)
			
		case let .OfflineEffect(aType):
			return (AUType.OfflineEffect.rawValue, aType.rawValue)
			
		case let .MIDIProcessor(aType):
			return (AUType.MIDIProcessor.rawValue, aType)
			
		case let .Unknown(AUType: aType, AUSubtype: aSubtype):
			return (aType, aSubtype)
		}
	}
}

extension AudioComponentDescription {	
	public init(component: AudioComponentType, manufacturer: OSType = AudioUnitManufacturer_Apple) {
		(componentType, componentSubType) = component.types
		componentManufacturer = manufacturer
		componentFlags = 0
		componentFlagsMask = 0
	}
	
	public var flag: AudioComponentFlags {
		get {
			return AudioComponentFlags(rawValue: componentFlags)
		}
		set {
			componentFlags = newValue.rawValue
		}
	}
	
	public var component: AudioComponentType {
		get {
			return AudioComponentType(AUType: componentType, AUSubtype: componentSubType)
		}
		set {
			(componentType, componentSubType) = newValue.types
		}
	}
}
