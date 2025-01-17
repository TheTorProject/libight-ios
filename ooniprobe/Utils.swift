import Foundation
import UIKit

extension UIViewController {

    @objc(resizeImage:newWidth:newHeight:)
    func resizeImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width

        let newSize = CGSize(width: newWidth, height: image.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    @objc(tintedImageColors:startColor:endColor:)
    func tintedImageColors(image: UIImage, startColor: CGColor, endColor: CGColor?) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        context.translateBy(x: 0, y: image.size.height)
        context.scaleBy(x: 1, y: -1)

        context.setBlendMode(.normal)
        let rect = CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height)

        // Create gradient
        let colors = [startColor, endColor ?? startColor] as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: space, colors: colors, locations: nil)

        // Apply gradient
        context.clip(to: rect, mask: image.cgImage!)
        context.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: image.size.height), options: .drawsAfterEndLocation)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return gradientImage!
    }
}
