Autosaver [![status]](https://circleci.com/gh/dobtco/formrenderer-base/tree/master) ![bower]
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

However, Autosaver shines by handling the edge cases for you. By using  Autosaver, you ensure that the client is only ever sending *1 request at a time* to your server, otherwise you might run into race conditions where the user's  data will be overwritten by conflicting saves.

### Options

| key | description | default |
| --- | --- | --- |
| fn | function signature: `function(done){}` | - |
| ms | The number of milliseconds to delay calls to `fn`. (Referred to as `wait` by most debounce functions.) | 2000 |
| max | The maximum time `fn` is allowed to be delayed before it is invoked. Set to `0` to always wait. | 8000 |

[status]: https://circleci-badges.herokuapp.com/dobtco/autosaver/98b9e34ac31737f706d16fb0b06b67ff28df5c18
[bower]: https://img.shields.io/bower/v/autosaver.svg
