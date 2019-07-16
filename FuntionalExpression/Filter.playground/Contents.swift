import UIKit

// MARK: - CoreImage
typealias Filter = (CIImage) -> CIImage
// 高斯模糊
func blur(radius: Double) -> Filter {
    return { image in
        let parameters: [String: Any] = [
            kCIInputRadiusKey: radius,
            kCIInputImageKey: image
        ]
        guard let filter = CIFilter(name: "CIGaussianBlur", parameters: parameters) else {
            fatalError("滤镜初始化失败")
        }
        guard let outImage = filter.outputImage else {
            fatalError("无输出")
        }
        return outImage
    }
}
// 颜色叠层
func generate(color: UIColor) -> Filter {
    return { _ in
        let parameters: [String: Any] = [
            kCIInputColorKey: CIColor(cgColor: color.cgColor)
        ]
        guard let filter = CIFilter(name: "CIConstantColorGenerator", parameters: parameters) else {
            fatalError()
        }
        guard let outputImage = filter.outputImage else {
            fatalError()
        }
        return outputImage
    }
}
// 合成滤镜
func compositeSourceOver(overlay: CIImage) -> Filter {
    return { image in
        let parameters: [String: Any] = [
            kCIInputBackgroundImageKey: image,
            kCIInputImageKey: overlay
        ]
        guard let filter = CIFilter(name: "CISourceOverCompositing", parameters: parameters) else {
            fatalError()
        }
        guard let outputImage = filter.outputImage else {
            fatalError()
        }
        return outputImage.cropped(to: image.extent)
    }
}
// 颜色 叠层滤镜
func overlay(_ color: UIColor) -> Filter {
    return { image in
        let overlay = generate(color: color)(image).cropped(to: image.extent)
        return compositeSourceOver(overlay: overlay)(image)
    }
}
let url = URL(string: "http://via.placeholder.com/500x500")!
let image = CIImage(contentsOf: url)!

infix operator >>>
func >>>(filter1: @escaping Filter,
         filter2: @escaping Filter) -> Filter {
    return { image in
        filter2(filter1(image))
    }
}
// 模糊 叠层
let blurAndOverlay = blur(radius: 10) >>> overlay(.red)
blurAndOverlay(image)

// MARK: - 柯里化
