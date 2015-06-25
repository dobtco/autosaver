class Autosaver
  defaults:
    ms: 2000
    max: 8000

  constructor: (options = {}) ->
    @options = _.extend({}, @defaults, options)

  saveLater: ->
    @queuedAt ||= _.now()

    if @options.max && ((_.now() - @queuedAt) > @options.max)
      @saveNow()
    else
      @_clearTimeout()
      @timeout = setTimeout =>
        @_clearTimeout()
        @saveNow()
      , @options.ms

  saveNow: (done) ->
    @clear()

    # If a save request is already in-flight, we need to delay this request
    # until after it's done
    if @inFlight
      @afterFlight = -> @saveNow(done)
      return

    @inFlight = true
    @options.fn =>
      @inFlight = false
      done?()

      if @afterFlight
        @afterFlight()
        @afterFlight = undefined

  ensure: (cb) ->
    if @isPending()
      @saveNow(cb)
    else
      cb()

  isPending: ->
    !!@timeout

  clear: ->
    @queuedAt = undefined
    @_clearTimeout()

  maxBackoffTo: ->
    @preBackoffOptions.ms * Math.pow(2, 4) # 5 Intervals

  backoff: ->
    @preBackoffOptions ||= {
      max: @options.max
      ms: @options.ms
    }

    @options.max = 0
    @options.ms = Math.min(@options.ms * 2, @maxBackoffTo())
    @_resetTimeout()

  resetBackoff: ->
    _.extend @options, @preBackoffOptions
    @orignals = undefined
    @_resetTimeout()

  _clearTimeout: ->
    clearTimeout(@timeout)
    @timeout = undefined

  # Useful if @options.ms changes
  _resetTimeout: ->
    if @isPending()
      @_clearTimeout()
      @saveLater()

if module?.exports
  module.exports = Autosaver
else
  window.Autosaver = Autosaver
