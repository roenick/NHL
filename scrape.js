(async () => {

let request = require('request');
let cheerio = require('cheerio');
let fs = require('fs'); // Für Testzwecke
const {Client} = require('pg');
const named = require('node-postgres-named');


const client = new Client({
    user: 'postgres',
    host: 'localhost',
    database: 'NHL',
    password: 'iceman11',
    port: 5432,
});

named.patch(client);

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
    let GameID = 10000 + $('#GameInfo tr').eq(-2).text().replace(/(\n)/gm,"").split(" ")[1]; //Playoff-Games are 10000+
    let GDate = $('#GameInfo tr').eq(-5).text().replace(/(\n)/gm,"");
    let GType = $('#GameInfo tr').eq(-6).text().replace(/(\n)/gm,"");
    let GSeason = 2016;

    let HTeamID = await client.query("SELECT id FROM team WHERE full_name_big = '"+ HTeam +"'");
    let ATeamID = await client.query("SELECT id FROM team WHERE full_name_big = '"+ ATeam +"'");

    const query = {
        text: 'INSERT INTO game VALUES($GameID, $HTeam, $ATeam, $HScore, $AScore, $GType, $GDate, $GFinishedIn, $GSeason)',
        values: {
            'GameID': GameID,
            'HTeam': HTeamID.rows[0].id,
            'ATeam': ATeamID.rows[0].id,
            'HScore': HScore,
            'AScore': AScore,
            'GType': GType,
            'GDate': GDate,
            'GFinishedIn': 'R',
            'GSeason': GSeason
        }
    }

    const res = await client.query(query);
}

async function storePlays() {
    let actualRow = $('tr.evenColor').eq(0).find('td') //Change this to each (tr.evenColor).each...
    let Period = actualRow.eq(1).text() //Period in second td
    let TimeElapsed = actualRow.eq(3).html().split("<br>")[0] //TimeElapsed in fourth td
    let EventName = actualRow.eq(4).text() // Event-Name
    let VisitorPlayersOnIce = []
    let HomePlayersOnIce = []
    let VisitorOnIce = actualRow.eq(6).find('table table') // Visitor on ice
    VisitorOnIce.each(function (index, element) {
        let PlayerName = $(element).find('font').attr('title').split(" - ")[1]
        let PlayerNumberAndPos = $(element).text().replace(/(\r\n|\n|\r)/gm,"");
        let PlayerNumber = PlayerNumberAndPos.split(/(\d+)/)[1]
        let PlayerPos = PlayerNumberAndPos.split(/(\d+)/)[2]
        VisitorPlayersOnIce.push([PlayerName,PlayerNumber,PlayerPos])
    });

    console.log(VisitorPlayersOnIce);
}

await storeGameDetails();
//await storePlays();

await client.end();


})().catch(e => setImmediate(() => { throw e }));

