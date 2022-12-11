#!/bin/bash


# add user name db sache
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_RESULT=$($PSQL "SELECT COUNT(*),MIN(tries) FROM users FULL JOIN games USING(user_id) GROUP BY name HAVING name='$USERNAME';")
if [[ -z $USER_RESULT ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_ADD_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
else
  echo "$USER_RESULT" | while IFS="|" read COUNT MIN
  do
    echo "Welcome back, $USERNAME! You have played $COUNT games, and your best game took $MIN guesses."
  done
fi




NR=$((1 + $RANDOM % 1000))

GUESS () {
  TRIES=$2
  echo $1
  read NUMBER
  if [[ ! $NUMBER =~ ^[1-9][0-9]*$ ]]
  then
    GUESS "That is not an integer, guess again:" $(($TRIES +1))
  else
    if [[ $NUMBER == $NR ]]
    then
      declare -rg TRIES_TOT=$(($TRIES +1))
    elif [[ $NUMBER < $NR ]]
    then
      GUESS "It's higher than that, guess again:" $(($TRIES +1))
    else
      GUESS "It's lower than that, guess again:" $(($TRIES +1))
    fi
  fi
}


GUESS "Guess the secret number between 1 and 1000:" 0
echo "You guessed it in $TRIES_TOT tries. The secret number was $NR. Nice job!"

ADD_RESULT=$($PSQL "INSERT INTO games(tries, user_id) VALUES($TRIES_TOT, (SELECT user_id FROM users WHERE name='$USERNAME'));")

#while [ $GUESSED == FALSE ]
#do
#  GUESS "Guess the secret number between 1 and 1000:"
#  TRIES=$(($TRIES+1))
#  echo "You guessed it in <number_of_guesses> tries. The secret number was $NR. Nice job!"
#done




