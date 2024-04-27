#!/usr/bin/env bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1") games"
echo "$($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1") teams"
echo "$($PSQL "TRUNCATE teams, games;") teams, games"
cat games.csv | while IFS="," read YEAR ROUND WIN OPP WIN_GOALS OPP_GOALS
do
  # check if line is a header
  if [[ $YEAR != year ]]; then
    # get team_id
    TEAM_ID_WIN=$($PSQL "SELECT team_id FROM teams WHERE name='$WIN';")
    TEAM_ID_OPP=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP';")

    # if team id win not found
    if [[ -z $TEAM_ID_WIN ]]; then

      # insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$WIN');")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]; then
	echo "Inserted into teams: $WIN"
      fi
      TEAM_ID_WIN=$($PSQL "SELECT team_id FROM teams WHERE name='$WIN';")
    fi

    # if team id opp not found
    if [[ -z $TEAM_ID_OPP ]]; then

      # insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$OPP');")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]; then
	echo "Inserted into teams: $OPP"
      fi
      TEAM_ID_OPP=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP';")
    fi

    # insert into games table
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $TEAM_ID_WIN, $TEAM_ID_OPP, $WIN_GOALS, $OPP_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]; then
      echo "Inserted into games $YEAR-$ROUND: $WIN vs $OPP"
    fi

  fi
done
