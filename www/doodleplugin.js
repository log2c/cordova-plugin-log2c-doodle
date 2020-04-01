var exec = require('cordova/exec');

exports.doodle = function (arg0, success, error) {
    exec(success, error, 'DoodlePlugin', 'doodle', [arg0]);
};

