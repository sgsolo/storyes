import AVFoundation

protocol PlayerInput {
	func play()
	func pause()
	func stop()
}

class Player {
	let avPlayer: AVPlayer
	
	init(url: URL) {
		self.avPlayer = AVPlayer(url: url)
	}
}

extension Player: PlayerInput {
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
