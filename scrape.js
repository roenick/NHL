(async () => {

    var request = require('request');
    var cheerio = require('cheerio');
    var fs = require('fs'); // Für Testzwecke
    const {Client} = require('pg');


    const client = new Client({
        user: 'postgres',
        host: 'localhost',
        database: 'NHL',
        password: 'iceman11',
        port: 5432,
    });

    await client.connect();

    $ = cheerio.load(fs.readFileSync('PlayByPlay.htm'));

    /*
    // Files: http://www.nhl.com/scores/htmlreports/20162017/PL02001 bis PL021230.HTM

    request('http://www.nhl.com/scores/htmlreports/20162017/PL030411.HTM', function (error, response, html) {
         if (!error && response.statusCode == 200) {
             var $ = cheerio.load(html);
         }
    });
    */

    async function storeGameDetails() {
        let ATeam = $('#Visitor td').last().html().split("<br>")[0]
        let AScore = $('#Visitor table td').eq(1).text()
        let HScore = $('#Home table td').eq(1).text()
        let HTeam = $('#Home td').last().html().split("<br>")[0]
        let GameID = $('#GameInfo tr').eq(-2).text().split(" ")[1];
        let GDate = $('#GameInfo tr').eq(-5).text();
        let GType = $('#GameInfo tr').eq(-6).text();

        const query = {
            text: 'INSERT INTO games VALUES($1, $2, $3, $4, $5, $6, $7)',
            values: [GameID, HTeam, ATeam, HScore, AScore, GType, GDate],
        }
        const res = await client.query(query);
    }

    await storeGameDetails();
    await client.end();


})().catch(e => setImmediate(() => { throw e }));
