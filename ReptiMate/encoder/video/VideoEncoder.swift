//
//  VideoEncoder.swift
//  app
//
//  Created by Pedro  on 16/5/21.
//  Copyright © 2021 pedroSG94. All rights reserved.
//

import Foundation
import AVFoundation
import VideoToolbox
import CoreFoundation

extension UInt32 {
    func toBytes() -> [UInt8] {
        let b1 = UInt8(self & 0x1F)
        let b2 = UInt8(self >> 8)
        let b3 = UInt8(self >> 16)
        let b4 = UInt8(self >> 24)
        return [UInt8](arrayLiteral: b1, b2, b3, b4)
    }
}

public class VideoEncoder {
    
    private var resolution: CameraHelper.Resolution = .vga640x480
    private var fps: Int = 60
    private var bitrate: Int = 1500 * 1000
    private var iFrameInterval: Int = 2
    private var initTs: Int64 = 0
    private var isSpsAndPpsSend = false
    private var running = false
    private var forceKey = false
    private var codec = CodecUtil.H264

    private var session: VTCompressionSession?
    private let callback: GetH264Data
    
    public init(callback: GetH264Data) {
        self.callback = callback
    }

    public func prepareVideo() -> Bool {
        prepareVideo(resolution: resolution, fps: fps, bitrate: bitrate, iFrameInterval: iFrameInterval)
    }

    public func prepareVideo(resolution: CameraHelper.Resolution, fps: Int, bitrate: Int, iFrameInterval: Int) -> Bool {
        let err = VTCompressionSessionCreate(allocator: nil, width: Int32(resolution.width), height: Int32(resolution.height),
                codecType: codec.value, encoderSpecification: nil, imageBufferAttributes: nil,
                compressedDataAllocator: nil, outputCallback: videoCallback, refcon: Unmanaged.passUnretained(self).toOpaque(),
                compressionSessionOut: &session)
        print("using codec \(codec)")
        self.resolution = resolution
        self.fps = fps
        self.bitrate = bitrate
        self.iFrameInterval = iFrameInterval
        if err == errSecSuccess{
            guard let sess = session else { return false }
            let bitRate = bitrate
            let frameInterval: Int32 = 60
            VTSessionSetProperties(sess, propertyDictionary: [
                kVTCompressionPropertyKey_ProfileLevel: codec.profile,
                kVTCompressionPropertyKey_AverageBitRate: bitRate,
                kVTCompressionPropertyKey_MaxKeyFrameInterval: frameInterval,
                kVTCompressionPropertyKey_RealTime: true,
                kVTCompressionPropertyKey_Quality: 0.25,
            ] as CFDictionary)
            VTCompressionSessionPrepareToEncodeFrames(sess)
            initTs = Date().millisecondsSince1970
            print("prepare video success")
            running = true
            return true
        }else{
            return false
        }
    }

    public func setCodec(codec: CodecUtil) {
        self.codec = codec
    }

    public func forceKeyFrame() {
        forceKey = true
    }

    public func encodeFrame(buffer: CMSampleBuffer) {
        if (running) {
            guard let session = session else { return }
            guard let px = CMSampleBufferGetImageBuffer(buffer) else { return }
            let time = CMSampleBufferGetPresentationTimeStamp(buffer)
            var properties: Dictionary<String, Any>?
            if (forceKey) {
                forceKey = false
                properties = [
                    kVTEncodeFrameOptionKey_ForceKeyFrame as String: true
                ];
            }
            var flag:VTEncodeInfoFlags = VTEncodeInfoFlags()
            VTCompressionSessionEncodeFrame(session, imageBuffer: px, presentationTimeStamp: time, duration: time, frameProperties: properties as CFDictionary?, sourceFrameRefcon: nil, infoFlagsOut: &flag)
        }
    }

    public func stop() {
        running = false
        guard let session: VTCompressionSession = session else { return }
        VTCompressionSessionInvalidate(session)
        isSpsAndPpsSend = false
        forceKey = false
    }
    
    private var videoCallback: VTCompressionOutputCallback = {(outputCallbackRefCon: UnsafeMutableRawPointer?, _: UnsafeMutableRawPointer?,
                                                               status: OSStatus, flags: VTEncodeInfoFlags, sampleBuffer: CMSampleBuffer?) in
        guard let sampleBuffer = sampleBuffer else {
            print("nil buffer")
            return
        }
        guard let refcon: UnsafeMutableRawPointer = outputCallbackRefCon else {
            print("nil pointer")
            return
        }
        if (status != noErr) {
            print("encoding failed")
            return
        }
        if (!CMSampleBufferDataIsReady(sampleBuffer)) {
            print("data is not ready")
            return
        }
        
        if (flags == VTEncodeInfoFlags.frameDropped) {
            print("frame dropped")
            return
        }

        let encoder: VideoEncoder = Unmanaged<VideoEncoder>.fromOpaque(refcon).takeUnretainedValue()
        encoder.getValidRawBuffer(sampleBuffer: sampleBuffer)
    }
    
    /*
     In iOS H264 and H265 are in AVC format and could contain multiple frames.
     We need split frames and convert to annexB
    */
    private func getValidRawBuffer(sampleBuffer: CMSampleBuffer) {
        let keyFrame = isKeyFrame(sampleBuffer: sampleBuffer)
        
        if (keyFrame) {
            //write sps and pps
            guard let description = CMSampleBufferGetFormatDescription(sampleBuffer) else { return }
            var parametersCount: Int = 0
            if (codec == .H264) {
                CMVideoFormatDescriptionGetH264ParameterSetAtIndex(description, parameterSetIndex: 0, parameterSetPointerOut: nil,
                        parameterSetSizeOut: nil, parameterSetCountOut: &parametersCount, nalUnitHeaderLengthOut: nil)
            } else if (codec == .H265) {
                CMVideoFormatDescriptionGetHEVCParameterSetAtIndex(description, parameterSetIndex: 0, parameterSetPointerOut: nil,
                        parameterSetSizeOut: nil, parameterSetCountOut: &parametersCount, nalUnitHeaderLengthOut: nil)
            }
            if (codec == .H264 && parametersCount != 2 || codec == .H265 && parametersCount < 3) {
                print("unexpected video parameters \(parametersCount)")
                return
            }

            var vps: UnsafePointer<UInt8>?
            var vpsSize: Int = 0
            if (codec == .H265) {
                CMVideoFormatDescriptionGetHEVCParameterSetAtIndex(description, parameterSetIndex: 0, parameterSetPointerOut: &vps,
                        parameterSetSizeOut: &vpsSize, parameterSetCountOut: nil, nalUnitHeaderLengthOut: nil)
            }
            var sps: UnsafePointer<UInt8>?
            var spsSize: Int = 0
            if (codec == .H264) {
                CMVideoFormatDescriptionGetH264ParameterSetAtIndex(description, parameterSetIndex: 0, parameterSetPointerOut: &sps,
                        parameterSetSizeOut: &spsSize, parameterSetCountOut: nil, nalUnitHeaderLengthOut: nil)
            } else if (codec == .H265) {
                CMVideoFormatDescriptionGetHEVCParameterSetAtIndex(description, parameterSetIndex: 1, parameterSetPointerOut: &sps,
                        parameterSetSizeOut: &spsSize, parameterSetCountOut: nil, nalUnitHeaderLengthOut: nil)
            }
            var pps: UnsafePointer<UInt8>?
            var ppsSize: Int = 0
            if (codec == .H264) {
                CMVideoFormatDescriptionGetH264ParameterSetAtIndex(description, parameterSetIndex: 1, parameterSetPointerOut: &pps,
                        parameterSetSizeOut: &ppsSize, parameterSetCountOut: nil, nalUnitHeaderLengthOut: nil)
            } else if (codec == .H265) {
                CMVideoFormatDescriptionGetHEVCParameterSetAtIndex(description, parameterSetIndex: 2, parameterSetPointerOut: &pps,
                        parameterSetSizeOut: &ppsSize, parameterSetCountOut: nil, nalUnitHeaderLengthOut: nil)
            }

            var vpsData: NSData? = nil
            if (codec == .H265) {
                vpsData = NSData(bytes: vps, length: vpsSize)
            }
            let spsData = NSData(bytes: sps, length: spsSize)
            let ppsData = NSData(bytes: pps, length: ppsSize)

            if (!isSpsAndPpsSend) {
                callback.getSpsAndPps(sps: [UInt8](spsData), pps: [UInt8](ppsData),
                        vps: vpsData != nil ? [UInt8](vpsData!) : nil)
                isSpsAndPpsSend = true
            }
        }
        convertBuffer(sampleBuffer: sampleBuffer)
    }

    /*
     H264/H265 AVC to annexB.
    */
    private func convertBuffer(sampleBuffer: CMSampleBuffer) {
        // handle frame data
        guard let dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
            return
        }

        let startCode = [UInt8](arrayLiteral: 0x00, 0x00, 0x00, 0x01)

        var lengthAtOffset: Int = 0
        var totalLength: Int = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        if CMBlockBufferGetDataPointer(dataBuffer, atOffset: 0, lengthAtOffsetOut: &lengthAtOffset,
                totalLengthOut: &totalLength, dataPointerOut: &dataPointer) == noErr {
            var bufferOffset: Int = 0
            let avcHeaderLength = 4

            while bufferOffset < (totalLength - avcHeaderLength) {
                var naluLength: UInt32 = 0
                // first four character is NALUnit length
                memcpy(&naluLength, dataPointer?.advanced(by: bufferOffset), avcHeaderLength)

                // big endian to host endian. in iOS it's little endian
                naluLength = CFSwapInt32BigToHost(naluLength)

                let data: NSData = NSData(bytes: dataPointer?.advanced(by: bufferOffset + avcHeaderLength),
                        length: Int(naluLength))
                // move forward to the next NAL Unit
                bufferOffset += Int(avcHeaderLength)
                bufferOffset += Int(naluLength)

                var rawH264 = [UInt8](data)
                rawH264.insert(contentsOf: startCode, at: 0)
                var frame = Frame()
                frame.buffer = rawH264
                let end = Date().millisecondsSince1970
                let elapsedNanoSeconds = (end - initTs) * 1000
                frame.timeStamp = UInt64(elapsedNanoSeconds)
                frame.length = UInt32(frame.buffer!.count)

                callback.getH264Data(frame: frame)
            }
        }
    }

    private func isKeyFrame(sampleBuffer: CMSampleBuffer) -> Bool {
        guard
            let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: false) as? [[CFString: Any]],
            let value = attachments.first?[kCMSampleAttachmentKey_NotSync] as? Bool else {
            return true
        }
        return !value
    }
}
