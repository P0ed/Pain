import UniformTypeIdentifiers

protocol TypeProvider {
	static var type: UTType { get }
	associatedtype ExportType: TypeProvider
}

enum PXD: TypeProvider {
	static var type: UTType { .pxd }
	typealias ExportType = PNG
}

enum PNG: TypeProvider {
	static var type: UTType { .png }
	typealias ExportType = PXD
}

extension UTType {
	static var pxd: Self { UTType("p0.xpaint.pxd")! }
}
