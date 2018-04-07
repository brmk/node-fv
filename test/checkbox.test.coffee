should = require('chai').should()
dv = require 'ndv'
fs = require 'fs'

{findCheckboxes} = require '../src/find_checkboxes'
{matchCheckboxes} = require '../src/match_checkboxes'

createFormSchema = (a, b) ->
	that =
		called: []
		fields: [
			path: 'one'
			type: 'checkbox'
			box:
				x: 10
				y: 0
				width: 10
				height: 20
			fieldValidator: if not a? then null else (value) -> value is a
			fieldSelector: (choices) ->
				that.called.push 'one'
				return 0
		,
			path: 'two'
			type: 'checkbox'
			box:
				x: 30
				y: 0
				width: 10
				height: 20
			fieldValidator: if not b? then null else (value) -> value is b
		]
	return that

schemaToPage = ({x, y, width, height}) -> {x, y, width, height}

schemaToData = ({x, y, width, height}) -> {x: x + 10, y: y + 10, width, height}

describe 'Checkbox recognizer', ->
	describe 'recognizer', ->
		femaleBox = { x: 1480, y: 300, width: 24, height: 23 }

		it 'should find checkboxes in synthetic image', ->
			checkboxesImage = new dv.Image('png', fs.readFileSync(__dirname + '/data/checkboxes.png'))
			[checkboxes, imageOut] = findCheckboxes checkboxesImage
			checkboxes.should.have.length 13
			imageOut.should.not.equal checkboxesImage

		it 'should find checkboxes in content image', ->
			contentImage = new dv.Image('png', fs.readFileSync(__dirname + '/data/m10-content.png'))
			[checkboxes, imageOut] = findCheckboxes contentImage
			checkboxes.should.not.be.empty
			imageOut.should.not.equal contentImage
			checkboxes.some((checkbox) -> Math.abs(checkbox.box.x - femaleBox.x) < 10).should.be.ok

	describe 'by position', ->
		it 'should tick "one" (mark) and untick "two"', ->
			formData = {}
			formSchema = createFormSchema undefined, undefined
			checkboxes = [
				checked: true
				confidence: 100
				box:
					x: 10
					y: 0
					width: 10
					height: 20
			]
			matchCheckboxes formData, formSchema, checkboxes, [], schemaToPage, schemaToData
			formData.one.confidence.should.equal checkboxes[0].confidence
			formData.one.value.should.be.true
			formData.one.box.should.deep.equal checkboxes[0].box
			formData.one.conflicts.should.have.length 0
			formData.two.confidence.should.be.within 65, 67
			formData.two.value.should.be.false
			formData.two.box.should.deep.equal formSchema.fields[1].box
			formData.two.conflicts.should.have.length 0

		it 'should tick "one" (word) and untick "two"', ->
			formData = {}
			formSchema = createFormSchema 'X', undefined
			words = [
				confidence: 42
				text: 'X'
				box:
					x: 10
					y: 0
					width: 10
					height: 20
			]
			matchCheckboxes formData, formSchema, [], words, schemaToPage, schemaToData
			formData.one.confidence.should.equal words[0].confidence
			formData.one.value.should.equal words[0].text
			formData.one.box.should.deep.equal words[0].box
			formData.one.conflicts.should.have.length 0
			formData.two.confidence.should.equal 100
			formData.two.value.should.be.false
			formData.two.box.should.deep.equal formSchema.fields[1].box
			formData.two.conflicts.should.have.length 0

		it 'should have low confidence on "one" and "two", due to ambigous mark', ->
			formData = {}
			formSchema = createFormSchema undefined, undefined
			checkboxes = [
				checked: true
				confidence: 100
				box:
					x: 24
					y: 4
					width: 2
					height: 2
			]
			matchCheckboxes formData, formSchema, checkboxes, [], schemaToPage, schemaToData
			formData.one.value.should.equal false
			formData.one.confidence.should.be.within 49, 51
			formData.one.box.should.deep.equal formSchema.fields[0].box
			formData.one.conflicts.should.have.length 0
			formData.two.value.should.equal false
			formData.two.confidence.should.be.within 49, 51
			formData.two.box.should.deep.equal formSchema.fields[1].box
			formData.two.conflicts.should.have.length 0

	describe 'by position and validator', ->
		it 'should tick "one" (word) and untick "two" (word)', ->
			formData = {}
			formSchema = createFormSchema 'a', 'x'
			words = [
				confidence: 100
				text: 'a'
				box:
					x: 10
					y: 0
					width: 10
					height: 20
			,
				confidence: 100
				text: 'b'
				box:
					x: 30
					y: 0
					width: 10
					height: 20
			]
			matchCheckboxes formData, formSchema, [], words, schemaToPage, schemaToData
			formData.one.confidence.should.equal 100
			formData.one.value.should.equal 'a'
			formData.one.box.should.equal words[0].box
			formData.one.conflicts.should.have.length 0
			formData.two.confidence.should.equal 100
			formData.two.value.should.be.false
			formData.two.box.should.deep.equal formSchema.fields[1].box
			formData.two.conflicts.should.have.length 0

		it 'should tick "one" and untick "two" (word > marker, different offsets)', ->
			formData = {}
			formSchema = createFormSchema 'a', undefined
			checkboxes = [
				checked: true
				confidence: 100
				box:
					x: 10
					y: 0
					width: 10
					height: 20
			]
			words = [
				confidence: 100
				text: 'a'
				box:
					x: 20
					y: 0
					width: 9
					height: 20
			]
			matchCheckboxes formData, formSchema, checkboxes, words, schemaToPage, schemaToData
			formData.one.confidence.should.equal 100
			formData.one.value.should.equal 'a'
			formData.one.box.should.deep.equal words[0].box
			formData.one.conflicts.should.have.length 0
			formData.two.confidence.should.be.within 60, 70
			formData.two.value.should.be.false
			formData.two.box.should.deep.equal formSchema.fields[1].box
			formData.two.conflicts.should.have.length 0
