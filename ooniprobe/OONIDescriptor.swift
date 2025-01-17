import Foundation
import UIKit

/// `NettestName` is an enumeration that defines a set of named constants for different nettests.
/// Each case in the enumeration represents a different nettest.
enum NettestName: String {
    case webConnectivity = "web_connectivity" // Represents the Web Connectivity test
    case whatsapp = "whatsapp" // Represents the WhatsApp test
    case telegram = "telegram" // Represents the Telegram test
    case facebookMessenger = "facebook_messenger" // Represents the Facebook Messenger test
    case signal = "signal" // Represents the Signal test
    case psiphon = "psiphon" // Represents the Psiphon test
    case tor = "tor" // Represents the Tor test
    case ndt = "ndt" // Represents the NDT test
    case dash = "dash" // Represents the DASH test
    case httpHeaderFieldManipulation = "http_header_field_manipulation" // Represents the HTTP Header Field Manipulation test
    case httpInvalidRequestLine = "http_invalid_request_line" // Represents the HTTP Invalid Request Line test
    case stunReachability = "stunreachability" // Represents the STUN Reachability test
    case dnsCheck = "dnscheck" // Represents the DNS Check test
    case riseupVPN = "riseupvpn" // Represents the RiseupVPN test
    case echCheck = "echcheck" // Represents the ECH Check test
    case torsf = "torsf" // Represents the TorSF test
    case vanillaTor = "vanilla_tor" // Represents the Vanilla Tor test
}

/// `Nettest` is a class that represents a nettest.
/// It contains information about the nettest such as the name, inputs, etc.
/// The class also provides a method to get the test object for the nettest.
@objc(Nettest)
public class Nettest: NSObject {

    // MARK: Initializers
    init(name: String, inputs: [String]?) {
        self.name = name
        self.inputs = inputs
    }

    // MARK: Properties
    @objc dynamic var name: String
    @objc dynamic var inputs: [String]?

    // MARK: Methods
    @objc public func getTest() -> AbstractTest {
        switch NettestName(rawValue: self.name) {
        case .webConnectivity:
            return WebConnectivity()
        case .whatsapp:
            return Whatsapp()
        case .telegram:
            return Telegram()
        case .facebookMessenger:
            return FacebookMessenger()
        case .signal:
            return Signal()
        case .psiphon:
            return Psiphon()
        case .tor:
            return Tor()
        case .ndt:
            return NdtTest()
        case .dash:
            return Dash()
        case .httpHeaderFieldManipulation:
            return HttpHeaderFieldManipulation()
        case .httpInvalidRequestLine:
            return HttpInvalidRequestLine()
        case .riseupVPN:
            return RiseupVPN()
        default:
            return Experimental(name: name)
        }
    }
}

/// `OONIDescriptor` is a class that represents an OONI descriptor.
/// It contains information about the descriptor such as the name, title, icon, color, etc.
/// It also contains information about the nettests that are part of the descriptor.
/// The class also provides a method to get the OONI descriptors for the OONI dashboard.
/// The class also provides a method to get the test suite for the current descriptor.
@objc(OONIDescriptor)
public class OONIDescriptor: NSObject {

    // MARK: Initializers
    init(name: String,
         title: String,
         shortDescription: String,
         longDescription: String,
         icon: String,
         color: UIColor,
         animation: String?,
         dataUsage: String,
         nettest: [Nettest],
         longRunningTests: [Nettest]?) {
        self.name = name
        self.title = title
        self.shortDescription = shortDescription
        self.longDescription = longDescription
        self.icon = icon
        self.color = color
        self.animation = animation
        self.dataUsage = dataUsage
        self.nettest = nettest
        self.longRunningTests = longRunningTests
    }

    // MARK: Properties
    @objc dynamic var name: String
    @objc dynamic var title: String
    @objc dynamic var shortDescription: String
    @objc dynamic var longDescription: String
    @objc dynamic var icon: String
    @objc dynamic var color: UIColor
    @objc dynamic var animation: String?
    @objc dynamic var dataUsage: String
    @objc dynamic var nettest: [Nettest]
    @objc dynamic var longRunningTests: [Nettest]?

    // MARK: Methods

    // Get the OONI descriptors for the OONI dashboard.
    @objc public static func getOONIDescriptors() -> [OONIDescriptor] {

        [
            OONIDescriptor(
                    name: "websites",
                    title: NSLocalizedString("Test.Websites.Fullname", comment: ""),
                    shortDescription: NSLocalizedString("Dashboard.Websites.Card.Description", comment: ""),
                    longDescription: NSLocalizedString("Dashboard.Websites.Overview.Paragraph", comment: ""),
                    icon: "websites",
                    color: UIColor(named: "color_indigo6")!,
                    animation: "websites",
                    dataUsage: "~ 8 MB",
                    nettest: [
                        Nettest(name: NettestName.webConnectivity.rawValue, inputs: [])
                    ],
                    longRunningTests: []
            ),

            OONIDescriptor(
                    name: "instant_messaging",
                    title: NSLocalizedString("Test.InstantMessaging.Fullname", comment: ""),
                    shortDescription: NSLocalizedString("Dashboard.InstantMessaging.Card.Description", comment: ""),
                    longDescription: NSLocalizedString("Dashboard.InstantMessaging.Overview.Paragraph", comment: ""),
                    icon: "instant_messaging",
                    color: UIColor(named: "color_indigo5")!,
                    animation: "instant_messaging",
                    dataUsage: "< 1 MB",
                    nettest: [
                        Nettest(name: NettestName.whatsapp.rawValue, inputs: []),
                        Nettest(name: NettestName.telegram.rawValue, inputs: []),
                        Nettest(name: NettestName.facebookMessenger.rawValue, inputs: []),
                        Nettest(name: NettestName.signal.rawValue, inputs: [])
                    ],
                    longRunningTests: []
            ),

            OONIDescriptor(
                    name: "circumvention",
                    title: NSLocalizedString("Test.Circumvention.Fullname", comment: ""),
                    shortDescription: NSLocalizedString("Dashboard.Circumvention.Card.Description", comment: ""),
                    longDescription: NSLocalizedString("Dashboard.Circumvention.Overview.Paragraph", comment: ""),
                    icon: "circumvention",
                    color: UIColor(named: "color_indigo2")!,
                    animation: "circumvention",
                    dataUsage: "< 1 MB",
                    nettest: [
                        Nettest(name: NettestName.psiphon.rawValue, inputs: []),
                        Nettest(name: NettestName.tor.rawValue, inputs: [])
                    ],
                    longRunningTests: []
            ),

            OONIDescriptor(
                    name: "performance",
                    title: NSLocalizedString("Test.Performance.Fullname", comment: ""),
                    shortDescription: NSLocalizedString("Dashboard.Performance.Card.Description", comment: ""),
                    longDescription: NSLocalizedString("Dashboard.Performance.Overview.Paragraph", comment: ""),
                    icon: "performance",
                    color: UIColor(named: "color_indigo4")!,
                    animation: "performance",
                    dataUsage: "5 - 200 MB",
                    nettest: [
                        Nettest(name: NettestName.ndt.rawValue, inputs: []),
                        Nettest(name: NettestName.dash.rawValue, inputs: []),
                        Nettest(name: NettestName.httpHeaderFieldManipulation.rawValue, inputs: []),
                        Nettest(name: NettestName.httpInvalidRequestLine.rawValue, inputs: [])
                    ],
                    longRunningTests: []
            ),

            OONIDescriptor(
                    name: "experimental",
                    title: NSLocalizedString("Test.Experimental.Fullname", comment: ""),
                    shortDescription: NSLocalizedString("Dashboard.Experimental.Card.Description", comment: ""),
                    longDescription: NSLocalizedString("Dashboard.Experimental.Overview.Paragraph", comment: ""),
                    icon: "experimental",
                    color: UIColor(named: "color_indigo1")!,
                    animation: "experimental",
                    dataUsage: NSLocalizedString("TestResults.NotAvailable", comment: ""),
                    nettest: [
                        Nettest(name: "stunreachability", inputs: []),
                        Nettest(name: "dnscheck", inputs: []),
                        Nettest(name: "riseupvpn", inputs: []),
                        Nettest(name: "echcheck", inputs: []),
                    ],
                    longRunningTests: [
                        Nettest(name: "torsf", inputs: []),
                        Nettest(name: "vanilla_tor", inputs: []),
                    ]
            )
        ]
    }


    /// Returns the test suite for the current descriptor.
    ///
    /// @return DynamicTestSuite representing the test suite for the current descriptor.
    @objc public func getTestSuites() -> Any {
        DynamicTestSuite(descriptor: self)
    }
}


/// This class is used to create [AbstractTest] dynamically for all instances where a Test Suite is required.
/// It is used to create a test suite from a Descriptor.
/// It acts as a bridge between the Descriptor format and the [AbstractSuite].
@objc(DynamicTestSuite)
class DynamicTestSuite: AbstractSuite {
    // MARK: Initializers
    @objc init(descriptor: OONIDescriptor) {
        self.descriptor = descriptor
        super.init()
        self.name = descriptor.name
        self.dataUsage = descriptor.dataUsage
        let tests = NSMutableArray()
        tests.addObjects(from: descriptor.nettest.map { nettest in
            nettest.getTest()
        })
        self.testList = tests
    }

    // MARK: Properties
    @objc dynamic var descriptor: OONIDescriptor
}
