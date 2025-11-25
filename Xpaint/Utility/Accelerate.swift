import Accelerate

typealias PixelBuffer<Format: PixelFormat> = vImage.PixelBuffer<Format>
typealias Interleaved8x4 = vImage.Interleaved8x4
typealias Size = vImage.Size

extension PixelBuffer where Format: SinglePlanePixelFormat, Format: StaticPixelFormat {

	mutating func merge(_ buffer: PixelBuffer) {
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

	mutating func withMutablePixels<A>(_ body: (UnsafeMutableBufferPointer<Px>) -> A) -> A {
		withUnsafeMutableBufferPointer { ptr in
			ptr.withMemoryRebound(to: Px.self, body)
		}
	}

	mutating func modifyEach(_ body: (inout Px) -> Void) {
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

extension Size {
	var cg: CGSize { CGSize(width: width, height: height) }
	var center: CGPoint { CGPoint(x: width / 2, y: height / 2) }
	var count: Int { width * height }

	func index(at pxl: PxL) -> Int? {
		if pxl.x >= 0 && pxl.x < width && pxl.y >= 0 && pxl.y < height {
			.some(pxl.x + (height - 1 - pxl.y) * width)
		} else {
			.none
		}
	}

	func pxl(at index: Int) -> PxL {
		PxL(
			x: index % width,
			y: index / width,
			z: 0
		)
	}

	func zoomToFit(_ size: CGSize) -> CGFloat {
		min(size.width / CGFloat(width), size.height / CGFloat(height))
	}
}
