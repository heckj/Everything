import Combine
import SwiftUI

#if os(macOS)
import AppKit

public typealias QuartzPlatformView = NSView
#elseif os(iOS)
import UIKit

public typealias QuartzPlatformView = UIView
#endif

public struct QuartzView: View {
    public struct Options: OptionSet {
        public let rawValue: Int
        public static let clear = Options(rawValue: 2 << 0)
        public static let center = Options(rawValue: 3 << 0)
        public static let drawAxes = Options(rawValue: 4 << 0)
        public static let redrawEveryFrame = Options(rawValue: 4 << 0)
        public static let `default`: Options = [.clear]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    public struct Parameter {
        public let bounds: CGRect
        public let context: CGContext
        public let dirtyRect: CGRect
    }

    public class Coordinator: ObservableObject {
        var view: _View?
        let displayLink = DisplayLinkPublisher()
    }

    @StateObject
    var coordinator = Coordinator()

    let options: Options
    let draw: (Parameter) -> Void

    public init(options: Options = .default, draw: @escaping (Parameter) -> Void) {
        self.options = options
        self.draw = draw
    }

    public var body: some View {
        ViewAdaptor {
            let view = _View()
            view.draw = draw
            view.needsDisplay = true
            coordinator.view = view
            return view
        } update: { view in
            view.needsDisplay = true
        }
        .onReceive(coordinator.displayLink.receive(on: DispatchQueue.main)) { _ in
#if os(macOS)
            coordinator.view?.needsDisplay = true
#else
            coordinator.view?.setNeedsDisplay()
#endif
        }
    }

    // swiftlint:disable:next type_name
    public class _View: QuartzPlatformView {
        var draw: ((Parameter) -> Void)?

        var options: Options = .default

        override public func draw(_ dirtyRect: CGRect) {
#if os(macOS)
            guard let context = NSGraphicsContext.current?.cgContext, let draw = draw else {
                return
            }
#else
            guard let context = UIGraphicsGetCurrentContext(), let draw = draw else {
                return
            }
#endif
            if options.contains(.clear) {
                context.saveGState()
                context.setFillColor(CGColor.white)
                context.fill(dirtyRect)
                context.restoreGState()
            }

            if options.contains(.center) {
                context.translateBy(x: bounds.midX, y: bounds.midY)
            }

            if options.contains(.drawAxes) {
                context.saveGState()
                context.setLineWidth(0.5)
                context.addLines(between: [CGPoint(-1_000, 0), CGPoint(1_000, 0)])
                context.strokePath()
                context.addLines(between: [CGPoint(0, -1_000), CGPoint(0, 1_000)])
                context.strokePath()
                context.restoreGState()
            }

            // TODO: if center is false dirty rect is wrong!!!
            draw(Parameter(bounds: bounds, context: context, dirtyRect: dirtyRect))
        }
    }
}
