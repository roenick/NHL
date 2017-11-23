(async () => {

class storingObj {
    constructor(table, client) {
        this.table = table;
        this.client = client;
        this.data = {};
    }
    addData(obj) { // input is an object
       for (var key in obj)  {
           this.data[key] = obj[key];
       }
    }

    async store() {
        let queryText = "INSERT INTO " + this.table + "(";
        let valuesObj = {};
        for (var key in this.data) {
            queryText = queryText + key + ", ";
            valuesObj[key] = this.data[key];
        }
        queryText = queryText.slice(0, -2) + ") VALUES (";
        for (var key in this.data) {
            queryText = queryText + "$" + key + ", ";
        }
        queryText = queryText.slice(0,-2) + ")";
        let query = {text: queryText, values: valuesObj};
        let res = await client.query(query);

    }
}
//    text: 'INSERT INTO faceoff(winning_team_id, losing_team_id, play_id, winning_player_id, losing_player_id) VALUES($winningTeam, $losingTeam, $play_id, $winning_player, $losing_player)',
//        values: {'winningTeam': winningTeam, 'losingTeam': losingTeam, 'play_id': id, 'winning_player': winningPlayer, 'losing_player': losingPlayer }


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
    //let GameDate = GDate.split(", ")[1] + ", " + GDate.split(", ")[2]; //converts 'Monday, May 29, 2017' into 'May 29, 2017'

    let GType = $('#GameInfo tr').eq(-6).text().replace(/(\n)/gm,"");
    let GSeason = 2016;
    let HTeamID = await client.query("SELECT id FROM team WHERE full_name_big = '"+ HTeam +"'");
    let ATeamID = await client.query("SELECT id FROM team WHERE full_name_big = '"+ ATeam +"'");
    let HTeamIDdef = HTeamID.rows[0].id;
    let ATeamIDdef = ATeamID.rows[0].id;

    let query = {
        text: 'INSERT INTO game VALUES($GameID, $HTeam, $ATeam, $HScore, $AScore, $GType, $GDate, $GFinishedIn, $GSeason)',
        values: {
            'GameID': GameID,
            'HTeam': HTeamIDdef,
            'ATeam': ATeamIDdef,
            'HScore': HScore,
            'AScore': AScore,
            'GType': GType,
            'GDate': GDate,
            'GFinishedIn': 'R',
            'GSeason': GSeason
        }
    };

    //let res = await client.query(query);
    await storePlays(GameID, ATeamIDdef, HTeamIDdef, GDate);
}

async function storePlays(GameID, ATeamIDdef, HTeamIDdef, GDate) {

    let allRows = $('.evenColor');
    let lastRow = allRows.get().length;
    for(i=33; i<35; i++) {
        let actualRow = allRows.eq(i).find("td.bborder");
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
        //let res = await client.query(query);

        let VisitorPlayersOnIce = [];
        let HomePlayersOnIce = [];
        let GameDate = new Date(GDate);
        let VisitorOnIce = actualRow.eq(6).find('table table'); // Visitor on ice
        for(let i=0;i<VisitorOnIce.length;i++) {
            let PlayerName = VisitorOnIce.eq(i).find('font').attr('title').split(" - ")[1];
            let PlayerNumberAndPos = VisitorOnIce.eq(i).text().replace(/(\r\n|\n|\r)/gm,"");
            let PlayerNumber = PlayerNumberAndPos.split(/(\d+)/)[1];
            let PlayerPos = PlayerNumberAndPos.split(/(\d+)/)[2];
            await updatePlayer(PlayerName,ATeamIDdef, PlayerPos, PlayerNumber, GameDate);
            VisitorPlayersOnIce.push([PlayerName,PlayerNumber,PlayerPos])
        }

        // somehow we have to look at Element 30 to get Home-Players
        let HomeOnIce = actualRow.eq(7).find('table table'); // Home on ice
        for(let i=0;i<HomeOnIce.length;i++) {
            let PlayerName = HomeOnIce.eq(i).find('font').attr('title').split(" - ")[1];
            let PlayerNumberAndPos = HomeOnIce.eq(i).text().replace(/(\r\n|\n|\r)/gm,"");
            let PlayerNumber = PlayerNumberAndPos.split(/(\d+)/)[1];
            let PlayerPos = PlayerNumberAndPos.split(/(\d+)/)[2];
            await updatePlayer(PlayerName,HTeamIDdef, PlayerPos, PlayerNumber, GameDate);
            HomePlayersOnIce.push([PlayerName,PlayerNumber,PlayerPos])
        }

        if (EventType == 'FAC') {await handleFaceoff(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
        if (EventType == 'HIT') {await handleHit(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
        if (EventType == 'SHOT') {await handleShot(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
        if (EventType == 'MISS') {await handleMiss(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
        if (EventType == 'GIVE') {await handleGive(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
        if (EventType == 'STOP') {await handleStop(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
        if (EventType == 'BLOCK') {await handleBlock(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
        if (EventType == 'PENL') {await handlePenalty(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
        if (EventType == 'GOAL') {await handleGoal(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
        if (EventType == 'TAKE') {await handleTakeaway(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
    }
}

async function handleFaceoff(id, FaceOffText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) { // 'NSH won Neu. Zone - NSH #12 FISHER vs PIT #87 CROSBY'
    let winningTeam = FaceOffText.substring(0,3);
    let losingTeam = FaceOffText.substring(FaceOffText.search(' vs ') + 4, FaceOffText.search(' vs ') + 7);
    let textArray = FaceOffText.split(' #');

    let winningNumber = textArray[1].substring(0,2).trim(); //Das stimmt nicht!! Manchmal ist der loosing Player vorne!!
    let losingNumber = textArray[2].substring(0,2).trim();  // Dito!!
    let winningPlayer = "";
    let losingPlayer = "";
    console.log(HomePlayersOnIce);
    console.log(losingNumber);
    if (winningTeam == ATeamIDdef) {
        winningPlayer = await getPlayerName(winningNumber,VisitorPlayersOnIce, ATeamIDdef);
        losingPlayer = await getPlayerName(losingNumber, HomePlayersOnIce, ATeamIDdef);
    }
    console.log(winningTeam);
    if (winningTeam == HTeamIDdef) {
        winningPlayer = await getPlayerName(winningNumber,HomePlayersOnIce, HTeamIDdef);
        losingPlayer = await getPlayerName(losingNumber, VisitorPlayersOnIce, HTeamIDdef);
    }
    let query = {
        text: 'INSERT INTO faceoff(winning_team_id, losing_team_id, play_id, winning_player_id, losing_player_id) VALUES($winningTeam, $losingTeam, $play_id, $winning_player, $losing_player)',
        values: {'winningTeam': winningTeam, 'losingTeam': losingTeam, 'play_id': id, 'winning_player': winningPlayer, 'losing_player': losingPlayer }
    };

    //let res = await client.query(query);
}

async function handleHit(id, hitText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) { // 'NSH #9 FORSBERG HIT PIT #17 RUST, Neu. Zone'
    let textArray = hitText.split(' HIT ');
    let hittingTeam = textArray[0].substring(0,3);
    let hittedTeam = textArray[1].substring(0,3);
    let hittingPlayer = "";
    let hittedPlayer = "";
    let hittingNumber = textArray[0].substring(5,7).trim();
    let hittedNumber = textArray[1].substring(5,7).trim();

    if (hittingTeam == ATeamIDdef) {
        hittingPlayer = await getPlayerName(hittingNumber,VisitorPlayersOnIce, ATeamIDdef);
        hittedPlayer = await getPlayerName(hittedNumber, HomePlayersOnIce, ATeamIDdef);
    }
    if (hittingTeam == HTeamIDdef) {
        hittingPlayer = await getPlayerName(hittingNumber, HomePlayersOnIce, HTeamIDdef);
        hittedPlayer = await getPlayerName(hittedNumber, VisitorPlayersOnIce, HTeamIDdef);
    }

    let query = {
        text: 'INSERT INTO hit(hitter_id, hitted_id, hitter_team_id, hitted_team_id, play_id) VALUES($hitter, $hitted, $hitter_team, $hitted_team, $play_id)',
        values: {'hitter': hittingPlayer, 'hitted': hittedPlayer, 'hitter_team': hittingTeam, 'hitted_team': hittedTeam, 'play_id': id }
    };

    //let res = await client.query(query);
}

async function handleShot(id, shootText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) { // 'PIT ONGOAL - #37 ROWNEY, Slap, Off. Zone, 31 ft.'
    let textArray = shootText.split(', ');
    let shootingTeam = textArray[0].substring(0,3);
    let hashPos = textArray[0].search('#');
    let shootingPlayerNumber = textArray[0].substring(hashPos+1,hashPos+3).trim();

    if (shootingTeam == ATeamIDdef) { shootingPlayer = await getPlayerName(shootingPlayerNumber,VisitorPlayersOnIce, ATeamIDdef);}
    if (shootingTeam == HTeamIDdef) { shootingPlayer = await getPlayerName(shootingPlayerNumber,HomePlayersOnIce, HTeamIDdef);}

    let shotType = textArray[1].trim();
    let shotDistance = textArray[3].substring(0,2).trim();

    let query = {
        text: 'INSERT INTO shot(player_id, distance, shot_type, team_id, play_id) VALUES($playerId, $dist, $shotType, $teamId, $playId)',
        values: {'playerId': shootingPlayer, 'dist': shotDistance, 'shotType': shotType, 'teamId': shootingTeam, 'playId': id }
    };

    //let res = await client.query(query);
}

async function handleMiss(id, missText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) {
    // 'NSH #59 JOSI, Slap, Wide of Net, Off. Zone, 64 ft.'
    let textArray = missText.split(', ');
    let missingTeam = textArray[0].substring(0,3);
    let missingPlayerNumber = textArray[0].substring(6,8).trim();

    if (missingTeam == ATeamIDdef) { missingPlayer = await getPlayerName(missingPlayerNumber,VisitorPlayersOnIce, ATeamIDdef);}
    if (missingTeam == HTeamIDdef) { missingPlayer = await getPlayerName(missingPlayerNumber,HomePlayersOnIce, HTeamIDdef);}
    let shotType = textArray[1].trim();
    let shotDistance = textArray[4].substring(0,2).trim();
}

async function handleGive(id, giveText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) {
    // 'PIT GIVEAWAY - #3 MAATTA, Def. Zone '
    let textArray = giveText.split('#');
    let givingTeam = textArray[0].substring(0,3);
    let playerNumber = textArray[2].substring(0,2).trim();
    if (givingTeam == ATeamIDdef) { givingPlayer = await getPlayerName(playerNumber,VisitorPlayersOnIce, ATeamIDdef);}
    if (givingTeam == HTeamIDdef) { givingPlayer = await getPlayerName(playerNumber,HomePlayersOnIce, HTeamIDdef);}
}

async function handleStop(id, giveText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) {
    // 'PUCK IN CROWD,TV TIMEOUT' ??
}

async function handleBlock(id, blockText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) {
    // 'PIT #17 RUST BLOCKED BY NSH #14 EKHOLM, Wrist, Def. Zone'
    let textArray = blockText.split(' BY ');
    let blockingTeam = textArray[1].substring(0,3);
    let blockedTeam = textArray[0].substring(0,3);
    let blockingPlayerNumber = textArray[1].substring(6,8).trim();
    let blockedPlayerNumber = textArray[0].substring(5,7).trim();
    let shotType = textArray[1].split(', ')[1];
    if (blockingTeam == ATeamIDdef) {
        let blockingPlayer = await getPlayerName(playerNumber,VisitorPlayersOnIce, ATeamIDdef);
        let blockedPlaayer = await getPlayerName(playerNumber, HomePlayersOnIce, ATeamIDdef);
    }
    if (blockingTeam == HTeamIDdef) {
        let blockingPlayer = await getPlayerName(playerNumber,HomePlayersOnIce, HTeamIDdef);
        let blockedPlaayer = await getPlayerName(playerNumber, VisitorPlayersOnIce, HTeamIDdef);
    }
}

async function handlePenalty(id, penaltyText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) {
    // 'NSH #76 SUBBAN&#xA0;Delaying Game-Puck over glass(2 min), Def. Zone'
    // PIT #71 MALKIN&#xA0;Slashing(2 min), Neu. Zone Drawn By: NSH #76 SUBBAN
    let textArray = penaltyText.split(";");
    let penaltyTeam = textArray[0].substring(0,3).trim();
    let penaltyPlayerNumber = textArray[0].substring(5,7).trim();
    let penaltyPlayer = "";
    if (penaltyTeam == ATeamIDdef) { penaltyPlayer = await getPlayerName(penaltyPlayerNumber,VisitorPlayersOnIce);}
    if (penaltyTeam == HTeamIDdef) { penaltyPlayer = await getPlayerName(penaltyPlayerNumber,HomePlayersOnIce);}
    let i = 0;
    let penaltyString = "";
    while (! (textArray[1].substring(i,i+1)==="(")) {
        penaltyString = penaltyString + textArray[1].substring(i,i+1);
        i++
    }
    let penaltyDuration = textArray[1].substring(i+1,i+3).trim();
    let drawnText = penaltyText.split(": ");
    let drawnTeam = "";
    let drawnPlayerNumber = "";
    let drawnPlayer = "";
    const penaltyObj = new storingObj('penalty', Client);
    penaltyObj.addData({'length': penaltyDuration, player_id: penaltyPlayer, reason: penaltyString, team_id: penaltyTeam, play_id: id});

    if (! (drawnText[1]==undefined)) {
        drawnTeam = drawnText[1].substring(0, 3);
        drawnPlayerNumber = drawnText[1].substring(5, 7).trim();
        if (drawnTeam == ATeamIDdef) { drawnPlayer = await getPlayerName(drawnPlayerNumber,VisitorPlayersOnIce, ATeamIDdef);}
        if (drawnTeam == HTeamIDdef) { drawnPlayer = await getPlayerName(drawnPlayerNumber,HomePlayersOnIce, HTeamIDdef);}
        penaltyObj.addData({'drawn_team_id': drawnTeam, 'drawn_player_id': drawnPlayer});
    }
    await penaltyObj.store();
}

async function handleGoal(id, goalText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) {
    // 'NSH #32 GAUDREAU(1), Wrist, Off. Zone, 17 ft. Assists: #51 WATSON(3); #12 FISHER(2)'
    // Achtung: was passiert, wenn shotDistance < 10 ???
    let textArray = goalText.split(", ");
    let goalTeam = textArray[0].substring(0,3);
    let goalScorerNumber = textArray[0].substring(5,7).trim();
    let shotType = textArray[1];
    let shotDistance = textArray[3].substring(0,3).trim();
    let assistsTextArray = textArray[3].split("#");
    let assistsObj= {playID: id, team: goalTeam, assists : []};
    for (let i=1; i<assistsTextArray.length;i++) {
        assistsObj.assists.push(assistsTextArray[i].substring(0,2).trim());
    }
    // store the goal

}

async function handleTakeaway(id, takeText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) {
    // 'NSH TAKEAWAY - #59 JOSI, Neu. Zone'
    let textArray = takeText.split(' - ');
    let takingTeam = textArray[0].substring(0,3);
    let takingPlayerNumber = textArray[1].substring(1,3).trim();
    if (takingTeam == ATeamIDdef){ takingPlayer = await getPlayerName(takingPlayerNumber,VisitorPlayersOnIce);}
    if (takingTeam == HTeamIDdef){ takingPlayer = await getPlayerName(takingPlayerNumber,HomePlayersOnIce);}
}

async function getPlayerName(number, playerArray, teamName) {
    let found = false;
    for (var i = 0; i < playerArray.length; i++) {
        if (playerArray[i][1] == number) {
            found = true;
            console.log("found: " + playerArray[i][0])
            return playerArray[i][0];   // Found it
        }
    }
    if (found == false) {
        let queryString = "SELECT name FROM player WHERE number = " + number + " AND actual_team_id ='" + teamName + "'";
        let playerName = await client.query(queryString);
        if (playerName.rows[0] == undefined) {return false}
        else {
            console.log("DB"+playerName.rows[0].name);
            return playerName.rows[0].name;
        }   // In some rare cases the Player isn't on the ice anymore - so we have to look in the DB
    }
}

async function updatePlayer(name, team, position, number, GameDate) {  // looks if Player is in DB and updates it if necessary
    let result = await client.query(`SELECT * FROM player WHERE name = '${name}' limit 1`);
    //let result = null;
    if (result == null || result.rowCount == 0 ) {   //Player not yet in the DB
        const query1 = {
            text: 'INSERT INTO player(name, actual_team_id, position, number, date) VALUES ($name, $team, $pos, $num, $GDate)',
            values: {'name': name, 'team': team, 'pos': position, 'num': number, 'GDate': GameDate.toDateString()}
        };
        let res = await client.query(query1);

    } else {
        let TempDate = new Date(result.rows[0].date);
        if (result.rows[0].actual_team_id != team && TempDate.getTime() < GameDate.getTime()) { // Team has changed, update (maybe we should test Date!!)
            const query2 = {
                text: 'UPDATE player SET actual_team_id = $team, date = $GDate WHERE id = $id',
                values: {'team': team, 'GDate': GameDate.toDateString(), 'id': result.rows[0].id}
            };
            //let res = await client.query(query2)
        }
    }
}

//await updatePlayer('MATTHEW MURRAY','PIT','G', 30, new Date('SATURDAY, November 18, 2017'));
await storeGameDetails();
//await storePlay();
//await testPlayerInsertion();

await client.end();

})().catch(e => setImmediate(() => { throw e }));

