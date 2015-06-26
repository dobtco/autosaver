autosaver [![status]](https://circleci.com/gh/dobtco/formrenderer-base/tree/master) ![bower]
====

Autosaver wraps your AJAX in a cozy, edge-case-preventing blanket.

## Usage

```js
var autosaver = new Autosaver({
  fn: function (done) {
    $.ajax({
      url: '/your/endpoint',
      data: { your: 'data' },
      complete: function(){
        done();
      }
    })
  }
});

// Autosaver debounces your AJAX calls so that only one request is made 
// on the trailing edge. In this example, the AJAX request will be made 
// *2000 milliseconds after* the last call to saveLater().
autosaver.saveLater();
autosaver.saveLater();
autosaver.saveLater();

// Autosaver also allows for calling .saveNow(). In this example, the AJAX 
// request will be sent immediately after the call to .saveNow().
autosaver.saveLater();
autosaver.saveNow();
```

However, Autosaver shines by handling the edge cases for you. By using  Autosaver, you ensure that the client is only ever sending *1 request at a time* to your server, otherwise you might run into race conditions where the user's data will be overwritten by conflicting saves.

## Methods

#### .saveLater()

Queues the call to your save function until `@options.ms` have passed. If the function has already been queued for more than `@options.max` milliseconds, calls it immediately.

#### .saveNow(cb)

Calls the save function immediately. If there is already a save in-flight, waits until after that save is complete to start another save.

#### .ensure(cb)

If there are unsycned changes, calls the save function and then `cb`. If there are no changes, calls `cb` immediately. Useful to ensuring that all changes are saved before a user [leaves the page](http://blog.dobt.co/2015/04/01/beforeunload-js/), for example.

#### .isPending()

Returns `true` if there is a save queued, otherwise `false` otherwise.

#### .backoff()

Exponentially increases the save interval. Useful if the server returns an error code so that you don't flood it with requests.

#### .resetBackoff()

Resets the save interval.

## Options

| key | description | default |
| --- | --- | --- |
| fn | function signature: `function(done){}` | - |
| ms | The number of milliseconds to delay calls to `fn`. (Referred to as `wait` by most debounce functions.) | 2000 |
| max | The maximum time `fn` is allowed to be delayed before it is invoked. Set to `0` to always wait. | 8000 |

[status]: https://circleci-badges.herokuapp.com/dobtco/Autosaver/98b9e34ac31737f706d16fb0b06b67ff28df5c18
[bower]: https://img.shields.io/bower/v/autosaver.svg
