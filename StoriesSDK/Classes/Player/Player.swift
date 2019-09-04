import AVFoundation

protocol PlayerInput {
	func play()
	func pause()
	func stop()
}

class Player {
	var avPlayer = AVPlayer()
	
	public init(url: URL) {
		self.avPlayer = AVPlayer(url: url)
	}
}

extension Player: PlayerInput {
	public func play() {
		avPlayer.play()
	}
	
	public func pause() {
		avPlayer.pause()
	}
	
	public func stop() {
		avPlayer.replaceCurrentItem(with: nil)
	}
}
