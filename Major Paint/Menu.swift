import SwiftUI

struct MenuCommands: Commands {
	@FocusedValue(\.editor) var editor: EditorView?
	@Environment(\.openDocument) var openDocument
	@Environment(\.newDocument) var newDocument

	var body: some Commands {
		CommandMenu("File") {
			Button("New") { newDocument(Document()) }
			.keyboardShortcut("N")

			Button("Open…") { openDocument }
			.keyboardShortcut("O")

			if let editor {
				Button("Save", action: editor.save)
				.keyboardShortcut("S")

				Button("Close", action: editor.dismiss.callAsFunction)
				.keyboardShortcut("W")
			}
		}

		if let editor {
			CommandMenu("Edit") {
				Button("Undo") { editor.undoManager?.undo() }
				.disabled(editor.undoManager?.canUndo != true)
				.keyboardShortcut("Z")

				Button("Redo") { editor.undoManager?.redo() }
				.disabled(editor.undoManager?.canRedo != true)
				.keyboardShortcut("Z", modifiers: [.shift, .command])
			}
		}
	}
}

extension FocusedValues {
	@Entry var editor: EditorView?
}
