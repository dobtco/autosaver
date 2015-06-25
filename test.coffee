describe 'Autosaver', ->
  it 'builds with defaults', ->
    as = new Autosaver
    expect(as.options.ms).toBe(2000)
    expect(as.options.max).toBe(8000)
