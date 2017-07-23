var request = require('request');
var cheerio = require('cheerio');

request('http://www.nhl.com/scores/htmlreports/20162017/PL030411.HTM', function (error, response, html) {
    if (!error && response.statusCode == 200) {
        var $ = cheerio.load(html);

    }
});