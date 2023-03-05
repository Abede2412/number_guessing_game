#!/bin/bash
PSQL="psql -U freecodecamp -d postgres -t --no-align -c"
SECRET_NUMBER=$(( $RANDOM % 1000 ))

START_GAME(){

  #get player id
  GET_PLAYER_ID=$($PSQL "select player_id from players where username = '$USERNAME'")
  #if user_name exist
  if [[ -n $GET_PLAYER_ID ]]
  then
    BEST_GAME=$($PSQL "select min(games_played) from games where player_id = $GET_PLAYER_ID")
    GAMES_PLAYED=$($PSQL "select count(games_played) from games where player_id = $GET_PLAYER_ID")
    #print record_game
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guess.\n"
  #else
  else
  #print welcome
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
    INSERT_PLAYER=$($PSQL "insert into players(username) values('$USERNAME')")
    GET_PLAYER_ID=$($PSQL "select player_id from players where username = '$USERNAME'")
  fi
  #start game

  echo "Guess the secret number between 1 and 1000:"
  read GUESS_NUMBER
  COUNT=1
  while [[ $NUMBER != $GUESS_NUMBER ]]
  do
    if [[ $GUESS_NUMBER =~ ^[0-9]+$ ]]
    then
      if [[ $GUESS_NUMBER > $NUMBER ]]
      then 
        echo "It's higher than that, guess again:"
      else
        echo "It's lower than that, guess again:"
      fi
    else
      echo  "That is not an integer, guess again:"
    fi
    read GUESS_NUMBER
    (( COUNT++ ))
  done

  echo "You guessed it in $COUNT tries. The secret number was $NUMBER. Nice job!"
  INSERT_games_played=$($PSQL "insert into games(player_id, games_played) values($GET_PLAYER_ID, $COUNT)")
}

MAIN_MENU(){

  if [[ -n $1 ]]
  then 
    echo -e "\n$1\n"
  fi

  echo "Enter your username:"
  read USERNAME

  LEN_USERNAME=$(echo -n "$USERNAME" | wc -m)

  if [[ $LEN_USERNAME -gt 22 ]]
  then
    MAIN_MENU "username must be less than or equal to 22 character"
  else
    START_GAME
  fi
}

MAIN_MENU "~~~ NUMBER GUESSING GAME ~~~"