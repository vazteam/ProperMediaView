# ProperMediaView

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

## Installation
### CocoaPods


## Usage
### Image
```
let imageMedia = ProperImage(
	thumbnailUrl: URL(string: "https://i.gyazo.com/f4f9410028b33650b7f2f0c76e3e82ff.png")!,
	originalImageUrl: URL(string: "https://i.gyazo.com/f32151613b826dec8faab456f1d6e8b6.png")!)

let imageMediaView = ProperMediaView(
	frame: CGRect(x: 0, y: 0, width: 200, height: 200), 
	media: imageMedia)
```

### Movie
```
let movieMedia = ProperMovie(
	thumbnailUrlStr: "https://i.gyazo.com/f4f9410028b33650b7f2f0c76e3e82ff.png",
	movieUrlStr: "http://img.profring.com/medias/4813cacbc19667eacb05c8705d9db7a5120832mnKcTmYOH8XiszVsaTMuohH8ovnCXSsH.mp4")

let movieMediaView = ProperMediaView(
	frame: CGRect(x: 0, y: 0, width: 200, height: 200),
	media: movieMedia)
```

### FullScreen
If this is set, it opens when tapped ProperMediaFullScreenViewController.
```
imageMediaView.setEnableFullScreen(fromViewController: self)
```

### OriginalImage DownLoad
ProperView downloads only thumbnails with default settings.
It is necessary to set it in order to download the original image.
```
let imageMediaView = ProperMediaView(
	frame: CGRect(x: 0, y: 0, width: 200, height: 200),
	media: imageMedia,
	isNeedsDownloadOriginalImage: true)
```

## License
MIT


