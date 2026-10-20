// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppleSignInManagerSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AppleSignInManagerSDK",
            targets: ["AppleSignInManagerSDK"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "AppleSignInManagerSDK",
            path: "Frameworks/AppleSignInManagerSDK.xcframework"
        )
    ]
)
