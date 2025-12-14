import UIKit
import SwiftUI

/// Image storage service for iOS 14+
final class ImageStorageService {
    static let shared = ImageStorageService()

    private let fileManager = FileManager.default
    private let imagesDirectory = "Images"
    private let thumbnailsDirectory = "Thumbnails"
    private let thumbnailSize = CGSize(width: 200, height: 200)

    private init() {
        createDirectoriesIfNeeded()
    }

    private func createDirectoriesIfNeeded() {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let imagesURL = documentsDirectory.appendingPathComponent(imagesDirectory)
        let thumbnailsURL = documentsDirectory.appendingPathComponent(thumbnailsDirectory)

        [imagesURL, thumbnailsURL].forEach { url in
            if !fileManager.fileExists(atPath: url.path) {
                try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
            }
        }
    }

    func saveImage(_ image: UIImage, completion: @escaping (Result<(imagePath: String, thumbnailPath: String), Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            guard let documentsDirectory = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                DispatchQueue.main.async {
                    completion(.failure(ImageStorageError.documentsDirectoryNotFound))
                }
                return
            }

            let filename = UUID().uuidString + ".jpg"
            let imagePath = "\(self.imagesDirectory)/\(filename)"
            let thumbnailPath = "\(self.thumbnailsDirectory)/\(filename)"

            let imageURL = documentsDirectory.appendingPathComponent(imagePath)
            let thumbnailURL = documentsDirectory.appendingPathComponent(thumbnailPath)

            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                DispatchQueue.main.async {
                    completion(.failure(ImageStorageError.compressionFailed))
                }
                return
            }

            do {
                try imageData.write(to: imageURL)

                let thumbnail = self.createThumbnail(from: image)
                if let thumbnailData = thumbnail.jpegData(compressionQuality: 0.7) {
                    try thumbnailData.write(to: thumbnailURL)
                }

                DispatchQueue.main.async {
                    completion(.success((imagePath: imagePath, thumbnailPath: thumbnailPath)))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func loadImage(from path: String) -> UIImage? {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let imageURL = documentsDirectory.appendingPathComponent(path)
        guard let data = try? Data(contentsOf: imageURL) else {
            return nil
        }

        return UIImage(data: data)
    }

    func deleteImage(imagePath: String, thumbnailPath: String?) {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let imageURL = documentsDirectory.appendingPathComponent(imagePath)
        try? fileManager.removeItem(at: imageURL)

        if let thumbnailPath = thumbnailPath {
            let thumbnailURL = documentsDirectory.appendingPathComponent(thumbnailPath)
            try? fileManager.removeItem(at: thumbnailURL)
        }
    }

    private func createThumbnail(from image: UIImage) -> UIImage {
        let aspectRatio = image.size.width / image.size.height
        var targetSize = thumbnailSize

        if aspectRatio > 1 {
            targetSize.height = thumbnailSize.width / aspectRatio
        } else {
            targetSize.width = thumbnailSize.height * aspectRatio
        }

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

enum ImageStorageError: LocalizedError {
    case documentsDirectoryNotFound
    case compressionFailed

    var errorDescription: String? {
        switch self {
        case .documentsDirectoryNotFound:
            return "ドキュメントディレクトリが見つかりません"
        case .compressionFailed:
            return "画像の圧縮に失敗しました"
        }
    }
}
