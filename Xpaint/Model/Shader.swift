import JavaScriptCore

struct Shader: Codable {
	var function: String
}

extension Shader {

	static let `default` = Shader(function: """
	(r, g, b, a, x, y) => {
		return [r, g, b, a];
	}
	""")

	private static func program(layer: Int, film: Film, fn: String) -> String {
	"""
	const w = \(film.size.width);
	const h = \(film.size.height);
	const frame = \(film.jsFrame(layer));
	let fn = \(fn);
	var result = frame.map((px, idx) => fn(px[0], px[1], px[2], px[3], idx % w, Math.floor(idx / w)));
	"""
	}

	func callAsFunction(_ layer: Int, _ film: inout Film) {
		guard let vm = JSVirtualMachine() else { return }
		guard let ctx = JSContext(virtualMachine: vm) else { return }

		ctx.exceptionHandler = { ctx, val in
			print("exception!")
			if let val { print(val) }
			ctx?.exception = val
		}

		let p = Self.program(layer: 0, film: film, fn: function)
		ctx.evaluateScript(p)

		guard ctx.exception == nil else { return }

		film.withMutableLayer(layer) { pxs in
			if let jspxs = ctx.globalObject.objectForKeyedSubscript("result") {
				for i in pxs.indices {
					let px = jspxs.objectAtIndexedSubscript(i).map { p in
						Px(
							alpha: UInt8(clamping: p.objectAtIndexedSubscript(3).toInt32()),
							red: UInt8(clamping: p.objectAtIndexedSubscript(0).toInt32()),
							green:UInt8(clamping: p.objectAtIndexedSubscript(1).toInt32()),
							blue: UInt8(clamping: p.objectAtIndexedSubscript(2).toInt32())
						)
					}
					if let px { pxs[i] = px }
				}
			}
		}
	}
}

private extension Film {

	func jsFrame(_ layer: Int) -> String {
		"[" + pxs[range(layer)]
			.map { e in "[\(e.red), \(e.green), \(e.blue), \(e.alpha)]" }
			.joined(separator: ",")
		+ "]"
	}
}
