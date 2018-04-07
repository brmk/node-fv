dv = require 'ndv'

tesseractInstance = null

# Return a binarized version of *image*. Currently uses Tesseract for this.
module.exports = (image) ->
	tesseractInstance ?= new dv.Tesseract()
	tesseractInstance.image = image
	return tesseractInstance.thresholdImage()
