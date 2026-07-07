#!/usr/bin/env swift
// usage: swift extract_text.swift <PDF路径>

import PDFKit
import Vision
import Foundation

func renderPDFPage(_ page: PDFPage, scale: CGFloat) -> CGImage? {
    let pdfRect = page.bounds(for: .mediaBox)
    let width = Int(ceil(pdfRect.width * scale))
    let height = Int(ceil(pdfRect.height * scale))
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(data: nil, width: width, height: height,
                              bitsPerComponent: 8, bytesPerRow: width * 4,
                              space: colorSpace,
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    else { return nil }
    ctx.setFillColor(CGColor(gray: 1, alpha: 1))
    ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
    ctx.scaleBy(x: scale, y: scale)
    page.draw(with: .mediaBox, to: ctx)
    return ctx.makeImage()
}

func main() {
    let args = CommandLine.arguments
    guard args.count >= 2 else {
        print("用法: swift extract_text.swift <PDF路径>")
        exit(1)
    }
    let pdfPath = (args[1] as NSString).expandingTildeInPath
    let pdfURL = URL(fileURLWithPath: pdfPath)
    guard let document = PDFDocument(url: pdfURL) else {
        print("无法打开 PDF: \(pdfPath)")
        exit(1)
    }

    let outURL = pdfURL.deletingPathExtension().appendingPathExtension("txt")
    print("共 \(document.pageCount) 页，输出: \(outURL.path)")

    let scale: CGFloat = 300.0 / 72.0
    let langPref = ["zh-Hans", "en-US"]

    var allLines: [String] = []

    for i in 0..<document.pageCount {
        autoreleasepool {
            guard let page = document.page(at: i),
                  let cgImage = renderPDFPage(page, scale: scale)
            else {
                print("跳过第 \(i+1) 页")
                return
            }
            print("第 \(i+1) 页识别中... (\(cgImage.width)x\(cgImage.height))", terminator: " ")

            let req = VNRecognizeTextRequest { req, err in
                if let err = err { print("OCR 错误: \(err.localizedDescription)"); return }
                guard let observations = req.results as? [VNRecognizedTextObservation] else { return }

                // Vision 坐标系: 原点左下角, y向上为正
                // 按 y 从大到小(从上到下), x 从小到大(从左到右)排序
                let sorted = observations.sorted { a, b in
                    let aBot = a.boundingBox.origin.y
                    let bBot = b.boundingBox.origin.y
                    if abs(aBot - bBot) < 0.015 { return a.boundingBox.origin.x < b.boundingBox.origin.x }
                    return aBot > bBot
                }

                var pageText = ""
                var lastBottom: CGFloat = -1
                for obs in sorted {
                    guard let candidate = obs.topCandidates(1).first else { continue }
                    let bot = obs.boundingBox.origin.y
                    if lastBottom >= 0 && abs(bot - lastBottom) > 0.015 {
                        pageText += "\n"
                    }
                    pageText += candidate.string
                    lastBottom = bot
                }

                if !pageText.isEmpty {
                    allLines.append("--- 第 \(i+1) 页 ---\n\(pageText)")
                }
                print("✓")
            }

            req.recognitionLevel = .accurate
            req.recognitionLanguages = langPref
            req.usesLanguageCorrection = true

            try? VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([req])
        }
    }

    let result = allLines.joined(separator: "\n\n")
    try? result.write(to: outURL, atomically: true, encoding: .utf8)
    print("\n完成！共 \(allLines.count)/\(document.pageCount) 页，\(result.count) 字符")
}

main()
