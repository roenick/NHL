(async () => {
// Problem bei 11.htm: Play 184: Penalty ist nicht standard!
class storingObj {
    constructor(table, client) {
        this.table = table;
        this.client = client;
        this.data = {};
    }
    addData(obj) { // input is an object
       for (let key in obj)  {
           if (obj.hasOwnProperty(key)) {
               this.data[key] = obj[key];
           }
       }
    }

    clearData() { // clears Data
        this.data = {};
    }

    async store() {
        let queryText = "INSERT INTO " + this.table + "(";
        let valuesObj = {};
        for (let key in this.data) {
            if (this.data.hasOwnProperty(key)) {
                queryText = queryText + key + ", ";
                valuesObj[key] = this.data[key];
            }
        }
        queryText = queryText.slice(0, -2) + ") VALUES (";
        for (let key in this.data) {
            if (this.data.hasOwnProperty(key)) {
                queryText = queryText + "$" + key + ", ";
            }
        }
        queryText = queryText.slice(0,-2) + ")";
        let query = {text: queryText, values: valuesObj};
        let res = await client.query(query);
    }
}
//    text: 'INSERT INTO faceoff(winning_team_id, losing_team_id, play_id, winning_player_id, losing_player_id) VALUES($winningTeam, $losingTeam, $play_id, $winning_player, $losing_player)',
//        values: {'winningTeam': winningTeam, 'losingTeam': losingTeam, 'play_id': id, 'winning_player': winningPlayer, 'losing_player': losingPlayer }
let homePlayers = [];
let awayPlayers = [];

let request = require('request-promise');
let cheerio = require('cheerio');
let fs = require('fs'); // Für Testzwecke lokale Files nehmen...
const {Client} = require('pg'); //postgress
const named = require('node-postgres-named');

const delay = require('delay');

const client = new Client({
    user: 'postgres',
    host: 'localhost',
    database: 'nhl2',
    password: 'iceman11',
    port: 5432,
});

named.patch(client);

await client.connect();

//$ = cheerio.load(fs.readFileSync('21.htm'));

/*
// Files: http://www.nhl.com/scores/htmlreports/20172018/PL020006.HTM
request('http://www.nhl.com/scores/htmlreports/20162017/PL030411.HTM', function (error, response, html) {
     if (!error && response.statusCode == 200) {
         var $ = cheerio.load(html);
     }
});
*/

// Remove a game and all associated Plays from DB
async function removeGameFromDB(gameID) {
    await client.query(`DELETE FROM game WHERE id = ${gameID}`);
}

async function storeGameDetails() {
    let ATeam = $('#Visitor td').last().html().split("<br>")[0];
    let AScore = $('#Visitor table td').eq(1).text();
    let HScore = $('#Home table td').eq(1).text();
    let HTeam = $('#Home td').last().html().split("<br>")[0];
    let GameInfo = $('#GameInfo').find('tr');
    let GameID = 10000 + GameInfo.eq(-2).text().replace(/(\n)/gm,"").split(" ")[1]; //Playoff-Games are 10000+

    let GDate = GameInfo.eq(-5).text().replace(/(\n)/gm,"");

    let GType = GameInfo.eq(-6).text().replace(/(\n)/gm,"");
    let GSeason = 2017;
    let HTeamID = await client.query("SELECT id FROM team WHERE full_name_big = '"+ HTeam +"'");
    let ATeamID = await client.query("SELECT id FROM team WHERE full_name_big = '"+ ATeam +"'");
    let HTeamIDdef = HTeamID.rows[0].id;
    let ATeamIDdef = ATeamID.rows[0].id;

    //remove Game from DB first (if exists...)
    await removeGameFromDB(GameID);

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

    let res = await client.query(query);
    await storePlays(GameID, ATeamIDdef, HTeamIDdef, GDate);
}

async function getPlayers() {
    let allRows = $('.evenColor');
    let lastRow = allRows.get().length;

}

async function storePlays(GameID, ATeamIDdef, HTeamIDdef, GDate) {

    let allRows = $('.evenColor');
    let lastRow = allRows.get().length;
    for(i=0; i<lastRow; i++) {
      //  for (i=335; i<347; i++) { //just to test one row
        let actualRow = allRows.eq(i).find("td.bborder");
        let InGameID = actualRow.eq(0).text();
        let ID = 1000 * GameID + InGameID;
        let Period = actualRow.eq(1).text(); //Period in second td
        let Strength = actualRow.eq(2).text(); //Strength in third td (if this is empty its a STOP-Event
        let TimeElapsed = "00:" + actualRow.eq(3).html().split("<br>")[0]; //TimeElapsed in fourth td
        let EventType = actualRow.eq(4).text(); // Event-Name
        // Now lets store those common things in table 'play'
        let query = {
            text: 'INSERT INTO play VALUES($ID, $GameID, $Period, $TimeElapsed, $InGameID, $EventType, $Strength)',
            values: {
                'ID': ID,
                'GameID': GameID,
                'Period': Period,
                'TimeElapsed': TimeElapsed,
                'InGameID': InGameID,
                'EventType': EventType,
                'Strength': Strength
            }
        };
        let res = await client.query(query);
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

        let HomeOnIce = actualRow.eq(7).find('table table'); // Home on ice
        for(let i=0;i<HomeOnIce.length;i++) {
            let PlayerName = HomeOnIce.eq(i).find('font').attr('title').split(" - ")[1];
            let PlayerNumberAndPos = HomeOnIce.eq(i).text().replace(/(\r\n|\n|\r)/gm,"");
            let PlayerNumber = PlayerNumberAndPos.split(/(\d+)/)[1];
            let PlayerPos = PlayerNumberAndPos.split(/(\d+)/)[2];
            await updatePlayer(PlayerName,HTeamIDdef, PlayerPos, PlayerNumber, GameDate);
            HomePlayersOnIce.push([PlayerName,PlayerNumber,PlayerPos])
        }
        await storeOnIce(HomePlayersOnIce, HTeamIDdef, ID);
        await storeOnIce(VisitorPlayersOnIce, ATeamIDdef, ID);
        if (Period === '5') { //Shootout
            await handleShootout(ID, actualRow.eq(5).html(), EventType, HomePlayersOnIce,VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);
        } else {
            if (EventType === 'FAC') {await handleFaceoff(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
            if (EventType === 'HIT') {await handleHit(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
            if (EventType === 'SHOT') {await handleShot(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
            if (EventType === 'MISS') {await handleMiss(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
            if (EventType === 'GIVE') {await handleGiveaway(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
            if (EventType === 'STOP') {await handleStop(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
            if (EventType === 'BLOCK') {await handleBlock(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
            if (EventType === 'PENL') {await handlePenalty(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
            if (EventType === 'GOAL') {await handleGoal(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}
            if (EventType === 'TAKE') {await handleTakeaway(ID, actualRow.eq(5).html(), HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef);}


        }
    }
}

async function handleShootout(id, shootoutText, eventType, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) {
    if (['GOAL','SHOT','MISS'].includes(eventType)) { // only possibilities are those 3 others are ignored
        let textArray = shootoutText.split(', ');
        let shootingTeam = textArray[0].substring(0, 3);
        let hashPos = textArray[0].search('#');
        let shootingPlayerNumber = textArray[0].substring(hashPos + 1, hashPos + 3).trim();
        let goalieTeam = "";
        if (shootingTeam === HTeamIDdef) {
            goalieName = VisitorPlayersOnIce[0][0];
            goalieId = await getPlayerIdfromName(goalieName);
            goalieTeam=ATeamIDdef
        } else {
            goalieName = HomePlayersOnIce[0][0];
            goalieId = await getPlayerIdfromName(goalieName);
            goalieTeam = HTeamIDdef;
        };
        shootingPlayerId = await getPlayerId(shootingPlayerNumber, [], shootingTeam);
        let scored = false;
        if (eventType=="GOAL") {scored = true;}
        let shootoutObj = new storingObj('shootout',client);
        shootoutObj.addData({'goalie_team_id': goalieTeam, 'player_id': shootingPlayerId, 'goalie_id': goalieId, 'play_id': id, 'scored': scored, 'team_id': shootingTeam});
        await shootoutObj.store();
    }
}

async function storeOnIce(playerArray, Team, PlayID) {
    let onIceObj = new storingObj('on_ice', Client);
    let arrayLength = playerArray.length;
    for (let i=0; i<arrayLength;i++) {
        playerData = playerArray[i];
        playerName = playerData[0].replace("'","");
        playerId = await getPlayerIdfromName(playerName);
        onIceObj.addData({'team_id': Team, 'play_id':PlayID, 'position':playerData[2], 'player_id':playerId, 'number':playerData[1]});
        await onIceObj.store();
        onIceObj.clearData();
    }
}

async function handleFaceoff(id, FaceOffText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) { // 'NSH won Neu. Zone - NSH #12 FISHER vs PIT #87 CROSBY'
    let winningTeam = FaceOffText.substring(0,3);
    let tempString = FaceOffText.substring(3,FaceOffText.length);
    let test1 = tempString.split("#");
    let number1 = test1[1].substring(0,2).trim();
    let number2 = test1[2].substring(0,2).trim();
    let winningNumber = 0;
    let losingNumber = 0;
    if (winningTeam === HTeamIDdef) {
        losingTeam = ATeamIDdef;
        losingNumber = number1;
        winningNumber = number2;
    } else {
        losingTeam = HTeamIDdef;
        losingNumber = number2;
        winningNumber = number1;
        }
    let winningPlayerId = 0;
    let losingPlayerId = 0;
    if (winningTeam === ATeamIDdef) {
        winningPlayerId = await getPlayerId(winningNumber,VisitorPlayersOnIce, ATeamIDdef);
        losingPlayerId = await getPlayerId(losingNumber, HomePlayersOnIce, HTeamIDdef);
    }
    if (winningTeam === HTeamIDdef) {
        winningPlayerId = await getPlayerId(winningNumber,HomePlayersOnIce, HTeamIDdef);
        losingPlayerId = await getPlayerId(losingNumber, VisitorPlayersOnIce, ATeamIDdef);
    }
    let faceoffObj = new storingObj('faceoff', Client);
    faceoffObj.addData({'winning_team_id': winningTeam, 'losing_team_id': losingTeam, 'play_id': id, 'winning_player_id': winningPlayerId, 'losing_player_id': losingPlayerId});
    await faceoffObj.store();
}

async function handleHit(id, hitText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) { // 'NSH #9 FORSBERG HIT PIT #17 RUST, Neu. Zone'
    let textArray = hitText.split(' HIT ');
    let hittingTeam = textArray[0].substring(0,3);
    let hittedTeam = textArray[1].substring(0,3);
    let hittingPlayer = "";
    let hittedPlayer = "";
    let hittingNumber = textArray[0].substring(5,7).trim();
    let hittedNumber = textArray[1].substring(5,7).trim();
    if (hittingTeam === ATeamIDdef) {
        hittingPlayer = await getPlayerId(hittingNumber,VisitorPlayersOnIce, ATeamIDdef);
        hittedPlayer = await getPlayerId(hittedNumber, HomePlayersOnIce, HTeamIDdef);
    }
    if (hittingTeam === HTeamIDdef) {
        hittingPlayer = await getPlayerId(hittingNumber, HomePlayersOnIce, HTeamIDdef);
        hittedPlayer = await getPlayerId(hittedNumber, VisitorPlayersOnIce, ATeamIDdef);
    }
    let hitObj = new storingObj('hit', Client);
    hitObj.addData({'hitter_id': hittingPlayer, 'hitted_id': hittedPlayer, 'hitter_team_id': hittingTeam, 'hitted_team_id': hittedTeam, 'play_id': id});
    await hitObj.store();
}

async function handleShot(id, shootText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) { // 'PIT ONGOAL - #37 ROWNEY, Slap, Off. Zone, 31 ft.'
    let textArray = shootText.split(', ');
    let shootingTeam = textArray[0].substring(0,3);
    let hashPos = textArray[0].search('#');
    let shootingPlayerNumber = textArray[0].substring(hashPos+1,hashPos+3).trim();
    if (shootingTeam === ATeamIDdef) { shootingPlayer = await getPlayerId(shootingPlayerNumber,VisitorPlayersOnIce, ATeamIDdef);}
    if (shootingTeam === HTeamIDdef) { shootingPlayer = await getPlayerId(shootingPlayerNumber,HomePlayersOnIce, HTeamIDdef);}

    let shotType = textArray[1].trim();
    if (shotType.includes("Zone")) shotType="";
    let lastEl = textArray.length-1; //Shot-Distance ist at last Element
    let shotDistance = textArray[lastEl].substring(0,2).trim();

    let shotObj = new storingObj('shot', Client);
    shotObj.addData({'player_id': shootingPlayer, 'distance': shotDistance, 'shot_type': shotType, 'team_id': shootingTeam, 'play_id': id});
    await shotObj.store();
}

async function handleMiss(id, missText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) {
    // 'NSH #59 JOSI, Slap, Wide of Net, Off. Zone, 64 ft.'
    let textArray = missText.split(', ');
    let missingTeam = textArray[0].substring(0,3);
    let missingPlayerNumber = textArray[0].substring(5,7).trim();
    if (missingTeam === ATeamIDdef) { missingPlayer = await getPlayerId(missingPlayerNumber,VisitorPlayersOnIce, ATeamIDdef);}
    if (missingTeam === HTeamIDdef) { missingPlayer = await getPlayerId(missingPlayerNumber,HomePlayersOnIce, HTeamIDdef);}
    let shotType = textArray[1].trim();
    if (shotType == "Wide of Net") shotType = ""; // rarely shotType is omitted
    let shotDistance = textArray[textArray.length-1].substring(0,2).trim(); // I take the last Element because sometimes "Zone" is missing...
    let missObj = new storingObj('miss', Client);
    missObj.addData({'player_id': missingPlayer, 'distance': shotDistance, 'team_id': missingTeam, 'shot_type': shotType, 'play_id': id});
    await missObj.store();
}

async function handleGiveaway(id, giveText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) {
    // 'PIT GIVEAWAY - #3 MAATTA, Def. Zone '
    let textArray = giveText.split('#');
    let givingTeam = textArray[0].substring(0,3);
    let playerNumber = textArray[2].substring(0,2).trim();
    if (givingTeam === ATeamIDdef) { givingPlayer = await getPlayerId(playerNumber,VisitorPlayersOnIce, ATeamIDdef);}
    if (givingTeam === HTeamIDdef) { givingPlayer = await getPlayerId(playerNumber,HomePlayersOnIce, HTeamIDdef);}

    let giveawayObj = new storingObj('giveaway', Client);
    giveawayObj.addData({'player_id': givingPlayer, 'team_id': givingTeam, 'play_id': id});
    await giveawayObj.store();
}

async function handleStop(id, stopText) {
    // 'PUCK IN CROWD,TV TIMEOUT' ??
    const stopObj = new storingObj('start_stop', Client);
    stopObj.addData({'what': stopText, 'play_id': id});
    await stopObj.store();
}

async function handleBlock(id, blockText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) {
    // 'PIT #17 RUST BLOCKED BY NSH #14 EKHOLM, Wrist, Def. Zone'
    let textArray = blockText.split(' BY ');
    let blockingTeam = textArray[1].substring(1,4);
    let blockedTeam = textArray[0].substring(0,3);
    let blockingPlayerNumber = textArray[1].substring(6,8).trim();
    let blockedPlayerNumber = textArray[0].substring(5,7).trim();
    let shotType = "";
    if (textArray[1].split(', ').length>2) { // If length of this array is 2 then the shotType is missing
        shotType = textArray[1].split(', ')[1]; // otherwise the shotType ist the 2nd Element
    }
    let blockingPlayer = 0;
    let blockedPlayer = 0;
    if (blockingTeam === ATeamIDdef) {
        blockingPlayer = await getPlayerId(blockingPlayerNumber,VisitorPlayersOnIce, ATeamIDdef);
        blockedPlayer = await getPlayerId(blockedPlayerNumber, HomePlayersOnIce, HTeamIDdef);
    }
    if (blockingTeam === HTeamIDdef) {
         blockingPlayer = await getPlayerId(blockingPlayerNumber,HomePlayersOnIce, HTeamIDdef);
         blockedPlayer = await getPlayerId(blockedPlayerNumber, VisitorPlayersOnIce, ATeamIDdef);
    }
    let blockObj = new storingObj('block', Client);
    blockObj.addData({'player_who_blocked_id': blockingPlayer, 'player_got_blocked_id': blockedPlayer, 'blocked_team_id': blockedTeam, 'blocking_team_id': blockingTeam, 'play_id': id, 'shot_type': shotType});
    await blockObj.store();
}

async function handlePenalty(id, penaltyText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) {
    // 'NSH #76 SUBBAN&#xA0;Delaying Game-Puck over glass(2 min), Def. Zone'
    // PIT #71 MALKIN&#xA0;Slashing(2 min), Neu. Zone Drawn By: NSH #76 SUBBAN
    // Ausnahme 1: Teampenalty:
    // TOR TEAM&#xA0;Too many men/ice - bench(2 min) Served By: #16 MARNER
    // Ausnahme 2: 10 Minuten für Torhüter
    // ANA #36 GIBSON Misconduct (10 min)(10 min) Served By: #40 BOLL
    let textArray = penaltyText.split("A0;");
    let penaltyTeam = textArray[0].substring(0,3).trim();
    let penaltyPlayerNumber = textArray[0].substring(5,7).trim();
    if (penaltyPlayerNumber == "&") return;  // rare case where no Player is given (Penalty that leads to Penalty Shoot)
    let penaltyPlayer = 0;
    let penaltyDuration = /\([0-9]+ /.exec(textArray[1])[0].substring(1);
    let penaltyString = "";
    let i = 0;
    while (!(textArray[1].substring(i, i + 1) === "(")) {
        penaltyString = penaltyString + textArray[1].substring(i, i + 1);
        i++
    }
    const penaltyObj = new storingObj('penalty', Client);
    if (! penaltyText.includes("TEAM")) { //Normal case (not Team Penalty)
        if (penaltyTeam === ATeamIDdef) {
            penaltyPlayer = await getPlayerId(penaltyPlayerNumber, VisitorPlayersOnIce, ATeamIDdef);
        }
        if (penaltyTeam === HTeamIDdef) {
            penaltyPlayer = await getPlayerId(penaltyPlayerNumber, HomePlayersOnIce, HTeamIDdef);
        }
        if (! penaltyText.includes("Served By")) { // Not Goalie
            let i = 0;
            let drawnText = penaltyText.split(": ");
            let drawnTeam = "";
            let drawnPlayerNumber = "";
            let drawnPlayer = "";
            if (!(drawnText[1] === undefined)) {
                drawnTeam = drawnText[1].substring(0, 3);
                drawnPlayerNumber = drawnText[1].substring(5, 7).trim();
                if (drawnTeam === ATeamIDdef) {
                    drawnPlayer = await getPlayerId(drawnPlayerNumber, VisitorPlayersOnIce, ATeamIDdef);
                }
                if (drawnTeam === HTeamIDdef) {
                    drawnPlayer = await getPlayerId(drawnPlayerNumber, HomePlayersOnIce, HTeamIDdef);
                }
                penaltyObj.addData({'drawn_team_id': drawnTeam, 'drawn_player_id': drawnPlayer});
            }
        }
    }
    if (penaltyText.includes("TEAM")) { penaltyPlayer = 0;} // Player with ID = 0 is the special "TEAMPLAYER"
    penaltyObj.addData({
        'length': penaltyDuration,
        player_id: penaltyPlayer, // either the Player or Teamplayer
        reason: penaltyString,
        team_id: penaltyTeam,
        play_id: id
    });
    await penaltyObj.store();
}

async function handleGoal(id, goalText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) {
    // 'NSH #32 GAUDREAU(1), Wrist, Off. Zone, 17 ft. Assists: #51 WATSON(3); #12 FISHER(2)'
    let textArray = goalText.split(", ");
    let goalTeam = textArray[0].substring(0,3);
    let goalScorerNumber = textArray[0].substring(5,7).trim();
    let goalPlayerId = 0;
    if (goalTeam === ATeamIDdef) {goalPlayerId = await getPlayerId(goalScorerNumber, VisitorPlayersOnIce, ATeamIDdef);}
    if (goalTeam === HTeamIDdef) {goalPlayerId = await getPlayerId(goalScorerNumber, HomePlayersOnIce, HTeamIDdef);}
    let shotType = "";
    let lastEl = textArray.length-1;
    if (textArray.length>2) shotType = textArray[1]; // in rare cases shotType and Zone are missing
    let shotDistance = '';
    let assistsTextArray = [];
    if (shotType ==='Penalty Shot') shotDistance=textArray[lastEl].substring(0,3).trim();
    if (shotType.includes("Zone")) {
        shotType = "";
        shotDistance = textArray[lastEl].substring(0, 3).trim();
        assistsTextArray = textArray[lastEl].split("#");
    }
    if (shotType != 'Penalty Shot' && shotType != '' ) {
        shotDistance=textArray[lastEl].substring(0,3).trim();
        assistsTextArray = textArray[lastEl].split("#");
    }
    if (shotDistance == "") shotDistance = "0";
    if (shotDistance.slice(-1)=="f") {shotDistance=shotDistance.substring(0,1)} //If Distance < 10 shotDistance is "8 f"

    const goalObj = new storingObj('goal', Client);
    goalObj.addData({'player_id': goalPlayerId, 'distance':shotDistance, 'team_id':goalTeam, 'shot_type':shotType, 'play_id':id});
    await goalObj.store();

    for (let i=1; i<assistsTextArray.length;i++) {
        let assistPlayerId = 0;
        let assistPlayerNumber = assistsTextArray[i].substring(0,2).trim();
        if (goalTeam === ATeamIDdef) {assistPlayerId = await getPlayerId(assistPlayerNumber, VisitorPlayersOnIce, ATeamIDdef);}
        if (goalTeam === HTeamIDdef) {assistPlayerId = await getPlayerId(assistPlayerNumber, HomePlayersOnIce, HTeamIDdef);}
        let assistObj = new storingObj('assist', Client);
        let assistType = "";
        if (i===1) assistType = "first";
        if (i===2) assistType = "second";
        assistObj.addData({'team_id': goalTeam, 'type': assistType, 'play_id': id, 'player_id': assistPlayerId});
        await assistObj.store();
    }
}

async function handleTakeaway(id, takeText, HomePlayersOnIce, VisitorPlayersOnIce, HTeamIDdef, ATeamIDdef) {
    // 'NSH TAKEAWAY - #59 JOSI, Neu. Zone'
    let textArray = takeText.split(' - ');
    let takingTeam = textArray[0].substring(0,3);
    let takingPlayerNumber = textArray[1].substring(1,3).trim();
    if (takingTeam === ATeamIDdef){ takingPlayerId = await getPlayerId(takingPlayerNumber,VisitorPlayersOnIce);}
    if (takingTeam === HTeamIDdef){ takingPlayerId = await getPlayerId(takingPlayerNumber,HomePlayersOnIce);}

    let takeawayObj = new storingObj('takeaway', Client);
    takeawayObj.addData({'player_id': takingPlayerId, 'team_id': takingTeam, 'play_id': id});
    await takeawayObj.store();
}

async function getPlayerName(number, playerArray, teamName) {
    let found = false;
    for (let i = 0; i < playerArray.length; i++) {
        if (playerArray[i][1] === number) {
            found = true;
            name = playerArray[i][0]; // Found it
            return name.replace("'", "");
        }
    }
    if (found === false) {
        let queryString = "SELECT name FROM player WHERE number = " + number + " AND actual_team_id ='" + teamName + "'";
        let playerName = await client.query(queryString);
        if (playerName.rows[0] === undefined) {return false}
        else {
            return playerName.rows[0].name;
        }   // In some rare cases the Player isn't on the ice anymore - so we have to look in the DB
    }
}

async function getPlayerId(number, playerArray, teamName) {
    let playerName = await getPlayerName(number, playerArray, teamName);
    let playerId = await getPlayerIdfromName(playerName);
    return playerId;
}

async function getPlayerIdfromName(name) {
    name = name.replace("'",""); // for example O'Gara has "'" I just delete it for now...
    let result = await client.query(`SELECT * FROM player WHERE name = '${name}' limit 1`);
    if (result) {
        return result.rows[0].id
    } else {
        console.log(`Didn't found {name} in the DB - getPlayerID`)
    }
}

async function updatePlayer(name, team, position, number, GameDate) {  // looks if Player is in DB and updates it if necessary
    name = name.replace("'",""); // for example O'Gara has "'" I just delete it for now...
    let result = await client.query(`SELECT * FROM player WHERE name = '${name}' limit 1`);
    if (result === null || result.rowCount === 0 ) {   //Player not yet in the DB
        const query1 = {
            text: 'INSERT INTO player(name, actual_team_id, position, number, date) VALUES ($name, $team, $pos, $num, $GDate)',
            values: {'name': name, 'team': team, 'pos': position, 'num': number, 'GDate': GameDate.toDateString()}
        };
        let res = await client.query(query1);

    } else {
        let TempDate = new Date(result.rows[0].date);
        if (result.rows[0].actual_team_id !== team) {
            const query2 = {
                text: 'UPDATE player SET actual_team_id = $team, date = $GDate WHERE id = $id',
                values: {'team': team, 'GDate': GameDate.toDateString(), 'id': result.rows[0].id}
            };
            let res = await client.query(query2)
        }
        if (result.rows[0].number != number) { //Number has changed
            const query3 = {
                text: 'UPDATE player SET number = $number, date = $GDate WHERE id = $id',
                values: {'number': number, 'GDate': GameDate.toDateString(), 'id': result.rows[0].id}
            };
            let res = await client.query(query3)
        }
    }
}

// 616: not found? 950 name.replace is not a function??
let gameNr = 1226;

while (gameNr < 1237) {
    gameNr++;
    let link = `http://www.nhl.com/scores/htmlreports/20172018/PL02${gameNr}.HTM`;
    await request(link, function (error, response, html) {
        if (!error && response.statusCode == 200) {
            $ = cheerio.load(html);
        }
    });
    //http://www.nhl.com/scores/htmlreports/20172018/PL020950.HTM
    await storeGameDetails();
    console.log("Game: " + gameNr + " ok!")
    await delay(1000);
}
//await removeGameFromDB('100000102')
await client.end();

})().catch(e => setImmediate(() => { throw e }));

