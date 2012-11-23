describe 'Wave Datepicker', ->
  beforeEach ->
    # The input box to test on.
    @$input = $('<input id="Date">').appendTo(document.body)

    @stubWaveDatepicker = ->
      @_WaveDatepicker =
        render: sinon.stub()
        destroy: sinon.stub()
      @_WaveDatepicker.render.returns @_WaveDatepicker
      @_WaveDatepickerStub = sinon.stub WDP, 'WaveDatepicker'
      @_WaveDatepickerStub.returns @_WaveDatepicker

    @restoreWaveDatepicker = ->
      @_WaveDatepickerStub.restore()


  afterEach ->
    @$input.datepicker('destroy')
    @$input.remove()


  describe '$.fn.datepicker', ->
    it 'should be defined on jQuery object', ->
      expect(@$input.datepicker).toEqual(jasmine.any(Function))

    it 'should instantiate the WaveDatepicker call', ->
      @stubWaveDatepicker()

      @$input.datepicker()

      expect(@_WaveDatepickerStub).toHaveBeenCalledOnce()

      @restoreWaveDatepicker()

    it 'should not instantiate datepicker twice on same element', ->
      @stubWaveDatepicker()

      # Called twice
      @$input.datepicker()
      @$input.datepicker()

      # But only instantiated twice
      expect(@_WaveDatepickerStub).toHaveBeenCalledOnce()

      @restoreWaveDatepicker()

    it 'should set the datepicker widget as data on the <input>', ->
      @stubWaveDatepicker()
      @$input.datepicker()
      expect(@$input.data('datepicker')).toEqual(@_WaveDatepicker)
      @restoreWaveDatepicker()

    it 'should use the value attribute to set default date', ->
      @$input.val('2012-08-01').datepicker()
      date = @$input.data('datepicker').date
      expect(date).toBeDefined()
      expect(date.getFullYear()).toEqual(2012)
      expect(date.getMonth()).toEqual(7)
      expect(date.getDate()).toEqual(1)

    it 'should set today as the default is value not set on <input>', ->
      @$input.datepicker()
      date = @$input.data('datepicker').date
      today = new Date()
      expect(date).toBeDefined()
      expect(date.getFullYear()).toEqual(today.getFullYear())
      expect(date.getMonth()).toEqual(today.getMonth())
      expect(date.getDate()).toEqual(today.getDate())


    describe 'Shortcuts', ->
      it 'should by default not have shortcuts', ->
        @$input.datepicker()
        widget = @$input.data('datepicker')
        expect(widget.$datepicker).not.toContain('.wdp-shortcut')

      it 'should provide default options if `shortcuts` is passed as true', ->
        @$input.datepicker({shortcuts: true})
        widget = @$input.data('datepicker')
        expect(widget.$datepicker).toContain('.wdp-shortcut')
        today = widget.$datepicker.find('.wdp-shortcut')
        expect($.trim(today.text())).toEqual('Today')

      it 'should attach extra element attributes if they are provided', ->
        @$input.datepicker(
          shortcuts: {
            'Foo': {days: 1, attrs: {'data-bar': 'abc'}}
          })

        widget = @$input.data('datepicker')

        expect(widget.shortcuts.$el.find('[data-bar=abc]')).toExist()

      describe 'When a shortcut is clicked', ->
        it 'should add the corresponding offset to the widget date', ->
          @$input.datepicker(
            'shortcuts': {
              'Foo': {days: 5, months: 1, years: -1}
            })
          today = new Date()
          # Date and month can overflow, which JavaScript will handle for us.
          expected = new Date(today.getFullYear() - 1, today.getMonth() + 1, today.getDate() + 5)
          widget = @$input.data('datepicker')

          widget.$datepicker.find('.wdp-shortcut').click()

          expect(widget.date.getFullYear()).toEqual(expected.getFullYear())
          expect(widget.date.getMonth()).toEqual(expected.getMonth())
          expect(widget.date.getDate()).toEqual(expected.getDate())


    describe 'On input change', ->
      it 'should update the date of the the widget', ->
        @$input.val('2012-08-01').datepicker()
        date = new Date 2012, 7, 1  # 7 is Aug
        widget = @$input.data('datepicker')
        expect(widget.date.getFullYear()).toEqual(date.getFullYear())
        expect(widget.date.getMonth()).toEqual(date.getMonth())
        expect(widget.date.getDate()).toEqual(date.getDate())

        @$input.val('2011-04-13').trigger('change')
        date = new Date 2011, 3, 13  # 7 is Aug
        expect(widget.date.getFullYear()).toEqual(date.getFullYear())
        expect(widget.date.getMonth()).toEqual(date.getMonth())
        expect(widget.date.getDate()).toEqual(date.getDate())

      describe 'when input value is bad', ->
        it 'should not change the date', ->
          @$input.val('2012-08-01').datepicker()
          widget = @$input.data('datepicker')
          originalDate = widget.date

          # This should not change widget's date.
          @$input.val('some bad value').trigger('change')

          expect(widget.date).toBe(originalDate)


    describe 'Rendered calendar', ->
      it 'should draw the calendar with current month and fill start/end with prev/next month', ->
        # Aug 2012
        @$input.val('2012-08-01').datepicker()
        $cells = @$input.data('datepicker').$calendar.find('td')
        expected = [29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
          20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8]
        array = []
        $cells.each -> array.push parseInt($.trim($(this).text()), 10)
        expect(array).toEqual(expected)

        # Nov 2014
        @$input.val('2014-11-13').trigger('change')
        $cells = @$input.data('datepicker').$calendar.find('td')
        expected = [26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
          20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 1, 2, 3, 4, 5, 6]
        array = []
        $cells.each -> array.push parseInt($.trim($(this).text()), 10)
        expect(array).toEqual(expected)

        # Jan 1900
        @$input.val('1900-01-01').trigger('change')
        $cells = @$input.data('datepicker').$calendar.find('td')
        expected = [31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
          20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        array = []
        $cells.each -> array.push parseInt($.trim($(this).text()), 10)
        expect(array).toEqual(expected)

        # Jul 2996
        @$input.val('2996-07-12').trigger('change')
        $cells = @$input.data('datepicker').$calendar.find('td')
        expected = [26, 27, 28, 29, 30, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 
          20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5, 6]
        array = []
        $cells.each -> array.push parseInt($.trim($(this).text()), 10)
        expect(array).toEqual(expected)

      it 'should have weekday names in table header', ->
        @$input.val('2012-08-01').datepicker()
        $cells = @$input.data('datepicker').$calendar.find('.wdp-weekdays > th')
        array = []
        $cells.each -> array.push $.trim($(this).text())
        expect(array).toEqual(['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'])

      it 'should have month and year in table header', ->
        @$input.val('2012-08-01').datepicker()
        monthAndYear = $.trim @$input.data('datepicker').$calendar.find('.wdp-month-and-year').text()
        expect(monthAndYear).toEqual('August 2012')


    # Tests for next and prev arrows for navigating through months.
    describe 'Navigation', ->
      beforeEach ->
        @$input.val('2012-08-01').datepicker()
        @widget = @$input.data 'datepicker'

      describe 'When next arrow is clicked', ->
        beforeEach ->
          @$next = @widget.$datepicker.find('.js-wdp-next')
          @$next.click()

        it 'should set the month and year of state', ->
          @$next.click()
          expect(@widget._state.month).toEqual(9)
          expect(@widget._state.year).toEqual(2012)

          # Brings calendar to Jan 2013
          @$next.click().click().click().click()
          expect(@widget._state.month).toEqual(1)
          expect(@widget._state.year).toEqual(2013)

      describe 'When prev arrow is clicked', ->
        beforeEach ->
          @$input.val('2012-03-01').trigger('change')
          @$prev = @widget.$datepicker.find('.js-wdp-prev')

        it 'should set the month and year of state', ->
          @$prev.click()
          expect(@widget._state.month).toEqual(1)
          expect(@widget._state.year).toEqual(2012)

          # Brings calendar to Jan 2013
          @$prev.click().click()
          expect(@widget._state.month).toEqual(11)
          expect(@widget._state.year).toEqual(2011)

    describe 'Multiple pickers on page', ->
      beforeEach ->
        @$input.datepicker()
        @$input2 = $('<input id="Date2">').appendTo(document.body).datepicker()
        @$input3 = $('<input id="Date3">').appendTo(document.body).datepicker()

        @picker1 = @$input.data('datepicker')
        @picker2 = @$input2.data('datepicker')
        @picker3 = @$input3.data('datepicker')

      afterEach ->
        @$input2.datepicker('destroy')
        @$input2.remove()

        @$input3.datepicker('destroy')
        @$input3.remove()

      describe 'When a click is on a different picker than current active picker', ->
        it 'should set new focus and hide inactive picker', ->
          @$input.focus()
          expect(@picker1._isShown).toBeTruthy()
          expect(@picker2._isShown).not.toBeTruthy()
          expect(@picker3._isShown).not.toBeTruthy()

          @$input2.focus()
          expect(@picker1._isShown).not.toBeTruthy()
          expect(@picker2._isShown).toBeTruthy()
          expect(@picker3._isShown).not.toBeTruthy()

          @$input3.focus()
          expect(@picker1._isShown).not.toBeTruthy()
          expect(@picker2._isShown).not.toBeTruthy()
          expect(@picker3._isShown).toBeTruthy()

    describe 'Base date', ->
      it 'should be used to calcualte shortcuts', ->
        expected = new Date(2012, 7, 1) 

        @$input.datepicker(
          baseDate: expected
          shortcuts:
            'Right away':
              days: 1
        )
        widget = @$input.data('datepicker')

        widget.$datepicker.find('.wdp-shortcut').click()

        expect(widget.date.getFullYear()).toEqual(expected.getFullYear())
        expect(widget.date.getMonth()).toEqual(expected.getMonth())
        expect(widget.date.getDate()).toEqual(expected.getDate() + 1)

    describe 'Add-on icon trigger', ->
      beforeEach ->
        # The input box to test on.
        @$box = $('<div class="input-append"><input id="Date2"><span class="add-on">*</span></div>').appendTo(document.body)
        @$box.find('input').datepicker()

      it 'should open datepicker when the add-on icon is clicked', ->
        @$box.find('.add-on').click()
        picker = @$box.find('input').data('datepicker')
        expect(picker._isShown).toBeTruthy()

    describe 'Date format', ->
      describe 'when the format option is passed', ->
        it 'should use that format string to parse and format dates', ->
          @$input.val('2012/08/31')
          @$input.datepicker(format: 'YYYY/MM/DD')
          date = @$input.data('datepicker').date
          expect(date).toBeDefined()
          expect(date.getFullYear()).toEqual(2012)
          expect(date.getMonth()).toEqual(7)
          expect(date.getDate()).toEqual(31)

      describe 'when date data-date-format is set on the <input>', ->
        it 'should use that format string to parse and format dates', ->
          @$input.val('2012/08/31').attr('data-date-format', 'YYYY/MM/DD')
          @$input.datepicker()
          date = @$input.data('datepicker').date
          expect(date).toBeDefined()
          expect(date.getFullYear()).toEqual(2012)
          expect(date.getMonth()).toEqual(7)
          expect(date.getDate()).toEqual(31)

      describe 'when the date format does not include year', ->
        it 'should use the current year', ->
          @$input.val('12-31').attr('data-date-format', 'MM-DD')
          @$input.datepicker()
          date = @$input.data('datepicker').date
          expect(date).toBeDefined()
          expect(date.getFullYear()).toEqual(2012)
          expect(date.getMonth()).toEqual(11)
          expect(date.getDate()).toEqual(31)
