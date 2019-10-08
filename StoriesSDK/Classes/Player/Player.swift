import AVFoundation

protocol PlayerInput {
	var avPlayer: AVPlayer { get }
	func play()
	func pause()
	func stop()
}

class Player: PlayerInput {
	let avPlayer: AVPlayer
	
	init(url: URL) {
		self.avPlayer = AVPlayer(url: url)
	}

	func play() {
		avPlayer.play()
	}
	
	func pause() {
		avPlayer.pause()
	}
	
	func stop() {
		avPlayer.replaceCurrentItem(with: nil)
	}
}
