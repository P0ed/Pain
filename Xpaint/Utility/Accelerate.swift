import Accelerate

typealias PixelBuffer<Format: PixelFormat> = vImage.PixelBuffer<Format>
typealias Interleaved8x4 = vImage.Interleaved8x4
typealias Size = vImage.Size

extension Px {

	var pixel8888: Pixel_8888 {
		(alpha, red, green, blue)
	}
}

extension PixelBuffer where Format: SinglePlanePixelFormat, Format: StaticPixelFormat {

	func merge(_ buffer: PixelBuffer) {
		_ = withUnsafePointerToVImageBuffer { bottom in
			buffer.withUnsafePointerToVImageBuffer { top in
				vImagePremultipliedAlphaBlend_ARGB8888(
					top,
					bottom,
					bottom,
					vImage_Flags(kvImageNoFlags)
				)
			}
		}
	}

	var cgImage: CGImage {
		makeCGImage(cgImageFormat: .init(
			bitsPerComponent: 8,
			bitsPerPixel: 8 * 4,
			colorSpace: CGColorSpace(name: CGColorSpace.displayP3)!,
			bitmapInfo: .init(rawValue: CGImageAlphaInfo.first.rawValue)
		)!)!
	}

	func withPixels<A>(_ body: (UnsafeBufferPointer<Px>) -> A) -> A {
		withUnsafeBufferPointer { ptr in
			ptr.withMemoryRebound(to: Px.self, body)
		}
	}

	func withMutablePixels<A>(_ body: (UnsafeMutableBufferPointer<Px>) -> A) -> A {
		withUnsafeMutableBufferPointer { ptr in
			ptr.withMemoryRebound(to: Px.self, body)
		}
	}

	func modifyEach(_ body: (inout Px) -> Void) {
		withMutablePixels { pxs in
			var span = pxs.mutableSpan
			for i in span.indices {
				body(&span[i])
			}
		}
	}

	subscript(_ index: Int) -> Px {
		withPixels { pxs in pxs[index] }
	}
}
