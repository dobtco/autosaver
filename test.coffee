describe 'Autosaver', ->
  beforeAll ->
    Autosaver::defaults.ms = 10

  it 'builds with defaults', ->
    as = new Autosaver
    expect(as.options.ms).toBeDefined()
    expect(as.options.max).toBeDefined()

  describe '#saveLater', ->
    it 'throttles multiple calls', (done) ->
      counter = 0

      as = new Autosaver
        fn: => counter += 1

      as.saveLater()
      as.saveLater()
      as.saveLater()

      setTimeout ->
        expect(counter).toBe(1)
        done()
      , 15

    it 'calls the function on the trailing edge', (done) ->
      input = 'hi'
      output = undefined

      as = new Autosaver
        fn: => output = input

      as.saveLater()
      input = 'bye'
      as.saveLater()
      expect(output).toBeUndefined()
      setTimeout ->
        expect(output).toBe('bye')
        done()
      , 15

    it 'saves once its been queued for the max amount of time', (done) ->
      saved = false

      as = new Autosaver
        max: 20
        fn: => saved = true

      setTimeout (-> as.saveLater() ), 5
      setTimeout (-> as.saveLater() ), 10
      setTimeout (-> as.saveLater() ), 15
      setTimeout (-> as.saveLater() ), 20
      setTimeout (-> as.saveLater() ), 25
      setTimeout (-> as.saveLater() ), 30

      setTimeout ->
        expect(saved).toBe(true)
        done()
      , 35

    it 'can disable options.max', (done) ->
      saved = false

      as = new Autosaver
        max: 0
        fn: => saved = true

      setTimeout (-> as.saveLater() ), 5
      setTimeout (-> as.saveLater() ), 10
      setTimeout (-> as.saveLater() ), 15
      setTimeout (-> as.saveLater() ), 20
      setTimeout (-> as.saveLater() ), 25
      setTimeout (-> as.saveLater() ), 30

      setTimeout ->
        expect(saved).toBe(false)
        done()
      , 35

  describe '#saveNow', ->
    it 'clears intervals created by saveLater', (done) ->
      counter = 0

      as = new Autosaver
        fn: => counter += 1

      as.saveLater()
      as.saveNow()

      setTimeout ->
        expect(counter).toBe(1)
        done()
      , 15

  describe '#clear', ->
    it 'clears pending timeouts', (done) ->
      saved = false

      as = new Autosaver
        fn: => saved = true

      as.saveLater()
      as.clear()

      setTimeout ->
        expect(saved).toBe(false)
        done()
      , 15

  describe '#saveNow', ->
    it 'queues another save if it was saved while in-flight', (done) ->
      current = 0
      passed = true

      as = new Autosaver
        ms: 10
        fn: (cb) =>
          current += 1
          passed = false if current > 1
          setTimeout ->
            current -= 1
            cb()
          , 10

      as.saveLater()

      setTimeout ->
        as.saveNow()
      , 15

      setTimeout ->
        expect(passed).toBe(true)
        done()
      , 30

  describe '#ensure', ->
    it 'calls the callback immediately if there are no changes', (done) ->
      called = false

      as = new Autosaver
        fn: (cb) ->
          called = true
          cb()

      as.ensure ->
        expect(called).toBe(false)
        done()

    it 'saves and then calls if there are changes', (done) ->
      called = false

      as = new Autosaver
        fn: (cb) ->
          called = true
          cb()

      as.saveLater()

      as.ensure ->
        expect(called).toBe(true)
        done()

    it 'waits for the request to finish if in-flight', (done) ->
      calledCount = 0

      as = new Autosaver
        fn: (cb) ->
          setTimeout ->
            calledCount += 1
            cb()
          , 15

      as.saveNow()

      setTimeout ->
        as.ensure ->
          expect(calledCount).toBe(1)
          done()
      , 10

    it 'waits for the another save request to finish if saved while in-flight', (done) ->
      calledCount = 0

      as = new Autosaver
        fn: (cb) ->
          setTimeout ->
            calledCount += 1
            cb()
          , 15

      as.saveNow()

      setTimeout ->
        as.saveNow()
        as.ensure ->
          expect(calledCount).toBe(2)
          done()
      , 10

  describe '#backoff', ->
    it 'increases backoff up to 5 intervals', ->
      as = new Autosaver
      expect(as.options.ms).toBe(10)
      as.backoff()
      expect(as.options.ms).toBe(20)
      as.backoff()
      expect(as.options.ms).toBe(40)
      as.backoff()
      expect(as.options.ms).toBe(80)
      as.backoff()
      expect(as.options.ms).toBe(160)
      as.backoff()
      expect(as.options.ms).toBe(160)

    it 'resets the timeout when increasing the backoff', (done) ->
      saved = false

      as = new Autosaver
        fn: => saved = true

      as.saveLater()
      as.backoff()

      setTimeout ->
        expect(saved).toBe(false)
      , 15

      setTimeout ->
        expect(saved).toBe(true)
        done()
      , 25

    it 'resets the backoff properly', ->
      as = new Autosaver
      as.backoff()
      expect(as.options.ms).toBe(20)
      as.resetBackoff()
      expect(as.options.ms).toBe(10)
      as.backoff()
      expect(as.options.ms).toBe(20)
      as.resetBackoff()
      expect(as.options.ms).toBe(10)
