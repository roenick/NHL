(async () => {

let request = require('request');
let cheerio = require('cheerio');
let fs = require('fs'); // Für Testzwecke lokale Files nehmen...
const {Client} = require('pg'); //postgress
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
    let ATeam = $('#Visitor td').last().html().split("<br>")[0];
    let AScore = $('#Visitor table td').eq(1).text();
    let HScore = $('#Home table td').eq(1).text();
    let HTeam = $('#Home td').last().html().split("<br>")[0];
    let GameID = 10000 + $('#GameInfo tr').eq(-2).text().replace(/(\n)/gm,"").split(" ")[1]; //Playoff-Games are 10000+
    let GDate = $('#GameInfo tr').eq(-5).text().replace(/(\n)/gm,"");
    let GType = $('#GameInfo tr').eq(-6).text().replace(/(\n)/gm,"");
    let GSeason = 2016;

    let HTeamID = await client.query("SELECT id FROM team WHERE full_name_big = '"+ HTeam +"'");
    let ATeamID = await client.query("SELECT id FROM team WHERE full_name_big = '"+ ATeam +"'");

    let query = {
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
    };

    let res = await client.query(query);
}

async function updatePlayer(name, team, position, number) {  // looks if Player is in DB and updates it if necessary
        let result = await client.query(`SELECT * FROM player WHERE name = '${name}' limit 1`);

        if (result.rowCount == 0) {   //Player not yet in the DB
            const query1 = {
                text: 'INSERT INTO player(name, actual_team_id, position, number) VALUES ($name, $team, $pos, $num)',
                values: {'name': name, 'team': team, 'pos': position, 'num': number}
            };
            const res = await client.query(query1);
        } else {
            if (result.rows[0].actual_team_id != team) { // Team has changed, update (maybe we should test Date!!)
                const query2 = {
                    text: 'UPDATE player SET actual_team_id = $team WHERE id = $id',
                    values: {'team': team, 'id': result.rows[0].id}
                };
                const res = await client.query(query2)
            }
        }
    }


async function storePlay() {
    let GameID = 10000 + $('#GameInfo tr').eq(-2).text().replace(/(\n)/gm, "").split(" ")[1]; //Playoff-Games are 10000+
    let allRows = $('tr.evenColor');
    let lastRow = allRows.get().length;
    for(i=0; i<1; i++) {
        let actualRow = allRows.eq(i).find('td');
        //GameID evtl besser als Parameter übergeben...
        let InGameID = actualRow.eq(0).text();
        let ID = 1000 * GameID + InGameID
        let Period = actualRow.eq(1).text(); //Period in second td
        let Strength = actualRow.eq(2).text(); //Strength in third td (if this is empty its a STOP-Event
        let TimeElapsed = "00:" + actualRow.eq(3).html().split("<br>")[0]; //TimeElapsed in fourth td
        let EventType = actualRow.eq(4).text(); // Event-Name
        // Now we store those common things in table 'play'
        let query = {
            text: 'INSERT INTO play VALUES($ID, $GameID, $Period, $TimeElapsed, $InGameID, $EventType, $Strength)',
            values: {
                'ID': ID,
                'GameID': GameID,
                'Period': Period,
                'TimeElapsed': TimeElapsed,
                'InGameID': InGameID,
                'EventType': EventType,
                'Strength': Strength,
            }
        };
        let res = await client.query(query);

        let VisitorPlayersOnIce = [];
        let HomePlayersOnIce = [];

        let VisitorOnIce = actualRow.eq(6).find('table table'); // Visitor on ice
        VisitorOnIce.each(function (index, element) {
            let PlayerName = $(element).find('font').attr('title').split(" - ")[1];
            let PlayerNumberAndPos = $(element).text().replace(/(\r\n|\n|\r)/gm,"");
            let PlayerNumber = PlayerNumberAndPos.split(/(\d+)/)[1];
            let PlayerPos = PlayerNumberAndPos.split(/(\d+)/)[2];
            VisitorPlayersOnIce.push([PlayerName,PlayerNumber,PlayerPos])
        });
        // somehow we have to look at Element 30 to get Home-Players
        let HomeOnIce = actualRow.eq(30).find('table table'); // Home on ice
        HomeOnIce.each(function (index, element) {
            let PlayerName = $(element).find('font').attr('title').split(" - ")[1];
            let PlayerNumberAndPos = $(element).text().replace(/(\r\n|\n|\r)/gm,"");
            let PlayerNumber = PlayerNumberAndPos.split(/(\d+)/)[1];
            let PlayerPos = PlayerNumberAndPos.split(/(\d+)/)[2];
            HomePlayersOnIce.push([PlayerName,PlayerNumber,PlayerPos])
        });
    }
}

async function testPlayerOnIceInsertion() {
    let query = {
        text: 'INSERT INTO on_ice(team_id, play_id, position, player_id, number) VALUES($t_id, $pr_id, $pos, $py_id, $n)',
        values: {
            't_id': 'ANA',
            'pr_id': 1000004110001,
            'pos': 'G',
            'py_id': 2,
            'n': 11
        }
    };
    let res = await client.query(query);
}

async function testPlayerInsertion() {
    let query = {
        text: 'INSERT INTO player(name, actual_team_id, position) VALUES($name, $actual_team, $pos)',
        values: {
            'name': 'Hans Wurst',
            'actual_team': 'ANA',
            'pos': 'G',
        }
    };
    let res = await client.query(query);
}


//await updatePlayer('Hans Wurst1','BOS','G');
//await storeGameDetails();
//await storePlay();


//await testPlayerInsertion();

await client.end();


})().catch(e => setImmediate(() => { throw e }));

