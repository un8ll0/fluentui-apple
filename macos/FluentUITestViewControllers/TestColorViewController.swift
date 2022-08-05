//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AppKit
import FluentUI
import SwiftUI
// conforming to NSAccessibilityTable causes overlapping with NSView
// subclassing NSScrollView to add custom accessibility support
class CustomScrollView: NSScrollView {
	var accessibilityCells : NSMutableArray = []
	// override accessibilityRows to let
	override func accessibilityRows() -> [Any]? {
		return accessibilityCells as! [Any]?
	}
		
	// override and set accessibilityRole to list
	override func accessibilityRole() -> NSAccessibility.Role? {
		return NSAccessibility.Role.table
	}
	// override isAccessibilityElement
	override func isAccessibilityElement() -> Bool {
		return true
	}
	
	// return an array of accessible cell objects
	public func populateSubviewstoAccessbilityCells(accessibilityRows:NSArray?) -> Void {
		if (accessibilityRows == nil) {
			return
		}
		accessibilityCells = NSMutableArray(capacity: accessibilityRows?.count ?? 0)
		for row in accessibilityRows.unsafelyUnwrapped {
			accessibilityCells.add(row)
		}
	}

}

// Color row View (child view of CustomScrollView)
// RNM calls insertReactSubview to add each subview to scrollview
// override accessibility
class CustomColorRowView: NSObject {
	//NSTextView
	// TODO: can't subclass the child view due to RCTUIView mapping. super class stores incoming subviews in reactSubviews
}

class TestColorViewController: NSViewController {
	var primaryColorsStackView = NSStackView()
	var subviewConstraints = [NSLayoutConstraint]()
	var toggleTextView = NSTextView(frame: NSRect(x: 0, y: 0, width: 100, height: 20))

	var scrollView = CustomScrollView()
	var rowArray = NSMutableArray()
	override func loadView() {
		let containerView = NSView()
		//let scrollView = NSScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.hasVerticalScroller = true

		containerView.addSubview(scrollView)

		let colorsStackView = NSStackView()
		colorsStackView.translatesAutoresizingMaskIntoConstraints = false
		colorsStackView.orientation = .vertical
		colorsStackView.alignment = .leading

		primaryColorsStackView.translatesAutoresizingMaskIntoConstraints = false
		primaryColorsStackView.orientation = .vertical
		primaryColorsStackView.alignment = .leading

		for color in Colors.Palette.allCases {
			colorsStackView.addArrangedSubview(createColorRowStackView(name: color.name, color: color.color))
		}

		loadPrimaryColors(state: NSControl.StateValue.off)

		let documentView = NSView()
		documentView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.documentView = documentView
		let textview1 = NSTextField(labelWithString: "textview1")
		textview1.translatesAutoresizingMaskIntoConstraints = false

		let textview2 = NSTextField(labelWithString: "textview2")
		let textview3 = NSTextField(labelWithString: "textview3")
		let textview4 = NSTextField(labelWithString: "textview4")
		let textview5 = NSTextField(labelWithString: "textview5")
		textview2.translatesAutoresizingMaskIntoConstraints = false
		textview3.translatesAutoresizingMaskIntoConstraints = false
		textview4.translatesAutoresizingMaskIntoConstraints = false
		textview5.translatesAutoresizingMaskIntoConstraints = false
		
		textview1.font = .systemFont(ofSize: 100)
		textview2.font = .systemFont(ofSize: 100)
		textview3.font = .systemFont(ofSize: 100)
		textview4.font = .systemFont(ofSize: 100)
		textview5.font = .systemFont(ofSize: 100)
		
		let primaryColorView = ColorRectView(color: Colors.primary)
		primaryColorView.translatesAutoresizingMaskIntoConstraints = false
		rowArray.add(textview1)
		rowArray.add(textview2)
		rowArray.add(textview3)
		rowArray.add(textview4)
		rowArray.add(textview5)
		rowArray.add(primaryColorView)
		scrollView.populateSubviewstoAccessbilityCells(accessibilityRows: rowArray)
		//documentView.addSubview(colorsStackView)
		//documentView.addSubview(primaryColorsStackView)
		//documentView.addSubview(rowArray)
		
		documentView.addSubview(textview1)
		documentView.addSubview(textview2)
		documentView.addSubview(textview3)
		documentView.addSubview(textview4)
		documentView.addSubview(textview5)
		documentView.addSubview(primaryColorView)
		subviewConstraints = [
			containerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
			containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			textview1.topAnchor.constraint(equalTo: documentView.topAnchor, constant: colorRowSpacing),
			textview1.leadingAnchor.constraint(equalTo: documentView.leadingAnchor, constant: colorRowSpacing),
			textview1.trailingAnchor.constraint(equalTo: documentView.trailingAnchor),
			textview2.topAnchor.constraint(equalTo: textview1.bottomAnchor, constant: colorRowSpacing),
			textview2.leadingAnchor.constraint(equalTo: documentView.leadingAnchor, constant: colorRowSpacing),
			textview2.trailingAnchor.constraint(equalTo: documentView.trailingAnchor),
			
			textview3.topAnchor.constraint(equalTo: textview2.bottomAnchor, constant: colorRowSpacing),
			textview3.leadingAnchor.constraint(equalTo: documentView.leadingAnchor, constant: colorRowSpacing),
			textview3.trailingAnchor.constraint(equalTo: documentView.trailingAnchor),
			
			textview4.topAnchor.constraint(equalTo: textview3.bottomAnchor, constant: colorRowSpacing),
			textview4.leadingAnchor.constraint(equalTo: documentView.leadingAnchor, constant: colorRowSpacing),
			textview4.trailingAnchor.constraint(equalTo: documentView.trailingAnchor),
			
			textview5.topAnchor.constraint(equalTo: textview4.bottomAnchor, constant: colorRowSpacing),
			textview5.leadingAnchor.constraint(equalTo: documentView.leadingAnchor, constant: colorRowSpacing),
			textview5.trailingAnchor.constraint(equalTo: documentView.trailingAnchor),
			primaryColorView.topAnchor.constraint(equalTo: textview5.bottomAnchor, constant: colorRowSpacing),
			primaryColorView.leadingAnchor.constraint(equalTo: documentView.leadingAnchor, constant: colorRowSpacing),
			primaryColorView.trailingAnchor.constraint(equalTo: documentView.trailingAnchor)
		]


			subviewConstraints.append(primaryColorView.bottomAnchor.constraint(equalTo: documentView.bottomAnchor, constant: -colorRowSpacing))

		NSLayoutConstraint.activate(subviewConstraints)
		view = containerView
	}

	private func createColorRowStackView(name: String?, color: NSColor?) -> NSStackView {
		let rowStackView = NSStackView()
		rowStackView.setAccessibilityElement(true)
		rowStackView.focusRingType = NSFocusRingType.exterior
		rowStackView.setAccessibilityRole(NSAccessibility.Role.row)
		let textView = NSTextField(labelWithString: name!)
		let primaryColorView = ColorRectView(color: color!)
		textView.font = .systemFont(ofSize: 18)
		rowStackView.setAccessibilityLabel(textView.stringValue)
		rowStackView.orientation = .horizontal
		rowStackView.spacing = 20.0
		rowStackView.addArrangedSubview(primaryColorView)
		rowStackView.addArrangedSubview(textView)
		return rowStackView
	}

	@available(OSX 10.15, *)
	@objc private func toggleClicked(button: NSSwitch?) {
		primaryColorsStackView.subviews.removeAll()
		loadPrimaryColors(state: button?.state ?? NSControl.StateValue.off)
	}

	private func loadPrimaryColors(state: NSControl.StateValue) {
		if state == NSControl.StateValue.on {
			Colors.primary = (NSColor(named: "Colors/DemoPrimaryColor"))!
			Colors.primaryShade10 = (NSColor(named: "Colors/DemoPrimaryShade10Color"))!
			Colors.primaryShade20 = (NSColor(named: "Colors/DemoPrimaryShade20Color"))!
			Colors.primaryShade30 = (NSColor(named: "Colors/DemoPrimaryShade30Color"))!
			Colors.primaryTint10 = (NSColor(named: "Colors/DemoPrimaryTint10Color"))!
			Colors.primaryTint20 = (NSColor(named: "Colors/DemoPrimaryTint20Color"))!
			Colors.primaryTint30 = (NSColor(named: "Colors/DemoPrimaryTint30Color"))!
			Colors.primaryTint40 = (NSColor(named: "Colors/DemoPrimaryTint40Color"))!
			toggleTextView.string = "Green"
		} else {
			Colors.primary = Colors.Palette.communicationBlue.color
			Colors.primaryShade10 = Colors.Palette.communicationBlueShade10.color
			Colors.primaryShade20 = Colors.Palette.communicationBlueShade20.color
			Colors.primaryShade30 = Colors.Palette.communicationBlueShade30.color
			Colors.primaryTint10 = Colors.Palette.communicationBlueTint10.color
			Colors.primaryTint20 = Colors.Palette.communicationBlueTint20.color
			Colors.primaryTint30 = Colors.Palette.communicationBlueTint30.color
			Colors.primaryTint40 = Colors.Palette.communicationBlueTint40.color
			toggleTextView.string = "Default"
		}

		primaryColorsStackView.addArrangedSubview(createColorRowStackView(name: "primary", color: Colors.primary))
		primaryColorsStackView.addArrangedSubview(createColorRowStackView(name: "primaryShade10", color: Colors.primaryShade10))
		primaryColorsStackView.addArrangedSubview(createColorRowStackView(name: "primaryShade20", color: Colors.primaryShade20))
		primaryColorsStackView.addArrangedSubview(createColorRowStackView(name: "primaryShade30", color: Colors.primaryShade30))
		primaryColorsStackView.addArrangedSubview(createColorRowStackView(name: "primaryTint10", color: Colors.primaryTint10))
		primaryColorsStackView.addArrangedSubview(createColorRowStackView(name: "primaryTint20", color: Colors.primaryTint20))
		primaryColorsStackView.addArrangedSubview(createColorRowStackView(name: "primaryTint30", color: Colors.primaryTint30))
		primaryColorsStackView.addArrangedSubview(createColorRowStackView(name: "primaryTint40", color: Colors.primaryTint40))
		NSLayoutConstraint.activate(subviewConstraints)
	}
}

class ColorRectView: NSView {

	let color: NSColor

	init(color: NSColor) {
		self.color = color
		super.init(frame: .zero)
	}
	override var intrinsicContentSize: CGSize {
		return CGSize(width: 40, height: 40)
	}

	@available(*, unavailable)
	required public init?(coder decoder: NSCoder) {
		preconditionFailure()
	}

	override func draw(_ dirtyRect: NSRect) {
		color.setFill()
		bounds.fill()
	}
}

private let colorRowSpacing: CGFloat = 10.0
